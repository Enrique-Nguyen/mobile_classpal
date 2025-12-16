import 'package:flutter/material.dart';
import 'package:mobile_classpal/core/constants/app_colors.dart';
import 'package:mobile_classpal/core/widgets/custom_header.dart';
import 'package:mobile_classpal/core/models/class.dart';
import 'package:mobile_classpal/core/models/member.dart';
import 'package:mobile_classpal/core/constants/mock_data.dart';
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

class _DutiesScreenMonitorState extends State<DutiesScreenMonitor> {
  int _selectedTabIndex = 0;
  String _searchQuery = '';
  late List<Map<String, dynamic>> _pendingApprovals;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pendingApprovals = List.from(MockData.pendingApprovals);
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

  // Get filtered duties based on search query
  List<dynamic> get _filteredDuties {
    final duties = MockData.duties;
    if (_searchQuery.isEmpty) return duties;
    
    return duties.where((duty) {
      return duty.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  // Get filtered pending approvals based on search query (duty name OR member name)
  List<Map<String, dynamic>> get _filteredPendingApprovals {
    if (_searchQuery.isEmpty) return _pendingApprovals;
    
    return _pendingApprovals.where((approval) {
      final dutyMatch = (approval['dutyTitle'] as String).toLowerCase().contains(_searchQuery.toLowerCase());
      final memberMatch = (approval['memberName'] as String).toLowerCase().contains(_searchQuery.toLowerCase());
      return dutyMatch || memberMatch;
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
            // Fixed header only
            CustomHeader(
              title: 'Duty roster',
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
                    ..._buildDutiesList()
                  else
                    ..._buildPendingApprovalsList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _searchQuery = value),
      decoration: InputDecoration(
        hintText: _selectedTabIndex == 0 
            ? 'Search duties...' 
            : 'Search by duty or member name...',
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
                child: Row(
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
                    if (_pendingApprovals.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDutiesList() {
    final duties = _filteredDuties;
    
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
    
    return duties.asMap().entries.map((entry) {
      final index = entry.key;
      final duty = entry.value;
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
              builder: (context) => DutyDetailsScreen(
                duty: {
                  'title': duty.name,
                  'description': duty.description ?? '',
                  'dateLabel': _formatDateLabel(duty.startTime),
                  'timeLabel': _formatTimeLabel(duty.startTime),
                  'ruleName': duty.ruleName,
                  'points': duty.points.toInt(),
                },
                isAdmin: widget.currentMember.role != MemberRole.thanhVien,
                isAssignedToAdmin: index % 2 == 0,
              ),
            ),
          );
        },
      );
    }).toList();
  }

  List<Widget> _buildPendingApprovalsList() {
    final approvals = _filteredPendingApprovals;
    
    if (approvals.isEmpty) {
      return [
        _buildEmptyState(
          icon: _searchQuery.isEmpty ? Icons.check_circle_outline : Icons.search_off,
          iconColor: _searchQuery.isEmpty ? AppColors.successGreen : null,
          title: _searchQuery.isEmpty ? 'No pending approvals' : 'No matching approvals',
          subtitle: _searchQuery.isEmpty 
              ? 'All submissions have been reviewed'
              : 'Try searching by duty or member name',
        ),
      ];
    }

    return approvals.asMap().entries.map((entry) {
      final index = entry.key;
      final approval = entry.value;
      
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
    }).toList();
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
