import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/class.dart';
import '../models/rule.dart';
import 'package:mobile_classpal/features/class_view/workflow/screens/create_rule_screen.dart';

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
  late PageController _pageController;

  final Map<RuleType, List<Rule>> _rulesByType = {
    RuleType.duty: [
      Rule(id: 'r1', name: 'Classroom Maintenance', type: RuleType.duty, points: 12),
      Rule(id: 'r2', name: 'Seating Arrangement', type: RuleType.duty, points: 15),
      Rule(id: 'r3', name: 'Attendance', type: RuleType.duty, points: 20),
      Rule(id: 'r4', name: 'Plant Care', type: RuleType.duty, points: 8),
      Rule(id: 'r5', name: 'Equipment Management', type: RuleType.duty, points: 15),
      Rule(id: 'r6', name: 'Homework Collection', type: RuleType.duty, points: 10),
    ],
    RuleType.event: [
      Rule(id: 'r7', name: 'Cultural Events', type: RuleType.event, points: 20),
      Rule(id: 'r8', name: 'Workshops', type: RuleType.event, points: 15),
      Rule(id: 'r9', name: 'Sports Day', type: RuleType.event, points: 18),
    ],
    RuleType.fund: [
      Rule(id: 'r10', name: 'Class Fund', type: RuleType.fund, points: 10),
      Rule(id: 'r11', name: 'Expense Tracking', type: RuleType.fund, points: 8),
    ],
  };

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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
                      'Quy tắc lớp học',
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
                  children: [
                    _buildTabItem('Nhiệm vụ', 0),
                    const SizedBox(width: 24),
                    _buildTabItem('Sự kiện', 1),
                    const SizedBox(width: 24),
                    _buildTabItem('Quỹ', 2),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Page view content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentTabIndex = index);
                  },
                  children: [
                    _buildRulesList(RuleType.duty, scrollController),
                    _buildRulesList(RuleType.event, scrollController),
                    _buildRulesList(RuleType.fund, scrollController),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabItem(String label, int index) {
    final isSelected = _currentTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _currentTabIndex = index);
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
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
            width: isSelected ? 24 : 0,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRulesList(RuleType type, ScrollController scrollController) {
    final rules = _rulesByType[type] ?? [];

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

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: rules.length,
      itemBuilder: (context, index) {
        return _buildRuleCard(rules[index], type);
      },
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
