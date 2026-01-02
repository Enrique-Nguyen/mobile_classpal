import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/fund_transaction.dart';
import '../services/fund_service.dart';
import '../screens/transaction_detail_screen.dart';

/// Widget hiển thị lịch sử giao dịch quỹ
class TransactionHistoryCard extends StatelessWidget {
  final String classId;
  final int maxItems;

  const TransactionHistoryCard({
    super.key,
    required this.classId,
    this.maxItems = 10,
  });

  String _formatCurrency(double value) {
    final format = NumberFormat('#,##0', 'vi_VN');
    return '${format.format(value)}đ';
  }

  String _formatTypeLabel(String type) {
    switch (type) {
      case 'expense':
        return 'Khoản chi';
      case 'income':
        return 'Khoản bổ sung';
      case 'payment':
        return 'Đóng quỹ';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FundTransaction>>(
      stream: FundService.streamTransactions(classId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Text(
                'Lỗi: ${snapshot.error}',
                style: const TextStyle(color: AppColors.errorRed),
              ),
            ),
          );
        }

        final transactions = snapshot.data ?? [];

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "LỊCH SỬ GIAO DỊCH",
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 10,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "${transactions.length} giao dịch",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              if (transactions.isEmpty)
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 48,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Chưa có giao dịch nào',
                        style: TextStyle(color: AppColors.textGrey, fontSize: 14),
                      ),
                    ],
                  ),
                )
              else
                ...transactions.take(maxItems).map((tx) => _buildTransactionItem(context, tx)),
              if (transactions.length > maxItems)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Center(
                    child: Text(
                      'Và ${transactions.length - maxItems} giao dịch khác...',
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTransactionItem(BuildContext context, FundTransaction tx) {
    final isIncome = tx.isIncome;
    final themeColor = isIncome ? AppColors.successGreen : AppColors.errorRed;
    final bgColor = isIncome
        ? const Color(0xFFE8F5E9)
        : const Color(0xFFFFEBEE);

    // Với payment, cần stream số tiền đã thu
    if (tx.type == 'payment') {
      return StreamBuilder<double>(
        stream: FundService.streamPaymentCollected(classId, tx.id),
        builder: (context, snapshot) {
          final collectedAmount = snapshot.data ?? 0.0;
          final amountText = '+${_formatCurrency(collectedAmount)}';
          
          return _buildTransactionTile(
            context: context,
            tx: tx,
            amountText: amountText,
            themeColor: themeColor,
            bgColor: bgColor,
          );
        },
      );
    }

    final amountText = '${isIncome ? '+' : '-'}${_formatCurrency(tx.amount)}';
    
    return _buildTransactionTile(
      context: context,
      tx: tx,
      amountText: amountText,
      themeColor: themeColor,
      bgColor: bgColor,
    );
  }

  Widget _buildTransactionTile({
    required BuildContext context,
    required FundTransaction tx,
    required String amountText,
    required Color themeColor,
    required Color bgColor,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TransactionDetailScreen(
              transaction: tx,
              classId: classId,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(tx.icon, color: themeColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_formatTypeLabel(tx.type)} • ${DateFormat('dd/MM/yyyy').format(tx.createdAt)}',
                    style: const TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              amountText,
              style: TextStyle(
                color: themeColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textGrey,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}