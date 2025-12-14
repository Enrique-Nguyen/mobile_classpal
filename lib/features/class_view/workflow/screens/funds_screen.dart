import 'package:flutter/material.dart';
// Import từ Core
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_header.dart';
import '../../../../core/models/class.dart';
import '../../../../core/models/member.dart';
// Import Widgets con từ module Funds
import '../widgets/fund_overview_card.dart';
import '../widgets/unpaid_members_card.dart';
import '../widgets/transaction_history_card.dart';

class ClassFundsScreenContent extends StatelessWidget {
  final Class classData;
  final Member currentMember;

  const ClassFundsScreenContent({
    super.key,
    required this.classData,
    required this.currentMember,
  });

  void _showFundOptions(BuildContext context) async {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(
          overlay.size.width - 100,
          overlay.size.height - 310,
          100,
          80,
        ),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(
          value: 'expense',
          child: Row(
            children: const [
              Icon(Icons.shopping_cart_outlined, color: Color(0xFFFF6B6B)),
              SizedBox(width: 12),
              Text(
                "Ghi lại khoản chi",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'income',
          child: Row(
            children: const [
              Icon(Icons.add_circle_outline, color: AppColors.successGreen),
              SizedBox(width: 12),
              Text(
                "Ghi lại khoản bổ sung",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'payment',
          child: Row(
            children: const [
              Icon(Icons.payments_outlined, color: AppColors.primaryBlue),
              SizedBox(width: 12),
              Text(
                "Tạo khoản đóng quỹ",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (result == 'expense') {
      // TODO: Navigate to expense screen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tính năng đang phát triển')),
      );
    } else if (result == 'income') {
      // TODO: Navigate to income screen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tính năng đang phát triển')),
      );
    } else if (result == 'payment') {
      // TODO: Navigate to create payment request screen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tính năng đang phát triển')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFundOptions(context),
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header (consistent with other screens) - dynamic subtitle
            CustomHeader(
              title: "Class Funds",
              subtitle: classData.name,
            ),

            // Main content (scrollable)
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
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
