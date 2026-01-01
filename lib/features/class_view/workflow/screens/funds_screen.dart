import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
// Import từ Core
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_header.dart';
import '../../../../core/models/class.dart';
import '../../../../core/models/member.dart';
import '../../../../core/models/rule.dart';
// Import Widgets con từ module Funds
import '../widgets/fund_overview_card.dart';
import '../widgets/unpaid_members_card.dart';
import '../widgets/transaction_history_card.dart';
import 'funds_transaction_screen.dart';
import '../services/fund_service.dart';
import '../../overview/services/rule_service.dart';

class ClassFundsScreenContent extends StatefulWidget {
  final Class classData;
  final Member currentMember;

  const ClassFundsScreenContent({
    super.key,
    required this.classData,
    required this.currentMember,
  });

  @override
  State<ClassFundsScreenContent> createState() =>
      _ClassFundsScreenContentState();
}

class _ClassFundsScreenContentState extends State<ClassFundsScreenContent> {
  Stream<double> get _balanceStream =>
      FundService.streamBalance(widget.classData.classId);

  Stream<double> get _totalIncomeStream =>
      FundService.streamTotalIncome(widget.classData.classId);

  Stream<double> get _totalExpenseStream =>
      FundService.streamTotalExpense(widget.classData.classId);

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

  Future<void> _exportToExcel() async {
    try {
      // Lấy danh sách giao dịch
      final transactions = await FundService.streamTransactions(widget.classData.classId).first;
      
      if (transactions.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Chưa có giao dịch nào để xuất'),
              backgroundColor: AppColors.warningOrange,
            ),
          );
        }
        return;
      }

      // Tạo file Excel
      final excel = Excel.createExcel();
      final sheet = excel['Quỹ lớp'];
      excel.delete('Sheet1'); // Xóa sheet mặc định

      // Header
      sheet.appendRow([
        TextCellValue('STT'),
        TextCellValue('Ngày'),
        TextCellValue('Loại'),
        TextCellValue('Tiêu đề'),
        TextCellValue('Số tiền'),
        TextCellValue('Mô tả'),
      ]);

      // Style cho header
      for (var col = 0; col < 6; col++) {
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0)).cellStyle = CellStyle(
          bold: true,
          horizontalAlign: HorizontalAlign.Center,
        );
      }

      // Thêm dữ liệu
      for (var i = 0; i < transactions.length; i++) {
        final tx = transactions[i];
        sheet.appendRow([
          IntCellValue(i + 1),
          TextCellValue(DateFormat('dd/MM/yyyy HH:mm').format(tx.createdAt)),
          TextCellValue(_formatTypeLabel(tx.type)),
          TextCellValue(tx.title),
          TextCellValue('${tx.type == 'expense' ? '-' : '+'}${_formatCurrency(tx.amount)}'),
          TextCellValue(tx.description ?? ''),
        ]);
      }

      // Thêm dòng tổng kết
      sheet.appendRow([TextCellValue('')]);
      
      final totalIncome = await _totalIncomeStream.first;
      final totalExpense = await _totalExpenseStream.first;
      final balance = await _balanceStream.first;
      
      sheet.appendRow([
        TextCellValue(''),
        TextCellValue(''),
        TextCellValue(''),
        TextCellValue('Tổng thu:'),
        TextCellValue('+${_formatCurrency(totalIncome)}'),
        TextCellValue(''),
      ]);
      sheet.appendRow([
        TextCellValue(''),
        TextCellValue(''),
        TextCellValue(''),
        TextCellValue('Tổng chi:'),
        TextCellValue('-${_formatCurrency(totalExpense)}'),
        TextCellValue(''),
      ]);
      sheet.appendRow([
        TextCellValue(''),
        TextCellValue(''),
        TextCellValue(''),
        TextCellValue('Số dư:'),
        TextCellValue(_formatCurrency(balance)),
        TextCellValue(''),
      ]);

      // Lưu file
      final bytes = excel.encode();
      if (bytes == null) throw Exception('Không thể tạo file Excel');

      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'Quy_${widget.classData.name.replaceAll(' ', '_')}_${DateFormat('ddMMyyyy').format(DateTime.now())}.xlsx';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(bytes);

      // Chia sẻ file
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Báo cáo quỹ lớp ${widget.classData.name}',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xuất file Excel thành công!'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi xuất file: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _showFundOptions(BuildContext context) async {
    // Kiểm tra xem có fund rules không
    final fundRules = await RuleService.getRules(widget.classData.classId)
        .map((rules) => rules.where((r) => r.type == RuleType.fund).toList())
        .first;

    final hasFundRules = fundRules.isNotEmpty;

    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(
          overlay.size.width - 100,
          overlay.size.height - 310,
          100,
          80,
        ),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(
          value: 'expense',
          child: Row(
            children: const [
              Icon(Icons.shopping_cart_outlined, color: Color(0xFFFF6B6B)),
              SizedBox(width: 12),
              Text(
                "Ghi lại khoản chi",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'income',
          child: Row(
            children: const [
              Icon(Icons.add_circle_outline, color: AppColors.successGreen),
              SizedBox(width: 12),
              Text(
                "Ghi lại khoản bổ sung",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'payment',
          child: Row(
            children: const [
              Icon(Icons.payments_outlined, color: AppColors.primaryBlue),
              SizedBox(width: 12),
              Text(
                "Tạo khoản đóng quỹ",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (result == null) return;

    // Kiểm tra nếu chọn 'payment' nhưng chưa có fund rules
    if (result == 'payment' && !hasFundRules) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bạn cần phải tạo luật trước'),
            backgroundColor: AppColors.errorRed,
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    // Điều hướng đến màn hình tạo giao dịch
    final txData = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => FundsTransactionScreen(
          transactionType: result,
          classData: widget.classData,
        ),
      ),
    );

    // Lưu giao dịch vào Firebase
    if (txData != null && mounted) {
      try {
        await FundService.createTransaction(
          classId: widget.classData.classId,
          type: txData['type'] as String,
          title: txData['title'] as String,
          amount: txData['amount'] as double,
          description: txData['description'] as String?,
          ruleName: txData['ruleName'] as String?,
          deadline: txData['deadline'] as DateTime?,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã tạo giao dịch thành công!'),
              backgroundColor: AppColors.successGreen,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: $e'),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canManage =
        widget.currentMember.role == MemberRole.quanLyLop ||
        widget.currentMember.role == MemberRole.canBoLop;

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: canManage
          ? FloatingActionButton(
              onPressed: () => _showFundOptions(context),
              backgroundColor: AppColors.primaryBlue,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(
              title: "Class Funds",
              subtitle: widget.classData.name,
              classData: widget.classData,
              currentMember: widget.currentMember,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Fund Overview với real-time data
                    StreamBuilder<double>(
                      stream: _balanceStream,
                      builder: (context, balanceSnapshot) {
                        return StreamBuilder<double>(
                          stream: _totalIncomeStream,
                          builder: (context, incomeSnapshot) {
                            return StreamBuilder<double>(
                              stream: _totalExpenseStream,
                              builder: (context, expenseSnapshot) {
                                return FundOverviewCard(
                                  totalBalance: balanceSnapshot.data ?? 0,
                                  totalIncome: incomeSnapshot.data ?? 0,
                                  totalExpense: expenseSnapshot.data ?? 0,
                                  onExport: _exportToExcel,
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    UnpaidMembersCard(classId: widget.classData.classId),
                    const SizedBox(height: 20),
                    // Lịch sử giao dịch
                    TransactionHistoryCard(classId: widget.classData.classId),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
