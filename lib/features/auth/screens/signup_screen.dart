import 'package:flutter/material.dart';
import 'package:mobile_classpal/core/constants/app_colors.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _isObscured = true;
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
                _buildBackButton(context, Colors.grey),
                Padding(padding: EdgeInsets.all(15)),
                Text(
                  "Đăng kí tài khoản",
                  style: TextStyle(
                    fontSize: 33.5,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                    color: Color(0xff1A1A2E),
                  ),
                ),
                Text(
                  "Tạo tài khoản để quản lý với ClassPal",
                  style: TextStyle(color: Color(0xFFA0A0AD), fontSize: 16.8),
                ),
                Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 30),
                      Text(
                        "Họ và tên",
                        style: TextStyle(
                          color: Color(0xFF9294A4),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.person_outlined,
                            color: Color(0xFF9294A4),
                          ),
                          hintText: 'Lê Đức Nguyên',
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF9294A4),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF9294A4),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Email",
                        style: TextStyle(
                          color: Color(0xFF9294A4),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.mail_outline,
                            color: Color(0xFF9294A4),
                          ),
                          hintText: 'hello@world.com',
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF9294A4),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF9294A4),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Mật khẩu",
                        style: TextStyle(
                          color: Color(0xFF9294A4),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextFormField(
                        obscureText: _isObscured,
                        // 4. Ký tự thay thế (Dấu chấm tròn to)
                        obscuringCharacter: '*',
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: Color(0xFF9294A4),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              // Đổi icon dựa trên trạng thái
                              _isObscured
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: const Color(0xFFA0A0AD),
                            ),
                            onPressed: () {
                              // Cập nhật lại giao diện
                              setState(() {
                                _isObscured = !_isObscured;
                              });
                            },
                          ),
                          hintText: '*********',
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF9294A4),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF9294A4),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 20),
                      _buildSignUpButton(context),
                      _buildDivider(),
                      _buildGoogleButton(),
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
}

Row _buildFooter(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        "Bạn đã có tài khoản?",
        style: TextStyle(fontSize: 15, color: Color(0xFF9294A4)),
      ),
      TextButton(
        onPressed: () {
          Navigator.pushNamed(context, '/signin');
        },
        child: Text(
          "Đăng nhập ở đây",
          style: TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.bold,
            color: Color(0xFF9294A4),
          ),
        ),
      ),
    ],
  );
}

SizedBox _buildSignUpButton(BuildContext context) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(context, '/class');
      },
      child: Text(
        "Đăng ký",
        style: TextStyle(fontSize: 17.2, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF4682A9),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: EdgeInsets.all(20),
      ),
    ),
  );
}

SizedBox _buildGoogleButton() {
  return SizedBox(
    width: double.infinity,
    child: OutlinedButton(
      onPressed: () {},
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/logo_google.png', width: 24, height: 24),
          SizedBox(width: 8),
          Text(
            "Google",
            style: TextStyle(fontSize: 17.2, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      style: ElevatedButton.styleFrom(
        // backgroundColor: Color(0xff1A1A2E),
        foregroundColor: Color(0xFF9294A4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: EdgeInsets.all(20),
      ),
    ),
  );
}

Row _buildDivider() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Expanded(child: Divider(color: Color(0xFF9294A4), thickness: 1)),
      Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Hoặc tiếp tục với',
          style: TextStyle(fontSize: 14, color: Color(0xFF9294A4)),
        ),
      ),
      Expanded(child: Divider(color: Color(0xFF9294A4), thickness: 1)),
    ],
  );
}

Container _buildBackButton(BuildContext context, Color borderColor) {
  return Container(
    width: 44,
    height: 44,
    decoration: BoxDecoration(
      border: Border.all(color: borderColor),
      borderRadius: BorderRadius.circular(12),
    ),
    child: IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
      onPressed: () {
        Navigator.pushNamed(context, '/welcome');
      },
    ),
  );
}
