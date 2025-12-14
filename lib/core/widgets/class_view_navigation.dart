import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/class_view_arguments.dart';
import '../models/class.dart';
import '../models/member.dart';
import '../../features/class_view/overview/screens/dashboard.dart';
import '../../features/class_view/overview/screens/profile.dart';
import '../../features/class_view/workflow/screens/duties_screen.dart';
import '../../features/class_view/workflow/screens/tasks_screen.dart';
import '../../features/class_view/workflow/screens/events_screen.dart';
import '../../features/class_view/workflow/screens/funds_screen.dart';

class ClassViewNavigation extends StatefulWidget {
  final ClassViewArguments arguments;

  const ClassViewNavigation({super.key, required this.arguments});

  @override
  State<ClassViewNavigation> createState() => _ClassViewNavigationState();
}

class _ClassViewNavigationState extends State<ClassViewNavigation> {
  int _currentIndex = 0;

  Class get classData => widget.arguments.classData;
  Member get currentMember => widget.arguments.currentMember;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      DashboardScreen(classData: classData, currentMember: currentMember),
      (currentMember.role == MemberRole.thanhVien)
          ? TasksScreenMember(classData: classData, currentMember: currentMember)
          : DutiesScreenMonitor(classData: classData, currentMember: currentMember),
      EventsScreenContent(classData: classData, currentMember: currentMember),
      ClassFundsScreenContent(classData: classData, currentMember: currentMember),
      ProfileScreen(classData: classData, currentMember: currentMember),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  0,
                  Icons.home_outlined,
                  Icons.home,
                  'Home',
                ),
                _buildNavItem(
                  1,
                  Icons.assignment_outlined,
                  Icons.assignment,
                  "Duties",
                ),
                _buildNavItem(
                  2,
                  Icons.calendar_today_outlined,
                  Icons.calendar_today,
                  'Events',
                ),
                _buildNavItem(
                  3,
                  Icons.account_balance_wallet_outlined,
                  Icons.account_balance_wallet,
                  'Funds',
                ),
                _buildNavItem(
                  4,
                  Icons.person_outline,
                  Icons.person,
                  'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData outlinedIcon,
    IconData filledIcon,
    String label,
  ) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.bgBlueLight : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? filledIcon : outlinedIcon,
              color: isSelected ? AppColors.primaryBlue : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primaryBlue : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
