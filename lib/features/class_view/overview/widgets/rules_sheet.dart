import 'package:flutter/material.dart';
import 'package:mobile_classpal/core/constants/app_colors.dart';
import 'package:mobile_classpal/core/models/class.dart';
import 'package:mobile_classpal/core/models/rule.dart';
import '../services/rule_service.dart';
import 'create_rule_screen.dart';

void showRulesSheet(BuildContext context, {required bool isAdmin, required Class classData}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => RulesSheet(isAdmin: isAdmin, classData: classData),
  );
}

class RulesSheet extends StatefulWidget {
  final bool isAdmin;
  final Class classData;

  const RulesSheet({super.key, required this.isAdmin, required this.classData});

  @override
  State<RulesSheet> createState() => _RulesSheetState();
}

class _RulesSheetState extends State<RulesSheet> {
  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.rule_folder_rounded,
                      color: AppColors.primaryBlue,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Quy tắc tính điểm',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    // Add button (only for admins)
                    if (widget.isAdmin)
                      GestureDetector(
                        onTap: () => _showAddRuleDialog(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: AppColors.primaryBlue,
                            size: 20,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Minimal page indicator tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: _buildTabItem(label: 'Nhiệm vụ', index: 0),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _buildTabItem(label: 'Sự kiện', index: 1),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _buildTabItem(label: 'Quỹ', index: 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Page view content
              Expanded(
                child: StreamBuilder<List<Rule>>(
                  stream: RuleService.getRules(widget.classData.classId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting)
                      return const Center(child: CircularProgressIndicator());
                    if (snapshot.hasError)
                      return Center(child: Text('Lỗi: ${snapshot.error}'));
                    
                    final allRules = snapshot.data ?? [];
                    List<Rule> dutyRules = [], eventRules = [], fundRules = [];
                    for (var rule in allRules) {
                      switch (rule.type) {
                        case RuleType.duty:
                          dutyRules.add(rule);
                          break;
                        case RuleType.event:
                          eventRules.add(rule);
                          break;
                        case RuleType.fund:
                          fundRules.add(rule);
                          break;
                      }
                    }

                    return IndexedStack(
                      index: _currentTabIndex,
                      children: [
                        _buildRulesList(type: RuleType.duty, rules: dutyRules),
                        _buildRulesList(type: RuleType.event, rules: eventRules),
                        _buildRulesList(type: RuleType.fund, rules: fundRules),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabItem({required String label, required int index}) {
    final isSelected = _currentTabIndex == index;
    return GestureDetector(
      onTap: () {
        if (isSelected) return;
        setState(() => _currentTabIndex = index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? AppColors.primaryBlue : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 3,
            width: isSelected ? (MediaQuery.of(context).size.width / 2) : 0,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRulesList({required RuleType type, required List<Rule> rules}) {
    if (rules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIconForType(type),
              size: 48,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 12),
            Text(
              'Chưa có quy tắc nào',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox.expand(
      child: ListView.builder(
        // physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: rules.length,
        itemBuilder: (context, index) {
          return _buildRuleCard(rules[index], type);
        },
      ),
    );
  }

  Widget _buildRuleCard(Rule rule, RuleType type) {
    final iconColor = _getColorForType(type);
    final icon = _getIconForType(type);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
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
          // Category icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          // Rule info (different layout for admin vs member)
          Expanded(
            child: widget.isAdmin
                ? _buildAdminLayout(rule)
                : _buildMemberLayout(rule),
          ),
          // Edit icon (only for admins)
          if (widget.isAdmin)
            GestureDetector(
              onTap: () => _showEditRuleDialog(context, rule),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          // Points badge for members (right side)
          if (!widget.isAdmin) _buildPointsBadge(rule.points),
        ],
      ),
    );
  }

  // Admin layout: name + points tag below
  Widget _buildAdminLayout(Rule rule) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          rule.name,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        _buildPointsBadge(rule.points),
      ],
    );
  }

  // Member layout: just the name (points on right side via parent)
  Widget _buildMemberLayout(Rule rule) {
    return Text(
      rule.name,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildPointsBadge(double points) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.bgGreenLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '+${points.toInt()} điểm',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.successGreen,
        ),
      ),
    );
  }

  IconData _getIconForType(RuleType type) {
    switch (type) {
      case RuleType.duty:
        return Icons.assignment_outlined;
      case RuleType.event:
        return Icons.event_outlined;
      case RuleType.fund:
        return Icons.account_balance_wallet_outlined;
    }
  }

  Color _getColorForType(RuleType type) {
    switch (type) {
      case RuleType.duty:
        return AppColors.primaryBlue;
      case RuleType.event:
        return Colors.purple;
      case RuleType.fund:
        return AppColors.warningOrange;
    }
  }

  void _showAddRuleDialog(BuildContext context) {
    Navigator.pop(context); // Close sheet first
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateRuleScreen(classData: widget.classData),
      ),
    );
  }

  void _showEditRuleDialog(BuildContext context, Rule rule) {
    Navigator.pop(context); // Close sheet first
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateRuleScreen(
          classData: widget.classData,
          existingRule: rule,
        ),
      ),
    );
  }
}
