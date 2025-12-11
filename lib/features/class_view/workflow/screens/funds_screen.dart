import 'package:flutter/material.dart';
// Import từ Core
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_header.dart';
// Import Widgets con từ module Funds
import '../widgets/fund_overview_card.dart';
import '../widgets/unpaid_members_card.dart';
import '../widgets/transaction_history_card.dart';

class ClassFundsScreen extends StatelessWidget {
  const ClassFundsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header (Dùng chung)
            const CustomHeader(
              title: "Class funds",
              subtitle: "CS101 · Product Ops",
            ),

            // 2. Nội dung chính (Cuộn được)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: const [
                    FundOverviewCard(),
                    SizedBox(height: 20),
                    UnpaidMembersCard(),
                    SizedBox(height: 20),
                    TransactionHistoryCard(),
                    SizedBox(height: 20), // Khoảng trống dưới cùng
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Giả lập BottomNav (Trong dự án thực tế, BottomNav sẽ nằm ở lớp MainWrapper ngoài cùng)
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 4, 
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: const [
           BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
           BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: "Duties"),
           BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: "Events"),
           BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: "Assets"),
           BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: "Funds"),
           BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
        ],
      ),
    );
  }
}