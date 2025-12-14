import 'package:flutter/material.dart';
import 'package:mobile_classpal/core/constants/app_colors.dart';
import 'package:mobile_classpal/core/constants/mock_data.dart';
import 'package:mobile_classpal/core/models/class.dart';
import 'package:mobile_classpal/core/models/member.dart';
import 'package:mobile_classpal/core/models/class_view_arguments.dart';
import 'package:mobile_classpal/features/main_view/screens/create_class.dart';

class OptionCreateJoin {
  final String routing;
  final String title;

  OptionCreateJoin({required this.routing, required this.title});
}

final List<OptionCreateJoin> availableOptions = [
  OptionCreateJoin(routing: "/create_class", title: "Tạo lớp"),
  OptionCreateJoin(routing: "/join_class", title: "Vào lớp"),
];

class HomepageScreen extends StatelessWidget {
  const HomepageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _buildCreateJoinBotton(context),
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildHelloWelcomeClass(MockData.currentUserName),
                  _buildLogoutButton(context),
                ],
              ),
            ),
            // Section title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Lớp của bạn (${MockData.userClasses.length})",
                style: const TextStyle(
                  fontSize: 18,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Classes ListView
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: MockData.userClasses.length,
                itemBuilder: (context, index) {
                  final data = MockData.userClasses[index];
                  return _buildClassCard(
                    context: context,
                    borderColor: data.borderColor,
                    title: data.classData.name,
                    subtitle: 'Vai trò: ${data.member.role.displayName}',
                    classData: data.classData,
                    member: data.member,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  RichText _buildHelloWelcomeClass(String userName) {
    return RichText(
      text: TextSpan(
        children: [
          const TextSpan(
            text: 'Chào mừng trở lại\n',
            style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
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

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.errorRed),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: const Icon(
          Icons.logout_outlined,
          color: AppColors.errorRed,
          size: 20,
        ),
        onPressed: () {
          Navigator.pushNamed(context, '/welcome');
        },
      ),
    );
  }

  Widget _buildClassCard({
    required BuildContext context,
    required Color borderColor,
    required String title,
    required String subtitle,
    required Class classData,
    required Member member,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/class',
            arguments: ClassViewArguments(
              classData: classData,
              currentMember: member,
            ),
          );
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
}

void _buildCreateJoinBotton(BuildContext context) async {
  // Lấy vị trí nút bấm (Cần GlobalKey gắn vào nút nếu muốn chính xác, ở đây lấy tương đối)
  final RenderBox overlay =
      Overlay.of(context).context.findRenderObject() as RenderBox;

  // Hiển thị Menu
  final result = await showMenu<String>(
    context: context,
    // Căn chỉnh vị trí: Left, Top, Right, Bottom
    // Bạn cần chỉnh số 'Top' và 'Left' sao cho vừa ý với vị trí nút của bạn
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
      MaterialPageRoute(builder: (context) => CreateClassScreen()),
    );
  } else if (result == 'join') {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Placeholder()),
    );
  }
}
