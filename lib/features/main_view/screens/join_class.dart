import 'package:flutter/material.dart';
import 'package:mobile_classpal/core/constants/app_colors.dart';

class JoinClassScreen extends StatefulWidget {
  const JoinClassScreen({super.key});

  @override
  State<JoinClassScreen> createState() => _JoinClassScreenState();
}

class _JoinClassScreenState extends State<JoinClassScreen> {
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
                  children: [
                    _buildBackButton(context, AppColors.textGrey),
                    SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Vào lớp",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Nhập mã hoặc quét QR",
                          style: TextStyle(
                            fontSize: 15,
                            // fontWeight: FontWeight.bold,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      _buildTitleField("Mã lớp"),
                      _buildTextField("e.g. CS101"),
                      SizedBox(height: 20),
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

  TextFormField _buildTextField(String hint) {
    return TextFormField(
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF9294A4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF9294A4)),
        ),
      ),
    );
  }

  Text _buildTitleField(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Color(0xFF9294A4),
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
  }
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
        Navigator.pop(context);
      },
    ),
  );
}

SizedBox _buildJoinClassButton(BuildContext context) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(context, '/home_page');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF4682A9),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: EdgeInsets.all(20),
      ),
      child: Text(
        "Tạo lớp",
        style: TextStyle(fontSize: 17.2, fontWeight: FontWeight.bold),
      ),
    ),
  );
}

SizedBox _buildJoinQRButton(BuildContext context) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(context, '/home_page');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: EdgeInsets.all(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.qr_code_2, color: AppColors.textPrimary),
          SizedBox(width: 10),
          Text(
            "Quét mã QR",
            style: TextStyle(fontSize: 17.2, fontWeight: FontWeight.bold),
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
      Expanded(child: Divider(color: Color(0xFF9294A4), thickness: 1)),
      Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Hoặc',
          style: TextStyle(fontSize: 14, color: Color(0xFF9294A4)),
        ),
      ),
      Expanded(child: Divider(color: Color(0xFF9294A4), thickness: 1)),
    ],
  );
}
