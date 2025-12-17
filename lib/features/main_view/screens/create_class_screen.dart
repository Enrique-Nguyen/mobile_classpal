import 'package:flutter/material.dart';
import 'package:mobile_classpal/core/constants/app_colors.dart';

class CreateClassScreen extends StatefulWidget {
  const CreateClassScreen({super.key});

  @override
  State<CreateClassScreen> createState() => _CreateClassScreenState();
}

class _CreateClassScreenState extends State<CreateClassScreen> {
  final _formKey = GlobalKey<FormState>();

  static const Color kErrorColor = Color(0xFFD57662);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
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
                          "Tạo lớp",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          "Cài đặt lớp mới của bạn",
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
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleField("Tên lớp"),
                      const SizedBox(height: 8),
                      _buildTextField(
                        hint: "e.g. CS101-Intro to Programming",
                        errorText: "Vui lòng nhập tên lớp",
                      ),
                      const SizedBox(height: 24),
                      _buildTitleField("Tên giáo viên"),
                      const SizedBox(height: 8),
                      _buildTextField(
                        hint: "e.g. Kiều Tuấn Dũng",
                        errorText: "Vui lòng nhập tên giáo viên",
                      ),
                      const SizedBox(height: 24),
                      _buildTitleField("Lịch học"),
                      const SizedBox(height: 8),
                      _buildTextField(
                        hint: "e.g. Mon 09:00-11:00",
                        errorText: "Vui lòng nhập lịch học",
                      ),
                      const SizedBox(height: 40),
                      _buildCreateClassButton(context),
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

  Widget _buildCreateClassButton(BuildContext context) {
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
          "Tạo lớp",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
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
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
