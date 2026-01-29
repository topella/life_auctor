import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:life_auctor/data/database_helper.dart';
import 'package:life_auctor/services/firestore_service.dart';
import 'package:life_auctor/services/connectivity_service.dart';
import 'package:life_auctor/services/sync_queue_service.dart';
import 'package:life_auctor/core/errors/app_error.dart';
import 'package:life_auctor/core/result.dart';

// Helper to convert string operation
SyncOpType _parseOpType(String op) => switch (op) {
  'create' => SyncOpType.create,
  'update' => SyncOpType.update,
  'delete' => SyncOpType.delete,
  _ => throw ArgumentError('Invalid operation type: $op'),
};

abstract class BaseRepository<T> {
  final DatabaseHelper _db;
  @protected
  final FirestoreService fire;
  final FirebaseAuth _auth;
  final SyncQueueService _sync;
  final ConnectivityService _conn;

  // Cached auth state
  bool _isRegisteredCache = false;
  String? _uidCache;

  BaseRepository(this._db, this.fire, this._auth, this._sync, this._conn) {
    _updateAuthCache();
    _auth.authStateChanges().listen((_) => _updateAuthCache());
  }

  void _updateAuthCache() {
    final user = _auth.currentUser;
    _isRegisteredCache = user != null && !user.isAnonymous;
    _uidCache = user?.uid ?? 'guest_local';
  }

  // if current user is registered (cached)
  bool get isRegistered => _isRegisteredCache;

  String get uid => _uidCache ?? 'guest_local';

  String get tableName;

  // Firestore collection path for current user
  String get collectionPath => 'users/$uid/$tableName';

  Map<String, dynamic> toJson(T entity);
  T fromJson(Map<String, dynamic> json); // Convert JSON map to entity

  String getId(T entity); //entity ID

  // Load entities from Firestore
  Future<List<T>> loadFromFirestore();

  // Add entity to Firestore
  Future<void> addToFirestore(T entity);

  // Update entity in Firestore (implemented by subclass)
  Future<void> updateInFirestore(T entity);

  // Delete entity from Firestore
  Future<void> deleteFromFirestore(String id);

  // db operation wrapper with error handling
  Future<Result<R>> dbOp<R>(Future<R> Function(Database) action) async {
    try {
      final db = await _db.database;
      final result = await action(db);
      return Success(result);
    } catch (e) {
      return Failure(DatabaseError(message: '$e', originalError: e));
    }
  }

  // sync wrapper with offline queueing
  Future<void> syncToCloud(
    String op,
    String id,
    Map<String, dynamic> data,
    Future<void> Function() action,
  ) async {
    if (!isRegistered) return;

    if (_conn.isOnline) {
      try {
        await action();
      } catch (e) {
        await _queueOp(op, id, data);
      }
    } else {
      await _queueOp(op, id, data);
    }
  }

  // queue operation for later sync
  Future<void> _queueOp(String op, String id, Map<String, dynamic> data) async {
    await _sync.addOperation(
      SyncOperation(
        id: '${DateTime.now().millisecondsSinceEpoch}_$id',
        type: _parseOpType(op),
        collection: collectionPath,
        documentId: id,
        data: data,
        timestamp: DateTime.now(),
      ),
    );
  }

  // Load all entities from local DB
  Future<Result<List<T>>> load() async {
    return dbOp((db) async {
      final maps = await db.query(tableName, orderBy: 'createdAt DESC');
      return maps.map((m) => fromJson(m)).toList();
    });
  }

  // Sync entities from Firestore to local DB
  Future<Result<void>> syncFromCloud() async {
    if (!isRegistered) return const Success(null);

    try {
      final entities = await loadFromFirestore();
      if (entities.isEmpty) return const Success(null);

      final db = await _db.database;
      final batch = db.batch();
      for (final entity in entities) {
        batch.insert(
          tableName,
          toJson(entity),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
      return const Success(null);
    } catch (e) {
      return Failure(SyncError(message: '$e', originalError: e));
    }
  }

  // Add entity to DB and sync to cloud
  Future<Result<void>> add(T entity) async {
    final result = await dbOp<void>(
      (db) => db.insert(tableName, toJson(entity)),
    );
    if (result is Failure) return result;

    await syncToCloud(
      'create',
      getId(entity),
      toJson(entity),
      () => addToFirestore(entity),
    );
    return const Success(null);
  }

  // Update entity in DB and sync to cloud
  Future<Result<void>> update(T entity) async {
    final result = await dbOp<void>(
      (db) => db.update(
        tableName,
        toJson(entity),
        where: 'id = ?',
        whereArgs: [getId(entity)],
      ),
    );
    if (result is Failure) return result;

    await syncToCloud(
      'update',
      getId(entity),
      toJson(entity),
      () => updateInFirestore(entity),
    );
    return const Success(null);
  }

  // Delete entity from DB and sync to cloud
  Future<Result<void>> delete(String id) async {
    final result = await dbOp<void>(
      (db) => db.delete(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      ),
    );
    if (result is Failure) return result;

    await syncToCloud(
      'delete',
      id,
      {},
      () => deleteFromFirestore(id),
    );
    return const Success(null);
  }

  // Batch update
  Future<Result<void>> batchUpdate(List<T> entities) async {
    final result = await dbOp<void>((db) async {
      final batch = db.batch();
      for (final entity in entities) {
        batch.update(
          tableName,
          toJson(entity),
          where: 'id = ?',
          whereArgs: [getId(entity)],
        );
      }
      await batch.commit(noResult: true);
    });

    if (result is Failure) return result;

    if (isRegistered && _conn.isOnline) {
      await Future.wait(
        entities.map(
          (entity) => syncToCloud(
            'update',
            getId(entity),
            toJson(entity),
            () => updateInFirestore(entity),
          ),
        ),
      );
    }

    return const Success(null);
  }

  // Batch delete entities
  Future<Result<void>> batchDelete(List<String> ids) async {
    final result = await dbOp<void>((db) async {
      final batch = db.batch();
      for (final id in ids) {
        batch.delete(tableName, where: 'id = ?', whereArgs: [id]);
      }
      await batch.commit(noResult: true);
    });

    if (result is Failure) return result;

    if (isRegistered && _conn.isOnline) {
      await Future.wait(
        ids.map(
          (id) => syncToCloud('delete', id, {}, () => deleteFromFirestore(id)),
        ),
      );
    }

    return const Success(null);
  }
}
