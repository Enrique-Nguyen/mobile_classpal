import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../models/class.dart';
import '../models/member.dart';
import '../providers/notification_provider.dart';
import 'notifications_sheet.dart';

/// Reusable notification button widget with badge
/// Shows unseen notification count and opens notification sheet on tap
class NotificationButton extends ConsumerWidget {
  final Class classData;
  final Member currentMember;
  
  /// Whether to use dark theme (white icon on transparent/dark bg)
  final bool isDarkTheme;

  const NotificationButton({
    super.key,
    required this.classData,
    required this.currentMember,
    this.isDarkTheme = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unseenCountAsync = ref.watch(
      NotificationProvider.unseenCountStreamProvider(
        (classId: classData.classId, uid: currentMember.uid),
      ),
    );

    return GestureDetector(
      onTap: () => showNotificationsSheet(
        context,
        classId: classData.classId,
        uid: currentMember.uid,
        classData: classData,
        currentMember: currentMember,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Icon container
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDarkTheme 
                  ? Colors.white.withOpacity(0.1) 
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: isDarkTheme 
                  ? null 
                  : Border.all(color: Colors.grey.shade200),
            ),
            child: Icon(
              Icons.notifications_outlined,
              color: isDarkTheme ? Colors.white : Colors.black87,
              size: 20,
            ),
          ),
          // Badge for unseen count
          unseenCountAsync.when(
            data: (count) => count > 0
                ? Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.errorRed,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        count > 99 ? '99+' : count.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
