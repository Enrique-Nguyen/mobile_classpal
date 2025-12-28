import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_classpal/features/class_view/overview/screens/dashboard_screen.dart';
import 'package:mobile_classpal/features/class_view/overview/screens/profile_screen.dart';
import 'package:mobile_classpal/features/class_view/workflow/screens/duties_screen.dart';
import 'package:mobile_classpal/features/class_view/workflow/screens/tasks_screen.dart';
import 'package:mobile_classpal/features/class_view/workflow/screens/events_screen.dart';
import 'package:mobile_classpal/features/class_view/workflow/screens/funds_screen.dart';
import '../constants/app_colors.dart';
import '../models/class.dart';
import '../models/member.dart';
import '../models/class_view_arguments.dart';
import '../providers/member_provider.dart';

class ClassViewNavigation extends ConsumerStatefulWidget {
  final ClassViewArguments arguments;

  const ClassViewNavigation({super.key, required this.arguments});

  @override
  ConsumerState<ClassViewNavigation> createState() => _ClassViewNavigationState();
}

class _ClassViewNavigationState extends ConsumerState<ClassViewNavigation> {
  int _currentIndex = 0;
  MemberRole? _previousRole;
  bool _hasShownKickedDialog = false;
  bool _hasShownDissolutionDialog = false;
  bool _memberWasLoaded = false;

  Class get classData => widget.arguments.classData;
  Member get initialMember => widget.arguments.member;

  @override
  Widget build(BuildContext context) {
    final memberAsync = ref.watch(
      MemberProvider.currentMemberStreamProvider((classId: classData.classId, uid: initialMember.uid)),
    );
    
    final classExistsAsync = ref.watch(
      MemberProvider.classExistsStreamProvider(classData.classId),
    );
    classExistsAsync.whenData((exists) {
      if (!exists && !_hasShownDissolutionDialog) {
        _hasShownDissolutionDialog = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showDissolutionDialog();
        });
      }
    });

    return memberAsync.when(
      loading: () => _buildContent(initialMember),
      error: (error, stack) => _buildContent(initialMember),
      data: (member) {
        if (member == null) {
          if (_memberWasLoaded && !_hasShownKickedDialog) {
            _hasShownKickedDialog = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showKickedDialog();
            });
          }
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        _memberWasLoaded = true;

        if (_previousRole != null && _previousRole != member.role) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showRoleChangeNotification(member.role);
          });
        }

        _previousRole = member.role;
        return _buildContent(member);
      },
    );
  }

  Widget _buildContent(Member currentMember) {
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

  void _showKickedDialog() {
    if (!mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Bạn đã bị mời ra khỏi lớp'),
        content: Text(classData.name),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pushNamedAndRemoveUntil('/home_page', (r) => false);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showDissolutionDialog() {
    if (!mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Lớp đã được giải tán'),
        content: Text(classData.name),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pushNamedAndRemoveUntil('/home_page', (r) => false);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showRoleChangeNotification(MemberRole newRole) {
    if (!mounted) return;
    final String message;
    final IconData icon;
    final Color backgroundColor;
    
    switch (newRole) {
      case MemberRole.quanLyLop:
        message = 'Bạn đã được thăng cấp thành Quản lý lớp!';
        icon = Icons.star;
        backgroundColor = Colors.amber.shade600;
        break;
      case MemberRole.canBoLop:
        message = 'Bạn đã được thăng cấp thành Cán bộ lớp!';
        icon = Icons.trending_up;
        backgroundColor = Colors.blue.shade600;
        break;
      case MemberRole.thanhVien:
        message = 'Vai trò của bạn đã được cập nhật thành Thành viên';
        icon = Icons.info_outline;
        backgroundColor = Colors.grey.shade600;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
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
