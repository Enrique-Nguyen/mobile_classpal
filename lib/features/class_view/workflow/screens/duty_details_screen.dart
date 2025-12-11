import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Sample rule data - will be replaced by actual Rules module
class DutyRule {
  final String id;
  final String name;
  final int points;

  const DutyRule({required this.id, required this.name, required this.points});
}

/// Sample assignee data
class DutyAssignee {
  final String id;
  final String name;
  final String avatar;
  final String status; // 'pending', 'completed', 'overdue'
  final String? completedAt;

  const DutyAssignee({
    required this.id,
    required this.name,
    this.avatar = '',
    required this.status,
    this.completedAt,
  });
}

class DutyDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> duty;

  const DutyDetailsScreen({super.key, required this.duty});

  @override
  State<DutyDetailsScreen> createState() => _DutyDetailsScreenState();
}

class _DutyDetailsScreenState extends State<DutyDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late String _selectedRuleId;

  // Sample rules - will come from Rules module
  final List<DutyRule> _availableRules = const [
    DutyRule(id: '1', name: 'Classroom Maintenance', points: 12),
    DutyRule(id: '2', name: 'Attendance', points: 20),
    DutyRule(id: '3', name: 'Homework Collection', points: 10),
    DutyRule(id: '4', name: 'Plant Care', points: 8),
    DutyRule(id: '5', name: 'Seating Arrangement', points: 15),
  ];

  // Sample assignees
  final List<DutyAssignee> _assignees = const [
    DutyAssignee(
      id: '1',
      name: 'Nguyen Van A',
      status: 'completed',
      completedAt: 'Dec 10, 14:30',
    ),
    DutyAssignee(id: '2', name: 'Tran Thi B', status: 'pending'),
    DutyAssignee(id: '3', name: 'Le Van C', status: 'overdue'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _titleController = TextEditingController(text: widget.duty['title'] ?? '');
    _descriptionController = TextEditingController(
      text: widget.duty['description'] ?? 'No description provided.',
    );
    _selectedRuleId = widget.duty['ruleId'] ?? '1';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  DutyRule get _selectedRule =>
      _availableRules.firstWhere((r) => r.id == _selectedRuleId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Custom header with back button (like Create/Edit Post)
            _buildHeader(),
            // Tab bar
            _buildTabBar(),
            const SizedBox(height: 8),
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildEditTab(), _buildAssigneesTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back,
                size: 20,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Edit Duty',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  widget.duty['title'] ?? 'Untitled',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Save button
          ElevatedButton(
            onPressed: _saveDuty,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Save',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        dividerColor: Colors.transparent,
        tabs: [
          const Tab(text: 'Duty Info'),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Assignees'),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_assignees.length}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title field
          _buildLabel('Title'),
          _buildTextField(_titleController, 'Enter duty title'),
          const SizedBox(height: 20),
          // Description field
          _buildLabel('Description'),
          _buildTextField(
            _descriptionController,
            'Enter description',
            maxLines: 4,
          ),
          const SizedBox(height: 20),
          // Start time
          _buildLabel('Start Time'),
          _buildInfoCard(
            icon: Icons.access_time,
            text: '${widget.duty['dateLabel']} · ${widget.duty['timeLabel']}',
            onTap: () {
              // TODO: Show time picker
            },
          ),
          const SizedBox(height: 20),
          // Rule selection
          _buildLabel('Rule'),
          _buildRuleDropdown(),
          const SizedBox(height: 12),
          // Points display
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgGreenLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: AppColors.successGreen, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Points for this duty: ',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
                Text(
                  '+${_selectedRule.points}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.successGreen,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildAssigneesTab() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _assignees.length,
      itemBuilder: (context, index) {
        final assignee = _assignees[index];
        return _buildAssigneeCard(assignee);
      },
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String text,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primaryBlue),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedRuleId,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: _availableRules.map((rule) {
            return DropdownMenuItem<String>(
              value: rule.id,
              child: Row(
                children: [
                  const Icon(
                    Icons.label_outline,
                    size: 18,
                    color: AppColors.warningOrange,
                  ),
                  const SizedBox(width: 8),
                  Text(rule.name),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.bgGreenLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '+${rule.points}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.successGreen,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedRuleId = value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildAssigneeCard(DutyAssignee assignee) {
    Color statusColor;
    Color statusBgColor;
    String statusText;

    switch (assignee.status) {
      case 'completed':
        statusColor = AppColors.successGreen;
        statusBgColor = AppColors.bgGreenLight;
        statusText = 'Completed';
        break;
      case 'overdue':
        statusColor = AppColors.errorRed;
        statusBgColor = AppColors.bgRedLight;
        statusText = 'Overdue';
        break;
      default:
        statusColor = AppColors.warningOrange;
        statusBgColor = AppColors.bgOrangeLight;
        statusText = 'Pending';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.bgBlueLight,
            child: Text(
              assignee.name.isNotEmpty ? assignee.name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Name and completion info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assignee.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (assignee.completedAt != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Completed: ${assignee.completedAt}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveDuty() {
    // Handle save
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Duty saved successfully'),
        backgroundColor: AppColors.successGreen,
        duration: Duration(milliseconds: 1300),
      ),
    );
    Navigator.of(context).pop();
  }
}
