import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_classpal/core/constants/app_colors.dart';
import 'package:mobile_classpal/core/models/fund_transaction.dart';
import '../services/fund_service.dart';

class TransactionDetailScreen extends StatelessWidget {
  final FundTransaction transaction;
  final String classId;

  const TransactionDetailScreen({
    super.key,
    required this.transaction,
    required this.classId,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.isIncome;
    final themeColor = isIncome ? AppColors.successGreen : AppColors.errorRed;
    final bgColor = isIncome ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chi tiết giao dịch',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Transaction Icon & Amount Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: bgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(transaction.icon, color: themeColor, size: 32),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    transaction.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _formatTypeLabel(transaction.type),
                      style: TextStyle(
                        color: themeColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Amount display - special handling for payment type
                  if (transaction.type == 'payment')
                    StreamBuilder<double>(
                      stream: FundService.streamPaymentCollected(
                        classId,
                        transaction.id,
                      ),
                      builder: (context, snapshot) {
                        final collectedAmount = snapshot.data ?? 0.0;
                        return Column(
                          children: [
                            Text(
                              '+${_formatCurrency(collectedAmount)}',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: themeColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Đã thu được',
                              style: TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.info_outline,
                                    size: 16,
                                    color: AppColors.textGrey,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Mức thu: ${_formatCurrency(transaction.amount)}/người',
                                    style: const TextStyle(
                                      color: AppColors.textGrey,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    )
                  else
                    Text(
                      '${isIncome ? '+' : '-'}${_formatCurrency(transaction.amount)}',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: themeColor,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Details Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thông tin chi tiết',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildDetailRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Ngày tạo',
                    value: DateFormat(
                      'dd/MM/yyyy, HH:mm',
                    ).format(transaction.createdAt),
                  ),
                  const Divider(height: 24),
                  _buildDetailRow(
                    icon: Icons.update_outlined,
                    label: 'Cập nhật lần cuối',
                    value: DateFormat(
                      'dd/MM/yyyy, HH:mm',
                    ).format(transaction.updatedAt),
                  ),
                  if (transaction.description != null &&
                      transaction.description!.isNotEmpty) ...[
                    const Divider(height: 24),
                    _buildDetailRow(
                      icon: Icons.notes_outlined,
                      label: 'Mô tả',
                      value: transaction.description!,
                      isMultiLine: true,
                    ),
                  ],
                ],
              ),
            ),
            // Payment Progress (only for payment type)
            if (transaction.type == 'payment') ...[
              const SizedBox(height: 20),
              _buildPaymentProgressCard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    bool isMultiLine = false,
    bool isSmall = false,
  }) {
    return Row(
      crossAxisAlignment: isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppColors.textGrey),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: isSmall ? 12 : 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentProgressCard() {
    return StreamBuilder<Map<String, dynamic>>(
      stream: FundService.streamPaymentProgress(classId, transaction.id),
      builder: (context, snapshot) {
        final data = snapshot.data ?? {'completed': 0, 'total': 0};
        final completed = data['completed'] as int;
        final total = data['total'] as int;
        final progress = total > 0 ? completed / total : 0.0;

        return Container(
          width: double.infinity,
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
                  const Text(
                    'Tiến độ thu quỹ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '$completed/$total',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: AppColors.background,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress >= 1.0
                        ? AppColors.successGreen
                        : AppColors.primaryBlue,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                progress >= 1.0
                    ? 'Đã thu đủ quỹ!'
                    : 'Còn ${total - completed} thành viên chưa đóng',
                style: TextStyle(
                  color: progress >= 1.0
                      ? AppColors.successGreen
                      : AppColors.textGrey,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );
      },
    );
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
