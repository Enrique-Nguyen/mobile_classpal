import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_classpal/core/constants/app_colors.dart';
import 'package:mobile_classpal/core/models/class.dart';
import 'package:mobile_classpal/core/models/member.dart';
import 'package:mobile_classpal/core/widgets/drawer_button.dart';
import 'package:mobile_classpal/core/widgets/notification_button.dart';
import 'package:mobile_classpal/core/widgets/leaderboard_button.dart';

class DashboardHeader extends ConsumerWidget {
  final String className;
  final String role;
  final String displayName;
  final Class classData;
  final Member currentMember;

  const DashboardHeader({
    super.key,
    required this.className,
    required this.role,
    required this.displayName,
    required this.classData,
    required this.currentMember,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 24,
      ),
      decoration: const BoxDecoration(color: AppColors.bannerBlue),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar with icons - using reusable components
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: Drawer button
              const DrawersButton(isDarkTheme: true),
              // Right: Notification + Leaderboard buttons
              Row(
                children: [
                  NotificationButton(
                    classData: classData,
                    currentMember: currentMember,
                    isDarkTheme: true,
                  ),
                  const SizedBox(width: 12),
                  LeaderboardButton(
                    classData: classData,
                    currentMember: currentMember,
                    isDarkTheme: true,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            className,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Text(
                  '$displayName ($role)',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ),
              const Icon(
                Icons.supervised_user_circle,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
