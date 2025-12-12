import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Sample notification data
class NotificationItem {
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color iconColor;

  const NotificationItem({
    required this.title,
    required this.subtitle,
    required this.time,
    this.icon = Icons.info_outline,
    this.iconColor = AppColors.primaryBlue,
  });
}

/// Show notifications as an expandable bottom sheet
void showNotificationsSheet(BuildContext context) {
  // Sample notifications
  final notifications = [
    NotificationItem(
      title: 'Equipment ready for Lab',
      subtitle: 'Camera ready',
      time: '5m ago',
      icon: Icons.warning_amber_rounded,
      iconColor: AppColors.warningOrange,
    ),
    NotificationItem(
      title: 'Attendance rate at 82%',
      subtitle: 'Not all members responded yet',
      time: '1h ago',
      icon: Icons.info_outline,
      iconColor: AppColors.primaryBlue,
    ),
    NotificationItem(
      title: '50,000 VND disbursed to funds',
      subtitle: 'Approved by advisor',
      time: '2h ago',
      icon: Icons.check_circle_outline,
      iconColor: AppColors.successGreen,
    ),
    NotificationItem(
      title: 'Whiteboard sterilized',
      subtitle: 'Duty completed by Nguyen Van A',
      time: '3h ago',
      icon: Icons.check_circle_outline,
      iconColor: AppColors.successGreen,
    ),
    NotificationItem(
      title: 'Advisor verified',
      subtitle: 'Your class advisor has been verified',
      time: 'Yesterday',
      icon: Icons.verified_outlined,
      iconColor: AppColors.primaryBlue,
    ),
    NotificationItem(
      title: 'Assets board updated',
      subtitle: 'New items added to inventory',
      time: 'Yesterday',
      icon: Icons.inventory_2_outlined,
      iconColor: AppColors.textSecondary,
    ),
  ];

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
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
                      'Notifications',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.errorRed,
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
                  ],
                ),
              ),
              const Divider(height: 1),
              // Notifications list
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: notifications.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1, indent: 72),
                  itemBuilder: (context, index) {
                    final notif = notifications[index];
                    return _buildNotificationTile(notif);
                  },
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

Widget _buildNotificationTile(NotificationItem notif) {
  return ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    leading: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: notif.iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(notif.icon, color: notif.iconColor, size: 20),
    ),
    title: Text(
      notif.title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    ),
    subtitle: Text(
      notif.subtitle,
      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
    ),
    trailing: Text(
      notif.time,
      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
    ),
  );
}
