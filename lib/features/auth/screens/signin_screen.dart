import 'package:flutter/material.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  bool _isObscured = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffafafa),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBackButton(context, Colors.grey),
                Padding(padding: EdgeInsets.all(20)),
                Text(
                  "Chào mừng trở lại!",
                  style: TextStyle(
                    fontSize: 33.5,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                    color: Color(0xff1A1A2E),
                  ),
                ),
                Text(
                  "Đăng nhập để tiếp tục với ClassPal",
                  style: TextStyle(color: Color(0xFFA0A0AD), fontSize: 16.8),
                ),
                Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 50),
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
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            "Quên mật khẩu?",
                            style: TextStyle(color: Color(0xFF9294A4)),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      _buildSignInButton(context),
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

Row _buildFooter(context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        "Bạn là người mới?",
        style: TextStyle(fontSize: 15, color: Color(0xFF9294A4)),
      ),
      TextButton(
        onPressed: () {
          Navigator.pushNamed(context, '/signup');
        },
        child: Text(
          "Đăng ký",
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

SizedBox _buildSignInButton(BuildContext context) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(context, '/class');
      },
      child: Text(
        "Đăng nhập",
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
