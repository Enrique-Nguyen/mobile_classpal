import 'package:flutter/material.dart';
import 'package:mobile_classpal/core/constants/app_colors.dart';
import 'package:mobile_classpal/core/models/leaderboard.dart';
import 'package:mobile_classpal/core/models/class.dart';
import 'package:mobile_classpal/core/models/member.dart';
import 'package:mobile_classpal/features/class_view/leaderboard/services/leaderboard_service.dart';
import 'package:mobile_classpal/features/class_view/leaderboard/screens/leaderboard_detail_screen.dart';
import 'package:mobile_classpal/features/class_view/leaderboard/widgets/create_leaderboard_dialog.dart';

class LeaderboardsScreen extends StatelessWidget {
  final Class classData;
  final Member currentMember;

  const LeaderboardsScreen({
    super.key,
    required this.classData,
    required this.currentMember,
  });

  bool get isAdmin => currentMember.role != MemberRole.thanhVien;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Bảng xếp hạng',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: isAdmin
            ? [
                IconButton(
                  icon: const Icon(Icons.add, color: AppColors.primaryBlue),
                  onPressed: () => _showCreateDialog(context),
                ),
              ]
            : null,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.grey.shade200,
            height: 1,
          ),
        ),
      ),
      body: StreamBuilder<List<Leaderboard>>(
        stream: LeaderboardService.streamLeaderboards(classData.classId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final leaderboards = snapshot.data ?? [];

          if (leaderboards.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: leaderboards.length,
            itemBuilder: (context, index) {
              final leaderboard = leaderboards[index];
              final isCurrent = index == 0; // First one is most recent
              return _buildLeaderboardCard(context, leaderboard, isCurrent);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có bảng xếp hạng',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (isAdmin) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showCreateDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Tạo bảng xếp hạng'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLeaderboardCard(
    BuildContext context,
    Leaderboard leaderboard,
    bool isCurrent,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isCurrent
            ? Border.all(color: AppColors.primaryBlue.withOpacity(0.3), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LeaderboardDetailScreen(
                  classData: classData,
                  currentMember: currentMember,
                  leaderboard: leaderboard,
                  isCurrent: isCurrent,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Trophy icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? AppColors.primaryBlue.withOpacity(0.1)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.emoji_events,
                    color: isCurrent ? AppColors.primaryBlue : Colors.grey.shade400,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                // Name and date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              leaderboard.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (isCurrent)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Hiện tại',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tạo ngày ${_formatDate(leaderboard.createdAt)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Edit button for current leaderboard (admin only)
                if (isAdmin && isCurrent)
                  IconButton(
                    icon: Icon(
                      Icons.edit_outlined,
                      color: Colors.grey.shade400,
                      size: 20,
                    ),
                    onPressed: () => _showEditDialog(context, leaderboard),
                  ),
                // Arrow icon
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _showCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CreateLeaderboardDialog(
        classId: classData.classId,
        onCreated: () {
          // Dialog handles creation, just close
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, Leaderboard leaderboard) {
    showDialog(
      context: context,
      builder: (context) => CreateLeaderboardDialog(
        classId: classData.classId,
        existingLeaderboard: leaderboard,
        onCreated: () {},
      ),
    );
  }
}
