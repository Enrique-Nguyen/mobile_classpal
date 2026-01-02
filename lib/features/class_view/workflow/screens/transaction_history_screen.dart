import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/fund_transaction.dart';
import '../services/fund_service.dart';
import 'transaction_detail_screen.dart';

class TransactionHistoryScreen extends StatelessWidget {
  final String classId;
  final String className;

  const TransactionHistoryScreen({
    super.key,
    required this.classId,
    required this.className,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lịch sử giao dịch',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              className,
              style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
            ),
          ],
        ),
      ),
      body: StreamBuilder<List<FundTransaction>>(
        stream: FundService.streamTransactions(classId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          final transactions = snapshot.data ?? [];

          if (transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Chưa có giao dịch nào',
                    style: TextStyle(color: AppColors.textGrey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          // Group transactions by date
          final groupedTransactions = _groupTransactionsByDate(transactions);

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groupedTransactions.length,
            itemBuilder: (context, index) {
              final date = groupedTransactions.keys.elementAt(index);
              final dayTransactions = groupedTransactions[date]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      _formatDateHeader(date),
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: dayTransactions.asMap().entries.map((entry) {
                        final tx = entry.value;
                        final isLast = entry.key == dayTransactions.length - 1;
                        return _buildTransactionItem(context, tx, isLast);
                      }).toList(),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    FundTransaction tx,
    bool isLast,
  ) {
    final isIncome = tx.isIncome;
    final themeColor = isIncome ? AppColors.successGreen : AppColors.errorRed;
    final bgColor = isIncome
        ? const Color(0xFFE8F5E9)
        : const Color(0xFFFFEBEE);

    // Đối với payment, hiển thị số tiền đã thu
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
            isLast: isLast,
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
      isLast: isLast,
    );
  }

  Widget _buildTransactionTile({
    required BuildContext context,
    required FundTransaction tx,
    required String amountText,
    required Color themeColor,
    required Color bgColor,
    required bool isLast,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                TransactionDetailScreen(transaction: tx, classId: classId),
          ),
        );
      },
      borderRadius: isLast
          ? const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            )
          : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(bottom: BorderSide(color: Colors.grey.shade100)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(tx.icon, color: themeColor, size: 20),
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
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTypeLabel(tx.type),
                    style: const TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amountText,
                  style: TextStyle(
                    color: themeColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('HH:mm').format(tx.createdAt),
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textGrey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Map<DateTime, List<FundTransaction>> _groupTransactionsByDate(
    List<FundTransaction> transactions,
  ) {
    final Map<DateTime, List<FundTransaction>> grouped = {};

    for (final tx in transactions) {
      final date = DateTime(
        tx.createdAt.year,
        tx.createdAt.month,
        tx.createdAt.day,
      );
      grouped.putIfAbsent(date, () => []);
      grouped[date]!.add(tx);
    }

    // Sort by date descending
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    return Map.fromEntries(
      sortedKeys.map((key) => MapEntry(key, grouped[key]!)),
    );
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) {
      return 'Hôm nay';
    } else if (date == yesterday) {
      return 'Hôm qua';
    } else {
      return DateFormat('EEEE, dd/MM/yyyy', 'vi_VN').format(date);
    }
  }

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
}
