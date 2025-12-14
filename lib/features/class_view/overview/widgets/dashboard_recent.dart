import 'package:flutter/material.dart';

class DashboardRecentActivities extends StatelessWidget {
  const DashboardRecentActivities({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RECENT ACTIVITY',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          _buildActivityCard(
            category: 'DUTY',
            categoryColor: const Color(0xFFFFF3E0),
            borderColor: const Color(0xFFFFB74D),
            text: 'Proof approved · Whiteboard sterilized',
          ),
          const SizedBox(height: 12),
          _buildActivityCard(
            category: 'FUNDS',
            categoryColor: const Color(0xFFE8F5E9),
            borderColor: const Color(0xFF81C784),
            text: '₫1.2M reimbursed · Advisor verified',
          ),
          const SizedBox(height: 12),
          _buildActivityCard(
            category: 'ASSETS',
            categoryColor: const Color(0xFFE3F2FD),
            borderColor: const Color(0xFF64B5F6),
            text: 'VR kit returned · Assets board updated',
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard({
    required String category,
    required Color categoryColor,
    required Color borderColor,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: borderColor, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: categoryColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              category,
              style: TextStyle(
                color: borderColor,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: Color(0xFF1E1E2D)),
            ),
          ),
        ],
      ),
    );
  }
}
