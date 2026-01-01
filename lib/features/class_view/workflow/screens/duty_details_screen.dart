import 'package:flutter/material.dart';
import 'package:mobile_classpal/core/constants/app_colors.dart';
import 'package:mobile_classpal/core/models/duty.dart';
import 'package:mobile_classpal/core/models/member.dart';
import 'package:mobile_classpal/core/models/task.dart';
import 'package:mobile_classpal/core/models/rule.dart';
import 'package:mobile_classpal/core/helpers/duty_helper.dart';
import 'package:mobile_classpal/features/class_view/overview/services/rule_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/assignees_selection.dart';
import 'package:mobile_classpal/features/class_view/workflow/services/duty_service.dart';

class DutyDetailsScreen extends StatefulWidget {
  final Duty duty;
  final bool isAdmin;
  final Task? task;
  final bool isAssignedToAdmin;

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
  late double _selectedPoints;
  DateTime _selectedDateTime = DateTime.now();

  bool _isSubmitting = false;

  final List<Member> _selectedMembers = [];
  final Set<String> _removedMemberIds = {};

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.duty.name);
    _descriptionController = TextEditingController(text: widget.duty.description ?? '');
    _selectedRule = widget.duty.ruleName;
    _selectedPoints = widget.duty.points.toDouble();
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
                widget.duty.name,
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

                  // Proof/Action Section
                  if (_shouldShowActionSection()) ...[
                    _buildActionSection(),
                    const SizedBox(height: 20),
                  ],

                  SizedBox(height: (widget.isAdmin ? 80 : 20)),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActionBar(),
    );
  }

  bool _shouldShowActionSection() {
    if (widget.task == null || _memberTaskStatus != TaskStatus.incomplete)
      return false;
    if (widget.isAdmin && widget.isAssignedToAdmin)
      return true;
    if (!widget.isAdmin)
      return true;

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
            label: 'Ngày bắt đầu',
            value: _formatDate(widget.duty.startTime),
            onEdit: widget.isAdmin ? () => _editDateTime() : null,
          ),
          const Divider(height: 24),
          _buildInfoRow(
            icon: Icons.timer_off_outlined,
            label: 'Thời hạn (Deadline)',
            value: '${_formatDate(widget.duty.endTime)} lúc ${_formatTime(widget.duty.endTime)}',
            iconColor: widget.duty.isExpired ? AppColors.errorRed : AppColors.primaryBlue,
            onEdit: null,
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
            value: '+${_selectedPoints.toInt()} điểm',
            iconColor: Colors.orange,
            onEdit: null,
          ),
          // Origin-specific info (location for events, amount for funds)
          if (DutyHelper.parseNoteField(widget.duty) != null) ...[
            const Divider(height: 24),
            Builder(builder: (context) {
              final extraInfo = DutyHelper.parseNoteField(widget.duty)!;
              return _buildInfoRow(
                icon: extraInfo.icon,
                label: extraInfo.label,
                value: extraInfo.value,
                iconColor: extraInfo.type == DutyExtraType.location 
                    ? Colors.teal 
                    : Colors.green,
                onEdit: null,
              );
            }),
          ],
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
            _descriptionController.text.isNotEmpty ? _descriptionController.text : 'Không có mô tả',
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
    final classId = widget.duty.classId;
    final dutyId = widget.duty.id;
    final assigneeIds = List<String>.from(widget.duty.assigneeIds);

    return StreamBuilder<List<Member>>(
      stream: FirebaseFirestore.instance
        .collection('classes')
        .doc(classId)
        .collection('members')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Member.fromMap(doc.data())).toList()),
      builder: (context, membersSnapshot) {
        final allMembers = membersSnapshot.data ?? [];
        
        return StreamBuilder<List<Task>>(
          stream: DutyService.streamDutyTasks(classId, dutyId),
          builder: (context, tasksSnapshot) {
            final tasks = tasksSnapshot.data ?? [];
            final memberTasks = {for (var t in tasks) t.uid: t};

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
                          const Icon(
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
                        onTap: () => _showMemberSelectionSheet(allMembers),
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
                  
                  // Display assigned members with their task status
                  if (assigneeIds.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text("Chưa có ai được phân công", style: TextStyle(color: AppColors.textSecondary)),
                    ),

                  ...assigneeIds.map((uid) {
                    final member = allMembers.firstWhere(
                      (m) => m.uid == uid, 
                      orElse: () => Member(uid: uid, name: 'Unknown', classId: classId, role: MemberRole.thanhVien, joinedAt: DateTime.now(), updatedAt: DateTime.now())
                    );
                    final task = memberTasks[uid];
                    
                    return _buildAssigneeRow(member, task);
                  }),

                  // Selected members to be added (new)
                  if (_selectedMembers.isNotEmpty) ...[
                    const Divider(),
                    const Text('Đang chọn:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    ..._selectedMembers.map((member) => _buildSelectedMemberRow(member)),
                  ],
                ],
              ),
            );
          }
        );
      },
    );
  }

  Widget _buildAssigneeRow(Member member, Task? task) {
    IconData statusIcon = Icons.radio_button_unchecked;
    Color statusColor = AppColors.textSecondary;
    String statusText = 'Chưa nhận';

    if (task != null) {
      switch (task.status) {
        case TaskStatus.completed:
          statusIcon = Icons.check_circle;
          statusColor = AppColors.successGreen;
          statusText = 'Hoàn thành';
          break;
        case TaskStatus.pending:
          statusIcon = Icons.hourglass_top;
          statusColor = Colors.orange;
          statusText = 'Chờ duyệt';
          break;
        case TaskStatus.incomplete:
          statusIcon = Icons.error_outline;
          statusColor = AppColors.errorRed;
          statusText = 'Chưa hoàn thành';
          break;
      }
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          if (widget.isAdmin && task != null) // Admin controls
             if (task.status == TaskStatus.pending)
               PopupMenuButton<String>(
                icon: Icon(statusIcon, size: 20, color: statusColor),
                onSelected: (value) {
                  if (value == 'approve') {
                    DutyService.updateTaskStatus(
                      classId: widget.duty.classId,
                      dutyId: widget.duty.id,
                      taskId: task.id,
                      newStatus: TaskStatus.completed,
                    );
                  } else if (value == 'reject') {
                    DutyService.updateTaskStatus(
                      classId: widget.duty.classId,
                      dutyId: widget.duty.id,
                      taskId: task.id,
                      newStatus: TaskStatus.incomplete,
                    );
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'approve', child: Text('Duyệt / Hoàn thành')),
                  const PopupMenuItem(value: 'reject', child: Text('Từ chối / Chưa xong')),
                ],
              )
             else
               Icon(statusIcon, size: 20, color: statusColor)
          else
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

  Widget _buildActionSection() {
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
              const Icon(
                Icons.check_circle_outline,
                size: 20,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(width: 8),
              const Text(
                'Hành động',
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
            'Xác nhận hoàn thành nhiệm vụ này?',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
           SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : () async {
                setState(() => _isSubmitting = true);
                try {
                  if (widget.task == null) return;
                    await DutyService.updateTaskStatus(
                    classId: widget.duty.classId,
                    dutyId: widget.duty.id,
                    taskId: widget.task!.id,
                    newStatus: TaskStatus.pending,
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã gửi xác nhận!")));
                    Navigator.pop(context);
                  }
                }
                finally {
                  if (mounted) setState(() => _isSubmitting = false);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: _isSubmitting 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.check, color: Colors.white),
              label: Text(
                _isSubmitting ? 'ĐANG GỬI...' : 'ĐÁNH DẤU LÀ XONG',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildBottomActionBar() {
    if (!widget.isAdmin)
      return null;

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
      child: SafeArea(child: _buildAdminBottomBar()),
    );
  }

  Widget _buildAdminBottomBar() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // End Duty button (if not already ended)
        if (!widget.duty.isEnded)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _showEndDutyConfirmation,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.errorRed,
                side: const BorderSide(color: AppColors.errorRed),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'KẾT THÚC NHIỆM VỤ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        if (!widget.duty.isEnded)
          const SizedBox(height: 12),
        // Save Changes button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _saveChanges,
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
        ),
      ],
    );
  }

  Future<void> _showEndDutyConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kết thúc nhiệm vụ?'),
        content: const Text(
          'Những thành viên chưa hoàn thành sẽ bị trừ điểm. Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.errorRed),
            child: const Text('Kết thúc'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await DutyService.endDuty(
          classId: widget.duty.classId,
          dutyId: widget.duty.id,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã kết thúc nhiệm vụ'),
              backgroundColor: AppColors.successGreen,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: $e'),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
      }
    }
  }

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

            const SizedBox(height: 16),
            StreamBuilder<List<Rule>>(
              stream: RuleService.getRules(widget.duty.classId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return const Center(child: CircularProgressIndicator());

                final rules = snapshot.data?.where((r) => r.type == RuleType.duty).toList() ?? [];
                if (rules.isEmpty)
                  return const Text("No rules found");

                return Column(
                  children: rules.map((rule) => ListTile(
                    title: Text(rule.name),
                    subtitle: Text('+${rule.points.toInt()} pts'),
                    trailing: _selectedRule == rule.name ? const Icon(Icons.check, color: AppColors.primaryBlue) : null,
                    onTap: () {
                      setState(() {
                        _selectedRule = rule.name;
                        _selectedPoints = rule.points;
                      });
                      Navigator.pop(context);
                    },
                  )).toList(),
                );
              },
            ),

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

  void _showMemberSelectionSheet(List<Member> allMembers) {
    showMemberSelectionSheet(
      context: context,
      allMembers: allMembers,
      selectedMembers: _selectedMembers,
      excludedMemberIds: (List<String>.from(widget.duty.assigneeIds))..addAll(_selectedMembers.map((m) => m.uid)),
      closeOnSelect: false, 
      onMemberSelected: (member) {
        setState(() => _selectedMembers.add(member));
      },
    );
  }

  Future<void> _saveChanges() async {
    final List<Member> finalMembers = [];
    for (final id in widget.duty.assigneeIds) {
      if (!_removedMemberIds.contains(id)) {
        finalMembers.add(Member(
          uid: id, 
          classId: widget.duty.classId, 
          name: '', 
          role: MemberRole.thanhVien, 
          joinedAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
      }
    }

    finalMembers.addAll(_selectedMembers);
    await DutyService.updateDuty(
      classId: widget.duty.classId,
      dutyId: widget.duty.id,
      name: _titleController.text != widget.duty.name ? _titleController.text : null,
      description: _descriptionController.text != widget.duty.description ? _descriptionController.text : null,
      startTime: _selectedDateTime != widget.duty.startTime ? _selectedDateTime : null,
      ruleName: _selectedRule != widget.duty.ruleName ? _selectedRule : null,
      points: _selectedPoints != widget.duty.points ? _selectedPoints : null,
      newAssignees: finalMembers,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã lưu thay đổi!')));
      Navigator.pop(context);
    }
  }
}
