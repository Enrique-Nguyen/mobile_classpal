import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_header.dart';
import '../../../../core/models/class.dart';
import '../../../../core/models/member.dart';
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

  final List<Map<String, dynamic>> _duties = [
    {
      'title': 'Clean Whiteboard',
      'description': 'Clean the whiteboard after each class session.',
      'dateLabel': 'Today',
      'timeLabel': '14:00',
      'ruleName': 'Classroom Maintenance',
      'ruleId': '1',
      'points': 12,
      'isAssignedToMonitor': true,
    },
    {
      'title': 'Arrange seating grid',
      'description': 'Arrange desks and chairs according to the seating plan.',
      'dateLabel': 'Tomorrow',
      'timeLabel': '10:00',
      'ruleName': 'Seating Arrangement',
      'ruleId': '5',
      'points': 15,
      'isAssignedToMonitor': false,
    },
    {
      'title': 'Attendance scan',
      'description': 'Scan attendance at the start of class.',
      'dateLabel': 'Yesterday',
      'timeLabel': '08:00',
      'ruleName': 'Attendance',
      'ruleId': '2',
      'points': 20,
      'isAssignedToMonitor': true,
    },
    {
      'title': 'Collect homework',
      'description': 'Collect homework assignments from all students.',
      'dateLabel': 'Dec 12',
      'timeLabel': '09:00',
      'ruleName': 'Homework Collection',
      'ruleId': '3',
      'points': 10,
      'isAssignedToMonitor': false,
    },
    {
      'title': 'Water plants',
      'description': 'Water all plants in the classroom.',
      'dateLabel': 'Dec 13',
      'timeLabel': '07:30',
      'ruleName': 'Plant Care',
      'ruleId': '4',
      'points': 8,
      'isAssignedToMonitor': false,
    },
  ];

  final List<Map<String, dynamic>> _pendingApprovals = [
    {
      'memberName': 'Nguyen Van A',
      'memberAvatar': '',
      'dutyTitle': 'Clean Whiteboard',
      'submittedAt': '2 hours ago',
      'proofImageUrl': '',
    },
    {
      'memberName': 'Tran Thi B',
      'memberAvatar': '',
      'dutyTitle': 'Arrange seating grid',
      'submittedAt': '5 hours ago',
      'proofImageUrl': '',
    },
    {
      'memberName': 'Le Van C',
      'memberAvatar': '',
      'dutyTitle': 'Water plants',
      'submittedAt': 'Yesterday',
      'proofImageUrl': '',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
            // Header - dynamic subtitle
            CustomHeader(
              title: 'Danh sách nhiệm vụ',
              subtitle: widget.classData.name,
            ),
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm...',
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
            // Tab bar
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
                  const Tab(text: 'Nhiệm vụ'),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Đang chờ'),
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
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: All Duties
                  _buildAllDutiesTab(),
                  // Tab 2: Pending Approvals
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
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _duties.length,
      itemBuilder: (context, index) {
        final duty = _duties[index];
        return DutyCard(
          title: duty['title'] as String,
          dateLabel: duty['dateLabel'] as String,
          timeLabel: duty['timeLabel'] as String,
          ruleName: duty['ruleName'] as String,
          points: duty['points'] as int,
          isAssignedToMonitor: duty['isAssignedToMonitor'] as bool,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DutyDetailsScreen(duty: duty),
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
            // Handle approve action
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
            // Handle reject action
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
