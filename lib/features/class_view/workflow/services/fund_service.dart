import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_classpal/core/models/member.dart';
import 'package:mobile_classpal/core/models/task.dart';
import 'package:mobile_classpal/core/models/notification.dart' as notif_model;
import 'package:mobile_classpal/features/class_view/overview/services/notification_service.dart';
import 'package:mobile_classpal/features/class_view/workflow/services/duty_service.dart';
import 'package:mobile_classpal/core/models/fund_transaction.dart';

class FundService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Tạo giao dịch quỹ mới
  /// Nếu type là 'payment', sẽ tự động tạo duty tương ứng cho tất cả members
  static Future<String> createTransaction({
    required String classId,
    required String type,
    required String title,
    required double amount,
    String? description,
    String? ruleName,
    DateTime? deadline,
  }) async {
    final now = DateTime.now();
    final batch = _firestore.batch();

    final txRef = _firestore
      .collection('classes')
      .doc(classId)
      .collection('funds')
      .doc();

    batch.set(txRef, {
      'id': txRef.id,
      'classId': classId,
      'type': type,
      'title': title,
      'amount': amount,
      'description': description,
      'createdAt': now.millisecondsSinceEpoch,
      'updatedAt': now.millisecondsSinceEpoch,
    });

    // Nếu là khoản đóng quỹ (payment), tạo duty tương ứng
    if (type == 'payment') {
      await _createPaymentDuty(
        batch: batch,
        classId: classId,
        title: title,
        amount: amount,
        description: description,
        ruleName: ruleName ?? 'Đóng quỹ',
        originId: txRef.id,
        createdAt: now.millisecondsSinceEpoch,
        deadline: deadline,
      );
    }

    await batch.commit();
    if (type == 'income' || type == 'expense') {
      final membersSnapshot = await _firestore
        .collection('classes')
        .doc(classId)
        .collection('members')
        .get();

      final memberUids = membersSnapshot.docs.map((doc) => doc.id).toList();
      if (memberUids.isNotEmpty) {
        final notifTitle = type == 'income' ? 'Thu nhập mới: $title' : 'Chi tiêu mới: $title';
        final notifSubtitle = type == 'income' ? 'Đã nhận ${_formatCurrency(amount)}' : 'Đã chi ${_formatCurrency(amount)}';

        await NotificationService.createNotificationsForMembers(
          classId: classId,
          memberUids: memberUids,
          type: notif_model.NotificationType.fund,
          title: notifTitle,
          subtitle: notifSubtitle,
          referenceId: txRef.id,
        );
      }
    }

    return txRef.id;
  }

  /// Lấy danh sách giao dịch theo stream
  static Stream<List<FundTransaction>> streamTransactions(String classId) {
    return _firestore
      .collection('classes')
      .doc(classId)
      .collection('funds')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => FundTransaction.fromMap(doc.data())).toList());
  }

  /// Lấy một giao dịch cụ thể
  static Future<FundTransaction?> getTransaction(
    String classId,
    String transactionId,
  ) async {
    final doc = await _firestore
      .collection('classes')
      .doc(classId)
      .collection('funds')
      .doc(transactionId)
      .get();
    if (doc.exists)
      return FundTransaction.fromMap(doc.data()!);

    return null;
  }

  /// Cập nhật giao dịch
  static Future<void> updateTransaction({
    required String classId,
    required String transactionId,
    String? title,
    double? amount,
    String? description,
  }) async {
    final updates = <String, dynamic>{
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    };

    if (title != null) updates['title'] = title;
    if (amount != null) updates['amount'] = amount;
    if (description != null) updates['description'] = description;

    await _firestore
      .collection('classes')
      .doc(classId)
      .collection('funds')
      .doc(transactionId)
      .update(updates);
  }

  /// Xóa giao dịch
  static Future<void> deleteTransaction({
    required String classId,
    required String transactionId,
  }) async {
    await _firestore
      .collection('classes')
      .doc(classId)
      .collection('funds')
      .doc(transactionId)
      .delete();
  }

  /// Stream tổng thu nhập (income + payment)
  static Stream<double> streamTotalIncome(String classId) {
    return streamTransactions(classId).asyncMap((transactions) async {
      double total = 0;

      for (final tx in transactions) {
        if (tx.type == 'income') {
          total += tx.amount;
        } else if (tx.type == 'payment') {
          // Với payment, chỉ cộng số tiền đã thu được
          final collected = await streamPaymentCollected(classId, tx.id).first;
          total += collected;
        }
      }

      return total;
    });
  }

  /// Stream tổng chi tiêu (expense)
  static Stream<double> streamTotalExpense(String classId) {
    return streamTransactions(classId).map((transactions) {
      return transactions
        .where((t) => t.type == 'expense')
        .fold<double>(0, (sum, t) => sum + t.amount);
    });
  }

  /// Stream số dư hiện tại
  static Stream<double> streamBalance(String classId) {
    return streamTransactions(classId).asyncMap((transactions) async {
      double income = 0;
      double expense = 0;

      for (final tx in transactions) {
        if (tx.type == 'income')
          income += tx.amount;
        else if (tx.type == 'payment') {
          final collected = await streamPaymentCollected(classId, tx.id).first;
          income += collected;
        }
        else if (tx.type == 'expense')
          expense += tx.amount;
      }

      return income - expense;
    });
  }

  /// Stream danh sách giao dịch theo loại
  static Stream<List<FundTransaction>> streamTransactionsByType(
    String classId,
    String type,
  ) {
    return _firestore
      .collection('classes')
      .doc(classId)
      .collection('funds')
      .where('type', isEqualTo: type)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => FundTransaction.fromMap(doc.data())).toList());
  }

  /// Helper: Tạo duty cho khoản đóng quỹ
  static Future<void> _createPaymentDuty({
    required WriteBatch batch,
    required String classId,
    required String title,
    required double amount,
    String? description,
    required String ruleName,
    required String originId,
    required int createdAt,
    DateTime? deadline,
  }) async {
    final membersSnapshot = await _firestore
      .collection('classes')
      .doc(classId)
      .collection('members')
      .get();

    final memberUids = membersSnapshot.docs.map((doc) => doc.id).toList();
    double points = 0;
    try {
      final ruleSnapshot = await _firestore
        .collection('classes')
        .doc(classId)
        .collection('rules')
        .where('name', isEqualTo: ruleName)
        .where('type', isEqualTo: 'fund')
        .limit(1)
        .get();

      if (ruleSnapshot.docs.isNotEmpty)
        points = (ruleSnapshot.docs.first.data()['points'] ?? 0).toDouble();
    }
    catch (e) {
      points = 0;
    }

    final endTimeMillis = deadline?.millisecondsSinceEpoch ?? (createdAt + const Duration(days: 7).inMilliseconds);
    await DutyService.createDuty(
      classId: classId,
      name: title,
      description: description,
      ruleName: ruleName,
      originId: originId,
      originType: 'funds',
      note: amount.toString(),
      startTime: DateTime.fromMillisecondsSinceEpoch(createdAt),
      endTime: DateTime.fromMillisecondsSinceEpoch(endTimeMillis),
      points: points,
      assignees: memberUids.map((uid) => Member(
        uid: uid,
        name: '',
        classId: classId,
        role: MemberRole.thanhVien,
        joinedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      )).toList(),
    );
  }

  static String _formatCurrency(double amount) {
    if (amount >= 1000000)
      return '${(amount / 1000000).toStringAsFixed(1)}tr';
    else if (amount >= 1000)
      return '${(amount / 1000).toStringAsFixed(0)}k';

    return amount.toStringAsFixed(0);
  }

  /// Stream số tiền đã thu được cho một payment transaction
  static Stream<double> streamPaymentCollected(
    String classId,
    String paymentId,
  ) {
    return _firestore
      .collection('classes')
      .doc(classId)
      .collection('duties')
      .where('originId', isEqualTo: paymentId)
      .where('originType', isEqualTo: 'funds')
      .snapshots()
      .asyncMap((dutySnapshot) async {
        if (dutySnapshot.docs.isEmpty)
          return 0.0;

        final dutyId = dutySnapshot.docs.first.id;
        final fundDoc = await _firestore
          .collection('classes')
          .doc(classId)
          .collection('funds')
          .doc(paymentId)
          .get();

        if (!fundDoc.exists)
          return 0.0;

        final perPersonAmount = (fundDoc.data()?['amount'] as num? ?? 0).toDouble();
        final tasksSnapshot = await _firestore
          .collection('classes')
          .doc(classId)
          .collection('duties')
          .doc(dutyId)
          .collection('tasks')
          .where('status', isEqualTo: TaskStatus.completed.storageKey)
          .get();

        final completedCount = tasksSnapshot.docs.length;
        return perPersonAmount * completedCount;
      });
  }

  /// Stream tiến độ thu quỹ cho một payment transaction
  static Stream<Map<String, dynamic>> streamPaymentProgress(
    String classId,
    String paymentId,
  ) {
    // Query trực tiếp từ collection duties thay vì collectionGroup
    return _firestore
      .collection('classes')
      .doc(classId)
      .collection('duties')
      .where('originId', isEqualTo: paymentId)
      .where('originType', isEqualTo: 'funds')
      .snapshots()
      .asyncMap((dutySnapshot) async {
        if (dutySnapshot.docs.isEmpty)
          return {'completed': 0, 'total': 0};

        final dutyId = dutySnapshot.docs.first.id;
        final tasksSnapshot = await _firestore
          .collection('classes')
          .doc(classId)
          .collection('duties')
          .doc(dutyId)
          .collection('tasks')
          .get();

        final totalTasks = tasksSnapshot.docs.length;
        final completedTasks = tasksSnapshot
          .docs
          .where((doc) => doc.data()['status'] == TaskStatus.completed.storageKey)
          .length;

        return {'completed': completedTasks, 'total': totalTasks};
      });
  }
}
