import 'package:flutter/material.dart';

class FundOverviewCard extends StatelessWidget {
  const FundOverviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3949AB).withOpacity(0.3),
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
              const Text("TOTAL FUND", style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1.5)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white30),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.download, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text("Export", style: TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 8),
          const Text("đ5.000.000", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          const Text("Updated 3 mins ago", style: TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildMiniStat("INCOME", "đ3.000.000", Colors.white),
              const SizedBox(width: 16),
              _buildMiniStat("EXPENSES", "đ1.250.000", Colors.white),
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
}