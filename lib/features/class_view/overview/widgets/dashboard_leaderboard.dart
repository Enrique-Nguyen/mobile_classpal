import 'package:flutter/material.dart';

class DashboardLeaderboard extends StatelessWidget {
  const DashboardLeaderboard({super.key});

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
                'LEADERBOARD',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildLeaderboardCard(
            rank: '#1',
            role: 'LEAD',
            roleColor: const Color(0xFFE8F5E9),
            borderColor: const Color(0xFF81C784),
            name: 'Sarah L.',
            subtitle: '8 duties cleared',
            points: '450 pts',
          ),
          const SizedBox(height: 12),
          _buildLeaderboardCard(
            rank: '#2',
            role: 'FOCUS',
            roleColor: const Color(0xFFFFF3E0),
            borderColor: const Color(0xFFFFB74D),
            name: 'John S.',
            subtitle: '5 audits logged',
            points: '380 pts',
          ),
          const SizedBox(height: 12),
          _buildLeaderboardCard(
            rank: '#3',
            role: 'ASSIST',
            roleColor: const Color(0xFFE3F2FD),
            borderColor: const Color(0xFF64B5F6),
            name: 'You',
            subtitle: '3 quick assists',
            points: '320 pts',
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardCard({
    required String rank,
    required String role,
    required Color roleColor,
    required Color borderColor,
    required String name,
    required String subtitle,
    required String points,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: borderColor, width: 4)),
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
              color: roleColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              role,
              style: TextStyle(
                color: borderColor,
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
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E1E2D),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                points,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E2D),
                ),
              ),
              Text(
                rank,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
