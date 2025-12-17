import 'package:flutter/material.dart';
import 'package:mobile_classpal/core/constants/app_colors.dart';

class JoinClassScreen extends StatefulWidget {
  const JoinClassScreen({super.key});

  @override
  State<JoinClassScreen> createState() => _JoinClassScreenState();
}

class _JoinClassScreenState extends State<JoinClassScreen> {
  // 1. Khai báo Key để quản lý Validation
  final _formKey = GlobalKey<FormState>();

  // Màu lỗi đồng bộ theo yêu cầu
  static const Color kErrorColor = Color(0xFFD57662);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24), // Đồng bộ padding 24
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildBackButton(
                      context,
                      AppColors.textGrey.withOpacity(0.2),
                    ),
                    const SizedBox(width: 20),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Vào lớp",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          "Nhập mã hoặc quét QR",
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Form(
                  key: _formKey, // Gán key vào Form
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleField("Mã lớp"),
                      const SizedBox(height: 8),
                      _buildTextField(
                        hint: "e.g. CS101",
                        errorText: "Vui lòng nhập mã lớp",
                      ),
                      const SizedBox(height: 30),
                      _buildJoinClassButton(context),
                      _buildDivider(),
                      _buildJoinQRButton(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget TextField đồng bộ style ClassPal
  Widget _buildTextField({required String hint, required String errorText}) {
    return TextFormField(
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return errorText;
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.textGrey.withOpacity(0.5)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.textGrey.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.bannerBlue, width: 1.5),
        ),
        // Style trạng thái lỗi (0xFFD57662)
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: kErrorColor, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: kErrorColor, width: 1.5),
        ),
        errorStyle: const TextStyle(color: kErrorColor, fontSize: 12),
      ),
    );
  }

  Widget _buildTitleField(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // Nút chính: Vào lớp
  Widget _buildJoinClassButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            Navigator.pushNamed(context, '/home_page');
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.bannerBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(18),
        ),
        child: const Text(
          "Vào lớp",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  // Nút phụ: Quét mã QR (Style Outlined hiện đại)
  Widget _buildJoinQRButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          // Logic quét mã QR sẽ thêm sau
          Navigator.pushNamed(context, '/home_page');
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.textGrey.withOpacity(0.2)),
          foregroundColor: AppColors.textPrimary,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(18),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.qr_code_scanner_rounded, size: 22),
            SizedBox(width: 10),
            Text(
              "Quét mã QR",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Divider(
            color: AppColors.textGrey.withOpacity(0.2),
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Text(
            'Hoặc',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textGrey.withOpacity(0.6),
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: AppColors.textGrey.withOpacity(0.2),
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildBackButton(BuildContext context, Color borderColor) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(14),
      ),
      child: IconButton(
        icon: const Icon(
          Icons.arrow_back,
          color: AppColors.textPrimary,
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }
}
