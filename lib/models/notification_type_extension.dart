import 'package:flutter/material.dart';
import 'package:life_auctor/models/notification_item.dart';

extension NotificationTypeExtension on NotificationType {
  // icons for this notification type
  IconData get icon {
    return switch (this) {
      NotificationType.expiring => Icons.schedule_outlined,
      NotificationType.expired => Icons.warning_amber_outlined,
      NotificationType.outOfStock => Icons.remove_shopping_cart_outlined,
      NotificationType.system => Icons.settings_outlined,
    };
  }

  // colors for this notification type
  Color get color {
    return switch (this) {
      NotificationType.expiring => Colors.orange,
      NotificationType.expired => Colors.red,
      NotificationType.outOfStock => Colors.blue,
      NotificationType.system => Colors.grey,
    };
  }
}
