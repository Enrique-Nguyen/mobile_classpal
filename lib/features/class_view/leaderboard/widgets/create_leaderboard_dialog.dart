import 'package:flutter/material.dart';
import 'package:mobile_classpal/core/constants/app_colors.dart';
import 'package:mobile_classpal/core/models/leaderboard.dart';
import 'package:mobile_classpal/features/class_view/leaderboard/services/leaderboard_service.dart';

class CreateLeaderboardDialog extends StatefulWidget {
  final String classId;
  final Leaderboard? existingLeaderboard;
  final VoidCallback onCreated;

  const CreateLeaderboardDialog({
    super.key,
    required this.classId,
    this.existingLeaderboard,
    required this.onCreated,
  });

  @override
  State<CreateLeaderboardDialog> createState() => _CreateLeaderboardDialogState();
}

class _CreateLeaderboardDialogState extends State<CreateLeaderboardDialog> {
  late TextEditingController _nameController;
  bool _isLoading = false;

  bool get isEditing => widget.existingLeaderboard != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.existingLeaderboard?.name ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(
            isEditing ? Icons.edit : Icons.add_circle_outline,
            color: AppColors.primaryBlue,
            size: 24,
          ),
          const SizedBox(width: 10),
          Text(
            isEditing ? 'Sửa bảng xếp hạng' : 'Tạo bảng xếp hạng mới',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Nhập tên bảng xếp hạng',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primaryBlue,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
          if (!isEditing) ...[
            const SizedBox(height: 12),
            Text(
              'Bảng xếp hạng mới sẽ trở thành bảng hiện tại',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text(
            'Hủy',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  isEditing ? 'Lưu' : 'Tạo',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (isEditing) {
        await LeaderboardService.updateLeaderboardName(
          widget.classId,
          widget.existingLeaderboard!.id,
          name,
        );
      } else {
        await LeaderboardService.createLeaderboard(widget.classId, name);
      }

      widget.onCreated();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
