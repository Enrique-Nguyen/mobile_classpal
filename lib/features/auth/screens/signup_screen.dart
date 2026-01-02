import 'package:flutter/material.dart';
import 'package:mobile_classpal/core/constants/app_colors.dart';
import 'package:mobile_classpal/features/auth/services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  static const Color kErrorColor = Color(0xFFD57662);

  @override
  void dispose() {
    // Dispose tất cả controller
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBackButton(context, AppColors.textGrey.withOpacity(0.2)),
                const Padding(padding: EdgeInsets.all(15)),
                const Text(
                  "Đăng ký tài khoản",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Inter',
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const Text(
                  "Tạo tài khoản để quản lý với ClassPal",
                  style: TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30),
                      const Text(
                        "Họ và tên",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController, // Gán controller
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Vui lòng nhập họ tên';
                          return null;
                        },
                        decoration: _buildInputDecoration(
                          hint: 'Lê Đức Nguyên',
                          icon: Icons.person_outlined,
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        "Email",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController, // Gán controller
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Vui lòng nhập Email';
                          final emailRegex = RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          );
                          if (!emailRegex.hasMatch(value))
                            return 'Email không hợp lệ';
                          return null;
                        },
                        decoration: _buildInputDecoration(
                          hint: 'hello@world.com',
                          icon: Icons.mail_outline,
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        "Mật khẩu",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        obscuringCharacter: '●',
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Vui lòng nhập mật khẩu';
                          if (value.length < 6)
                            return 'Mật khẩu tối thiểu 6 ký tự';
                          return null;
                        },
                        decoration: _buildInputDecoration(
                          hint: '●●●●●●●●',
                          icon: Icons.lock_outline,
                          isPassword: true,
                          obscureText: _obscurePassword,
                          onToggle: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        "Nhập lại mật khẩu",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        obscuringCharacter: '●',
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Vui lòng xác nhận mật khẩu';
                          if (value != _passwordController.text)
                            return 'Mật khẩu không trùng khớp';
                          return null;
                        },
                        decoration: _buildInputDecoration(
                          hint: '●●●●●●●●',
                          icon: Icons.lock_outline,
                          isPassword: true,
                          obscureText: _obscureConfirmPassword,
                          onToggle: () => setState(
                            () => _obscureConfirmPassword =
                                !_obscureConfirmPassword,
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),
                      // 3. Truyền các controller vào hàm build Button để xử lý Logic
                      _buildSignUpButton(
                        context,
                        _formKey,
                        _nameController,
                        _emailController,
                        _passwordController,
                      ),
                      _buildDivider(),
                      _buildGoogleButton(context),
                      _buildFooter(context),
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

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool? obscureText,
    VoidCallback? onToggle,
  }) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: AppColors.textGrey),
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(
                obscureText!
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.textGrey,
              ),
              onPressed: onToggle,
            )
          : null,
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.textGrey.withOpacity(0.5)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
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
    );
  }
}

Row _buildFooter(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text(
        "Bạn đã có tài khoản?",
        style: TextStyle(fontSize: 15, color: AppColors.textGrey),
      ),
      TextButton(
        onPressed: () => Navigator.pushNamed(context, '/signin'),
        child: const Text(
          "Đăng nhập",
          style: TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.bold,
            color: AppColors.bannerBlue,
          ),
        ),
      ),
    ],
  );
}

// Cập nhật hàm này để nhận Controller và xử lý Auth
SizedBox _buildSignUpButton(
  BuildContext context,
  GlobalKey<FormState> formKey,
  TextEditingController nameCtrl,
  TextEditingController emailCtrl,
  TextEditingController passCtrl,
) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: () async {
        if (formKey.currentState!.validate()) {
          // A. Hiển thị Loading Dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) =>
                const Center(child: CircularProgressIndicator()),
          );

          try {
            // B. Gọi Service Đăng ký
            final authService = AuthService();
            final user = await authService.signUp(
              email: emailCtrl.text.trim(),
              password: passCtrl.text.trim(),
              userName: nameCtrl.text,
            );

            if (user != null) {
              // C. Cập nhật tên hiển thị (Display Name) cho user
              await user.updateDisplayName(nameCtrl.text.trim());
              await user.reload(); // Refresh để cập nhật data mới

              // D. Tắt loading
              if (!context.mounted) return;
              Navigator.pop(context);

              // E. Thông báo thành công
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Đăng ký thành công!"),
                  backgroundColor: Colors.green,
                ),
              );

              // F. Chuyển trang
              Navigator.pushNamed(context, '/home_page');
            }
          } catch (e) {
            // G. Xử lý lỗi
            if (!context.mounted) return;
            Navigator.pop(context); // Tắt loading trước
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.toString().replaceAll("Exception: ", "")),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.bannerBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.all(18),
      ),
      child: const Text(
        "Đăng ký",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    ),
  );
}

SizedBox _buildGoogleButton(BuildContext context) {
  return SizedBox(
    width: double.infinity,
    child: OutlinedButton(
      onPressed: () async {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );
        try {
          // B. Gọi Service Đăng nhập
          final authService = AuthService();
          final user = await authService.signInWithGoogle();

          // C. Tắt loading
          if (!context.mounted) return;
          Navigator.pop(context);

          if (user != null) {
            // Đăng nhập thành công -> Chuyển trang
            Navigator.pushNamed(context, '/home_page'); // Chuyển đến trang chủ

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Đăng nhập Google thành công!"),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            // Trường hợp User bấm nút hủy (đóng cửa sổ Google mà không nhập)
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Đã hủy đăng nhập."),
                backgroundColor: Colors.orange, // Màu cam cảnh báo nhẹ
              ),
            );
          }
        } catch (e) {
          if (!context.mounted) return;
          // Quan trọng: Phải tắt loading nếu có lỗi xảy ra trước khi kịp tắt ở bước C
          // (Kiểm tra xem dialog có đang mở không để tránh pop nhầm màn hình)
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll("Exception: ", "")),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        backgroundColor: Colors.white,
        side: BorderSide(color: AppColors.textGrey.withOpacity(0.2)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.all(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/logo_google.png', width: 22, height: 22),
          const SizedBox(width: 10),
          const Text(
            "Google",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    ),
  );
}

Row _buildDivider() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Expanded(
        child: Divider(
          color: AppColors.textGrey.withOpacity(0.3),
          thickness: 1,
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Text(
          'Hoặc tiếp tục với',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textGrey.withOpacity(0.8),
          ),
        ),
      ),
      Expanded(
        child: Divider(
          color: AppColors.textGrey.withOpacity(0.3),
          thickness: 1,
        ),
      ),
    ],
  );
}

Container _buildBackButton(BuildContext context, Color borderColor) {
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
      onPressed: () => Navigator.pushNamed(context, '/welcome'),
    ),
  );
}
