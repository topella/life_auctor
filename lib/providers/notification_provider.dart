import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:life_auctor/models/notification_item.dart';
import 'package:life_auctor/services/firestore_service.dart';
import 'package:life_auctor/data/database_helper.dart';

class NotificationProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final FirebaseAuth _auth;
  final DatabaseHelper _db = DatabaseHelper();

  List<NotificationItem> _notifications = [];
  bool _isLoading = false;
  bool _isRegisteredUser = false;
  String _currentUserId = 'guest_local';

  NotificationProvider({
    required FirestoreService firestoreService,
    required FirebaseAuth auth,
  }) : _firestoreService = firestoreService,
       _auth = auth {
    _updateAuthStatus();
    _auth.authStateChanges().listen((_) => _updateAuthStatus());
  }

  List<NotificationItem> get notifications => _notifications;
  bool get isLoading => _isLoading;
  bool get isEmpty => _notifications.isEmpty;

  // Get unread count
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  // Update cached auth status
  void _updateAuthStatus() {
    final user = _auth.currentUser;
    _isRegisteredUser = user != null && !user.isAnonymous;
    _currentUserId = user?.uid ?? 'guest_local';
  }

  /// Set user ID for guest mode (called from AuthProvider)
  void setUserId(String userId) {
    _currentUserId = userId;
  }

  /// Load all notifications from SQLite
  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      final database = await _db.database;
      final List<Map<String, dynamic>> maps = await database.query(
        'notifications',
        where: 'userId = ?',
        whereArgs: [_currentUserId],
        orderBy: 'timestamp DESC',
      );

      _notifications = maps
          .map((map) => NotificationItem.fromJson(map))
          .toList();

      if (_isRegisteredUser) {
        try {
          final firebaseNotifications = await _firestoreService
              .getNotifications(_currentUserId);
          // Merge Firebase notifications into SQLite
          await _mergeFirebaseNotifications(firebaseNotifications);
        } catch (e) {
          debugPrint('Error syncing from Firebase: $e');
        }
      }
    } catch (e) {
      debugPrint('Error loading notifications: $e');
      _notifications = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Merge Firebase notifications into SQLite
  Future<void> _mergeFirebaseNotifications(
    List<NotificationItem> firebaseNotifications,
  ) async {
    try {
      final database = await _db.database;
      final existingIds = _notifications.map((n) => n.id).toSet();

      for (final notification in firebaseNotifications) {
        if (!existingIds.contains(notification.id)) {
          // Adding new notification from Firebase to SQLite
          await database.insert('notifications', {
            'id': notification.id,
            'userId': _currentUserId,
            'title': notification.title,
            'message': notification.message,
            'type': notification.type.name,
            'timestamp': notification.timestamp.millisecondsSinceEpoch,
            'isRead': notification.isRead ? 1 : 0,
          });
          _notifications.insert(0, notification);
        }
      }

      // Sort by timestamp
      _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      debugPrint('Error merging Firebase notifications: $e');
    }
  }

  // Add notification to SQLite and optionally Firebase
  Future<void> addNotification(NotificationItem notification) async {
    try {
      // Add to SQLite
      final database = await _db.database;
      await database.insert('notifications', {
        'id': notification.id,
        'userId': _currentUserId,
        'title': notification.title,
        'message': notification.message,
        'type': notification.type.name,
        'timestamp': notification.timestamp.millisecondsSinceEpoch,
        'isRead': notification.isRead ? 1 : 0,
      });

      // Add to local list
      _notifications.insert(0, notification);
      notifyListeners();

      // If registered user sync to Firebase
      if (_isRegisteredUser) {
        try {
          await _firestoreService.addNotification(_currentUserId, notification);
        } catch (e) {
          debugPrint('Error syncing to Firebase: $e');
        }
      }
    } catch (e) {
      debugPrint('Error adding notification: $e');
    }
  }

  // Mark notification as read in SQLite and optionally Firebase
  Future<void> markAsRead(String notificationId) async {
    try {
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        notifyListeners();

        // Update in SQLite
        final database = await _db.database;
        await database.update(
          'notifications',
          {'isRead': 1},
          where: 'id = ? AND userId = ?',
          whereArgs: [notificationId, _currentUserId],
        );

        if (_isRegisteredUser) {
          try {
            await _firestoreService.markAsRead(_currentUserId, notificationId);
          } catch (e) {
            debugPrint('Error syncing to Firebase: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final unreadNotifications = _notifications
          .where((n) => !n.isRead)
          .toList();
      // update in memory
      for (int i = 0; i < _notifications.length; i++) {
        if (!_notifications[i].isRead) {
          _notifications[i] = _notifications[i].copyWith(isRead: true);
        }
      }
      notifyListeners();

      // Update in SQLite
      final database = await _db.database;
      await database.update(
        'notifications',
        {'isRead': 1},
        where: 'userId = ? AND isRead = 0',
        whereArgs: [_currentUserId],
      );

      if (_isRegisteredUser) {
        for (final notification in unreadNotifications) {
          try {
            await _firestoreService.markAsRead(_currentUserId, notification.id);
          } catch (e) {
            debugPrint('Error syncing to Firebase: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('Error marking all as read: $e');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      // Remove from local list
      _notifications.removeWhere((n) => n.id == notificationId);
      notifyListeners();

      // Delete from SQLite
      final database = await _db.database;
      await database.delete(
        'notifications',
        where: 'id = ? AND userId = ?',
        whereArgs: [notificationId, _currentUserId],
      );
    } catch (e) {
      debugPrint('Error deleting notification: $e');
    }
  }

  // Check if notification with ID already exists
  Future<bool> hasNotification(String notificationId) async {
    if (_notifications.any((n) => n.id == notificationId)) {
      return true;
    }

    // check in database
    try {
      final database = await _db.database;
      final result = await database.query(
        'notifications',
        where: 'id = ? AND userId = ?',
        whereArgs: [notificationId, _currentUserId],
        limit: 1,
      );
      return result.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking notification: $e');
      return false;
    }
  }

  // Create expiring item notification with specific ID
  Future<void> createExpiringNotificationWithId(
    String id,
    String itemName,
    int daysLeft,
  ) async {
    final notification = NotificationItem(
      id: id,
      title: 'Item Expiring Soon',
      message: '$itemName expires in $daysLeft day${daysLeft > 1 ? 's' : ''}',
      type: NotificationType.expiring,
      timestamp: DateTime.now(),
    );
    await addNotification(notification);
  }

  //Create expired item notification with specific ID
  Future<void> createExpiredNotificationWithId(
    String id,
    String itemName,
  ) async {
    final notification = NotificationItem(
      id: id,
      title: 'Item Expired',
      message: '$itemName has expired',
      type: NotificationType.expired,
      timestamp: DateTime.now(),
    );
    await addNotification(notification);
  }
}
