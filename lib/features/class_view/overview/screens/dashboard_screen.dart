import 'package:flutter/material.dart';
import 'package:mobile_classpal/core/constants/app_colors.dart';
import 'package:mobile_classpal/core/models/class.dart';
import 'package:mobile_classpal/core/models/member.dart';
import '../widgets/dashboard_leaderboard.dart';
import '../widgets/dashboard_notifications.dart';
import '../widgets/dashboard_rules.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/chatbot_window.dart';

class DashboardScreen extends StatefulWidget {
  final Class classData;
  final Member currentMember;

  const DashboardScreen({
    super.key,
    required this.classData,
    required this.currentMember,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isChatOpen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.fastOutSlowIn.flipped,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleChat() {
    setState(() {
      if (_isChatOpen) {
        FocusScope.of(context).unfocus();
      }
      _isChatOpen = !_isChatOpen;
      if (_isChatOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final canManage =
        widget.currentMember.role == MemberRole.quanLyLop ||
        widget.currentMember.role == MemberRole.canBoLop;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: DashboardHeader(
                  className: widget.classData.name,
                  role: widget.currentMember.role.displayName,
                  displayName: widget.currentMember.name,
                  classData: widget.classData,
                  currentMember: widget.currentMember,
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      DashboardNotifications(
                        classId: widget.classData.classId,
                        uid: widget.currentMember.uid,
                        classData: widget.classData,
                        currentMember: widget.currentMember,
                      ),
                      const SizedBox(height: 32),
                      DashboardRules(
                        isAdmin:
                            widget.currentMember.role != MemberRole.thanhVien,
                        classData: widget.classData,
                      ),
                      const SizedBox(height: 32),
                      DashboardLeaderboard(
                        classData: widget.classData,
                        currentMember: widget.currentMember,
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.1,
            bottom: 80, // Cách đáy một khoảng để nằm trên FAB
            right: 16,
            child: ScaleTransition(
              scale: _scaleAnimation,
              alignment: Alignment.bottomRight,
              child: ChatbotWindow(
                classData: widget.classData,
                currentMember: widget.currentMember,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: canManage
          ? FloatingActionButton(
              backgroundColor: AppColors.primaryBlue,
              onPressed: _toggleChat,
              child: Icon(
                _isChatOpen ? Icons.close : Icons.smart_toy,
                color: Colors.white,
              ),
            )
          : null,
    );
  }
}
