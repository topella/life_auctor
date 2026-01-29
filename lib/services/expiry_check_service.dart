import 'package:life_auctor/models/item.dart';
import 'package:life_auctor/core/extensions/item_extensions.dart';
import 'package:life_auctor/providers/notification_provider.dart';

class ExpiryCheckService {
  final NotificationProvider _notificationProvider;

  ExpiryCheckService({
    required NotificationProvider notificationProvider,
  }) : _notificationProvider = notificationProvider;

  /// Check all items and create notifications for expiring/expired items
  Future<void> checkItems(List<Item> items) async {
    for (final item in items) {
      await _checkItem(item);
    }
  }

  /// Check a single item for expiry
  Future<void> _checkItem(Item item) async {
    // Skip consumed items
    if (item.isConsumed) return;

    // Check if expired - use item.id as unique notification ID
    if (item.isExpired) {
      final notificationId = 'expired_${item.id}';
      // Check if notification already exists
      if (!await _notificationProvider.hasNotification(notificationId)) {
        await _notificationProvider.createExpiredNotificationWithId(notificationId, item.name);
      }
      return;
    }

    // Check if expiring soon
    if (item.isExpiringSoon) {
      final notificationId = 'expiring_${item.id}';
      // Check if notification already exists
      if (!await _notificationProvider.hasNotification(notificationId)) {
        final daysLeft = _getDaysLeft(item);
        if (daysLeft >= 0) {
          await _notificationProvider.createExpiringNotificationWithId(notificationId, item.name, daysLeft);
        }
      }
    }
  }

  /// Get days left until expiry
  int _getDaysLeft(Item item) {
    if (item.expiryDate == null) return -1;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiryDay = DateTime(
      item.expiryDate!.year,
      item.expiryDate!.month,
      item.expiryDate!.day,
    );

    return expiryDay.difference(today).inDays;
  }

  /// Call this when user changes (logout/login) - no longer needed but kept for compatibility
  void onUserChanged() {
    // Notifications are now tracked by ID in the database, no need to clear
  }
}
