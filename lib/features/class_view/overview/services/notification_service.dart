import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_classpal/core/models/notification.dart';

class NotificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Tạo thông báo cho một người dùng
  static Future<String> createNotification({
    required String classId,
    required String uid,
    required NotificationType type,
    required String title,
    required String subtitle,
    String? referenceId,
    DateTime? signupEndTime,
    DateTime? startTime,
  }) async {
    final now = DateTime.now();
    final notifRef = _firestore
      .collection('classes')
      .doc(classId)
      .collection('notifications')
      .doc();

    await notifRef.set({
      'notificationId': notifRef.id,
      'classId': classId,
      'uid': uid,
      'type': type.name,
      'title': title,
      'subtitle': subtitle,
      'referenceId': referenceId,
      'signupEndTime': signupEndTime?.millisecondsSinceEpoch,
      'startTime': startTime?.millisecondsSinceEpoch,
      'createdAt': now.millisecondsSinceEpoch,
      'seenAt': null,
    });

    return notifRef.id;
  }

  /// Tạo thông báo cho nhiều thành viên (batch)
  static Future<void> createNotificationsForMembers({
    required String classId,
    required List<String> memberUids,
    required NotificationType type,
    required String title,
    required String subtitle,
    String? referenceId,
    DateTime? signupEndTime,
    DateTime? startTime,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final batch = _firestore.batch();

    for (final uid in memberUids) {
      final notifRef = _firestore
        .collection('classes')
        .doc(classId)
        .collection('notifications')
        .doc();

      batch.set(notifRef, {
        'id': notifRef.id,
        'classId': classId,
        'uid': uid,
        'type': type.name,
        'title': title,
        'subtitle': subtitle,
        'referenceId': referenceId,
        'signupEndTime': signupEndTime?.millisecondsSinceEpoch,
        'startTime': startTime?.millisecondsSinceEpoch,
        'createdAt': now,
        'seenAt': null,
      });
    }

    await batch.commit();
  }

  /// Stream thông báo của một user, sắp xếp theo ưu tiên
  /// Event/Duty: signupEndTime -> startTime -> createdAt
  /// Fund: createdAt
  static Stream<List<Notification>> streamUserNotifications(String classId, String uid) {
    return _firestore
      .collection('classes')
      .doc(classId)
      .collection('notifications')
      .where('uid', isEqualTo: uid)
      // .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
        final notifications = snapshot.docs
          .map((doc) => Notification.fromMap(doc.data()))
          .toList();

        // Sort by priority: events/duties by signupEndTime/startTime, funds by createdAt
        notifications.sort((a, b) {
          final now = DateTime.now();
          
          // Prioritize unseen over seen
          if (a.isSeen != b.isSeen) {
            return a.isSeen ? 1 : -1;
          }

          // For events and duties, sort by urgency (signupEndTime, startTime)
          if (a.type != NotificationType.fund && b.type != NotificationType.fund) {
            // Both are event or duty
            final aUrgency = a.signupEndTime ?? a.startTime ?? a.createdAt;
            final bUrgency = b.signupEndTime ?? b.startTime ?? b.createdAt;
            
            // Closer to now = more urgent = should come first
            final aDiff = aUrgency.difference(now).inMinutes.abs();
            final bDiff = bUrgency.difference(now).inMinutes.abs();
            return aDiff.compareTo(bDiff);
          }
          
          // Funds just sort by createdAt (newest first)
          return b.createdAt.compareTo(a.createdAt);
        });

        return notifications;
      });
  }

  /// Stream số lượng thông báo chưa đọc
  static Stream<int> streamUnseenCount(String classId, String uid) {
    return _firestore
      .collection('classes')
      .doc(classId)
      .collection('notifications')
      .where('uid', isEqualTo: uid)
      // .where('seenAt', isNull: true)
      .snapshots()
      .map((snapshot) {
        final notifications = snapshot.docs
          .map((doc) => Notification.fromMap(doc.data()))
          .toList();

        return notifications.where((notif) => !notif.isSeen).length;
      });
  }

  /// Đánh dấu tất cả thông báo là đã đọc
  static Future<void> markAllAsSeen(String classId, String uid) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    
    final querySnapshot = await _firestore
      .collection('classes')
      .doc(classId)
      .collection('notifications')
      .where('uid', isEqualTo: uid)
      .where('seenAt', isNull: true)
      .get();

    if (querySnapshot.docs.isEmpty) return;

    final batch = _firestore.batch();
    for (final doc in querySnapshot.docs) {
      batch.update(doc.reference, {'seenAt': now});
    }
    await batch.commit();
  }

  /// Lấy 3 thông báo mới nhất cho dashboard
  static Stream<List<Notification>> streamLatestNotifications(String classId, String uid, {int limit = 3}) {
    return _firestore
      .collection('classes')
      .doc(classId)
      .collection('notifications')
      .where('uid', isEqualTo: uid)
      // .orderBy('createdAt', descending: true)
      .limit(limit)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => Notification.fromMap(doc.data())).toList());
  }

  /// Xóa một thông báo
  static Future<void> deleteNotification(String classId, String notificationId) async {
    await _firestore
      .collection('classes')
      .doc(classId)
      .collection('notifications')
      .doc(notificationId)
      .delete();
  }
}
