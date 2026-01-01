import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_classpal/core/models/event.dart';
import 'package:mobile_classpal/core/models/task.dart';
import 'package:mobile_classpal/core/models/member.dart';
import 'package:mobile_classpal/core/models/duty.dart';
import 'package:mobile_classpal/core/models/notification.dart' as notif_model;
import 'package:mobile_classpal/features/class_view/overview/services/notification_service.dart';
import 'duty_service.dart';

class EventService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Tạo sự kiện mới và duty tương ứng
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

    // Tạo duty tương ứng với event (không chỉ định assignees)
    await DutyService.createDuty(
      classId: classId,
      name: name,
      originId: eventRef.id,
      originType: 'event',
      description: description,
      startTime: signupEndTime, // Hạn đăng ký là startTime của duty
      endTime: startTime, // Ngày tổ chức event là deadline của duty
      ruleName: ruleName,
      points: points,
      assignees: null, // Không chỉ định ai
    );

    // Gửi thông báo cho tất cả thành viên
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

  /// Cập nhật sự kiện và đồng bộ với duty liên quan
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

    // Đồng bộ thay đổi với duty liên quan
    final duty = await getDutyByEventId(classId, eventId);
    if (duty != null) {
      await DutyService.updateDuty(
        classId: classId,
        dutyId: duty.id,
        name: name,
        description: description,
        startTime: signupEndTime, // startTime của duty = signupEndTime của event
        ruleName: ruleName,
        points: points,
      );
      
      // Cập nhật endTime (deadline) của duty nếu startTime của event thay đổi
      if (startTime != null) {
        await _firestore
          .collection('classes')
          .doc(classId)
          .collection('duties')
          .doc(duty.id)
          .update({
            'endTime': startTime.millisecondsSinceEpoch,
            'updatedAt': DateTime.now().millisecondsSinceEpoch,
          });
      }
    }
  }

  /// Xóa sự kiện và duty liên quan
  static Future<void> deleteEvent({
    required String classId,
    required String eventId,
  }) async {
    // Xóa duty liên quan trước
    final duty = await getDutyByEventId(classId, eventId);
    if (duty != null) {
      await DutyService.deleteDuty(classId: classId, dutyId: duty.id);
    }

    // Xóa tất cả registrations
    final registrationsSnapshot = await _firestore
      .collection('classes')
      .doc(classId)
      .collection('events')
      .doc(eventId)
      .collection('registrations')
      .get();

    final batch = _firestore.batch();
    for (final doc in registrationsSnapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();

    // Xóa event
    await _firestore
      .collection('classes')
      .doc(classId)
      .collection('events')
      .doc(eventId)
      .delete();
  }

  /// Kết thúc sự kiện (chỉ có thể dùng khi đã qua thời gian bắt đầu)
  /// Xóa event và duty liên quan, tính điểm cho người tham gia
  static Future<void> endEvent({
    required String classId,
    required String eventId,
  }) async {
    // Lấy thông tin event
    final event = await getEvent(classId, eventId);
    if (event == null) return;

    // Kiểm tra xem đã qua thời gian bắt đầu chưa
    if (DateTime.now().isBefore(event.startTime)) {
      throw Exception('Chưa đến thời gian sự kiện, không thể kết thúc');
    }

    // Lấy duty liên quan và kết thúc nó (tính điểm cho người hoàn thành)
    final duty = await getDutyByEventId(classId, eventId);
    if (duty != null) {
      await DutyService.endDuty(classId: classId, dutyId: duty.id);
      // Sau khi kết thúc, xóa duty
      await DutyService.deleteDuty(classId: classId, dutyId: duty.id);
    }

    // Xóa tất cả registrations
    final registrationsSnapshot = await _firestore
      .collection('classes')
      .doc(classId)
      .collection('events')
      .doc(eventId)
      .collection('registrations')
      .get();

    final batch = _firestore.batch();
    for (final doc in registrationsSnapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();

    // Xóa event
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

  /// Lấy duty tương ứng với event
  static Future<Duty?> getDutyByEventId(String classId, String eventId) async {
    final querySnapshot = await _firestore
      .collection('classes')
      .doc(classId)
      .collection('duties')
      .where('originId', isEqualTo: eventId)
      .where('originType', isEqualTo: 'event')
      .limit(1)
      .get();

    if (querySnapshot.docs.isEmpty) return null;
    return Duty.fromMap(querySnapshot.docs.first.data());
  }

  /// Stream duty tương ứng với event
  static Stream<Duty?> streamEventDuty(String classId, String eventId) {
    return _firestore
      .collection('classes')
      .doc(classId)
      .collection('duties')
      .where('originId', isEqualTo: eventId)
      .where('originType', isEqualTo: 'event')
      .limit(1)
      .snapshots()
      .map((snapshot) {
        if (snapshot.docs.isEmpty) return null;
        return Duty.fromMap(snapshot.docs.first.data());
      });
  }

  /// Đăng ký tham gia sự kiện - tạo task trong duty tương ứng
  static Future<void> registerForEvent({
    required String classId,
    required String eventId,
    required String memberUid,
  }) async {
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
      'registeredAt': DateTime.now().millisecondsSinceEpoch,
    });

    await batch.commit();

    // Lấy duty tương ứng và tạo task
    final duty = await getDutyByEventId(classId, eventId);
    if (duty != null) {
      await DutyService.createTask(
        classId: classId,
        dutyId: duty.id,
        assigneeUid: memberUid,
      );
    }
  }

  /// Hủy đăng ký sự kiện - xóa task từ duty tương ứng
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

    await batch.commit();

    // Lấy duty tương ứng và xóa task
    final duty = await getDutyByEventId(classId, eventId);
    if (duty != null) {
      await DutyService.deleteTask(
        classId: classId,
        dutyId: duty.id,
        memberUid: memberUid,
      );
    }
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

  /// Stream tasks của event thông qua duty liên quan
  static Stream<List<Task>> streamEventTasks(String classId, String eventId) {
    return streamEventDuty(classId, eventId).asyncMap((duty) async {
      if (duty == null) return <Task>[];
      
      final tasksSnapshot = await _firestore
        .collection('classes')
        .doc(classId)
        .collection('duties')
        .doc(duty.id)
        .collection('tasks')
        .get();
      
      return tasksSnapshot.docs.map((doc) => Task.fromMap(doc.data())).toList();
    });
  }
}
