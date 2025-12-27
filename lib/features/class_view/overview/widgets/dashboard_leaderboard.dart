import 'package:flutter/material.dart';
import 'package:mobile_classpal/core/constants/app_colors.dart';
import 'package:mobile_classpal/core/models/class.dart';
import 'package:mobile_classpal/core/models/member.dart';
import 'package:mobile_classpal/core/models/leaderboard_entry.dart';
import 'package:mobile_classpal/features/class_view/leaderboard/services/leaderboard_service.dart';
import 'package:mobile_classpal/features/class_view/leaderboard/screens/leaderboards_screen.dart';

class DashboardLeaderboard extends StatelessWidget {
  final Class classData;
  final Member currentMember;

  const DashboardLeaderboard({
    super.key,
    required this.classData,
    required this.currentMember,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'BẢNG XẾP HẠNG',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
              GestureDetector(
                onTap: () => _navigateToLeaderboards(context),
                child: Text(
                  'Xem tất cả',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          StreamBuilder<List<LeaderboardEntry>>(
            stream: LeaderboardService.streamTopEntries(
              classData.classId,
              currentMember.uid,
              limit: 3,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final entries = snapshot.data ?? [];

              if (entries.isEmpty) {
                return _buildEmptyState(context);
              }

              return Column(
                children: entries.map((entry) {
                  Color borderColor;
                  Color bgColor;
                  
                  switch (entry.rank) {
                    case 1:
                      borderColor = const Color(0xFFFFD700);
                      bgColor = const Color(0xFFFFF8E1);
                      break;
                    case 2:
                      borderColor = const Color(0xFFC0C0C0);
                      bgColor = const Color(0xFFF5F5F5);
                      break;
                    case 3:
                      borderColor = const Color(0xFFCD7F32);
                      bgColor = const Color(0xFFFBE9E7);
                      break;
                    default:
                      borderColor = AppColors.primaryBlue;
                      bgColor = AppColors.bgBlueLight;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildLeaderboardCard(
                      rank: '#${entry.rank}',
                      rankColor: borderColor,
                      rankBgColor: bgColor,
                      name: entry.isCurrentUser ? 'Bạn' : entry.memberName,
                      subtitle: '${entry.achievementCount} thành tích',
                      points: '${entry.totalPoints.toInt()} điểm',
                      isCurrentUser: entry.isCurrentUser,
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToLeaderboards(context),
      child: Container(
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
        child: Column(
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 48,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 12),
            Text(
              'Chưa có thành tích nào',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Hoàn thành nhiệm vụ để tích lũy điểm',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardCard({
    required String rank,
    required Color rankColor,
    required Color rankBgColor,
    required String name,
    required String subtitle,
    required String points,
    bool isCurrentUser = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentUser ? AppColors.bgBlueLight : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: rankColor, width: 4)),
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
          // Rank badge
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: rankBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                rank,
                style: TextStyle(
                  color: rankColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.w600,
                    color: const Color(0xFF1E1E2D),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          Text(
            points,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: rankColor,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToLeaderboards(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LeaderboardsScreen(
          classData: classData,
          currentMember: currentMember,
        ),
      ),
    );
  }
}
