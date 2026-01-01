import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_classpal/features/class_view/overview/services/notification_service.dart';
import '../constants/app_colors.dart';
import '../models/class.dart';
import '../models/member.dart';
import '../providers/notification_provider.dart';
import 'notification_tile.dart';

/// Show notifications as an expandable bottom sheet
void showNotificationsSheet(
  BuildContext context, {
  required String classId,
  required String uid,
  Class? classData,
  Member? currentMember,
}) {
  // Mark all notifications as seen when opening the sheet
  NotificationService.markAllAsSeen(classId, uid);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _NotificationsSheet(
      classId: classId,
      uid: uid,
      classData: classData,
      currentMember: currentMember,
    ),
  );
}

class _NotificationsSheet extends ConsumerWidget {
  final String classId;
  final String uid;
  final Class? classData;
  final Member? currentMember;

  const _NotificationsSheet({
    required this.classId,
    required this.uid,
    this.classData,
    this.currentMember,
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
                        return NotificationTile(
                          notification: notif,
                          onTap: (classData != null && currentMember != null)
                            ? () {
                                Navigator.pop(context); // Close sheet first
                                navigateToNotificationDetail(
                                  context,
                                  notif,
                                  classData!,
                                  currentMember!,
                                );
                              }
                            : null,
                        );
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
}
