import 'package:flutter/material.dart';

class DashboardNotifications extends StatelessWidget {
  const DashboardNotifications({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NOTIFICATIONS',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          _buildNotificationCard(
            category: 'DUTIES',
            categoryColor: const Color(0xFFFFF3E0),
            borderColor: const Color(0xFFFFB74D),
            title: 'Upload proof for Lab Clean-up',
            subtitle: 'Due in 45 mins · Camera ready',
            icon: Icons.warning_amber_rounded,
            iconColor: const Color(0xFFFFB74D),
          ),
          const SizedBox(height: 12),
          _buildNotificationCard(
            category: 'EVENTS',
            categoryColor: const Color(0xFFE3F2FD),
            borderColor: const Color(0xFF64B5F6),
            title: 'AI Forum join rate at 82%',
            subtitle: '18 have not responded yet',
            icon: Icons.info_outline,
            iconColor: const Color(0xFF64B5F6),
          ),
          const SizedBox(height: 12),
          _buildNotificationCard(
            category: 'FUNDS',
            categoryColor: const Color(0xFFE8F5E9),
            borderColor: const Color(0xFF81C784),
            title: '₫1.2M reimbursed to funds',
            subtitle: 'Receipt verified by advisor',
            icon: Icons.check_circle_outline,
            iconColor: const Color(0xFF81C784),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard({
    required String category,
    required Color categoryColor,
    required Color borderColor,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E1E2D),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          Icon(icon, color: iconColor, size: 22),
        ],
      ),
    );
  }
}
