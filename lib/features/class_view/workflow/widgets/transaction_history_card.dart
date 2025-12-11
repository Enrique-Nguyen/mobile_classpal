import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class TransactionHistoryCard extends StatelessWidget {
  const TransactionHistoryCard({super.key});

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
          
          _buildTransactionItem(
            icon: Icons.trending_up,
            title: "Monthly Class Fee - January",
            subtitle: "Contribution • Jan 15, 2024",
            amount: "đ2.000.000",
            isIncome: true,
          ),
          _buildTransactionItem(
            icon: Icons.trending_down,
            title: "Class Party Supplies",
            subtitle: "Event • Jan 20, 2024",
            amount: "đ800.000",
            isIncome: false,
            hasEvidence: true,
          ),
           // ... Thêm các item khác nếu cần
           
          const Divider(height: 40),

          // Tổng kết
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F9FC),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildSummaryRow("Total contributions", "đ3.000.000", AppColors.successGreen),
                const SizedBox(height: 12),
                _buildSummaryRow("Total expenses", "đ1.250.000", AppColors.errorRed),
                const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider()),
                _buildSummaryRow("Current balance", "đ5.000.000", AppColors.successGreen, isBold: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String amount,
    required bool isIncome,
    bool hasEvidence = false,
  }) {
    final themeColor = isIncome ? AppColors.successGreen : AppColors.errorRed;
    final bgColor = isIncome ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: themeColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                    Text(
                      "${isIncome ? '+' : '-'}$amount",
                      style: TextStyle(color: themeColor, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
                if (hasEvidence) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F4FF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE3E8F0)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.receipt_long, size: 12, color: Color(0xFF3D5AFE)),
                        SizedBox(width: 4),
                        Text("Evidence attached", style: TextStyle(color: Color(0xFF3D5AFE), fontSize: 11)),
                      ],
                    ),
                  )
                ]
              ],
            ),
          ),
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
}