import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';

class FundOverviewCard extends StatelessWidget {
  final double totalBalance;
  final double totalIncome;
  final double totalExpense;

  const FundOverviewCard({
    super.key,
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpense,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryBlue, Color(0xFF4C6FFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4C6FFF).withOpacity(0.28),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("TỔNG QUỸ", style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1.5)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white30),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.visibility_outlined, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text("Xem chi tiết", style: TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _formatCurrency(totalBalance),
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const Text("Cập nhật tức thì", style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildMiniStat("THU", _formatCurrency(totalIncome), Colors.white),
              const SizedBox(width: 16),
              _buildMiniStat("CHI", _formatCurrency(totalExpense), Colors.white),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 1.2)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double value) {
    final format = NumberFormat('#,##0', 'vi_VN');
    return 'đ${format.format(value)}';
  }
}