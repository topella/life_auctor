import 'package:life_auctor/models/notification_item.dart';

enum NotificationFilter {
  all('All'),
  unread('Unread'),
  expiring('Expiring'),
  system('System');

  const NotificationFilter(this.displayName);
  final String displayName;

  List<NotificationItem> apply(List<NotificationItem> notifications) {
    return switch (this) {
      NotificationFilter.all => notifications,
      NotificationFilter.unread =>
        notifications.where((n) => !n.isRead).toList(),
      NotificationFilter.expiring =>
        notifications
            .where(
              (n) =>
                  n.type == NotificationType.expiring ||
                  n.type == NotificationType.expired,
            )
            .toList(),
      NotificationFilter.system =>
        notifications.where((n) => n.type == NotificationType.system).toList(),
    };
  }

  static NotificationFilter fromDisplayName(String name) {
    return NotificationFilter.values.firstWhere(
      (filter) => filter.displayName == name,
      orElse: () => NotificationFilter.all,
    );
  }
}
