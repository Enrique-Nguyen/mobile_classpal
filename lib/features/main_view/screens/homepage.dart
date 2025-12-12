import 'package:flutter/material.dart';
import 'package:mobile_classpal/core/constants/app_colors.dart';

class HomepageScreen extends StatelessWidget {
  const HomepageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _builldHelloWelcomeClass(),
                    _buildLogoutButton(context),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  "Lớp của bạn",
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
                _buildClassCard(
                  context: context,
                  borderColor: Colors.red,
                  title: 'CS101·Product Ops',
                  subtitle: 'Vai trò: Lớp trưởng',
                  // icon: Icons.warning_amber_rounded,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  RichText _builldHelloWelcomeClass() {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'Chào mừng trở lại\n',
            style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
          ),
          TextSpan(
            text: 'Lê Đức Nguyên',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

Container _buildLogoutButton(BuildContext context) {
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

  // required IconData icon,
}) {
  return Column(
    children: [
      SizedBox(height: 20),
      TextButton(
        onPressed: () {
          Navigator.pushNamed(context, '/class');
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
    ],
  );
}
