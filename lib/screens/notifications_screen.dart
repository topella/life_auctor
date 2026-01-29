import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:life_auctor/widgets/nav_bar.dart/app_bar.dart';
import 'package:life_auctor/models/notification_item.dart';
import 'package:life_auctor/models/notification_type_extension.dart';
import 'package:life_auctor/providers/notification_provider.dart';
import 'package:life_auctor/utils/notification_filter.dart';
import 'package:life_auctor/utils/notification_sizes.dart';
import 'package:life_auctor/utils/app_constants.dart';
import 'package:life_auctor/utils/theme_extensions.dart';
import 'package:life_auctor/utils/time_ago_formatter.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  NotificationFilter _selectedFilter = NotificationFilter.all;

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final allNotifications = notificationProvider.notifications;
    final filteredNotifications = _selectedFilter.apply(allNotifications);
    final unreadCount = notificationProvider.unreadCount;

    return Scaffold(
      backgroundColor: context.isDark ? AppConstants.darkBackground : Colors.grey[100],
      appBar: const CustomAppBar(showBackButton: false),
      body: SafeArea(
        child: notificationProvider.isLoading
            ? Center(child: CircularProgressIndicator(color: AppConstants.primaryGreen))
            : LayoutBuilder(
                builder: (context, constraints) {
                  final sizes = NotificationSizes(constraints.maxWidth);

                  return Column(
                    children: [
                      // Header
                      Padding(
                        padding: EdgeInsets.all(sizes.padding),
                        child: Row(
                          children: [
                            Text(
                              'Notifications',
                              style: TextStyle(
                                fontSize: sizes.titleSize,
                                fontWeight: FontWeight.bold,
                                color: context.adaptiveTextColor,
                              ),
                            ),
                            const Spacer(),
                            if (unreadCount > 0)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: sizes.badgeSize * 0.6,
                                  vertical: sizes.badgeSize * 0.3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(sizes.badgeSize * 0.5),
                                ),
                                child: Text(
                                  '$unreadCount',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: sizes.badgeSize * 0.57,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Filters
                      Container(
                        height: sizes.padding * 2.5,
                        margin: EdgeInsets.only(bottom: sizes.padding),
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(horizontal: sizes.padding),
                          children: NotificationFilter.values.map((filter) {
                            final isSelected = filter == _selectedFilter;
                            return Padding(
                              padding: EdgeInsets.only(right: sizes.filterSpacing),
                              child: FilterChip(
                                label: Text(
                                  filter.displayName,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : context.adaptiveTextColor,
                                    fontSize: sizes.filterFontSize,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                ),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() => _selectedFilter = filter);
                                },
                                backgroundColor: context.adaptiveBackgroundColor,
                                selectedColor: AppConstants.primaryGreen,
                                checkmarkColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: sizes.padding * 0.75,
                                  vertical: sizes.padding * 0.5,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      // Mark all as read button
                      if (unreadCount > 0)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: sizes.padding, vertical: sizes.padding * 0.5),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                await notificationProvider.markAllAsRead();
                              },
                              icon: Icon(Icons.done_all, color: AppConstants.primaryGreen, size: sizes.filterFontSize * 1.3),
                              label: Text(
                                'Mark all as read',
                                style: TextStyle(
                                  fontSize: sizes.filterFontSize,
                                  color: AppConstants.primaryGreen,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: AppConstants.primaryGreen, width: 2),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(sizes.padding * 0.5)),
                                padding: EdgeInsets.symmetric(vertical: sizes.padding * 0.75),
                              ),
                            ),
                          ),
                        ),

                      // Notifications List
                      Expanded(
                        child: filteredNotifications.isEmpty
                            ? _buildEmptyState(sizes)
                            : ListView.builder(
                                padding: EdgeInsets.symmetric(horizontal: sizes.padding),
                                itemCount: filteredNotifications.length,
                                itemBuilder: (context, index) {
                                  final notification = filteredNotifications[index];
                                  return _buildNotificationCard(
                                    notification,
                                    sizes,
                                    notificationProvider,
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }

  Widget _buildEmptyState(NotificationSizes sizes) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_outlined,
            size: sizes.emptyIconSize,
            color: context.adaptiveSecondaryTextColor,
          ),
          SizedBox(height: sizes.padding),
          Text(
            'No notifications',
            style: TextStyle(
              fontSize: sizes.emptyTextSize,
              fontWeight: FontWeight.w600,
              color: context.adaptiveSecondaryTextColor,
            ),
          ),
          SizedBox(height: sizes.padding * 0.5),
          Text(
            'You\'re all caught up!',
            style: TextStyle(
              fontSize: sizes.emptyTextSize * 0.8,
              color: context.adaptiveSecondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    NotificationItem notification,
    NotificationSizes sizes,
    NotificationProvider provider,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: sizes.cardSpacing),
      decoration: BoxDecoration(
        color: notification.isRead
            ? context.adaptiveBackgroundColor
            : (context.isDark ? const Color(0xFF1E3A1E) : const Color(0xFFE8F5E9)),
        borderRadius: BorderRadius.circular(sizes.cardSpacing),
        border: Border.all(
          color: notification.isRead
              ? context.adaptiveBorderColor
              : AppConstants.primaryGreen.withValues(alpha: 0.3),
          width: notification.isRead ? 1 : 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(sizes.cardSpacing),
          onTap: () async {
            if (!notification.isRead) {
              await provider.markAsRead(notification.id);
            }
          },
          child: Padding(
            padding: EdgeInsets.all(sizes.cardPadding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNotificationIcon(notification.type, sizes),
                SizedBox(width: sizes.cardPadding),
                Expanded(
                  child: _buildNotificationContent(notification, sizes),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(NotificationType type, NotificationSizes sizes) {
    final iconColor = type.color;
    return Container(
      width: sizes.iconSize,
      height: sizes.iconSize,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        type.icon,
        color: iconColor,
        size: sizes.iconSize * 0.5,
      ),
    );
  }

  Widget _buildNotificationContent(NotificationItem notification, NotificationSizes sizes) {
    final timeAgo = TimeAgoFormatter.format(notification.timestamp);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                notification.title,
                style: TextStyle(
                  fontSize: sizes.messageSize,
                  fontWeight: FontWeight.bold,
                  color: context.adaptiveTextColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (!notification.isRead)
              Container(
                width: sizes.cardPadding * 0.5,
                height: sizes.cardPadding * 0.5,
                margin: EdgeInsets.only(left: sizes.cardPadding * 0.5),
                decoration: BoxDecoration(
                  color: AppConstants.primaryGreen,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        SizedBox(height: sizes.cardPadding * 0.25),
        Text(
          notification.message,
          style: TextStyle(
            fontSize: sizes.messageSize,
            color: context.adaptiveSecondaryTextColor,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: sizes.cardPadding * 0.4),
        Text(
          timeAgo,
          style: TextStyle(
            fontSize: sizes.timeSize,
            color: context.adaptiveSecondaryTextColor,
          ),
        ),
      ],
    );
  }
}
