import 'package:flutter/material.dart';
import 'package:mobile_classpal/core/constants/app_colors.dart';
import 'package:mobile_classpal/core/widgets/custom_header.dart';
import '../../../../core/models/class.dart';
import '../../../../core/models/member.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_classpal/features/main_view/services/class_service.dart';

class ProfileScreen extends StatelessWidget {
  final Class classData;
  final Member currentMember;
  static final ClassService _classService = ClassService();

  const ProfileScreen({
    super.key,
    required this.classData,
    required this.currentMember,
  });
  bool get _isManager => currentMember.role.displayName == "Quản lý lớp";
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(title: "Trang cá nhân", subtitle: classData.name),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: const Color(0xFF4682A9),
                      child: Text(
                        currentMember.name.isNotEmpty
                            ? currentMember.name.substring(0, 1).toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      currentMember.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        currentMember.role.displayName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSummaryProfile(
                          point: "320",
                          subtitle: "Điểm",
                          icon: Icons.emoji_events_outlined,
                          iconColor: Colors.orange,
                        ),
                        const SizedBox(width: 10),
                        _buildSummaryProfile(
                          point: "24",
                          subtitle: "Nhiệm vụ",
                          icon: Icons.access_time,
                          iconColor: Colors.green,
                        ),
                        const SizedBox(width: 10),
                        _buildSummaryProfile(
                          point: "8",
                          subtitle: "Sự kiện",
                          icon: Icons.calendar_today,
                          iconColor: Colors.purple,
                        ),
                      ],
                    ),
                    // const SizedBox(height: 10),
                    // _buildPersonalInformation(),
                    // const SizedBox(height: 10),
                    // _buildClassID(context),
                    // const SizedBox(height: 10),
                    // _buildAchievements(),
                    const SizedBox(height: 15),
                    _buildMembersAccessButton(context),

                    const SizedBox(height: 15),
                    _buildPersonalInformation(),
                    const SizedBox(height: 15),
                    _buildClassID(context),
                    const SizedBox(height: 30),
                    _buildFooterActions(context),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassID(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
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
          const Text(
            "ID LỚP HỌC",
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textGrey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Mã lớp
                Expanded(
                  child: Text(
                    classData.joinCode,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    _showQRCodeDialog(context, classData.joinCode);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.qr_code_2,
                          color: AppColors.bannerBlue,
                          size: 24,
                        ),
                        SizedBox(width: 4),
                        Text(
                          "Mã QR",
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.bannerBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Hàm hiển thị Dialog chứa QR Code
  void _showQRCodeDialog(BuildContext context, String code) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Dialog chỉ to vừa nội dung
              children: [
                const Text(
                  "Quét để tham gia",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                QrImageView(
                  data: code,
                  version: QrVersions.auto,
                  size: 200.0,
                  backgroundColor: Colors.white,
                ),
                const SizedBox(height: 20),
                Text(
                  code,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.grey.shade100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Đóng",
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPersonalInformation() {
    return Container(
      padding: const EdgeInsets.all(15),
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
          const Text(
            "THÔNG TIN CÁ NHÂN",
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textGrey,
              fontWeight: FontWeight.bold,
            ),
          ),
          _buildDetailInformation(
            icon: Icons.person_outlined,
            subtitle: "Tên hiển thị",
            title: currentMember.name,
            iconColor: Colors.blue,
          ),
          _buildDetailInformation(
            icon: Icons.class_outlined,
            subtitle: "Lớp",
            title: classData.name,
            iconColor: Colors.orange,
          ),
          _buildDetailInformation(
            icon: Icons.calendar_month,
            subtitle: "Ngày vào lớp",
            title:
                currentMember.joinedAt.day.toString().padLeft(2, '0') +
                '/' +
                currentMember.joinedAt.month.toString().padLeft(2, '0') +
                '/' +
                currentMember.joinedAt.year.toString(),
            iconColor: Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailInformation({
    required IconData icon,
    required String subtitle,
    required String title,
    required Color iconColor,
  }) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: iconColor.withOpacity(0.1),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textGrey,
                    ),
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Inter",
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMemberStat({
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
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
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textGrey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryProfile({
    required String point,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
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
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersAccessButton(BuildContext context) {
    return InkWell(
      onTap: () => _showMembersModal(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "THÀNH VIÊN LỚP",
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textGrey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.textGrey,
                ),
              ],
            ),
            const SizedBox(height: 15),
            StreamBuilder<MemberCounts>(
              stream: _classService.getClassMemberCountsStream(
                classData.classId,
              ),
              builder: (context, snapshot) {
                final counts = snapshot.data ?? const MemberCounts.empty();

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMemberStat(
                      subtitle: "Sĩ số: ${counts.total}",
                      icon: Icons.groups_outlined,
                      iconColor: AppColors.primaryBlue,
                    ),
                    const SizedBox(width: 10),
                    _buildMemberStat(
                      subtitle: "Cán bộ: ${counts.canBos}",
                      icon: Icons.shield_outlined,
                      iconColor: Colors.orange,
                    ),
                    const SizedBox(width: 10),
                    _buildMemberStat(
                      subtitle: "Quản lý: ${counts.managers}",
                      icon: Icons.settings_accessibility,
                      iconColor: Colors.purple,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Hàm hiển thị Modal Danh sách thành viên
  void _showMembersModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      // backgroundColor: Colors.back,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Modal Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Danh sách thành viên",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: StreamBuilder<List<Member>>(
                // Giả định bạn đã viết hàm trả về Stream trong service
                stream: _classService.getClassMembersStream(classData.classId),
                builder: (context, snapshot) {
                  // 1. Xử lý lỗi trước
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('Lỗi: ${snapshot.error}'),
                      ),
                    );
                  }

                  // 2. Xử lý trạng thái đang tải (chỉ hiện khi chưa có data)
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // 3. Lấy dữ liệu
                  final members = snapshot.data ?? [];

                  // 4. Xử lý danh sách rỗng
                  if (members.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('Chưa có thành viên nào'),
                      ),
                    );
                  }

                  // 5. Hiển thị danh sách (Code UI giữ nguyên)
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      final m = members[index];
                      return Card(
                        color: AppColors.background,
                        margin: const EdgeInsets.only(bottom: 10),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: ListTile(
                          leading: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              CircleAvatar(
                                radius: 25,
                                backgroundColor: Colors.grey.shade400,
                                child: Text(
                                  m.name.isNotEmpty
                                      ? m.name[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18, // Cỡ chữ vừa phải
                                    color: Colors.black54,
                                  ),
                                ),
                              ),

                              if (m.role.displayName == "Quản lý lớp")
                                Positioned(
                                  right: -1,
                                  bottom: -1,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.key,
                                      color: Color(0xFFFFB800),
                                      size: 15,
                                    ),
                                  ),
                                ),
                              if (m.role.displayName == "Cán bộ lớp")
                                Positioned(
                                  right: -1,
                                  bottom: -1,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.key,
                                      color: Colors.grey,
                                      size: 15,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          title: Text(
                            m.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(m.role.displayName),

                          trailing: _isManager && m.role != MemberRole.quanLyLop
                              ? PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert),
                                  onSelected: (value) {
                                    Navigator.pop(context);
                                    print(
                                      "Selected action: $value for user ${m.name}",
                                    );
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'promote',
                                      child: Text("Bổ nhiệm Cán bộ"),
                                    ),
                                    const PopupMenuItem(
                                      value: 'demote',
                                      child: Text("Cắt chức Cán bộ"),
                                    ),
                                    const PopupMenuItem(
                                      value: 'transfer',
                                      child: Text("Chuyển quyền Quản lý"),
                                    ),
                                    const PopupMenuItem(
                                      value: 'kick',
                                      child: Text(
                                        "Mời ra khỏi lớp",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                )
                              : null,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.red.withOpacity(0.5)),
                ),
              ),
              child: const Text(
                "Rời khỏi lớp học",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          if (_isManager) ...[
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.red.shade50,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Giải tán / Xóa lớp học",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
