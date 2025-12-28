import 'package:flutter/material.dart';
import 'package:mobile_classpal/core/constants/app_colors.dart';
import 'package:mobile_classpal/core/models/class.dart';
import 'package:mobile_classpal/core/models/member.dart';
import '../widgets/dashboard_leaderboard.dart';
import '../widgets/dashboard_notifications.dart';
import '../widgets/dashboard_recent.dart';
import '../widgets/dashboard_rules.dart';
import '../widgets/dashboard_header.dart';

class DashboardScreen extends StatelessWidget {
  final Class classData;
  final Member currentMember;

  const DashboardScreen({
    super.key,
    required this.classData,
    required this.currentMember,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(child: DashboardHeader(
            className: classData.name,
            role: currentMember.role.displayName,
            displayName: currentMember.name,
            classData: classData,
            currentMember: currentMember,
          )),
          // Content
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  DashboardNotifications(
                    classId: classData.classId,
                    uid: currentMember.uid,
                  ),
                  const SizedBox(height: 32),

                  DashboardRules(isAdmin: currentMember.role != MemberRole.thanhVien, classData: classData),
                  const SizedBox(height: 32),

                  DashboardLeaderboard(
                    classData: classData,
                    currentMember: currentMember,
                  ),
                  const SizedBox(height: 32),

                  DashboardRecentActivities(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
