import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/mock_data.dart';
import '../../../../core/widgets/custom_header.dart';
import '../../../../core/models/class.dart';
import '../../../../core/models/member.dart';
import '../../../../core/models/task.dart';
import 'task_detail_screen.dart';

class TasksScreenMember extends StatelessWidget {
  final Class classData;
  final Member currentMember;

  const TasksScreenMember({
    super.key,
    required this.classData,
    required this.currentMember,
  });

  String _formatDateLabel(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(dt.year, dt.month, dt.day);
    
    if (taskDate == today) return 'Hôm nay';
    if (taskDate == today.add(const Duration(days: 1))) return 'Ngày mai';
    if (taskDate == today.subtract(const Duration(days: 1))) return 'Hôm qua';
    return '${dt.day}/${dt.month}';
  }

  String _formatTimeLabel(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final tasks = MockData.memberTasks;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(
              title: 'Nhiệm vụ của tôi',
              subtitle: classData.name,
            ),
            const SizedBox(height: 8),
            // Task summary
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildStatusChip(
                    count: tasks.where((t) => t.status == TaskStatus.incomplete).length,
                    label: 'Chưa hoàn thành',
                    color: AppColors.errorRed,
                  ),
                  const SizedBox(width: 8),
                  _buildStatusChip(
                    count: tasks.where((t) => t.status == TaskStatus.pending).length,
                    label: 'Chờ duyệt',
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  _buildStatusChip(
                    count: tasks.where((t) => t.status == TaskStatus.completed).length,
                    label: 'Hoàn thành',
                    color: AppColors.successGreen,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Task list
            Expanded(
              child: tasks.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return _buildTaskCard(context, task);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip({
    required int count,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt,
            size: 64,
            color: AppColors.successGreen.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Không có nhiệm vụ nào',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, Task task) {
    final extraInfo = MockData.parseNoteField(task.note);
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskDetailScreen(task: task),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
            // Top row: Status and Points
            Row(
              children: [
                _buildStatusBadge(task.status),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.bgGreenLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: AppColors.successGreen,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '+${task.points.toInt()}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.successGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Title
            Text(
              task.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            // Date/time and rule
            Row(
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  '${_formatDateLabel(task.startTime)} · ${_formatTimeLabel(task.startTime)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.bookmark_outline,
                  size: 14,
                  color: AppColors.primaryBlue.withOpacity(0.7),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    task.ruleName,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primaryBlue.withOpacity(0.7),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            // Extra info (location/amount)
            if (extraInfo != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: extraInfo.type == DutyExtraType.location
                      ? AppColors.bgBlueLight
                      : AppColors.bgGreenLight.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      extraInfo.icon,
                      size: 14,
                      color: extraInfo.type == DutyExtraType.location
                          ? AppColors.primaryBlue
                          : AppColors.successGreen,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      extraInfo.value,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: extraInfo.type == DutyExtraType.location
                            ? AppColors.primaryBlue
                            : AppColors.successGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(TaskStatus status) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case TaskStatus.completed:
        color = AppColors.successGreen;
        label = 'Hoàn thành';
        icon = Icons.check_circle;
        break;
      case TaskStatus.pending:
        color = Colors.orange;
        label = 'Chờ duyệt';
        icon = Icons.hourglass_top;
        break;
      case TaskStatus.incomplete:
        color = AppColors.errorRed;
        label = 'Chưa làm';
        icon = Icons.radio_button_unchecked;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
