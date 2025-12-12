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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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

