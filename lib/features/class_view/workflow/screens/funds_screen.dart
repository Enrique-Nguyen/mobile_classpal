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
import 'funds_transaction_screen.dart';
import '../models/fund_transaction.dart';

class ClassFundsScreenContent extends StatefulWidget {
  final Class classData;
  final Member currentMember;

  const ClassFundsScreenContent({
    super.key,
    required this.classData,
    required this.currentMember,
  });

  @override
  State<ClassFundsScreenContent> createState() => _ClassFundsScreenContentState();
}

class _ClassFundsScreenContentState extends State<ClassFundsScreenContent> {
  final List<FundTransaction> _transactions = [
    FundTransaction(
      type: 'payment',
      title: 'Đóng quỹ tháng 11',
      amount: 2000000,
      description: 'Thu quỹ định kỳ',
      createdAt: DateTime(2024, 11, 5),
    ),
    FundTransaction(
      type: 'expense',
      title: 'Mua đồ dùng sự kiện',
      amount: 800000,
      description: 'Trang trí buổi tổng kết',
      createdAt: DateTime(2024, 11, 10),
    ),
    FundTransaction(
      type: 'income',
      title: 'Tài trợ từ cựu sinh viên',
      amount: 1500000,
      description: 'Ủng hộ hoạt động lớp',
      createdAt: DateTime(2024, 11, 15),
    ),
  ];

  double get _totalIncome => _transactions.where((t) => t.isIncome).fold<double>(0, (sum, t) => sum + t.amount);
  double get _totalExpense => _transactions.where((t) => !t.isIncome).fold<double>(0, (sum, t) => sum + t.amount);
  double get _balance => _totalIncome - _totalExpense;

  Future<void> _showFundOptions(BuildContext context) async {
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

    if (result == null) return;

    final newTx = await Navigator.push<FundTransaction>(
      context,
      MaterialPageRoute(
        builder: (context) => FundsTransactionScreen(
          transactionType: result,
          classData: widget.classData,
        ),
      ),
    );

    if (newTx != null) {
      setState(() {
        _transactions.insert(0, newTx);
      });
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
            CustomHeader(
              title: "Class Funds",
              subtitle: widget.classData.name,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    FundOverviewCard(
                      totalBalance: _balance,
                      totalIncome: _totalIncome,
                      totalExpense: _totalExpense,
                    ),
                    const SizedBox(height: 20),
                    const UnpaidMembersCard(),
                    const SizedBox(height: 20),
                    TransactionHistoryCard(transactions: _transactions),
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
}
