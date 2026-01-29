import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:synchronized/synchronized.dart';
import 'package:life_auctor/services/connectivity_service.dart';

enum SyncOpType {
  create,
  update,
  delete;

  String toJson() => name;
  static SyncOpType fromJson(String value) => SyncOpType.values.byName(value);
}

class SyncOperation {
  final String id;
  final SyncOpType type;
  final String collection;
  final String documentId;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final int version;

  SyncOperation({
    required this.id,
    required this.type,
    required this.collection,
    required this.documentId,
    required this.data,
    required this.timestamp,
    this.version = 1,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.toJson(),
    'collection': collection,
    'documentId': documentId,
    'data': data,
    'timestamp': timestamp.toIso8601String(),
    'version': version,
  };

  factory SyncOperation.fromJson(Map<String, dynamic> json) {
    return SyncOperation(
      id: json['id'] as String,
      type: SyncOpType.fromJson(json['type'] as String),
      collection: json['collection'] as String,
      documentId: json['documentId'] as String,
      data: Map<String, dynamic>.from(json['data'] as Map),
      timestamp: DateTime.parse(json['timestamp'] as String),
      version: json['version'] as int? ?? 1,
    );
  }
}

class SyncQueueService extends ChangeNotifier {
  static const String _queueKey = 'sync_queue';
  final List<SyncOperation> _queue = [];
  final ConnectivityService _connectivityService;
  final _syncLock = Lock();
  bool _isSyncing = false;

  List<SyncOperation> get queue => List.unmodifiable(_queue);
  int get pendingOperations => _queue.length;
  bool get isSyncing => _isSyncing;
  bool get hasPendingOperations => _queue.isNotEmpty;

  SyncQueueService(this._connectivityService) {
    _loadQueue();
    _connectivityService.addListener(_onConnectivityChanged);
  }

  @override
  void dispose() {
    _connectivityService.removeListener(_onConnectivityChanged);
    super.dispose();
  }

  // Load queue from constant storage
  Future<void> _loadQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = prefs.getString(_queueKey);
      if (queueJson != null) {
        final List<dynamic> queueList = jsonDecode(queueJson) as List;
        _queue.clear();
        _queue.addAll(
          queueList.map(
            (json) => SyncOperation.fromJson(json as Map<String, dynamic>),
          ),
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading sync queue: $e');
    }
  }

  // Save queue to constant storage
  Future<void> _saveQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = jsonEncode(_queue.map((op) => op.toJson()).toList());
      await prefs.setString(_queueKey, queueJson);
    } catch (e) {
      debugPrint('Error saving sync queue: $e');
    }
  }

  // Add operation to queue
  Future<void> addOperation(SyncOperation operation) async {
    _queue.add(operation);
    await _saveQueue();
    notifyListeners();

    // Try to sync if online
    if (_connectivityService.isOnline) {
      unawaited(_syncQueue());
    }
  }

  // Remove operation from queue
  Future<void> _removeOperation(String operationId) async {
    _queue.removeWhere((op) => op.id == operationId);
    await _saveQueue();
    notifyListeners();
  }

  // when connectivity changes
  void _onConnectivityChanged() {
    if (_connectivityService.isOnline && _queue.isNotEmpty) {
      debugPrint('Back online, syncing ${_queue.length} pending operations');
      unawaited(_syncQueue());
    }
  }

  // Sync all pending operations
  Future<void> _syncQueue() async {
    return await _syncLock.synchronized(() async {
      if (_queue.isEmpty) return;

      _isSyncing = true;
      notifyListeners();

      final operations = List<SyncOperation>.from(_queue);

      for (final operation in operations) {
        if (!_connectivityService.isOnline) {
          debugPrint('Lost connection during sync, stopping');
          break;
        }

        try {
          await _executeSyncOperation(operation);
          await _removeOperation(operation.id);
        } catch (e) {
          debugPrint('Error syncing operation ${operation.id}: $e');
          break;
        }
      }

      _isSyncing = false;
      notifyListeners();
    });
  }

  // Execute a single sync operation to Firestore
  Future<void> _executeSyncOperation(SyncOperation operation) async {
    final firestore = FirebaseFirestore.instance;
    final docRef = firestore.doc(
      '${operation.collection}/${operation.documentId}',
    );

    switch (operation.type) {
      case SyncOpType.create:
        await docRef.set(operation.data, SetOptions(merge: true));
        debugPrint(
          'Synced CREATE: ${operation.collection}/${operation.documentId}',
        );

      case SyncOpType.update:
        await _executeUpdateOperation(docRef, operation);

      case SyncOpType.delete:
        await docRef.delete();
        debugPrint(
          'Synced DELETE: ${operation.collection}/${operation.documentId}',
        );
    }
  }

  // Execute update operation with version check
  Future<void> _executeUpdateOperation(
    DocumentReference docRef,
    SyncOperation operation,
  ) async {
    final doc = await docRef.get();

    if (doc.exists) {
      final serverVersion =
          (doc.data() as Map<String, dynamic>?)?['version'] as int? ?? 0;

      // Skip if server has newer version
      if (operation.version <= serverVersion) {
        debugPrint(
          'Skipped UPDATE: ${operation.collection}/${operation.documentId} (outdated version)',
        );
        return;
      }
    }

    await docRef.update({
      ...operation.data,
      'version': operation.version + 1,
    });
    debugPrint(
      'Synced UPDATE: ${operation.collection}/${operation.documentId}',
    );
  }

  Future<void> manualSync() async {
    if (_connectivityService.isOffline) {
      throw Exception('Cannot sync while offline');
    }
    await _syncQueue();
  }

  Future<void> clearQueue() async {
    _queue.clear();
    await _saveQueue();
    notifyListeners();
  }
}
