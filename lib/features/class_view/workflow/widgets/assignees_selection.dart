import 'package:flutter/material.dart';
import 'package:mobile_classpal/core/models/member.dart';
import 'package:mobile_classpal/core/constants/app_colors.dart';

void showMemberSelectionSheet({
  required BuildContext context,
  required List<Member> allMembers,
  required List<Member> selectedMembers,
  required void Function(Member member) onMemberSelected,
  void Function(List<Member> members)? onSelectAll,
  List<String> excludedMemberIds = const [],
  bool closeOnSelect = false,
}) {
  String searchQuery = '';
  
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => StatefulBuilder(
      builder: (sheetContext, setSheetState) {
        final filteredMembers = allMembers.where((member) {
          final nameMatch = member.name.toLowerCase().contains(searchQuery.toLowerCase());
          final notSelected = !selectedMembers.any((m) => m.uid == member.uid);
          final notExcluded = !excludedMemberIds.contains(member.uid);
          return nameMatch && notSelected && notExcluded;
        }).toList();

        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header and search
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Chọn thành viên',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Search field
                    TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm theo tên...',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onChanged: (value) => setSheetState(() => searchQuery = value),
                    ),
                    // Select All button
                    if (filteredMembers.isNotEmpty && onSelectAll != null) ...[
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {
                          onSelectAll(filteredMembers);
                          Navigator.pop(sheetContext);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.select_all, size: 18, color: AppColors.primaryBlue),
                              const SizedBox(width: 8),
                              Text(
                                'Chọn tất cả (${filteredMembers.length})',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Member list
              Expanded(
                child: filteredMembers.isEmpty
                    ? Center(
                        child: Text(
                          searchQuery.isEmpty ? 'Tất cả thành viên đã được chọn' : 'Không tìm thấy thành viên',
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: filteredMembers.length,
                        itemBuilder: (context, index) {
                          final member = filteredMembers[index];
                          return GestureDetector(
                            onTap: () {
                              onMemberSelected(member);
                              if (closeOnSelect) {
                                Navigator.pop(sheetContext);
                              } else {
                                setSheetState(() {}); // Refresh list
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                                    backgroundImage: member.avatarUrl != null && member.avatarUrl!.isNotEmpty
                                      ? NetworkImage(member.avatarUrl!)
                                      : null,
                                    child: member.avatarUrl == null || member.avatarUrl!.isEmpty
                                      ? Text(
                                          member.name.substring(0, 1).toUpperCase(),
                                          style: const TextStyle(
                                            color: AppColors.primaryBlue,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        )
                                      : null,
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
                                          member.role.displayName,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.add_circle_outline,
                                    color: AppColors.primaryBlue,
                                    size: 22,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

/// Widget to display selected members as chips with add button
class MemberSelectionField extends StatelessWidget {
  final List<Member> selectedMembers;
  final VoidCallback onAddTap;
  final void Function(Member member) onRemoveMember;
  final VoidCallback? onRemoveAll;
  final String? label;
  final bool required;

  const MemberSelectionField({
    super.key,
    required this.selectedMembers,
    required this.onAddTap,
    required this.onRemoveMember,
    this.onRemoveAll,
    this.label,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            required ? '$label *' : label!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        // Selected members as chips
        if (selectedMembers.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: selectedMembers.map((member) {
              return Chip(
                backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                side: BorderSide.none,
                avatar: CircleAvatar(
                  backgroundColor: AppColors.primaryBlue,
                  radius: 12,
                  backgroundImage: member.avatarUrl != null && member.avatarUrl!.isNotEmpty
                    ? NetworkImage(member.avatarUrl!)
                    : null,
                  child: member.avatarUrl == null || member.avatarUrl!.isEmpty
                    ? Text(
                        member.name.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : null,
                ),
                label: Text(
                  member.name,
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                deleteIcon: const Icon(
                  Icons.close,
                  size: 16,
                  color: AppColors.primaryBlue,
                ),
                onDeleted: () => onRemoveMember(member),
              );
            }).toList(),
          ),
          // Remove All button
          if (onRemoveAll != null && selectedMembers.length > 1) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: onRemoveAll,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.errorRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.remove_circle_outline, size: 16, color: AppColors.errorRed),
                    const SizedBox(width: 6),
                    Text(
                      'Xóa tất cả (${selectedMembers.length})',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.errorRed,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
        ],
        // Add member button
        GestureDetector(
          onTap: onAddTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.person_add_outlined,
                  size: 20,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedMembers.isEmpty 
                        ? 'Thêm thành viên...'
                        : 'Thêm thành viên khác...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
                const Icon(
                  Icons.add_circle_outline,
                  size: 20,
                  color: AppColors.primaryBlue,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}