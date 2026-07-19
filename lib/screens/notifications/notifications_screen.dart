import 'package:flutter/material.dart';

import '../../config/app_theme.dart';

class NotificationItem {
  final String title;
  final String subtitle;
  final String timeAgo;
  final IconData icon;
  final Color iconColor;
  bool isRead;

  NotificationItem({
    required this.title,
    required this.subtitle,
    required this.timeAgo,
    required this.icon,
    required this.iconColor,
    this.isRead = false,
  });
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<NotificationItem> _notifications = [
    NotificationItem(
      title: 'New 5-star review received',
      subtitle: 'A customer left a glowing review on your profile',
      timeAgo: '2h ago',
      icon: Icons.star,
      iconColor: AppColors.orange,
    ),
    NotificationItem(
      title: 'Audit score improved to 45',
      subtitle: 'Your business profile optimization is getting better',
      timeAgo: '1d ago',
      icon: Icons.trending_up,
      iconColor: AppColors.success,
    ),
    NotificationItem(
      title: 'Post published on Instagram',
      subtitle: 'Your AI-generated post is now live',
      timeAgo: '2d ago',
      icon: Icons.check_circle,
      iconColor: AppColors.success,
      isRead: true,
    ),
    NotificationItem(
      title: 'New customer added',
      subtitle: 'A new customer was added to your CRM',
      timeAgo: '3d ago',
      icon: Icons.person_add,
      iconColor: AppColors.navy,
      isRead: true,
    ),
    NotificationItem(
      title: 'Weekly report ready',
      subtitle: 'Your weekly performance summary is available',
      timeAgo: '5d ago',
      icon: Icons.assessment,
      iconColor: AppColors.navy,
      isRead: true,
    ),
  ];

  void _markAsRead(int index) {
    setState(() {
      _notifications[index].isRead = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _notifications.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return _NotificationTile(
            notification: notification,
            onTap: () => _markAsRead(index),
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationItem notification;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: notification.isRead
          ? null
          : Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: notification.iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  notification.icon,
                  color: notification.iconColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontWeight: notification.isRead
                            ? FontWeight.w400
                            : FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    notification.timeAgo,
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  if (!notification.isRead) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
