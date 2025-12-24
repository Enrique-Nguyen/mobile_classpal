import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_classpal/core/constants/app_colors.dart';
import 'package:mobile_classpal/core/widgets/custom_header.dart';
import 'package:mobile_classpal/core/models/class.dart';
import 'package:mobile_classpal/core/models/member.dart';
import 'package:mobile_classpal/core/models/duty.dart';
import 'package:mobile_classpal/core/helpers/duty_helper.dart';
import 'package:mobile_classpal/features/auth/services/auth_service.dart';
import 'package:mobile_classpal/features/class_view/workflow/services/duty_service.dart';
import 'package:mobile_classpal/core/models/task.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/duty_card.dart';
import '../widgets/pending_approval_card.dart';
import 'create_duty_screen.dart';
import 'duty_details_screen.dart';

class DutiesScreenMonitor extends ConsumerStatefulWidget {
  final Class classData;
  final Member currentMember;

  const DutiesScreenMonitor({
    super.key,
    required this.classData,
    required this.currentMember,
  });

  @override
  ConsumerState<DutiesScreenMonitor> createState() => _DutiesScreenMonitorState();
}

class _DutiesScreenMonitorState extends ConsumerState<DutiesScreenMonitor> {
  int _selectedTabIndex = 0;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatDateLabel(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dutyDate = DateTime(dt.year, dt.month, dt.day);
    
    if (dutyDate == today)
      return 'Today';
    if (dutyDate == today.add(const Duration(days: 1)))
      return 'Tomorrow';
    if (dutyDate == today.subtract(const Duration(days: 1)))
      return 'Yesterday';

    return '${dt.day}/${dt.month}';
  }

  String _formatTimeLabel(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Stream<List<Duty>> get _dutiesStream {
    return FirebaseFirestore.instance
      .collection('classes')
      .doc(widget.classData.classId)
      .collection('duties')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => Duty.fromMap(doc.data())).toList());
  }

  List<Duty> _filterDuties(List<Duty> duties) {
    if (_searchQuery.isEmpty) return duties;
    return duties.where((duty) {
      return duty.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateDutyScreen(
                classData: widget.classData,
                currentMember: widget.currentMember,
              ),
            ),
          );
        },
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(
              title: 'Nhiệm vụ',
              subtitle: widget.classData.name,
            ),
            // Scrollable content (search, tabs, and items)
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const SizedBox(height: 10),
                  // Search bar (scrolls with content)
                  _buildSearchBar(),
                  const SizedBox(height: 12),
                  // Tab bar (scrolls with content)
                  _buildTabBar(),
                  const SizedBox(height: 16),
                  // Content based on selected tab
                  if (_selectedTabIndex == 0)
                    StreamBuilder<List<Duty>>(
                      stream: _dutiesStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting)
                          return const Center(child: CircularProgressIndicator());
                        if (snapshot.hasError)
                          return Center(child: Text('Lỗi: ${snapshot.error}'));

                        final duties = _filterDuties(snapshot.data ?? []);
                        return Column(
                          children: _buildDutiesList(duties),
                        );
                      },
                    )
                  else
                    StreamBuilder<List<Task>>(
                      stream: DutyService.streamPendingApprovals(widget.classData.classId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting)
                          return const Center(child: CircularProgressIndicator());
                        if (snapshot.hasError)
                          return Center(child: Text('Lỗi: ${snapshot.error}'));

                        final tasks = snapshot.data ?? [];
                        // Client-side filtering if needed, though search is mainly for names
                        // We need to filter tasks based on member name or duty name which requires async data... 
                        // For simplicity, we won't filter initially or will do it inside the item builder (not ideal for strict search).
                        // Let's just show all for now, or implement a smarter filter later.
                        
                        if (tasks.isEmpty) {
                          return _buildEmptyState(
                            icon: Icons.check_circle_outline,
                            iconColor: AppColors.successGreen,
                            title: 'No pending approvals',
                            subtitle: 'All submissions have been reviewed',
                          );
                        }

                        return Column(
                          children: tasks.map((task) => _PendingApprovalItem(
                            task: task,
                            classId: widget.classData.classId,
                            searchQuery: _searchQuery,
                            onApprove: () => _handleApproval(task, true),
                            onReject: () => _handleApproval(task, false),
                          )).toList(),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleApproval(Task task, bool approved) async {
    try {
      await DutyService.updateTaskStatus(
        classId: widget.classData.classId,
        dutyId: task.dutyId,
        taskId: task.id,
        newStatus: approved ? TaskStatus.completed : TaskStatus.incomplete,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(approved ? 'Đã duyệt nhiệm vụ' : 'Đã từ chối nhiệm vụ'),
            backgroundColor: approved ? AppColors.successGreen : AppColors.errorRed,
            duration: const Duration(milliseconds: 1300),
          ),
        );
      }
    }
    catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _searchQuery = value),
      decoration: InputDecoration(
        hintText: _selectedTabIndex == 0 
          ? 'Search duties...' 
          : 'Search pending...',
        hintStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
        prefixIcon: const Icon(
          Icons.search,
          color: AppColors.textSecondary,
        ),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // All Duties tab
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _selectedTabIndex = 0;
                _searchQuery = '';
                _searchController.clear();
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 0 ? AppColors.bannerBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'All Duties',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: _selectedTabIndex == 0 ? FontWeight.w600 : FontWeight.w500,
                    color: _selectedTabIndex == 0 ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
          // Pending tab
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _selectedTabIndex = 1;
                _searchQuery = '';
                _searchController.clear();
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 1 ? AppColors.bannerBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: StreamBuilder<List<Task>>(
                  stream: DutyService.streamPendingApprovals(widget.classData.classId),
                  builder: (context, snapshot) {
                    final count = snapshot.data?.length ?? 0;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Pending',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: _selectedTabIndex == 1 ? FontWeight.w600 : FontWeight.w500,
                            color: _selectedTabIndex == 1 ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                        if (count > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.errorRed,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$count',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  }
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDutiesList(List<Duty> duties) {
    if (duties.isEmpty) {
      return [
        _buildEmptyState(
          icon: _searchQuery.isEmpty ? Icons.assignment_outlined : Icons.search_off,
          title: _searchQuery.isEmpty ? 'No duties yet' : 'No duties found',
          subtitle: _searchQuery.isEmpty 
            ? 'Create your first duty to get started'
            : 'Try a different search term',
        ),
      ];
    }
    
    return duties.map((duty) => DutyCard(
      title: duty.name,
      dateLabel: _formatDateLabel(duty.startTime),
      timeLabel: _formatTimeLabel(duty.startTime),
      ruleName: duty.ruleName,
      points: duty.points.toInt(),
      isAssignedToMonitor: duty.assigneeIds.contains(widget.currentMember.uid),
      extraInfo: DutyHelper.parseNoteField(duty),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DutyDetailsScreen(
              duty: duty,
              isAdmin: true,
              isAssignedToAdmin: duty.assigneeIds.contains(widget.currentMember.uid),
            ),
          ),
        );
      },
    )).toList();
  }

  Widget _buildEmptyState({
    required IconData icon,
    Color? iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: (iconColor ?? AppColors.textSecondary).withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _PendingApprovalItem extends StatelessWidget {
  final Task task;
  final String classId;
  final String searchQuery;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _PendingApprovalItem({
    required this.task,
    required this.classId,
    required this.searchQuery,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        DutyService.getDuty(classId, task.dutyId),
        AuthService.getMember(classId, task.uid),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const SizedBox.shrink();
        
        final duty = snapshot.data![0] as Duty?;
        final member = snapshot.data![1] as Member?;

        if (duty == null || member == null)
          return const SizedBox.shrink();

        if (searchQuery.isNotEmpty) {
          final q = searchQuery.toLowerCase();
          if (!duty.name.toLowerCase().contains(q) && !member.name.toLowerCase().contains(q)) {
            return const SizedBox.shrink();
          }
        }

        return PendingApprovalCard(
          memberName: member.name,
          memberAvatar: member.avatarUrl ?? '',
          dutyTitle: duty.name,
          submittedAt: _formatTime(task.updatedAt.millisecondsSinceEpoch > 0 ? task.updatedAt : task.createdAt),
          proofImageUrl: null, // TODO: Add proofUrl to Task
          onApprove: onApprove,
          onReject: onReject,
        );
      },
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')} ${dt.day}/${dt.month}';
  }
}
