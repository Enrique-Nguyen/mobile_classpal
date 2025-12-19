import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/class.dart';
import '../models/fund_transaction.dart';

class FundsTransactionScreen extends StatefulWidget {
	final String transactionType; // expense | income | payment
	final Class? classData;

	const FundsTransactionScreen({
		super.key,
		required this.transactionType,
		this.classData,
	});

	@override
	State<FundsTransactionScreen> createState() => _FundsTransactionScreenState();
}

class _FundsTransactionScreenState extends State<FundsTransactionScreen> {
	final _formKey = GlobalKey<FormState>();
	final _nameController = TextEditingController();
	final _amountController = TextEditingController();
	final _descriptionController = TextEditingController();

	@override
	void dispose() {
		_nameController.dispose();
		_amountController.dispose();
		_descriptionController.dispose();
		super.dispose();
	}

	String get _typeLabel {
		switch (widget.transactionType) {
			case 'expense':
				return 'Khoản chi';
			case 'income':
				return 'Khoản bổ sung';
			case 'payment':
				return 'Khoản đóng quỹ';
			default:
				return 'Giao dịch';
		}
	}

	Color get _typeColor {
		switch (widget.transactionType) {
			case 'expense':
				return const Color(0xFFFF6B6B);
			case 'income':
				return AppColors.successGreen;
			case 'payment':
				return AppColors.primaryBlue;
			default:
				return AppColors.primaryBlue;
		}
	}

	IconData get _typeIcon {
		switch (widget.transactionType) {
			case 'expense':
				return Icons.shopping_cart_outlined;
			case 'income':
				return Icons.add_circle_outline;
			case 'payment':
				return Icons.payments_outlined;
			default:
				return Icons.attach_money;
		}
	}

	void _submit() {
		if (!_formKey.currentState!.validate()) return;

		final amount = double.parse(_amountController.text.replaceAll(',', ''));
		final tx = FundTransaction(
			type: widget.transactionType,
			title: _nameController.text,
			amount: amount,
			description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
		);

		Navigator.pop(context, tx);
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: AppColors.background,
			appBar: AppBar(
				backgroundColor: Colors.white,
				elevation: 0,
				leading: IconButton(
					icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 18),
					onPressed: () => Navigator.pop(context),
				),
				centerTitle: true,
				title: Column(
					children: [
						Text(
							'Giao dịch quỹ',
							style: const TextStyle(
								fontSize: 18,
								fontWeight: FontWeight.bold,
								color: AppColors.textPrimary,
							),
						),
						if (widget.classData != null)
							Text(
								widget.classData!.name,
								style: const TextStyle(
									fontSize: 13,
									color: AppColors.textSecondary,
								),
							),
					],
				),
				bottom: PreferredSize(
					preferredSize: const Size.fromHeight(1),
					child: Container(height: 1, color: Colors.grey.shade200),
				),
			),
			body: SafeArea(
				child: SingleChildScrollView(
					padding: const EdgeInsets.all(20),
					child: Form(
						key: _formKey,
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								_buildSectionCard(
									children: [
										const Text(
											'Thể loại giao dịch',
											style: TextStyle(
												fontSize: 14,
												fontWeight: FontWeight.w600,
												color: AppColors.textPrimary,
											),
										),
										const SizedBox(height: 8),
										TextFormField(
											initialValue: _typeLabel,
											enabled: false,
											decoration: InputDecoration(
												prefixIcon: Icon(_typeIcon, color: _typeColor),
												disabledBorder: OutlineInputBorder(
													borderRadius: BorderRadius.circular(14),
													borderSide: BorderSide(color: _typeColor.withOpacity(0.4)),
												),
												filled: true,
												fillColor: Colors.white,
												contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
											),
										),
									],
								),
								const SizedBox(height: 16),

								_buildSectionCard(
									children: [
										const Text(
											'Tên khoản',
											style: TextStyle(
												fontSize: 14,
												fontWeight: FontWeight.w600,
												color: AppColors.textPrimary,
											),
										),
										const SizedBox(height: 8),
										TextFormField(
											controller: _nameController,
											decoration: InputDecoration(
												hintText: 'Nhập tên khoản',
												filled: true,
												fillColor: Colors.white,
												border: OutlineInputBorder(
													borderRadius: BorderRadius.circular(14),
													borderSide: BorderSide.none,
												),
												contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
											),
											validator: (value) => (value == null || value.isEmpty)
													? 'Vui lòng nhập tên khoản'
													: null,
										),
										const SizedBox(height: 16),
										const Text(
											'Số tiền',
											style: TextStyle(
												fontSize: 14,
												fontWeight: FontWeight.w600,
												color: AppColors.textPrimary,
											),
										),
										const SizedBox(height: 8),
										TextFormField(
											controller: _amountController,
											keyboardType: TextInputType.number,
											decoration: InputDecoration(
												hintText: 'Nhập số tiền',
												prefixIcon: Icon(Icons.attach_money, color: _typeColor),
												filled: true,
												fillColor: Colors.white,
												border: OutlineInputBorder(
													borderRadius: BorderRadius.circular(14),
													borderSide: BorderSide.none,
												),
												contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
											),
											validator: (value) {
												if (value == null || value.isEmpty) {
													return 'Vui lòng nhập số tiền';
												}
												final amount = double.tryParse(value.replaceAll(',', ''));
												if (amount == null || amount <= 0) {
													return 'Số tiền phải lớn hơn 0';
												}
												return null;
											},
										),
									],
								),
								const SizedBox(height: 16),

								_buildSectionCard(
									children: [
										const Text(
											'Mô tả',
											style: TextStyle(
												fontSize: 14,
												fontWeight: FontWeight.w600,
												color: AppColors.textPrimary,
											),
										),
										const SizedBox(height: 8),
										TextFormField(
											controller: _descriptionController,
											maxLines: 4,
											decoration: InputDecoration(
												hintText: 'Thêm mô tả (tuỳ chọn)',
												filled: true,
												fillColor: Colors.white,
												border: OutlineInputBorder(
													borderRadius: BorderRadius.circular(14),
													borderSide: BorderSide.none,
												),
												contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
											),
										),
									],
								),
								const SizedBox(height: 28),

								SizedBox(
									width: double.infinity,
									height: 52,
									child: ElevatedButton(
										onPressed: _submit,
										style: ElevatedButton.styleFrom(
											backgroundColor: AppColors.primaryBlue,
											elevation: 0,
											shape: RoundedRectangleBorder(
												borderRadius: BorderRadius.circular(14),
											),
										),
										child: const Text(
											'Lưu giao dịch',
											style: TextStyle(
												fontSize: 16,
												fontWeight: FontWeight.bold,
												color: Colors.white,
											),
										),
									),
								),
							],
						),
					),
				),
			),
		);
	}

	Widget _buildSectionCard({required List<Widget> children}) {
		return Container(
			width: double.infinity,
			padding: const EdgeInsets.all(16),
			decoration: BoxDecoration(
				color: Colors.white,
				borderRadius: BorderRadius.circular(16),
				boxShadow: [
					BoxShadow(
						color: Colors.black.withOpacity(0.04),
						blurRadius: 8,
						offset: const Offset(0, 2),
					),
				],
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: children,
			),
		);
	}
}
