import 'package:flutter/material.dart';
// Import từ Core
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_header.dart';
import '../../../../core/models/class.dart';
import '../../../../core/models/member.dart';
import '../../../../core/models/rule.dart';
// Import Widgets con từ module Funds
import '../widgets/fund_overview_card.dart';
import '../widgets/unpaid_members_card.dart';
import '../widgets/transaction_history_card.dart';
import 'funds_transaction_screen.dart';
import '../models/fund_transaction.dart';
import '../services/fund_service.dart';
import '../../overview/services/rule_service.dart';

class ClassFundsScreenContent extends StatefulWidget {
  final Class classData;
  final Member currentMember;

  const ClassFundsScreenContent({
    super.key,
    required this.classData,
    required this.currentMember,
  });

  @override
  State<ClassFundsScreenContent> createState() =>
      _ClassFundsScreenContentState();
}

class _ClassFundsScreenContentState extends State<ClassFundsScreenContent> {
  Stream<List<FundTransaction>> get _transactionsStream =>
      FundService.streamTransactions(widget.classData.classId);

  Stream<double> get _balanceStream =>
      FundService.streamBalance(widget.classData.classId);

  Stream<double> get _totalIncomeStream =>
      FundService.streamTotalIncome(widget.classData.classId);

  Stream<double> get _totalExpenseStream =>
      FundService.streamTotalExpense(widget.classData.classId);

  Future<void> _showFundOptions(BuildContext context) async {
    // Kiểm tra xem có fund rules không
    final fundRules = await RuleService.getRules(widget.classData.classId)
        .map((rules) => rules.where((r) => r.type == RuleType.fund).toList())
        .first;
    
    final hasFundRules = fundRules.isNotEmpty;

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
        if (hasFundRules)
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

    // Điều hướng đến màn hình tạo giao dịch
    final txData = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => FundsTransactionScreen(
          transactionType: result,
          classData: widget.classData,
        ),
      ),
    );

    // Lưu giao dịch vào Firebase
    if (txData != null && mounted) {
      try {
        await FundService.createTransaction(
          classId: widget.classData.classId,
          type: txData['type'] as String,
          title: txData['title'] as String,
          amount: txData['amount'] as double,
          description: txData['description'] as String?,
          ruleName: txData['ruleName'] as String?,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã tạo giao dịch thành công!'),
              backgroundColor: AppColors.successGreen,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: $e'),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canManage = widget.currentMember.role == MemberRole.quanLyLop || 
                      widget.currentMember.role == MemberRole.canBoLop;

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: canManage ? FloatingActionButton(
        onPressed: () => _showFundOptions(context),
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ) : null,
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(
              title: "Class Funds",
              subtitle: widget.classData.name,
            ),
            Expanded(
              child: StreamBuilder<List<FundTransaction>>(
                stream: _transactionsStream,
                builder: (context, transactionsSnapshot) {
                  if (transactionsSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (transactionsSnapshot.hasError) {
                    return Center(
                      child: Text('Lỗi: ${transactionsSnapshot.error}'),
                    );
                  }

                  final transactions = transactionsSnapshot.data ?? [];

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Fund Overview với real-time data
                        StreamBuilder<double>(
                          stream: _balanceStream,
                          builder: (context, balanceSnapshot) {
                            return StreamBuilder<double>(
                              stream: _totalIncomeStream,
                              builder: (context, incomeSnapshot) {
                                return StreamBuilder<double>(
                                  stream: _totalExpenseStream,
                                  builder: (context, expenseSnapshot) {
                                    return FundOverviewCard(
                                      totalBalance: balanceSnapshot.data ?? 0,
                                      totalIncome: incomeSnapshot.data ?? 0,
                                      totalExpense: expenseSnapshot.data ?? 0,
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        const UnpaidMembersCard(),
                        const SizedBox(height: 20),
                        TransactionHistoryCard(
                          transactions: transactions,
                          classId: widget.classData.classId,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
