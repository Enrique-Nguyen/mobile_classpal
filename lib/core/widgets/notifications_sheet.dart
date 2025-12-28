import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_classpal/features/class_view/overview/services/notification_service.dart';
import '../constants/app_colors.dart';
import '../models/notification.dart' as notif_model;
import '../providers/notification_provider.dart';

/// Show notifications as an expandable bottom sheet
void showNotificationsSheet(
  BuildContext context, {
  required String classId,
  required String uid,
}) {
  // Mark all notifications as seen when opening the sheet
  NotificationService.markAllAsSeen(classId, uid);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _NotificationsSheet(classId: classId, uid: uid),
  );
}

class _NotificationsSheet extends ConsumerWidget {
  final String classId;
  final String uid;

  const _NotificationsSheet({
    required this.classId,
    required this.uid,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(
      NotificationProvider.notificationsStreamProvider(
        (classId: classId, uid: uid),
      ),
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    const Text(
                      'Thông báo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    notificationsAsync.when(
                      data: (notifications) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: notifications.isEmpty
                              ? AppColors.textSecondary
                              : AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${notifications.length}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Notifications list
              Expanded(
                child: notificationsAsync.when(
                  data: (notifications) {
                    if (notifications.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_none_rounded,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Không có thông báo nào',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: notifications.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1, indent: 72),
                      itemBuilder: (context, index) {
                        final notif = notifications[index];
                        return _buildNotificationTile(notif);
                      },
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, _) => Center(
                    child: Text('Đã xảy ra lỗi: $error'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationTile(notif_model.Notification notif) {
    final config = _getNotificationConfig(notif.type);
    final timeAgo = _formatTimeAgo(notif.createdAt);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: config.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(config.icon, color: config.color, size: 20),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: config.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              notif.type.displayName,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: config.color,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(
            child: Text(
              notif.title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: notif.isSeen ? FontWeight.w500 : FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      subtitle: Text(
        notif.subtitle,
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
      trailing: Text(
        timeAgo,
        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
      ),
    );
  }

  _NotificationConfig _getNotificationConfig(notif_model.NotificationType type) {
    switch (type) {
      case notif_model.NotificationType.duty:
        return _NotificationConfig(
          icon: Icons.assignment_outlined,
          color: AppColors.warningOrange,
        );
      case notif_model.NotificationType.event:
        return _NotificationConfig(
          icon: Icons.event_outlined,
          color: AppColors.primaryBlue,
        );
      case notif_model.NotificationType.fund:
        return _NotificationConfig(
          icon: Icons.account_balance_wallet_outlined,
          color: AppColors.successGreen,
        );
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}p trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d trước';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }
}

class _NotificationConfig {
  final IconData icon;
  final Color color;

  _NotificationConfig({required this.icon, required this.color});
}
