import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_classpal/core/constants/app_colors.dart';
import 'package:mobile_classpal/core/models/class.dart';
import 'package:mobile_classpal/core/models/member.dart';
import 'package:mobile_classpal/core/models/rule.dart';
import 'package:mobile_classpal/features/class_view/overview/services/rule_service.dart';
import '../services/duty_service.dart';
import '../widgets/assignees_selection.dart';

class CreateDutyScreen extends ConsumerStatefulWidget {
  final Class classData;
  final Member currentMember;

  const CreateDutyScreen({
    super.key,
    required this.classData,
    required this.currentMember,
  });

  @override
  ConsumerState<CreateDutyScreen> createState() => _CreateDutyScreenState();
}

class _CreateDutyScreenState extends ConsumerState<CreateDutyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ruleNoteController = TextEditingController();
  
  DateTime _selectedDateTime = DateTime.now().add(const Duration(hours: 1));
  DateTime _selectedDeadline = DateTime.now().add(const Duration(days: 1)); // Default: 1 day from now
  Rule? _selectedRule;
  final List<Member> _selectedMembers = [];
  bool _isLoading = false;

  Stream<List<Member>> get _membersStream => FirebaseFirestore.instance
    .collection('classes')
    .doc(widget.classData.classId)
    .collection('members')
    .snapshots()
    .map((snapshot) => snapshot.docs.map((doc) => Member.fromMap(doc.data())).toList());

  Stream<List<Rule>> get _rulesStream => RuleService.getRules(widget.classData.classId)
    .map((rules) => rules.where((r) => r.type == RuleType.duty).toList());

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _ruleNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFC),
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        centerTitle: true,
        title: Column(
          children: [
            const Text(
              'Tạo nhiệm vụ mới',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              widget.classData.name,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.grey.shade200,
            height: 1,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('TÊN NHIỆM VỤ'),
              const SizedBox(height: 8),
              _buildInputField(
                controller: _titleController,
                hint: 'Ví dụ: Lau bảng sau giờ học',
                validator: (value) => value?.isEmpty ?? true
                  ? 'Vui lòng nhập tên nhiệm vụ'
                  : null,
              ),
              const SizedBox(height: 12),
              _buildSectionTitle('MÔ TẢ'),
              const SizedBox(height: 8),
              _buildInputField(
                controller: _descriptionController,
                hint: 'Mô tả chi tiết về nhiệm vụ...',
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('NGƯỜI THỰC HIỆN'),
              const SizedBox(height: 8),
              StreamBuilder<List<Member>>(
                stream: _membersStream,
                builder: (context, snapshot) {
                  final allMembers = snapshot.data ?? [];
                  return MemberSelectionField(
                    label: null,
                    required: true,
                    selectedMembers: _selectedMembers,
                    onAddTap: () => showMemberSelectionSheet(
                      context: context,
                      allMembers: allMembers, // Pass real members
                      selectedMembers: _selectedMembers,
                      onMemberSelected: (member) {
                        setState(() {
                          if (!_selectedMembers.any((m) => m.uid == member.uid)) {
                            _selectedMembers.add(member);
                          }
                        });
                      },
                    ),
                    onRemoveMember: (member) {
                      setState(() {
                        _selectedMembers.removeWhere((m) => m.uid == member.uid);
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 24),
              _buildRuleSectionTitle(),
              const SizedBox(height: 8),
              StreamBuilder<List<Rule>>(
                stream: _rulesStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return const Center(child: CircularProgressIndicator());

                  final rules = snapshot.data ?? [];
                  if (_selectedRule == null && rules.isNotEmpty)
                    _selectedRule = rules.first;

                  return _buildRuleSelector(rules);
                },
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('THỜI GIAN BẮT ĐẦU'),
              const SizedBox(height: 8),
              _buildDateTimePicker(
                value: _selectedDateTime,
                onPick: () => _pickDateTime(isDeadline: false),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('THỜI HẠN (DEADLINE)'),
              const SizedBox(height: 8),
              _buildDateTimePicker(
                value: _selectedDeadline,
                onPick: () => _pickDateTime(isDeadline: true),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Tạo nhiệm vụ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade500,
        letterSpacing: 1.2,
      ),
    );
  }


  Widget _buildInputField({
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryBlue),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.errorRed),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRuleSelector(List<Rule> rules) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Rule>(
              value: _selectedRule,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
              onChanged: (Rule? newValue) {
                if (newValue != null && _selectedRule != newValue) {
                  setState(() => _selectedRule = newValue);
                }
              },
              items: rules.map<DropdownMenuItem<Rule>>((Rule rule) {
                return DropdownMenuItem<Rule>(
                  value: rule,
                  child: Text(
                    rule.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        if (_selectedRule != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.bgGreenLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.stars_rounded, size: 18, color: AppColors.successGreen),
                const SizedBox(width: 8),
                Text(
                  'Điểm thưởng: +${_selectedRule!.points.toInt()} điểm',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.successGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRuleSectionTitle() {
    return Row(
      children: [
        _buildSectionTitle('QUY TẮC TÍNH ĐIỂM'),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: _showRulesHelpDialog,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.help_outline_rounded,
              size: 14,
              color: AppColors.primaryBlue,
            ),
          ),
        ),
      ],
    );
  }

  void _showRulesHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.rule_folder_rounded, color: AppColors.primaryBlue),
            const SizedBox(width: 10),
            const Text('Quy tắc tính điểm'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quy tắc tính điểm xác định số điểm thành viên nhận được khi hoàn thành nhiệm vụ này.',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            SizedBox(height: 12),
            Text(
              '• Điểm được cộng vào bảng xếp hạng lớp\n• Mỗi quy tắc có mức điểm khác nhau\n• Quản trị viên có thể tạo quy tắc mới từ Tổng quan',
              style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.6),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đã hiểu'),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimePicker({
    required DateTime value,
    required VoidCallback onPick,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onPick,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.event,
                  size: 20,
                  color: AppColors.primaryBlue,
                ),
                const SizedBox(width: 12),
                Text(
                  _formatDateTime(value),
                  style: const TextStyle(fontSize: 14),
                ),
                const Spacer(),
                Icon(
                  Icons.edit_calendar,
                  size: 18,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDateTime({required bool isDeadline}) async {
    final currentValue = isDeadline ? _selectedDeadline : _selectedDateTime;
    final date = await showDatePicker(
      context: context,
      initialDate: currentValue,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(currentValue),
    );
    if (time == null) return;

    final newDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      if (isDeadline)
        _selectedDeadline = newDateTime;
      else
        _selectedDateTime = newDateTime;
    });
  }

  String _formatDateTime(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year;
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day/$month/$year lúc $hour:$minute';
  }

  Future<void> _submitForm() async {
    if (_selectedMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ít nhất một thành viên'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedRule == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng chọn hoặc tạo một quy tắc'),
            backgroundColor: AppColors.errorRed,
          ),
        );
        return;
      }
      setState(() => _isLoading = true);
      try {
        await DutyService.createDuty(
          classId: widget.classData.classId,
          name: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty 
              ? null 
              : _descriptionController.text.trim(),
          startTime: _selectedDateTime,
          endTime: _selectedDeadline,
          ruleName: _selectedRule!.name,
          points: _selectedRule!.points,
          assignees: _selectedMembers,
        );

        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã tạo nhiệm vụ thành công!'),
            backgroundColor: AppColors.successGreen,
          ),
        );
        Navigator.pop(context);
      }
      catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
      finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }
}
