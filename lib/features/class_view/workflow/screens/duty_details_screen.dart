import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:mobile_classpal/core/constants/app_colors.dart';
import 'package:mobile_classpal/core/constants/mock_data.dart';
import 'package:mobile_classpal/core/models/member.dart';
import 'package:mobile_classpal/core/models/task.dart';
import '../widgets/assignees_selection.dart';

/// Assignee model with status
class DutyAssignee {
  final String id;
  final String name;
  final String avatar;
  final String status;
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
  final bool isAdmin;
  final Task? task; // For member view, pass the task
  final bool isAssignedToAdmin; // If admin is also assigned to this duty

  const DutyDetailsScreen({
    super.key,
    required this.duty,
    this.isAdmin = true,
    this.task,
    this.isAssignedToAdmin = false,
  });

  @override
  State<DutyDetailsScreen> createState() => _DutyDetailsScreenState();
}

class _DutyDetailsScreenState extends State<DutyDetailsScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late String _selectedRule;
  DateTime _selectedDateTime = DateTime.now();
  File? _proofImage;
  bool _isSubmitting = false;

  final List<Member> _selectedMembers = [];

  // Sample assignees
  final List<DutyAssignee> _assignees = const [
    DutyAssignee(
      id: '1',
      name: 'Nguyen Van A',
      status: 'completed',
      completedAt: 'Dec 10, 14:30',
    ),
    DutyAssignee(id: '2', name: 'Tran Thi B', status: 'pending'),
    DutyAssignee(id: '3', name: 'Le Van C', status: 'incomplete'),
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.duty['title'] ?? '');
    _descriptionController = TextEditingController(
      text: widget.duty['description'] ?? '',
    );
    _selectedRule = widget.duty['ruleName'] ?? MockData.ruleOptions.first;
    _initializeDateTime();
  }

  void _initializeDateTime() {
    _selectedDateTime = DateTime.now().add(const Duration(hours: 2));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Get task status for member view
  TaskStatus get _memberTaskStatus {
    return widget.task?.status ?? TaskStatus.incomplete;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Gradient App Bar (matching event details screen)
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primaryBlue,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.duty['title'] ?? 'Untitled',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryBlue,
                      AppColors.primaryBlue.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.assignment,
                    size: 80,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge
                  _buildStatusBadge(),
                  const SizedBox(height: 20),

                  // Info Card
                  _buildInfoCard(),
                  const SizedBox(height: 20),

                  // Description Section
                  _buildDescriptionSection(),
                  const SizedBox(height: 20),

                  // Assignees Section (Admin only)
                  if (widget.isAdmin) ...[
                    _buildAssigneesSection(),
                    const SizedBox(height: 20),
                  ],

                  // Proof Section (Member with incomplete status OR Admin if assigned)
                  if (_shouldShowProofSection()) ...[
                    _buildProofSection(),
                    const SizedBox(height: 20),
                  ],

                  const SizedBox(height: 80), // Space for bottom bar
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActionBar(),
    );
  }

  bool _shouldShowProofSection() {
    if (widget.isAdmin && widget.isAssignedToAdmin) {
      return true;
    }
    if (!widget.isAdmin && _memberTaskStatus == TaskStatus.incomplete) {
      return true;
    }
    return false;
  }

  Widget _buildStatusBadge() {
    Color color;
    String label;
    IconData icon;

    if (widget.isAdmin) {
      color = AppColors.primaryBlue;
      label = 'Quản lý nhiệm vụ';
      icon = Icons.admin_panel_settings;
    }
    else {
      switch (_memberTaskStatus) {
        case TaskStatus.completed:
          color = AppColors.successGreen;
          label = 'Hoàn thành';
          icon = Icons.check_circle;
          break;
        case TaskStatus.pending:
          color = Colors.orange;
          label = 'Đang chờ duyệt';
          icon = Icons.hourglass_top;
          break;
        case TaskStatus.incomplete:
          color = AppColors.errorRed;
          label = 'Chưa hoàn thành';
          icon = Icons.radio_button_unchecked;
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
        children: [
          _buildInfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Ngày',
            value: _formatDate(_selectedDateTime),
            onEdit: widget.isAdmin ? () => _editDateTime() : null,
          ),
          const Divider(height: 24),
          _buildInfoRow(
            icon: Icons.access_time_outlined,
            label: 'Thời gian',
            value: _formatTime(_selectedDateTime),
            onEdit: widget.isAdmin ? () => _editDateTime() : null,
          ),
          const Divider(height: 24),
          _buildInfoRow(
            icon: Icons.bookmark_outline,
            label: 'Quy tắc',
            value: _selectedRule,
            onEdit: widget.isAdmin ? () => _editRule() : null,
          ),
          const Divider(height: 24),
          _buildInfoRow(
            icon: Icons.star_outline,
            label: 'Điểm thưởng',
            value: '+${MockData.rulePoints[_selectedRule] ?? 10} điểm',
            iconColor: Colors.orange,
            onEdit: null, // Points are determined by rule
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? iconColor,
    VoidCallback? onEdit,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (iconColor ?? AppColors.primaryBlue).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: iconColor ?? AppColors.primaryBlue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        if (onEdit != null)
          GestureDetector(
            onTap: onEdit,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.edit_outlined,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Icon(
                Icons.description_outlined,
                size: 20,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Mô tả nhiệm vụ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (widget.isAdmin)
                GestureDetector(
                  onTap: _editDescription,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _descriptionController.text.isNotEmpty
                ? _descriptionController.text
                : 'Không có mô tả',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssigneesSection() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 20,
                    color: AppColors.primaryBlue,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Người được phân công',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _showMemberSelectionSheet,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 16, color: AppColors.primaryBlue),
                      SizedBox(width: 4),
                      Text(
                        'Thêm',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Assignee list with status icons
          ..._assignees.map((assignee) => _buildAssigneeRow(assignee)),
          // Selected members (new)
          ..._selectedMembers.map((member) => _buildSelectedMemberRow(member)),
        ],
      ),
    );
  }

  Widget _buildAssigneeRow(DutyAssignee assignee) {
    IconData statusIcon;
    Color statusColor;

    switch (assignee.status) {
      case 'completed':
        statusIcon = Icons.check_circle;
        statusColor = AppColors.successGreen;
        break;
      case 'pending':
        statusIcon = Icons.hourglass_top;
        statusColor = Colors.orange;
        break;
      default:
        statusIcon = Icons.cancel;
        statusColor = AppColors.errorRed;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                assignee.name.isNotEmpty ? assignee.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assignee.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (assignee.completedAt != null)
                  Text(
                    'Hoàn tất: ${assignee.completedAt}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          Icon(statusIcon, size: 20, color: statusColor),
        ],
      ),
    );
  }

  Widget _buildSelectedMemberRow(Member member) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              member.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _selectedMembers.remove(member)),
            child: const Icon(Icons.close, size: 20, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildProofSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Icon(
                Icons.camera_alt_outlined,
                size: 20,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(width: 8),
              const Text(
                'Minh chứng hoàn thành',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Đính kèm ảnh minh chứng để hoàn thành nhiệm vụ',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          if (_proofImage != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Image.file(
                    _proofImage!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => setState(() => _proofImage = null),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Row(
              children: [
                Expanded(child: _buildImagePickerButton(
                  icon: Icons.photo_library_outlined,
                  label: 'Thư viện',
                  onTap: _pickImage,
                )),
                const SizedBox(width: 12),
                Expanded(child: _buildImagePickerButton(
                  icon: Icons.camera_alt_outlined,
                  label: 'Chụp ảnh',
                  onTap: _takePhoto,
                )),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImagePickerButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primaryBlue.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: AppColors.primaryBlue),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: widget.isAdmin
            ? _buildAdminBottomBar()
            : _buildMemberBottomBar(),
      ),
    );
  }

  Widget _buildAdminBottomBar() {
    // Show Save button, and Submit Proof if admin is assigned
    if (widget.isAssignedToAdmin) {
      return Row(
        children: [
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _saveDuty,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.successGreen,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'LƯU',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _proofImage != null ? _submitProof : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                disabledBackgroundColor: AppColors.primaryBlue.withOpacity(0.3),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'GỬI DUYỆT',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Just Save button for admin
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveDuty,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.successGreen,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
          'LƯU THAY ĐỔI',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildMemberBottomBar() {
    // Status-based button for member
    switch (_memberTaskStatus) {
      case TaskStatus.incomplete:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isSubmitting ? null : _submitProof,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : const Icon(Icons.send, color: Colors.white),
            label: Text(
              _isSubmitting ? 'ĐANG GỬI...' : 'GỬI MINH CHỨNG',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: Colors.white,
              ),
            ),
          ),
        );

      case TaskStatus.pending:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEFF2F7),
              disabledBackgroundColor: const Color(0xFFEFF2F7),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.hourglass_top, color: Colors.orange),
            label: const Text(
              'ĐANG CHỜ DUYỆT',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: Colors.orange,
              ),
            ),
          ),
        );

      case TaskStatus.completed:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.successGreen.withOpacity(0.1),
              disabledBackgroundColor: AppColors.successGreen.withOpacity(0.1),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.check_circle, color: AppColors.successGreen),
            label: const Text(
              'ĐÃ HOÀN THÀNH',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: AppColors.successGreen,
              ),
            ),
          ),
        );
    }
  }

  // Helper methods
  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  // Edit actions
  void _editDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );
    if (time == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        date.year, date.month, date.day, time.hour, time.minute,
      );
    });
  }

  void _editRule() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Chọn quy tắc',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            ...MockData.ruleOptions.map((rule) => ListTile(
              title: Text(rule),
              trailing: _selectedRule == rule
                  ? const Icon(Icons.check, color: AppColors.primaryBlue)
                  : null,
              onTap: () {
                setState(() => _selectedRule = rule);
                Navigator.pop(context);
              },
            )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _editDescription() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Chỉnh sửa mô tả',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                maxLines: 4,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Nhập mô tả...',
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {});
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Xong', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Member selection
  void _showMemberSelectionSheet() {
    showMemberSelectionSheet(
      context: context,
      selectedMembers: _selectedMembers,
      excludedMemberIds: _assignees.map((a) => a.id).toList(),
      closeOnSelect: false, // Keep sheet open for multiple selections
      onMemberSelected: (member) {
        setState(() => _selectedMembers.add(member));
      },
    );
  }

  // Image picker
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _proofImage = File(picked.path));
    }
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() => _proofImage = File(picked.path));
    }
  }

  // Save/Submit actions
  void _saveDuty() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã lưu thay đổi!'),
        backgroundColor: AppColors.successGreen,
        duration: Duration(milliseconds: 1300),
      ),
    );
    Navigator.of(context).pop();
  }

  void _submitProof() {
    if (_proofImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đính kèm ảnh minh chứng'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã gửi minh chứng thành công!'),
            backgroundColor: AppColors.successGreen,
          ),
        );
        Navigator.pop(context);
      }
    });
  }
}
