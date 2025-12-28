import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_classpal/core/models/event.dart';
import 'package:mobile_classpal/core/models/task.dart';
import 'package:mobile_classpal/core/models/member.dart';
import 'package:mobile_classpal/core/models/notification.dart' as notif_model;
import 'package:mobile_classpal/features/class_view/overview/services/notification_service.dart';

class EventService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Tạo sự kiện mới
  static Future<String> createEvent({
    required String classId,
    required String name,
    String? description,
    String? location,
    required double maxQuantity,
    required DateTime signupEndTime,
    required DateTime startTime,
    required String ruleName,
    required double points,
  }) async {
    final now = DateTime.now();
    final eventRef = _firestore
        .collection('classes')
        .doc(classId)
        .collection('events')
        .doc();

    await eventRef.set({
      'id': eventRef.id,
      'classId': classId,
      'name': name,
      'description': description,
      'location': location,
      'maxQuantity': maxQuantity,
      'signupEndTime': signupEndTime.millisecondsSinceEpoch,
      'startTime': startTime.millisecondsSinceEpoch,
      'ruleName': ruleName,
      'points': points,
      'createdAt': now.millisecondsSinceEpoch,
      'updatedAt': now.millisecondsSinceEpoch,
    });

    final membersSnapshot = await _firestore
      .collection('classes')
      .doc(classId)
      .collection('members')
      .get();

    final memberUids = membersSnapshot.docs.map((doc) => doc.id).toList();
    if (memberUids.isNotEmpty) {
      await NotificationService.createNotificationsForMembers(
        classId: classId,
        memberUids: memberUids,
        type: notif_model.NotificationType.event,
        title: 'Sự kiện mới: $name',
        subtitle: location != null ? 'Địa điểm: $location' : (description ?? 'Sự kiện mới đã được tạo'),
        referenceId: eventRef.id,
        signupEndTime: signupEndTime,
        startTime: startTime,
      );
    }

    return eventRef.id;
  }

  /// Lấy danh sách sự kiện theo stream
  static Stream<List<Event>> streamEvents(String classId) {
    return _firestore
      .collection('classes')
      .doc(classId)
      .collection('events')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => Event.fromMap(doc.data())).toList());
  }

  /// Lấy một sự kiện cụ thể
  static Future<Event?> getEvent(String classId, String eventId) async {
    final doc = await _firestore
      .collection('classes')
      .doc(classId)
      .collection('events')
      .doc(eventId)
      .get();

    if (doc.exists)
      return Event.fromMap(doc.data()!);
      
    return null;
  }

  /// Cập nhật sự kiện
  static Future<void> updateEvent({
    required String classId,
    required String eventId,
    String? name,
    String? description,
    String? location,
    double? maxQuantity,
    DateTime? signupEndTime,
    DateTime? startTime,
    String? ruleName,
    double? points,
  }) async {
    final updates = <String, dynamic>{
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    };

    if (name != null) updates['name'] = name;
    if (description != null) updates['description'] = description;
    if (location != null) updates['location'] = location;
    if (maxQuantity != null) updates['maxQuantity'] = maxQuantity;
    if (signupEndTime != null) updates['signupEndTime'] = signupEndTime.millisecondsSinceEpoch;
    if (startTime != null) updates['startTime'] = startTime.millisecondsSinceEpoch;
    if (ruleName != null) updates['ruleName'] = ruleName;
    if (points != null) updates['points'] = points;

    await _firestore
        .collection('classes')
        .doc(classId)
        .collection('events')
        .doc(eventId)
        .update(updates);
  }

  /// Xóa sự kiện
  static Future<void> deleteEvent({
    required String classId,
    required String eventId,
  }) async {
    await _firestore
      .collection('classes')
      .doc(classId)
      .collection('events')
      .doc(eventId)
      .delete();
  }

  /// Đếm số lượng người đã đăng ký tham gia sự kiện
  static Stream<int> streamRegisteredCount(String classId, String eventId) {
    return _firestore
      .collection('classes')
      .doc(classId)
      .collection('events')
      .doc(eventId)
      .collection('registrations')
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
  }

  /// Kiểm tra xem thành viên đã đăng ký sự kiện chưa
  static Stream<bool> streamIsRegistered(String classId, String eventId, String memberUid) {
    return _firestore
      .collection('classes')
      .doc(classId)
      .collection('events')
      .doc(eventId)
      .collection('registrations')
      .doc(memberUid)
      .snapshots()
      .map((snapshot) => snapshot.exists);
  }

  /// Đăng ký tham gia sự kiện
  static Future<void> registerForEvent({
    required String classId,
    required String eventId,
    required String memberUid,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final batch = _firestore.batch();

    // Tạo registration document
    final registrationRef = _firestore
      .collection('classes')
      .doc(classId)
      .collection('events')
      .doc(eventId)
      .collection('registrations')
      .doc(memberUid);

    batch.set(registrationRef, {
      'uid': memberUid,
    });

    // Tạo task tương ứng cho event này
    _addEventTaskToBatch(
      batch: batch,
      classId: classId,
      eventId: eventId,
      memberUid: memberUid,
      createdAt: now,
    );

    await batch.commit();
  }

  /// Hủy đăng ký sự kiện
  static Future<void> unregisterFromEvent({
    required String classId,
    required String eventId,
    required String memberUid,
  }) async {
    final batch = _firestore.batch();

    // Xóa registration document
    final registrationRef = _firestore
      .collection('classes')
      .doc(classId)
      .collection('events')
      .doc(eventId)
      .collection('registrations')
      .doc(memberUid);

    batch.delete(registrationRef);

    // Xóa task tương ứng
    final tasksSnapshot = await _firestore
      .collection('classes')
      .doc(classId)
      .collection('events')
      .doc(eventId)
      .collection('tasks')
      .where('uid', isEqualTo: memberUid)
      .get();

    for (final doc in tasksSnapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  /// Helper function để thêm task vào batch (tương tự duty_service)
  static void _addEventTaskToBatch({
    required WriteBatch batch,
    required String classId,
    required String eventId,
    required String memberUid,
    required int createdAt,
  }) {
    final taskRef = _firestore
      .collection('classes')
      .doc(classId)
      .collection('events')
      .doc(eventId)
      .collection('tasks')
      .doc();

    batch.set(taskRef, {
      'id': taskRef.id,
      'classId': classId,
      'dutyId': eventId, // Sử dụng eventId cho dutyId để tương thích với Task model
      'uid': memberUid,
      'status': TaskStatus.incomplete.storageKey,
      'createdAt': createdAt,
      'updatedAt': createdAt,
    });
  }

  /// Tạo task cho event (tương tự createTask trong duty_service)
  static Future<void> createEventTask({
    required String classId,
    required String eventId,
    required String memberUid,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final batch = _firestore.batch();

    _addEventTaskToBatch(
      batch: batch,
      classId: classId,
      eventId: eventId,
      memberUid: memberUid,
      createdAt: now,
    );

    await batch.commit();
  }

  /// Stream để lấy danh sách tasks của event
  static Stream<List<Task>> streamEventTasks(String classId, String eventId) {
    return _firestore
      .collection('classes')
      .doc(classId)
      .collection('events')
      .doc(eventId)
      .collection('tasks')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => Task.fromMap(doc.data())).toList());
  }

  /// Stream để lấy danh sách tasks của một member trong event
  static Stream<List<Task>> streamMemberEventTasks(String classId, String memberUid) {
    return _firestore
      .collectionGroup('tasks')
      .where('classId', isEqualTo: classId)
      .where('uid', isEqualTo: memberUid)
      .snapshots()
      .asyncMap((taskSnapshot) async {
        if (taskSnapshot.docs.isEmpty) return <Task>[];

        final tasks = <Task>[];
        for (final taskDoc in taskSnapshot.docs) {
          final task = Task.fromMap(taskDoc.data());
          
          // Kiểm tra xem task này có phải của event không (bằng cách check parent collection)
          final parentPath = taskDoc.reference.parent.parent?.path;
          if (parentPath != null && parentPath.contains('/events/')) {
            tasks.add(task);
          }
        }
        return tasks;
      });
  }

  /// Cập nhật trạng thái task của event
  static Future<void> updateEventTaskStatus({
    required String classId,
    required String eventId,
    required String taskId,
    required TaskStatus newStatus,
  }) async {
    final taskRef = _firestore
      .collection('classes')
      .doc(classId)
      .collection('events')
      .doc(eventId)
      .collection('tasks')
      .doc(taskId);

    await taskRef.update({
      'status': newStatus.storageKey,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Stream danh sách người đã đăng ký sự kiện với thông tin đầy đủ
  static Stream<List<Member>> streamRegisteredMembers(String classId, String eventId) {
    return _firestore
      .collection('classes')
      .doc(classId)
      .collection('events')
      .doc(eventId)
      .collection('registrations')
      .snapshots()
      .asyncMap((registrationsSnapshot) async {
        if (registrationsSnapshot.docs.isEmpty) return <Member>[];

        final memberUids = registrationsSnapshot.docs.map((doc) => doc.id).toList();
        final members = <Member>[];

        // Lấy thông tin member từ collection members
        for (final uid in memberUids) {
          final memberDoc = await _firestore
            .collection('classes')
            .doc(classId)
            .collection('members')
            .doc(uid)
            .get();

          if (memberDoc.exists) {
            members.add(Member.fromMap(memberDoc.data()!));
          }
        }

        return members;
      });
  }
}
