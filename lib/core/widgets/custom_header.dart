import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'app_drawer.dart';
import 'notifications_sheet.dart';
import 'leaderboard_sheet.dart';

class CustomHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const CustomHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          _buildIconBtn(Icons.grid_view, onTap: () => showAppDrawer(context)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
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
          const SizedBox(width: 16),
          _buildIconBtn(
            Icons.notifications_none,
            onTap: () => showNotificationsSheet(context),
          ),
          const SizedBox(width: 8),
          _buildIconBtn(
            Icons.emoji_events_outlined,
            onTap: () => showLeaderboardSheet(context),
          ),
        ],
      ),
    );
  }

  Widget _buildIconBtn(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Icon(icon, size: 20, color: Colors.black87),
      ),
    );
  }
}
