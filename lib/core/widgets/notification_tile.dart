import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_classpal/features/class_view/workflow/screens/duty_details_screen.dart';
import 'package:mobile_classpal/features/class_view/workflow/screens/event_details_screen.dart';
import '../constants/app_colors.dart';
import '../models/notification.dart' as notif_model;
import '../models/class.dart';
import '../models/member.dart';
import '../models/duty.dart';
import '../models/event.dart';
import '../models/task.dart';

class NotificationConfig {
  final Color backgroundColor;
  final Color borderColor;
  final IconData icon;

  const NotificationConfig({
    required this.backgroundColor,
    required this.borderColor,
    required this.icon,
  });

  static NotificationConfig fromType(notif_model.NotificationType type) {
    switch (type) {
      case notif_model.NotificationType.duty:
        return const NotificationConfig(
          backgroundColor: Color(0xFFFFF3E0),
          borderColor: AppColors.warningOrange,
          icon: Icons.assignment_outlined,
        );
      case notif_model.NotificationType.event:
        return const NotificationConfig(
          backgroundColor: Color(0xFFE3F2FD),
          borderColor: AppColors.primaryBlue,
          icon: Icons.event_outlined,
        );
      case notif_model.NotificationType.fund:
        return const NotificationConfig(
          backgroundColor: Color(0xFFE8F5E9),
          borderColor: AppColors.successGreen,
          icon: Icons.account_balance_wallet_outlined,
        );
    }
  }
}

/// Format time ago string for notifications
String formatTimeAgo(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inMinutes < 1)
    return 'Vừa xong';
  else if (difference.inMinutes < 60)
    return '${difference.inMinutes}p trước';
  else if (difference.inHours < 24)
    return '${difference.inHours}h trước';
  else if (difference.inDays < 7)
    return '${difference.inDays}d trước';

  return '${dateTime.day}/${dateTime.month}';
}

/// Navigate to the detail screen based on notification type
Future<void> navigateToNotificationDetail(
  BuildContext context,
  notif_model.Notification notification,
  Class classData,
  Member currentMember,
) async {
  if (notification.referenceId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Không tìm thấy nội dung liên quan')),
    );
    return;
  }

  final classId = classData.classId;
  final referenceId = notification.referenceId!;
  final isAdmin = currentMember.role != MemberRole.thanhVien;

  try {
    switch (notification.type) {
      case notif_model.NotificationType.duty:
        // Fetch duty data
        final dutyDoc = await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('duties')
          .doc(referenceId)
          .get();
        
        if (!dutyDoc.exists) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Nhiệm vụ không tồn tại')),
            );
          }
          return;
        }

        final duty = Duty.fromMap(dutyDoc.data()!);
        final isAssignee = duty.assigneeIds.contains(currentMember.uid);

        Task? task;
        if (isAssignee) {
          final taskDoc = await FirebaseFirestore.instance
            .collection('classes')
            .doc(classId)
            .collection('duties')
            .doc(referenceId)
            .collection('tasks')
            .where('uid', isEqualTo: currentMember.uid)
            .limit(1)
            .get();
          
          if (taskDoc.docs.isNotEmpty) {
            task = Task.fromMap(taskDoc.docs.first.data());
          }
        }

        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DutyDetailsScreen(
                duty: duty,
                isAdmin: isAdmin,
                task: task,
                isAssignedToAdmin: isAdmin && isAssignee,
              ),
            ),
          );
        }
        break;

      case notif_model.NotificationType.event:
        // Fetch event data
        final eventDoc = await FirebaseFirestore.instance
            .collection('classes')
            .doc(classId)
            .collection('events')
            .doc(referenceId)
            .get();
        
        if (!eventDoc.exists) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sự kiện không tồn tại')),
            );
          }
          return;
        }

        final event = Event.fromMap(eventDoc.data()!);

        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventDetailsScreen(
                event: event,
                classId: classId,
                memberUid: currentMember.uid,
                isAdmin: isAdmin,
              ),
            ),
          );
        }
        break;

      case notif_model.NotificationType.fund:
        break;
    }
  }
  catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }
}

/// Shared notification card widget for dashboard display
class NotificationCard extends StatelessWidget {
  final notif_model.Notification notification;
  final VoidCallback? onTap;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final config = NotificationConfig.fromType(notification.type);

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
      ),
    );
  }
}

/// Shared notification tile widget for sheet/list display
class NotificationTile extends StatelessWidget {
  final notif_model.Notification notification;
  final VoidCallback? onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final config = NotificationConfig.fromType(notification.type);
    final timeAgo = formatTimeAgo(notification.createdAt);

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: config.borderColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(config.icon, color: config.borderColor, size: 20),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: config.borderColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              notification.type.displayName,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: config.borderColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(
            child: Text(
              notification.title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: notification.isSeen ? FontWeight.w500 : FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      subtitle: Text(
        notification.subtitle,
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
      trailing: Text(
        timeAgo,
        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
      ),
    );
  }
}
