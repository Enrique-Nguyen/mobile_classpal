import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_classpal/core/constants/app_colors.dart';
import 'package:mobile_classpal/core/models/notification.dart' as notif_model;
import 'package:mobile_classpal/core/providers/notification_provider.dart';

class DashboardNotifications extends ConsumerWidget {
  final String classId;
  final String uid;

  const DashboardNotifications({
    super.key,
    required this.classId,
    required this.uid,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(
      NotificationProvider.latestNotificationsProvider(
        (classId: classId, uid: uid),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'THÔNG BÁO',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          notificationsAsync.when(
            data: (notifications) {
              if (notifications.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.notifications_none_rounded,
                          size: 32,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Chưa có thông báo',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: notifications.asMap().entries.map((entry) {
                  final index = entry.key;
                  final notification = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(bottom: index < notifications.length - 1 ? 12 : 0),
                    child: _buildNotificationCard(notification),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (_, __) => Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'Không thể tải thông báo',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(notif_model.Notification notification) {
    final config = _getNotificationConfig(notification.type);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: config.borderColor, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: config.backgroundColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              notification.type.displayName,
              style: TextStyle(
                color: config.borderColor,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E1E2D),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  notification.subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(config.icon, color: config.borderColor, size: 22),
        ],
      ),
    );
  }

  _NotificationDisplayConfig _getNotificationConfig(notif_model.NotificationType type) {
    switch (type) {
      case notif_model.NotificationType.duty:
        return _NotificationDisplayConfig(
          backgroundColor: const Color(0xFFFFF3E0),
          borderColor: AppColors.warningOrange,
          icon: Icons.assignment_outlined,
        );
      case notif_model.NotificationType.event:
        return _NotificationDisplayConfig(
          backgroundColor: const Color(0xFFE3F2FD),
          borderColor: AppColors.primaryBlue,
          icon: Icons.event_outlined,
        );
      case notif_model.NotificationType.fund:
        return _NotificationDisplayConfig(
          backgroundColor: const Color(0xFFE8F5E9),
          borderColor: AppColors.successGreen,
          icon: Icons.account_balance_wallet_outlined,
        );
    }
  }
}

class _NotificationDisplayConfig {
  final Color backgroundColor;
  final Color borderColor;
  final IconData icon;

  _NotificationDisplayConfig({
    required this.backgroundColor,
    required this.borderColor,
    required this.icon,
  });
}
