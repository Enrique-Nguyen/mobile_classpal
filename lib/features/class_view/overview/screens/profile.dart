import 'package:flutter/material.dart';
import 'package:mobile_classpal/core/constants/app_colors.dart';
import 'package:mobile_classpal/core/widgets/custom_header.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const CustomHeader(
                title: "Trang cá nhân",
                subtitle: "CS101 · Product Ops",
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Color(0xFF4682A9),
                      child: Icon(Icons.person, size: 40, color: Colors.white),
                    ),
                    SizedBox(height: 15),
                    Text(
                      "Lê Đức Nguyên",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "ID: 07092005",
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textGrey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSumaryProfile(
                          point: "320",
                          subtitle: "Điểm",
                          icon: Icons.emoji_events_outlined,
                          iconColor: Colors.orange,
                        ),
                        SizedBox(width: 10),
                        _buildSumaryProfile(
                          point: "24",
                          subtitle: "Nhiệm vụ",
                          icon: Icons.access_time,
                          iconColor: Colors.green,
                        ),
                        SizedBox(width: 10),
                        _buildSumaryProfile(
                          point: "8",
                          subtitle: "Sự kiện",
                          icon: Icons.calendar_today,
                          iconColor: Colors.purple,
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    _buildPersonalInformation(),
                    SizedBox(height: 10),
                    _buildClassCurrent(),
                    SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "THÀNH TỰU",
                            style: TextStyle(
                              fontSize: 15,
                              color: AppColors.textGrey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildAchievementsProfile(
                                subtitle: "Top 3",
                                icon: Icons.military_tech,
                                iconColor: Colors.brown,
                              ),
                              SizedBox(width: 10),
                              _buildAchievementsProfile(
                                subtitle: "Tuyệt vời",
                                icon: Icons.star_purple500_sharp,
                                iconColor: const Color.fromARGB(
                                  255,
                                  222,
                                  200,
                                  0,
                                ),
                              ),
                              SizedBox(width: 10),
                              _buildAchievementsProfile(
                                subtitle: "Lớp trưởng",
                                icon: Icons.workspace_premium,
                                iconColor: Colors.red,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container _buildClassCurrent() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "LỚP HIỆN TẠI",
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textGrey,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              'CS101-2024',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container _buildPersonalInformation() {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            "THÔNG TIN CÁ NHÂN",
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textGrey,
              fontWeight: FontWeight.bold,
            ),
          ),
          _builDetailInformation(
            icon: Icons.person_outlined,
            subtitle: "Tên hiển thị",
            title: "Lê Đức Nguyên",
            iconColor: Colors.blue,
          ),
          _builDetailInformation(
            icon: Icons.tag,
            subtitle: "ID người dùng",
            title: "07092005",
            iconColor: Colors.purple,
          ),
          _builDetailInformation(
            icon: Icons.mail,
            subtitle: "Email",
            title: "leducnguyen07092005@gmail.com",
            iconColor: Colors.green,
          ),
          _builDetailInformation(
            icon: Icons.calendar_today,
            subtitle: "Ngày vào lớp",
            title: "Lê Đức Nguyên",
            iconColor: Colors.orange,
          ),
        ],
      ),
    );
  }

  Column _builDetailInformation({
    required IconData icon,
    required String subtitle,
    required String title,
    required Color iconColor,
  }) {
    return Column(
      children: [
        SizedBox(height: 10),
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: iconColor.withOpacity(0.1),
              ),
              child: Icon(icon, color: iconColor),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Inter",
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAchievementsProfile({
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 25),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSumaryProfile({
    required String point,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 25),
            Text(
              point,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
