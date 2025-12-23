import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_classpal/core/models/task.dart';
import 'package:mobile_classpal/core/models/member.dart';

class DutyService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<String> createDuty({
    required String classId,
    required String name,
    String? originId,
    String? originType,
    String? description,
    required DateTime startTime,
    required String ruleName,
    required double points,
    List<Member>? assignees,
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
      'startTime': startTime.millisecondsSinceEpoch,
      'ruleName': ruleName,
      'points': points,
      'assigneeIds': assignees?.map((m) => m.uid).toList() ?? [],
      'createdAt': now,
      'updatedAt': now,
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

  static void _addTaskToBatch({
    required WriteBatch batch,
    required String classId,
    required String dutyId,
    required String assigneeUid,
    required int createdAt,
  }) {
    final taskRef = _firestore.collection('classes').doc(classId).collection('duties').doc(dutyId).collection('tasks').doc();
    batch.set(taskRef, {
      'id': taskRef.id,
      'classId': classId,
      'uid': assigneeUid,
      'status': TaskStatus.incomplete.storageKey,
      'createdAt': createdAt,
    });
  }
}
