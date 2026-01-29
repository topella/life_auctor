import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:life_auctor/data/database_helper.dart';
import 'package:life_auctor/models/history_event.dart';
import 'package:life_auctor/services/firestore_service.dart';

class HistoryProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final FirebaseAuth _auth;
  final DatabaseHelper _db = DatabaseHelper();

  List<HistoryEvent> _events = [];
  bool _isLoading = false;
  final List<HistoryEvent> _pendingEvents = [];
  Timer? _batchTimer;
  bool _isRegisteredUser = false;

  static const int _maxEvents = 100; // Limit to prevent memory issues
  static const Duration _batchInterval = Duration(seconds: 5);

  List<HistoryEvent> get events => _events;
  bool get isLoading => _isLoading;

  HistoryProvider({
    required FirestoreService firestoreService,
    required FirebaseAuth auth,
  }) : _firestoreService = firestoreService,
       _auth = auth {
    _updateAuthStatus();
    _auth.authStateChanges().listen((_) => _updateAuthStatus());
  }

  void _updateAuthStatus() {
    final user = _auth.currentUser;
    _isRegisteredUser = user != null && !user.isAnonymous;
  }

  @override
  void dispose() {
    _batchTimer?.cancel();
    super.dispose();
  }

  // Load all history events with limit
  Future<void> loadEvents() async {
    _isLoading = true;
    notifyListeners();
    try {
      if (_isRegisteredUser) {
        final userId = _auth.currentUser!.uid;
        final allEvents = await _firestoreService.getHistoryEvents(userId);
        _events = allEvents.take(_maxEvents).toList();
      } else {
        // Load from local SQLite for guests
        _events = await _loadLocalEvents();
      }
    } catch (e) {
      debugPrint('Error loading history events: $e');
      _events = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  // load events from local SQLite database
  Future<List<HistoryEvent>> _loadLocalEvents() async {
    try {
      final db = await _db.database;
      final maps = await db.query(
        'history_events',
        orderBy: 'timestamp DESC',
        limit: _maxEvents,
      );
      return maps.map((map) => HistoryEvent.fromJson(map)).toList();
    } catch (e) {
      debugPrint('Error loading local history: $e');
      return [];
    }
  }

  // Save event to SQLite
  Future<void> _saveLocalEvent(HistoryEvent event) async {
    try {
      final db = await _db.database;
      await db.insert(
        'history_events',
        event.toJson(),
      );
    } catch (e) {
      debugPrint('Error saving local history event: $e');
    }
  }

  // Add history event with batching (10 events or 5 sec interval)
  Future<void> addEvent(HistoryEvent event) async {
    try {
      // Add to local
      _events.insert(0, event);
      // Trim to max limit
      if (_events.length > _maxEvents) {
        _events = _events.take(_maxEvents).toList();
      }
      notifyListeners();

      // If registered user, batch events to Firestore
      if (_isRegisteredUser) {
        _pendingEvents.add(event);
        // send if batch reaches 10 events
        if (_pendingEvents.length >= 10) {
          await _flushBatch();
        } else {
          _batchTimer?.cancel();
          _batchTimer = Timer(_batchInterval, _flushBatch);
        }
      } else {
        // For guests, save toSQLite
        await _saveLocalEvent(event);
      }
    } catch (e) {
      debugPrint('Error adding history event: $e');
    }
  }

  Future<void> _flushBatch() async {
    if (_pendingEvents.isEmpty || !_isRegisteredUser) return;

    _batchTimer?.cancel();
    final userId = _auth.currentUser!.uid;
    final eventsToSend = List<HistoryEvent>.from(_pendingEvents);
    _pendingEvents.clear();

    try {
      for (final event in eventsToSend) {
        await _firestoreService.addHistoryEvent(userId, event);
      }
      debugPrint('✓ Flushed ${eventsToSend.length} history events');
    } catch (e) {
      debugPrint('✗ Error flushing batch: $e');
      // Re add failed events to retry later
      _pendingEvents.addAll(eventsToSend);
    }
  }

  // Add item added event
  Future<void> addItemAddedEvent(String itemName, String itemId) async {
    final event = HistoryEvent.create(
      type: HistoryEventType.addedItem,
      title: 'Added Item',
      subtitle: itemName,
      timestamp: DateTime.now(),
      itemId: itemId,
    );
    await addEvent(event);
  }

  // Adding barcode scanned event
  Future<void> addBarcodeScanEvent(String barcode, String? itemName) async {
    final event = HistoryEvent.create(
      type: HistoryEventType.scannedBarcode,
      title: 'Scanned Barcode',
      subtitle: itemName ?? 'Barcode: $barcode',
      timestamp: DateTime.now(),
    );
    await addEvent(event);
  }

  // Add list created event
  Future<void> addListCreatedEvent(String listName, String listId) async {
    final event = HistoryEvent.create(
      type: HistoryEventType.createdList,
      title: 'Created List',
      subtitle: listName,
      timestamp: DateTime.now(),
      listId: listId,
    );
    await addEvent(event);
  }

  // Add item expired
  Future<void> addItemExpiredEvent(String itemName, String itemId) async {
    final event = HistoryEvent.create(
      type: HistoryEventType.itemExpired,
      title: 'Item Expired',
      subtitle: itemName,
      timestamp: DateTime.now(),
      itemId: itemId,
    );
    await addEvent(event);
  }
}
