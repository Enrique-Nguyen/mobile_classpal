import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_classpal/core/models/class_model.dart';
import 'package:mobile_classpal/core/models/member_model.dart';
import 'package:mobile_classpal/core/constants/app_colors.dart';
import 'package:mobile_classpal/features/auth/providers/auth_provider.dart';
import '../providers/class_provider.dart';
import 'create_class_screen.dart';
import 'join_class_screen.dart';

class UserClassData {
  final ClassModel classModel;
  final MemberModel member;
  final Color borderColor;

  UserClassData({
    required this.classModel,
    required this.member,
    required this.borderColor,
  });
}

class HomepageScreen extends ConsumerWidget {
  const HomepageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(AuthStateProvider.currentUserProvider)?.uid;
    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text("Vui lòng đăng nhập lại")),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _buildCreateJoinBotton(context),
        backgroundColor: AppColors.bannerBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER: LỜI CHÀO ---
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                    _buildHelloWelcomeClass(ref.watch(AuthStateProvider.currentUserProvider)?.displayName ?? "Bạn"),
                    _buildLogoutButton(context, ref),
                  ],
                ),
              ),

              // --- DANH SÁCH LỚP HỌC ---
              Expanded(
                child: Consumer(
                  builder: (context, ref, child) {
                    final classesAsync = ref.watch(userClassesProvider);
                    
                    return classesAsync.when(
                      data: (classes) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                "Lớp của bạn (${classes.length})",
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: AppColors.textGrey,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: classes.isEmpty
                                  ? _buildEmptyState()
                                  : ListView.builder(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                      itemCount: classes.length,
                                      itemBuilder: (context, index) {
                                        final data = classes[index];
                                        return _buildClassCard(
                                          context: context,
                                          ref: ref,
                                          borderColor: data.borderColor,
                                          title: data.classModel.name,
                                          subtitle: 'Vai trò: ${data.member.role}',
                                          classModel: data.classModel,
                                        );
                                      },
                                    ),
                            ),
                          ],
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, stack) => Center(child: Text("Lỗi: $e")),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.class_outlined, size: 60, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "Bạn chưa tham gia lớp nào",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  RichText _buildHelloWelcomeClass(String userName) {
    return RichText(
      text: TextSpan(
        children: [
          const TextSpan(
            text: 'Chào mừng trở lại\n',
            style: TextStyle(fontSize: 15, color: AppColors.textGrey),
          ),
          TextSpan(
            text: userName,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: const Icon(Icons.logout_outlined, color: Colors.red, size: 20),
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/welcome',
              (route) => false,
            );
          }
        },
      ),
    );
  }

  Widget _buildClassCard({
    required BuildContext context,
    required WidgetRef ref,
    required Color borderColor,
    required String title,
    required String subtitle,
    required ClassModel classModel,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextButton(
        onPressed: () {
          ref.read(selectedClassIdProvider.notifier).setSelectedClassId(classModel.classId);
          // Navigator.pushNamed(context, '/class_detail', arguments: classModel);
        },
        style: TextButton.styleFrom(padding: EdgeInsets.zero),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border(left: BorderSide(color: borderColor, width: 4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E1E2D),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.person, color: borderColor, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  void _buildCreateJoinBotton(BuildContext context) async {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(
          overlay.size.width - 100,
          overlay.size.height - 200,
          100,
          100,
        ),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(
          value: 'create',
          child: Row(
            children: const [
              Icon(Icons.group_add),
              SizedBox(width: 8),
              Text(
                "Tạo lớp",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'join',
          child: Row(
            children: const [
              Icon(Icons.qr_code_2),
              SizedBox(width: 8),
              Text(
                "Vào lớp",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (result == 'create') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CreateClassScreen()),
      );
    } else if (result == 'join') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const JoinClassScreen()),
      );
    }
  }
}
