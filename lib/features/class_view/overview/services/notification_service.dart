import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_classpal/core/models/notification.dart';

class NotificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
    final signupEndTimeMs = signupEndTime?.millisecondsSinceEpoch;
    final startTimeMs = startTime?.millisecondsSinceEpoch;

    // Remove existing notifications for the same referenceId and members to prevent duplicates
    if (referenceId != null)
      await _deleteExistingNotifications(
        classId: classId,
        memberUids: memberUids,
        referenceId: referenceId,
      );

    final batch = _firestore.batch();
    for (final uid in memberUids) {
      final notifRef = _firestore
        .collection('classes')
        .doc(classId)
        .collection('notifications')
        .doc();

      batch.set(notifRef, {
        'notificationId': notifRef.id,
        'classId': classId,
        'uid': uid,
        'type': type.name,
        'title': title,
        'subtitle': subtitle,
        'referenceId': referenceId,
        'signupEndTime': signupEndTimeMs,
        'startTime': startTimeMs,
        'createdAt': now,
        'seenAt': null,
      });
    }

    await batch.commit();
  }

  /// Delete existing notifications for a specific referenceId and members
  static Future<void> _deleteExistingNotifications({
    required String classId,
    required List<String> memberUids,
    required String referenceId,
  }) async {
    final futures = <Future<QuerySnapshot<Map<String, dynamic>>>>[];
    for (final uid in memberUids) {
      final existingNotifs = _firestore
        .collection('classes')
        .doc(classId)
        .collection('notifications')
        .where('uid', isEqualTo: uid)
        .where('referenceId', isEqualTo: referenceId)
        .get();
      futures.add(existingNotifs);
    }

    final results = await Future.wait(futures);
    final batch = _firestore.batch();
    for (final result in results)
      for (final doc in result.docs)
        batch.delete(doc.reference);

    await batch.commit();
  }

  /// Delete notification for a member when they are removed from a duty/event
  static Future<void> deleteNotificationForMember({
    required String classId,
    required String memberUid,
    required String referenceId,
  }) async {
    final existingNotifs = await _firestore
      .collection('classes')
      .doc(classId)
      .collection('notifications')
      .where('uid', isEqualTo: memberUid)
      .where('referenceId', isEqualTo: referenceId)
      .get();

    final batch = _firestore.batch();
    for (final doc in existingNotifs.docs)
      batch.delete(doc.reference);

    await batch.commit();
  }

  static Stream<List<Notification>> streamUserNotifications(String classId, String uid) {
    return _firestore
      .collection('classes')
      .doc(classId)
      .collection('notifications')
      .where('uid', isEqualTo: uid)
      // .orderBy('createdAt', descending: true)
      .snapshots()
      .asyncMap((snapshot) async {
        final notifications = snapshot.docs
          .map((doc) => Notification.fromMap(doc.data()))
          .toList();

        final now = DateTime.now();
        final filteredNotifications = <Notification>[];
        for (final notif in notifications) {
          if (notif.type == NotificationType.event && notif.signupEndTime != null && notif.signupEndTime!.isBefore(now))
            continue;
          
          if (notif.type == NotificationType.fund) {
            final hoursSinceCreated = now.difference(notif.createdAt).inHours;
            if (hoursSinceCreated >= 24)
              continue;
          }

          if (notif.type == NotificationType.duty && notif.referenceId != null) {
            // Hide duty notifications older than 7 days
            final daysSinceCreated = now.difference(notif.createdAt).inDays;
            if (daysSinceCreated >= 7)
              continue;

            final shouldHide = await _shouldHideDutyNotification(
              classId: classId,
              dutyId: notif.referenceId!,
              uid: uid,
            );
            if (shouldHide)
              continue;
          }
          filteredNotifications.add(notif);
        }

        filteredNotifications.sort((a, b) {
          final now = DateTime.now();
          if (a.isSeen != b.isSeen)
            return a.isSeen ? 1 : -1;

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

        return filteredNotifications;
      });
  }

  static Future<bool> _shouldHideDutyNotification({
    required String classId,
    required String dutyId,
    required String uid,
  }) async {
    try {
      final dutyDoc = await _firestore
        .collection('classes')
        .doc(classId)
        .collection('duties')
        .doc(dutyId)
        .get();
      
      if (!dutyDoc.exists)
        return true;

      final dutyData = dutyDoc.data()!;
      if (dutyData['endedAt'] != null)
        return true;

      final taskSnapshot = await _firestore
        .collection('classes')
        .doc(classId)
        .collection('duties')
        .doc(dutyId)
        .collection('tasks')
        .where('uid', isEqualTo: uid)
        .limit(1)
        .get();

      if (taskSnapshot.docs.isNotEmpty) {
        final taskData = taskSnapshot.docs.first.data();
        final status = taskData['status'] as String?;
        if (status == 'Hoàn thành' || status == 'completed')
          return true;
      }
      
      return false;
    }
    catch (e) {
      return false;
    }
  }

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
        
        final now = DateTime.now();
        return notifications.where((notif) {
          if (notif.isSeen) return false;
          
          // Exclude event notifications past signup time
          if (notif.type == NotificationType.event) {
            if (notif.signupEndTime != null && notif.signupEndTime!.isBefore(now)) {
              return false;
            }
          }
          
          // Exclude fund notifications older than 24 hours
          if (notif.type == NotificationType.fund) {
            final hoursSinceCreated = now.difference(notif.createdAt).inHours;
            if (hoursSinceCreated >= 24) {
              return false;
            }
          }
          
          return true;
        }).length;
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

    if (querySnapshot.docs.isEmpty)
      return;

    final batch = _firestore.batch();
    for (final doc in querySnapshot.docs)
      batch.update(doc.reference, { 'seenAt': now });

    await batch.commit();
  }

  static Stream<List<Notification>> streamLatestNotifications({
    required String classId,
    required String uid,
    int limit = 3,
  }) {
    // Reuse the main stream with filtering, just take first N items
    return streamUserNotifications(classId, uid).map((notifications) => notifications.take(limit).toList());
  }

  static Future<void> deleteNotification(String classId, String notificationId) async {
    await _firestore
      .collection('classes')
      .doc(classId)
      .collection('notifications')
      .doc(notificationId)
      .delete();
  }
}
