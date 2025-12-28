import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/member.dart';
import '../../../../core/models/duty.dart';
import '../../../../core/models/task.dart';

/// Model để lưu thông tin người chưa đóng quỹ
class UnpaidMemberInfo {
  final Member member;
  final String dutyName;
  final double amount;
  final DateTime dueDate;
  final int daysOverdue; // Số ngày quá hạn (âm nếu còn hạn)

  UnpaidMemberInfo({
    required this.member,
    required this.dutyName,
    required this.amount,
    required this.dueDate,
    required this.daysOverdue,
  });

  bool get isOverdue => daysOverdue > 0;
}

class UnpaidMembersCard extends StatefulWidget {
  final String classId;

  const UnpaidMembersCard({
    super.key,
    required this.classId,
  });

  @override
  State<UnpaidMembersCard> createState() => _UnpaidMembersCardState();
}

class _UnpaidMembersCardState extends State<UnpaidMembersCard> {
  bool _isCollapsed = false;

  /// Stream lấy danh sách người chưa đóng quỹ
  Stream<List<UnpaidMemberInfo>> _streamUnpaidMembers() {
    final firestore = FirebaseFirestore.instance;
    
    // Lấy các duties có originType = 'payment' (duties từ khoản đóng quỹ)
    return firestore
        .collection('classes')
        .doc(widget.classId)
        .collection('duties')
        .where('originType', isEqualTo: 'payment')
        .snapshots()
        .asyncMap((dutiesSnapshot) async {
      final List<UnpaidMemberInfo> unpaidList = [];
      
      for (final dutyDoc in dutiesSnapshot.docs) {
        final duty = Duty.fromMap(dutyDoc.data());
        
        // Lấy các tasks chưa hoàn thành cho duty này
        final tasksSnapshot = await firestore
            .collection('classes')
            .doc(widget.classId)
            .collection('duties')
            .doc(duty.id)
            .collection('tasks')
            .where('status', isEqualTo: TaskStatus.incomplete.storageKey)
            .get();
        
        // Lấy thông tin fund transaction để biết số tiền
        double amount = duty.points.abs(); // points thường là số âm cho payment
        if (duty.originId != null) {
          final fundDoc = await firestore
              .collection('classes')
              .doc(widget.classId)
              .collection('funds')
              .doc(duty.originId)
              .get();
          if (fundDoc.exists) {
            amount = (fundDoc.data()?['amount'] ?? 0).toDouble();
          }
        }
        
        // Tính số ngày quá hạn
        final now = DateTime.now();
        final dueDate = duty.startTime;
        final difference = now.difference(dueDate).inDays;
        
        // Lấy thông tin member cho mỗi task chưa hoàn thành
        for (final taskDoc in tasksSnapshot.docs) {
          final task = Task.fromMap(taskDoc.data());
          
          // Lấy thông tin member
          final memberDoc = await firestore
              .collection('classes')
              .doc(widget.classId)
              .collection('members')
              .doc(task.uid)
              .get();
          
          if (memberDoc.exists) {
            final member = Member.fromMap(memberDoc.data()!);
            unpaidList.add(UnpaidMemberInfo(
              member: member,
              dutyName: duty.name,
              amount: amount,
              dueDate: dueDate,
              daysOverdue: difference,
            ));
          }
        }
      }
      
      // Sắp xếp: quá hạn nhiều nhất lên đầu
      unpaidList.sort((a, b) => b.daysOverdue.compareTo(a.daysOverdue));
      
      return unpaidList;
    });
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return 'đ${(amount / 1000000).toStringAsFixed(1)}tr';
    } else if (amount >= 1000) {
      return 'đ${(amount / 1000).toStringAsFixed(0)}.000';
    }
    return 'đ${amount.toStringAsFixed(0)}';
  }

  String _getStatusText(int daysOverdue) {
    if (daysOverdue > 0) {
      return 'Quá hạn $daysOverdue ngày';
    } else if (daysOverdue == 0) {
      return 'Hôm nay là hạn chót';
    } else {
      return 'Còn ${-daysOverdue} ngày';
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<UnpaidMemberInfo>>(
      stream: _streamUnpaidMembers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final unpaidMembers = snapshot.data ?? [];
        
        // Nếu không có ai chưa đóng, không hiển thị card
        if (unpaidMembers.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "NHỮNG NGƯỜI CHƯA ĐÓNG QUỸ",
                        style: TextStyle(
                          color: AppColors.errorRed,
                          fontSize: 10,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${unpaidMembers.length} người đang nợ",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () => setState(() => _isCollapsed = !_isCollapsed),
                    child: Text(
                      _isCollapsed ? "Hiện" : "Ẩn",
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox(height: 0),
                secondChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    ...unpaidMembers.map((info) => _buildDebtItem(
                      info.member.name,
                      info.dutyName,
                      _getStatusText(info.daysOverdue),
                      _formatCurrency(info.amount),
                      isWarning: info.daysOverdue <= 0, // Còn hạn thì hiện màu cam
                    )),
                    const SizedBox(height: 8),
                  ],
                ),
                crossFadeState: _isCollapsed
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                duration: const Duration(milliseconds: 200),
                sizeCurve: Curves.easeInOut,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDebtItem(
    String name,
    String dutyName,
    String status,
    String amount, {
    bool isWarning = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgRedLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFCDD2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dutyName,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: TextStyle(
                    color: isWarning ? Colors.orange[800] : Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            amount,
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}