import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_header.dart';
import '../../../../core/models/class.dart';
import '../../../../core/models/member.dart';
import '../../../../core/constants/mock_data.dart';
import '../widgets/duty_card.dart';
import '../widgets/pending_approval_card.dart';
import 'duty_details_screen.dart';
import 'create_duty_screen.dart';

class DutiesScreenMonitor extends StatefulWidget {
  final Class classData;
  final Member currentMember;

  const DutiesScreenMonitor({
    super.key,
    required this.classData,
    required this.currentMember,
  });

  @override
  State<DutiesScreenMonitor> createState() => _DutiesScreenMonitorState();
}

class _DutiesScreenMonitorState extends State<DutiesScreenMonitor>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Local copy for mutable pending approvals
  late List<Map<String, dynamic>> _pendingApprovals;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _pendingApprovals = List.from(MockData.pendingApprovals);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatDateLabel(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dutyDate = DateTime(dt.year, dt.month, dt.day);
    
    if (dutyDate == today) return 'Today';
    if (dutyDate == today.add(const Duration(days: 1))) return 'Tomorrow';
    if (dutyDate == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return '${dt.day}/${dt.month}';
  }

  String _formatTimeLabel(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
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
              title: 'Duty roster',
              subtitle: widget.classData.name,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search duties...',
                  hintStyle: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.textSecondary,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: const Color.fromARGB(255, 25, 25, 30),
                  borderRadius: BorderRadius.circular(12),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.all(4),
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                dividerColor: Colors.transparent,
                tabs: [
                  const Tab(text: 'All Duties'),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Pending'),
                        if (_pendingApprovals.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.errorRed,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${_pendingApprovals.length}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAllDutiesTab(),
                  _buildPendingApprovalsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllDutiesTab() {
    final duties = MockData.duties;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: duties.length,
      itemBuilder: (context, index) {
        final duty = duties[index];
        final extraInfo = MockData.parseNoteField(duty.note);
        return DutyCard(
          title: duty.name,
          dateLabel: _formatDateLabel(duty.startTime),
          timeLabel: _formatTimeLabel(duty.startTime),
          ruleName: duty.ruleName,
          points: duty.points.toInt(),
          isAssignedToMonitor: index % 2 == 0,
          extraInfo: extraInfo,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DutyDetailsScreen(duty: {
                  'title': duty.name,
                  'description': duty.description ?? '',
                  'dateLabel': _formatDateLabel(duty.startTime),
                  'timeLabel': _formatTimeLabel(duty.startTime),
                  'ruleName': duty.ruleName,
                  'points': duty.points.toInt(),
                }),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPendingApprovalsTab() {
    if (_pendingApprovals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: AppColors.successGreen.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No pending approvals',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'All submissions have been reviewed',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _pendingApprovals.length,
      itemBuilder: (context, index) {
        final approval = _pendingApprovals[index];
        return PendingApprovalCard(
          memberName: approval['memberName'] as String,
          memberAvatar: approval['memberAvatar'] as String,
          dutyTitle: approval['dutyTitle'] as String,
          submittedAt: approval['submittedAt'] as String,
          proofImageUrl: approval['proofImageUrl'] as String?,
          onApprove: () {
            setState(() {
              _pendingApprovals.removeAt(index);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Submission approved'),
                backgroundColor: AppColors.successGreen,
                duration: Duration(milliseconds: 1300),
              ),
            );
          },
          onReject: () {
            setState(() {
              _pendingApprovals.removeAt(index);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Submission rejected'),
                backgroundColor: AppColors.errorRed,
                duration: Duration(milliseconds: 1300),
              ),
            );
          },
        );
      },
    );
  }
}
