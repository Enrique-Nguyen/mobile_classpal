import 'package:flutter/material.dart';

class FundTransaction {
  final String id;
  final String classId;
  final String type; // expense | income | payment
  final String title;
  final double amount;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  FundTransaction({
    required this.id,
    required this.classId,
    required this.type,
    required this.title,
    required this.amount,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'classId': classId,
      'type': type,
      'title': title,
      'amount': amount,
      'description': description,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory FundTransaction.fromMap(Map<String, dynamic> map) {
    return FundTransaction(
      id: map['id'] as String,
      classId: map['classId'] as String,
      type: map['type'] as String,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      description: map['description'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
    );
  }
}

