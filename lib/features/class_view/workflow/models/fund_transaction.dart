import 'package:flutter/material.dart';

class FundTransaction {
  final String type; // expense | income | payment
  final String title;
  final double amount;
  final String? description;
  final DateTime createdAt;

  FundTransaction({
    required this.type,
    required this.title,
    required this.amount,
    this.description,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isIncome => type != 'expense';

  IconData get icon {
    switch (type) {
      case 'expense':
        return Icons.trending_down;
      case 'income':
        return Icons.trending_up;
      case 'payment':
        return Icons.payments_outlined;
      default:
        return Icons.receipt_long;
    }
  }
}
