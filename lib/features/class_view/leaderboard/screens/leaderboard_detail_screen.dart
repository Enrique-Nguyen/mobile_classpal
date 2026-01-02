import 'package:flutter/material.dart';
import 'package:mobile_classpal/core/constants/app_colors.dart';
import 'package:mobile_classpal/core/models/leaderboard.dart';
import 'package:mobile_classpal/core/models/leaderboard_entry.dart';
import 'package:mobile_classpal/core/models/class.dart';
import 'package:mobile_classpal/core/models/member.dart';
import 'package:mobile_classpal/features/class_view/leaderboard/services/leaderboard_service.dart';
import 'package:mobile_classpal/features/class_view/leaderboard/screens/member_achievements_screen.dart';

class LeaderboardDetailScreen extends StatelessWidget {
  final Class classData;
  final Member currentMember;
  final Leaderboard leaderboard;
  final bool isCurrent;

  const LeaderboardDetailScreen({
    super.key,
    required this.classData,
    required this.currentMember,
    required this.leaderboard,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Gradient App Bar
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppColors.primaryBlue,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    leaderboard.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (isCurrent)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Hiện tại',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              centerTitle: true,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryBlue,
                      AppColors.primaryBlue.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.emoji_events,
                    size: 80,
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
              ),
            ),
          ),

          // Leaderboard Content
          SliverToBoxAdapter(
            child: StreamBuilder<List<LeaderboardEntry>>(
              stream: LeaderboardService.streamLeaderboardEntries(
                classId: classData.classId,
                leaderboardId: leaderboard.leaderboardId,
                currentUserUid: currentMember.uid,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final entries = snapshot.data ?? [];

                if (entries.isEmpty) {
                  return _buildEmptyState();
                }

                return Column(
                  children: [
                    const SizedBox(height: 24),
                    
                    // Top 3 Podium
                    if (entries.length >= 3) _buildPodium(context, entries),
                    if (entries.length < 3 && entries.isNotEmpty)
                      _buildSmallPodium(context, entries),
                    
                    const SizedBox(height: 24),
                    
                    // Full List
                    _buildFullList(context, entries),
                    
                    const SizedBox(height: 24),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.leaderboard_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có thành tích nào',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hoàn thành nhiệm vụ để tích lũy điểm',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodium(BuildContext context, List<LeaderboardEntry> entries) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd place
          _buildPodiumItem(context, entries[1], 2, 90),
          const SizedBox(width: 8),
          // 1st place
          _buildPodiumItem(context, entries[0], 1, 110),
          const SizedBox(width: 8),
          // 3rd place
          _buildPodiumItem(context, entries[2], 3, 70),
        ],
      ),
    );
  }

  Widget _buildSmallPodium(BuildContext context, List<LeaderboardEntry> entries) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: entries.asMap().entries.map((e) {
          final index = e.key;
          final entry = e.value;
          final height = index == 0 ? 110.0 : (index == 1 ? 90.0 : 70.0);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _buildPodiumItem(context, entry, index + 1, height),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPodiumItem(
    BuildContext context,
    LeaderboardEntry entry,
    int rank,
    double height,
  ) {
    Color rankColor;
    Color bgColor;
    switch (rank) {
      case 1:
        rankColor = const Color(0xFFFFD700); // Gold
        bgColor = const Color(0xFFFFF8E1);
        break;
      case 2:
        rankColor = const Color(0xFFC0C0C0); // Silver
        bgColor = const Color(0xFFF5F5F5);
        break;
      case 3:
        rankColor = const Color(0xFFCD7F32); // Bronze
        bgColor = const Color(0xFFFBE9E7);
        break;
      default:
        rankColor = AppColors.textSecondary;
        bgColor = AppColors.background;
    }

    return GestureDetector(
      onTap: () => _navigateToMemberAchievements(context, entry),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: rankColor, width: 3),
            ),
            child: Center(
              child: Text(
                entry.memberName.isNotEmpty 
                    ? entry.memberName[0].toUpperCase() 
                    : '?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Name
          SizedBox(
            width: 80,
            child: Text(
              entry.memberName,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: entry.isCurrentUser ? FontWeight.bold : FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          // Points
          Text(
            '${entry.totalPoints.toInt()} điểm',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: rankColor,
            ),
          ),
          const SizedBox(height: 8),
          // Podium block
          Container(
            width: 80,
            height: height,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              border: Border.all(color: rankColor.withOpacity(0.3)),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: rankColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullList(BuildContext context, List<LeaderboardEntry> entries) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Xếp hạng đầy đủ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...entries.map((entry) => _buildListTile(context, entry)),
        ],
      ),
    );
  }

  Widget _buildListTile(BuildContext context, LeaderboardEntry entry) {
    Color rankColor;
    Color rankBgColor;

    switch (entry.rank) {
      case 1:
        rankColor = const Color(0xFFFFD700);
        rankBgColor = const Color(0xFFFFF8E1);
        break;
      case 2:
        rankColor = const Color(0xFFC0C0C0);
        rankBgColor = const Color(0xFFF5F5F5);
        break;
      case 3:
        rankColor = const Color(0xFFCD7F32);
        rankBgColor = const Color(0xFFFBE9E7);
        break;
      default:
        rankColor = AppColors.textSecondary;
        rankBgColor = AppColors.background;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _navigateToMemberAchievements(context, entry),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: entry.isCurrentUser 
                ? AppColors.primaryBlue.withOpacity(0.05) 
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: entry.isCurrentUser
                ? Border.all(color: AppColors.primaryBlue.withOpacity(0.2))
                : null,
          ),
          child: Row(
            children: [
              // Rank badge
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: rankBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '#${entry.rank}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: rankColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    entry.memberName.isNotEmpty 
                        ? entry.memberName[0].toUpperCase() 
                        : '?',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Name and achievements count
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.memberName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: entry.isCurrentUser 
                                  ? FontWeight.bold 
                                  : FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (entry.isCurrentUser)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Bạn',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${entry.achievementCount} thành tích',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              // Points
              Text(
                '${entry.totalPoints.toInt()} điểm',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: entry.rank <= 3 ? rankColor : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToMemberAchievements(BuildContext context, LeaderboardEntry entry) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MemberAchievementsScreen(
          classData: classData,
          leaderboard: leaderboard,
          memberUid: entry.memberUid,
          memberName: entry.memberName,
          totalPoints: entry.totalPoints,
        ),
      ),
    );
  }
}
