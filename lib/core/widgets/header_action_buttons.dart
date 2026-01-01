import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../models/class.dart';
import '../models/member.dart';
import '../providers/notification_provider.dart';
import 'notifications_sheet.dart';
import 'app_drawer.dart';
import 'package:mobile_classpal/features/class_view/leaderboard/screens/leaderboards_screen.dart';

class HeaderActionButtons extends ConsumerWidget {
  final Class classData;
  final Member currentMember;
  final bool isDarkTheme;

  const HeaderActionButtons({
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

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left: Drawer button
        _buildIconButton(
          icon: Icons.grid_view_rounded,
          onTap: () => showAppDrawer(context),
        ),
        // Right: Notification + Leaderboard buttons
        Row(
          children: [
            // Notifications button with badge
            GestureDetector(
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
                  _buildIconContainer(Icons.notifications_outlined),
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
            ),
            const SizedBox(width: 12),
            // Leaderboard button
            _buildIconButton(
              icon: Icons.emoji_events_outlined,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LeaderboardsScreen(
                    classData: classData,
                    currentMember: currentMember,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: _buildIconContainer(icon),
    );
  }

  Widget _buildIconContainer(IconData icon) {
    if (isDarkTheme) {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Icon(icon, size: 20, color: Colors.black87),
      );
    }
  }
}
