import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_classpal/core/helpers/duty_helper.dart';
import 'package:mobile_classpal/core/models/task.dart';
import 'package:mobile_classpal/core/models/member.dart';
import 'package:mobile_classpal/core/models/duty.dart';
import 'package:mobile_classpal/core/models/notification.dart' as notif_model;
import 'package:mobile_classpal/features/class_view/leaderboard/services/leaderboard_service.dart';
import 'package:mobile_classpal/features/class_view/overview/services/notification_service.dart';

class DutyService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<String> createDuty({
    required String classId,
    required String name,
    String? originId,
    String? originType,
    String? description,
    String? note,
    required DateTime startTime,
    required DateTime endTime,
    required String ruleName,
    required double points,
    List<Member>? assignees,
    DateTime? signupEndTime, // For event-origin duties
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final batch = _firestore.batch();

    final dutyRef = _firestore.collection('classes').doc(classId).collection('duties').doc();
    batch.set(dutyRef, {
      'id': dutyRef.id,
      'classId': classId,
      'name': name,
      'originId': originId,
      'originType': originType,
      'description': description,
      'note': note,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,
      'ruleName': ruleName,
      'points': points,
      'assigneeIds': assignees?.map((m) => m.uid).toList() ?? [],
      'createdAt': now,
      'updatedAt': now,
      'signupEndTime': signupEndTime?.millisecondsSinceEpoch,
    });

    if (assignees != null && assignees.isNotEmpty) {
      for (final assignee in assignees) {
        _addTaskToBatch(
          batch: batch,
          classId: classId,
          dutyId: dutyRef.id,
          assigneeUid: assignee.uid,
          createdAt: now,
        );
      }

      await NotificationService.createNotificationsForMembers(
        classId: classId,
        memberUids: assignees.map((m) => m.uid).toList(),
        type: notif_model.NotificationType.duty,
        title: 'Nhiệm vụ mới: $name',
        subtitle: 'Thời hạn: ${endTime.day.toString().padLeft(2, '0')}/${endTime.month.toString().padLeft(2, '0')}/${endTime.year} lúc ${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
        referenceId: dutyRef.id,
        startTime: startTime,
      );
    }

    await batch.commit();
    return dutyRef.id;
  }

  static Future<void> createTask({
    required String classId,
    required String dutyId,
    required String assigneeUid,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final batch = _firestore.batch();

    _addTaskToBatch(
      batch: batch,
      classId: classId,
      dutyId: dutyId,
      assigneeUid: assigneeUid,
      createdAt: now,
    );

    final dutyRef = _firestore.collection('classes').doc(classId).collection('duties').doc(dutyId);
    batch.update(dutyRef, {
      'assigneeIds': FieldValue.arrayUnion([assigneeUid]),
      'updatedAt': now,
    });

    await batch.commit();
  }

  /// Xóa task của một member từ duty
  static Future<void> deleteTask({
    required String classId,
    required String dutyId,
    required String memberUid,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final tasksSnapshot = await _firestore
      .collection('classes')
      .doc(classId)
      .collection('duties')
      .doc(dutyId)
      .collection('tasks')
      .where('uid', isEqualTo: memberUid)
      .get();

    if (tasksSnapshot.docs.isEmpty) return;

    final batch = _firestore.batch();
    for (final doc in tasksSnapshot.docs)
      batch.delete(doc.reference);

    final dutyRef = _firestore
      .collection('classes')
      .doc(classId)
      .collection('duties')
      .doc(dutyId);
    batch.update(dutyRef, {
      'assigneeIds': FieldValue.arrayRemove([memberUid]),
      'updatedAt': now,
    });

    await batch.commit();
    await NotificationService.deleteNotificationForMember(
      classId: classId,
      memberUid: memberUid,
      referenceId: dutyId,
    );
  }

  /// Xóa duty và tất cả tasks liên quan
  static Future<void> deleteDuty({
    required String classId,
    required String dutyId,
  }) async {
    // Xóa tất cả tasks trong duty
    final tasksSnapshot = await _firestore
      .collection('classes')
      .doc(classId)
      .collection('duties')
      .doc(dutyId)
      .collection('tasks')
      .get();

    final batch = _firestore.batch();
    for (final doc in tasksSnapshot.docs)
      batch.delete(doc.reference);

    final dutyRef = _firestore
      .collection('classes')
      .doc(classId)
      .collection('duties')
      .doc(dutyId);

    batch.delete(dutyRef);
    await batch.commit();
  }

  static void _addTaskToBatch({
    required WriteBatch batch,
    required String classId,
    required String dutyId,
    required String assigneeUid,
    required int createdAt,
  }) {
    final taskRef = _firestore
      .collection('classes')
      .doc(classId)
      .collection('duties')
      .doc(dutyId)
      .collection('tasks')
      .doc();

    batch.set(taskRef, {
      'id': taskRef.id,
      'classId': classId,
      'dutyId': dutyId,
      'uid': assigneeUid,
      'status': TaskStatus.incomplete.storageKey,
      'createdAt': createdAt,
    });
  }

  static Stream<List<DutyWithTask>> streamMemberDutiesWithTasks(String classId, String memberUid) {
    return _firestore
      .collectionGroup('tasks')
      .where('classId', isEqualTo: classId)
      .where('uid', isEqualTo: memberUid)
      .snapshots()
      .asyncMap((taskSnapshot) async {
        if (taskSnapshot.docs.isEmpty) return <DutyWithTask>[];

        final futures = taskSnapshot.docs.map((taskDoc) async {
          final task = Task.fromMap(taskDoc.data());
          final dutyDoc = await _firestore
            .collection('classes')
            .doc(classId)
            .collection('duties')
            .doc(task.dutyId)
            .get();

          if (!dutyDoc.exists) return null;
          
          final duty = Duty.fromMap(dutyDoc.data()!);
          return DutyWithTask(duty: duty, task: task);
        });

        final results = await Future.wait(futures);
        return results.whereType<DutyWithTask>().toList();
      });
  }

  static Stream<List<Task>> streamDutyTasks(String classId, String dutyId) {
    return _firestore
      .collection('classes')
      .doc(classId)
      .collection('duties')
      .doc(dutyId)
      .collection('tasks')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => Task.fromMap(doc.data())).toList());
  }

  static Stream<List<Task>> streamPendingApprovals(String classId) {
    return _firestore
      .collectionGroup('tasks')
      .where('classId', isEqualTo: classId)
      .where('status', isEqualTo: TaskStatus.pending.storageKey)
      // .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => Task.fromMap(doc.data())).toList());
  }

  static Future<void> updateTaskStatus({
    required String classId,
    required String dutyId,
    required String taskId,
    required TaskStatus newStatus,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final taskRef = _firestore
      .collection('classes')
      .doc(classId)
      .collection('duties')
      .doc(dutyId)
      .collection('tasks')
      .doc(taskId);

    final updateData = <String, dynamic>{
      'status': newStatus.storageKey,
      'updatedAt': now,
    };

    if (newStatus == TaskStatus.pending)
      updateData['submittedAt'] = now;

    // If approving (changing to completed), check if submission was late
    if (newStatus == TaskStatus.completed) {
      final taskDoc = await taskRef.get();
      if (taskDoc.exists) {
        final task = Task.fromMap(taskDoc.data()!);
        final dutyDoc = await _firestore
          .collection('classes')
          .doc(classId)
          .collection('duties')
          .doc(dutyId)
          .get();

        if (dutyDoc.exists) {
          final duty = Duty.fromMap(dutyDoc.data()!);
          final isLateSubmission = task.wasSubmittedAfterDeadline(duty.endTime);

          if (duty.isEnded || isLateSubmission)
            await LeaderboardService.createPenalty(
              classId: classId,
              memberUid: task.uid,
              dutyName: duty.name,
              points: duty.points,
            );
          else
            await LeaderboardService.createAchievement(
              classId: classId,
              memberUid: task.uid,
              title: duty.name,
              points: duty.points,
            );
        }
      }
    }

    await taskRef.update(updateData);
  }

  static Future<void> updateDuty({
    required String classId,
    required String dutyId,
    String? name,
    String? description,
    DateTime? startTime,
    String? ruleName,
    double? points,
    List<Member>? newAssignees,
  }) async {
    final dutyRef = _firestore
      .collection('classes')
      .doc(classId)
      .collection('duties')
      .doc(dutyId);

    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(dutyRef);
      if (!snapshot.exists) return;

      final now = DateTime.now().millisecondsSinceEpoch;
      final currentData = snapshot.data()!;
      final List<String> currentAssigneeIds = List<String>.from(currentData['assigneeIds'] ?? []);

      final updates = <String, dynamic>{
        'updatedAt': now,
      };

      if (name != null) updates['name'] = name;
      if (description != null) updates['description'] = description;
      if (startTime != null) updates['startTime'] = startTime.millisecondsSinceEpoch;
      if (ruleName != null) updates['ruleName'] = ruleName;
      if (points != null) updates['points'] = points;

      if (newAssignees != null) {
        final newAssigneeIds = newAssignees.map((m) => m.uid).toList();
        updates['assigneeIds'] = newAssigneeIds;

        // Calculate diff
        final toAdd = newAssigneeIds.toSet().difference(currentAssigneeIds.toSet());
        final toRemove = currentAssigneeIds.toSet().difference(newAssigneeIds.toSet());

        // Add new tasks
        for (final uid in toAdd) {
          final taskRef = dutyRef.collection('tasks').doc();
          transaction.set(taskRef, {
            'id': taskRef.id,
            'classId': classId,
            'dutyId': dutyId,
            'uid': uid,
            'status': TaskStatus.incomplete.storageKey,
            'createdAt': now,
          });
        }

        if (toAdd.isNotEmpty) {
          final dutyName = currentData['name'] ?? 'Nhiệm vụ';
          final description = currentData['description'] as String?;
          final startTimeMs = currentData['startTime'] as int?;
          await NotificationService.createNotificationsForMembers(
            classId: classId,
            memberUids: toAdd.toList(),
            type: notif_model.NotificationType.duty,
            title: 'Nhiệm vụ mới: $dutyName',
            subtitle: description ?? 'Bạn được giao một nhiệm vụ mới',
            referenceId: dutyId,
            startTime: startTimeMs != null ? DateTime.fromMillisecondsSinceEpoch(startTimeMs) : null,
          );
        }

        for (final uid in toRemove) {
          final taskRef = await dutyRef.collection('tasks').where('uid', isEqualTo: uid).get();
          if (taskRef.docs.isNotEmpty) transaction.delete(taskRef.docs.first.reference);
        }
      }

      transaction.update(dutyRef, updates);
    });
  }

  static Future<Duty?> getDuty(String classId, String dutyId) async {
    final doc = await _firestore
      .collection('classes')
      .doc(classId)
      .collection('duties')
      .doc(dutyId)
      .get();

    if (doc.exists)
      return Duty.fromMap(doc.data()!);

    return null;
  }

  static Future<void> endDuty({
    required String classId,
    required String dutyId,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final dutyDoc = await _firestore
      .collection('classes')
      .doc(classId)
      .collection('duties')
      .doc(dutyId)
      .get();

    if (!dutyDoc.exists) return;
    final duty = Duty.fromMap(dutyDoc.data()!);

    // Get all tasks for this duty
    final tasksSnapshot = await _firestore
      .collection('classes')
      .doc(classId)
      .collection('duties')
      .doc(dutyId)
      .collection('tasks')
      .get();

    final futures = <Future<void>>[_firestore
      .collection('classes')
      .doc(classId)
      .collection('duties')
      .doc(dutyId)
      .update({
        'endedAt': now,
        'updatedAt': now,
      })];
    for (final taskDoc in tasksSnapshot.docs) {
      final task = Task.fromMap(taskDoc.data());
      if (task.status != TaskStatus.completed) {
        futures.add(LeaderboardService.createPenalty(
          classId: classId,
          memberUid: task.uid,
          dutyName: duty.name,
          points: duty.points,
        ));
      }
    }
    
    await Future.wait(futures);
  }
}
