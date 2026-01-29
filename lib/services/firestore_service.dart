import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:life_auctor/models/item.dart';
import 'package:life_auctor/models/shopping_list.dart';
import 'package:life_auctor/models/history_event.dart';
import 'package:life_auctor/models/notification_item.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ==================== GENERIC CRUD (60 lines) ====================

  Future<void> add(String path, Map<String, dynamic> data) async {
    try {
      await _db.doc(path).set(data);
      debugPrint('✓ Added $path');
    } catch (e) {
      debugPrint('✗ Add failed $path: $e');
      rethrow;
    }
  }

  Future<void> update(String path, Map<String, dynamic> data) async {
    try {
      await _db.doc(path).update(data);
      debugPrint('✓ Updated $path');
    } catch (e) {
      debugPrint('✗ Update failed $path: $e');
      rethrow;
    }
  }

  Future<void> delete(String path) async {
    try {
      await _db.doc(path).delete();
      debugPrint('✓ Deleted $path');
    } catch (e) {
      debugPrint('✗ Delete failed $path: $e');
      rethrow;
    }
  }

  Future<List<T>> getAll<T>(
    String path,
    T Function(DocumentSnapshot) fromDoc, {
    String? orderBy,
    bool desc = false,
  }) async {
    try {
      Query q = _db.collection(path);
      if (orderBy != null) q = q.orderBy(orderBy, descending: desc);

      final snap = await q.get();
      final result = snap.docs.map(fromDoc).toList();
      debugPrint('✓ Got ${result.length} from $path');
      return result;
    } catch (e) {
      debugPrint('✗ Get failed $path: $e');
      rethrow;
    }
  }

  Stream<List<T>> watch<T>(
    String path,
    T Function(DocumentSnapshot) fromDoc, {
    String? orderBy,
    bool desc = false,
  }) {
    Query q = _db.collection(path);
    if (orderBy != null) q = q.orderBy(orderBy, descending: desc);

    return q.snapshots().map((snap) {
      debugPrint('📡 Stream update: ${snap.docs.length} docs from $path');
      return snap.docs.map(fromDoc).toList();
    });
  }

  Future<void> batch(List<BatchOp> ops) async {
    if (ops.isEmpty) return;

    try {
      final b = _db.batch();
      for (final op in ops) {
        final ref = _db.doc(op.path);
        switch (op.type) {
          case OpType.set:
            b.set(ref, op.data);
          case OpType.update:
            b.update(ref, op.data);
          case OpType.delete:
            b.delete(ref);
        }
      }
      await b.commit();
      debugPrint('✓ Batch: ${ops.length} operations committed');
    } catch (e) {
      debugPrint('✗ Batch failed: $e');
      rethrow;
    }
  }

  // ==================== ITEMS (8 lines) ====================

  Future<void> addItem(String uid, Item item) =>
      add('users/$uid/items/${item.id}', item.toFirestore());

  Future<void> updateItem(String uid, Item item) =>
      update('users/$uid/items/${item.id}', item.toFirestore());

  Future<void> deleteItem(String uid, String id) =>
      delete('users/$uid/items/$id');

  Future<List<Item>> getItems(String uid) =>
      getAll('users/$uid/items', Item.fromFirestore);

  Stream<List<Item>> watchItems(String uid) =>
      watch('users/$uid/items', Item.fromFirestore);

  // ==================== SHOPPING LISTS (8 lines) ====================

  Future<void> addList(String uid, ShoppingList list) =>
      add('users/$uid/shopping_lists/${list.id}', list.toFirestore());

  Future<void> updateList(String uid, ShoppingList list) =>
      update('users/$uid/shopping_lists/${list.id}', list.toFirestore());

  Future<void> deleteList(String uid, String id) =>
      delete('users/$uid/shopping_lists/$id');

  Future<List<ShoppingList>> getLists(String uid) =>
      getAll('users/$uid/shopping_lists', ShoppingList.fromFirestore);

  Stream<List<ShoppingList>> watchLists(String uid) =>
      watch('users/$uid/shopping_lists', ShoppingList.fromFirestore);

  // ==================== HISTORY (6 lines) ====================

  Future<void> addHistoryEvent(String uid, HistoryEvent event) =>
      add('users/$uid/history/${event.id}', event.toJson());

  Future<List<HistoryEvent>> getHistoryEvents(String uid) =>
      getAll('users/$uid/history', HistoryEvent.fromFirestore, orderBy: 'timestamp', desc: true);

  Stream<List<HistoryEvent>> watchHistory(String uid) =>
      watch('users/$uid/history', HistoryEvent.fromFirestore, orderBy: 'timestamp', desc: true);

  // ==================== NOTIFICATIONS (7 lines) ====================

  Future<void> addNotification(String uid, NotificationItem notif) =>
      add('users/$uid/notifications/${notif.id}', notif.toJson());

  Future<List<NotificationItem>> getNotifications(String uid) =>
      getAll('users/$uid/notifications', NotificationItem.fromFirestore, orderBy: 'timestamp', desc: true);

  Future<void> markAsRead(String uid, String id) =>
      update('users/$uid/notifications/$id', {'isRead': true});

  Stream<List<NotificationItem>> watchNotifications(String uid) =>
      watch('users/$uid/notifications', NotificationItem.fromFirestore, orderBy: 'timestamp', desc: true);
}

// ==================== BATCH HELPERS (10 lines) ====================

class BatchOp {
  final OpType type;
  final String path;
  final Map<String, dynamic> data;

  const BatchOp(this.type, this.path, [this.data = const {}]);

  // Convenience constructors
  BatchOp.set(String path, Map<String, dynamic> data) : this(OpType.set, path, data);
  BatchOp.update(String path, Map<String, dynamic> data) : this(OpType.update, path, data);
  BatchOp.delete(String path) : this(OpType.delete, path);
}

enum OpType { set, update, delete }
