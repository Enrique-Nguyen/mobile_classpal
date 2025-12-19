import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../models/fund_transaction.dart';

class TransactionHistoryCard extends StatelessWidget {
  final List<FundTransaction> transactions;

  const TransactionHistoryCard({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("LEDGER", style: TextStyle(color: AppColors.textGrey, fontSize: 10, letterSpacing: 1.5)),
                  SizedBox(height: 4),
                  Text("Transaction history", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text("Auto-synced", style: TextStyle(fontSize: 10, color: AppColors.textGrey)),
              )
            ],
          ),
          const SizedBox(height: 20),
          
          ...transactions.map((tx) => _buildTransactionItem(tx)),

          const Divider(height: 40),

          _buildSummary(),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(FundTransaction tx) {
    final isIncome = tx.isIncome;
    final themeColor = isIncome ? AppColors.successGreen : AppColors.errorRed;
    final bgColor = isIncome ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);
    final subtitle = _formatSubtitle(tx);
    final amountText = '${isIncome ? '+' : '-'}${_formatCurrency(tx.amount)}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(tx.icon, color: themeColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(tx.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                    Text(
                      amountText,
                      style: TextStyle(color: themeColor, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    final totalIncome = transactions.where((t) => t.isIncome).fold<double>(0, (sum, t) => sum + t.amount);
    final totalExpense = transactions.where((t) => !t.isIncome).fold<double>(0, (sum, t) => sum + t.amount);
    final balance = totalIncome - totalExpense;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildSummaryRow("Tổng thu", _formatCurrency(totalIncome), AppColors.successGreen),
          const SizedBox(height: 12),
          _buildSummaryRow("Tổng chi", _formatCurrency(totalExpense), AppColors.errorRed),
          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider()),
          _buildSummaryRow("Số dư hiện tại", _formatCurrency(balance), AppColors.successGreen, isBold: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color color, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: AppColors.textGrey, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: isBold ? 16 : 14)),
      ],
    );
  }

  String _formatCurrency(double value) {
    final format = NumberFormat('#,##0', 'vi_VN');
    return 'đ${format.format(value)}';
  }

  String _formatSubtitle(FundTransaction tx) {
    final typeLabel = tx.type == 'expense'
        ? 'Chi'
        : tx.type == 'payment'
            ? 'Đóng quỹ'
            : 'Bổ sung';
    final dateText = DateFormat('dd/MM/yyyy').format(tx.createdAt);
    return '$typeLabel • $dateText';
  }
}