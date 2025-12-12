import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Sample leaderboard entry
class LeaderboardEntry {
  final int rank;
  final String name;
  final int points;
  final bool isCurrentUser;

  const LeaderboardEntry({
    required this.rank,
    required this.name,
    required this.points,
    this.isCurrentUser = false,
  });
}

/// Show leaderboard as an expandable bottom sheet
void showLeaderboardSheet(BuildContext context) {
  // Sample leaderboard data
  final leaderboard = [
    const LeaderboardEntry(rank: 1, name: 'Nguyen Van A', points: 450),
    const LeaderboardEntry(rank: 2, name: 'Tran Thi B', points: 380),
    const LeaderboardEntry(
      rank: 3,
      name: 'Le Van C',
      points: 320,
      isCurrentUser: true,
    ),
    const LeaderboardEntry(rank: 4, name: 'Pham Minh D', points: 290),
    const LeaderboardEntry(rank: 5, name: 'Hoang Van E', points: 275),
    const LeaderboardEntry(rank: 6, name: 'Vo Thi F', points: 250),
    const LeaderboardEntry(rank: 7, name: 'Dao Van G', points: 220),
    const LeaderboardEntry(rank: 8, name: 'Bui Thi H', points: 195),
    const LeaderboardEntry(rank: 9, name: 'Ngo Van I', points: 180),
    const LeaderboardEntry(rank: 10, name: 'Duong Thi K', points: 165),
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
                    const Icon(
                      Icons.emoji_events_rounded,
                      color: Color(0xFFFFB800),
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Leaderboard',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'CS101 · Product Ops',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Leaderboard list
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: leaderboard.length,
                  itemBuilder: (context, index) {
                    final entry = leaderboard[index];
                    return _buildLeaderboardTile(entry);
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

Widget _buildLeaderboardTile(LeaderboardEntry entry) {
  // Rank badge colors
  Color rankColor;
  Color rankBgColor;

  switch (entry.rank) {
    case 1:
      rankColor = const Color(0xFFFFB800);
      rankBgColor = const Color(0xFFFFF8E1);
      break;
    case 2:
      rankColor = const Color(0xFF9E9E9E);
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

  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: entry.isCurrentUser ? AppColors.bgBlueLight : Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: entry.isCurrentUser
          ? Border.all(color: AppColors.primaryBlue.withOpacity(0.3))
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
        const SizedBox(width: 14),
        // Name
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: entry.isCurrentUser
                      ? FontWeight.bold
                      : FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              if (entry.isCurrentUser)
                const Text(
                  'You',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
        // Points
        Text(
          '${entry.points} pts',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: entry.rank <= 3 ? rankColor : AppColors.textPrimary,
          ),
        ),
      ],
    ),
  );
}
