import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import 'package:mobile_classpal/core/models/class.dart';
import 'package:mobile_classpal/core/models/member.dart';
import 'drawer_button.dart';
import 'notification_button.dart';
import 'leaderboard_button.dart';

/// Reusable header widget for class view screens
/// Composes DrawerButton, NotificationButton, and LeaderboardButton
class CustomHeader extends ConsumerWidget {
  final String title;
  final String subtitle;
  final Class? classData;
  final Member? currentMember;

  const CustomHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.classData,
    this.currentMember,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasRequiredData = classData != null && currentMember != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: SizedBox(
        height: 44,
        child: Stack(
          children: [
            // Action buttons row
            if (hasRequiredData)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left: Drawer button
                  const DrawersButton(isDarkTheme: false),
                  // Right: Notification + Leaderboard buttons
                  Row(
                    children: [
                      NotificationButton(
                        classData: classData!,
                        currentMember: currentMember!,
                        isDarkTheme: false,
                      ),
                      const SizedBox(width: 12),
                      LeaderboardButton(
                        classData: classData!,
                        currentMember: currentMember!,
                        isDarkTheme: false,
                      ),
                    ],
                  ),
                ],
              ),
            
            // Centered title (absolute center)
            Positioned.fill(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
