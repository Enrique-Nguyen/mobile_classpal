import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class UnpaidMembersCard extends StatefulWidget {
  const UnpaidMembersCard({super.key});

  @override
  State<UnpaidMembersCard> createState() => _UnpaidMembersCardState();
}

class _UnpaidMembersCardState extends State<UnpaidMembersCard> {
  bool _isCollapsed = false;

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
                  Text("NHỮNG NGƯỜI CHƯA ĐÓNG QUỸ", style: TextStyle(color: AppColors.errorRed, fontSize: 10, letterSpacing: 1.5)),
                  SizedBox(height: 4),
                  Text("3 người đang nợ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary)),
                ],
              ),
              InkWell(
                onTap: () => setState(() => _isCollapsed = !_isCollapsed),
                child: Text(
                  _isCollapsed ? "Hiện" : "Ẩn",
                  style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(height: 0),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildDebtItem("Wean Lê", "ID · 20123456", "Quá hạn 5 ngày", "đ500.000"),
                _buildDebtItem("Emma Wilson", "ID · 20123457", "Còn 2 ngày", "đ500.000", isWarning: true),
                _buildDebtItem("Alex Johnson", "ID · 20123458", "Quá hạn 2 ngày", "đ500.000"),
                const SizedBox(height: 16),
                // const Center(
                //   child: Text(
                //     "TRANSPARENCY KEEPS EVERYONE ACCOUNTABLE",
                //     style: TextStyle(color: Colors.redAccent, fontSize: 10, letterSpacing: 1.2),
                //   ),
                // ),
              ],
            ),
            crossFadeState: _isCollapsed ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 200),
            sizeCurve: Curves.easeInOut,
          ),
        ],
      ),
    );
  }

  Widget _buildDebtItem(String name, String id, String status, String amount, {bool isWarning = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgRedLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFCDD2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 2),
              Text(id, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 4),
              Text(status, style: TextStyle(color: isWarning ? Colors.orange[800] : Colors.red, fontSize: 12)),
            ],
          ),
          Text(amount, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}