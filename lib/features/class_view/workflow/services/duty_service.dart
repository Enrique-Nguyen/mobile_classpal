import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_classpal/core/models/task.dart';
import 'package:mobile_classpal/core/models/member.dart';

class DutyService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<String> createDuty({
    required String classId,
    required String name,
    String? description,
    required DateTime startTime,
    required String ruleName,
    required double points,
    List<Member>? assignees,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final now = DateTime.now();
    final batch = _firestore.batch();

    final dutyRef = _firestore.collection('classes').doc(classId).collection('duties').doc();
    batch.set(dutyRef, {
      'id': dutyRef.id,
      'classId': classId,
      'name': name,
      'description': description,
      'startTime': startTime,
      'ruleName': ruleName,
      'points': points,
      'assigneeIds': assignees?.map((m) => m.uid).toList() ?? [],
      'createdBy': user.uid,
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
          name: name,
          description: description,
          startTime: startTime,
          ruleName: ruleName,
          points: points,
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
    required String name,
    String? description,
    required DateTime startTime,
    required String ruleName,
    required double points,
  }) async {
    final now = DateTime.now();
    final batch = _firestore.batch();
    
    _addTaskToBatch(
      batch: batch,
      classId: classId,
      dutyId: dutyId,
      assigneeUid: assigneeUid,
      name: name,
      description: description,
      startTime: startTime,
      ruleName: ruleName,
      points: points,
      createdAt: now,
    );

    final dutyRef = _firestore.collection('classes').doc(classId).collection('duties').doc(dutyId);
    batch.update(dutyRef, {
      'assigneeIds': FieldValue.arrayUnion([assigneeUid]),
      'updatedAt': now.millisecondsSinceEpoch,
    });

    await batch.commit();
  }

  static void _addTaskToBatch({
    required WriteBatch batch,
    required String classId,
    required String dutyId,
    required String assigneeUid,
    required String name,
    String? description,
    required DateTime startTime,
    required String ruleName,
    required double points,
    required DateTime createdAt,
  }) {
    final taskRef = _firestore.collection('classes').doc(classId).collection('tasks').doc();
    batch.set(taskRef, {
      'id': taskRef.id,
      'dutyId': dutyId,
      'classId': classId,
      'uid': assigneeUid,
      'name': name,
      'description': description,
      'status': TaskStatus.incomplete,
      'startTime': startTime,
      'ruleName': ruleName,
      'points': points,
      'createdAt': createdAt,
    });
  }
}
