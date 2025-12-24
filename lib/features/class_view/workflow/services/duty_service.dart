import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_classpal/core/helpers/duty_helper.dart';
import 'package:mobile_classpal/core/models/task.dart';
import 'package:mobile_classpal/core/models/member.dart';
import 'package:mobile_classpal/core/models/duty.dart';

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
    // USE UID AS DOC ID for easy O(1) lookup
    final taskRef = _firestore
        .collection('classes')
        .doc(classId)
        .collection('duties')
        .doc(dutyId)
        .collection('tasks')
        .doc(assigneeUid);
        
    batch.set(taskRef, {
      'id': taskRef.id,
      'classId': classId,
      'dutyId': dutyId,
      'uid': assigneeUid,
      'status': TaskStatus.incomplete.storageKey,
      'createdAt': createdAt,
    });
  }

  /// Stream tasks combined with their parent duty for a specific member
  /// Queries duties where assigneeIds contains memberUid, then fetches the specific task doc (by uid)
  static Stream<List<DutyWithTask>> streamMemberDutiesWithTasks(String classId, String memberUid) {
    return _firestore
        .collection('classes')
        .doc(classId)
        .collection('duties')
        .where('assigneeIds', arrayContains: memberUid)
        .orderBy('startTime', descending: true)
        .snapshots()
        .asyncMap((dutyQuerySnapshot) async {
      if (dutyQuerySnapshot.docs.isEmpty) return [];

      final futures = dutyQuerySnapshot.docs.map((dutyDoc) async {
        final duty = Duty.fromMap(dutyDoc.data());
        final taskDoc = await dutyDoc.reference.collection('tasks').doc(memberUid).get();
        
        if (!taskDoc.exists) {
          return DutyWithTask(
            duty: duty,
            task: Task(
              id: "",
              classId: "",
              dutyId: "",
              uid: "",
              status: TaskStatus.incomplete,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );
        }
        
        return DutyWithTask(
          duty: duty,
          task: Task.fromMap(taskDoc.data()!),
        );
      });

      return Future.wait(futures);
    });
  }

  /// Stream all tasks for a specific duty (for admin view)
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

  /// Stream all pending approvals for the class (tasks with status 'pending')
  /// Since we can't efficiently collectionGroup query with the new structure easily without composite indexes sometimes,
  /// we can stick to collectionGroup IF we maintain the tasks as we do.
  /// BUT if we change Task IDs to be `uid`, collectionGroup might have uniqueness issues per collection? No, document IDs don't need to be unique globally, just within collection.
  /// However, for pending approvals, we can just query the duties and filter/fetch or check `tasks`. 
  /// Let's keep collectionGroup for now as it's the efficient way to find ALL pending tasks across ALL duties.
  static Stream<List<Task>> streamPendingApprovals(String classId) {
    return _firestore
        .collectionGroup('tasks')
        .where('classId', isEqualTo: classId)
        .where('status', isEqualTo: TaskStatus.pending.storageKey)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Task.fromMap(doc.data())).toList());
  }

  /// Update task status
  static Future<void> updateTaskStatus({
    required String classId,
    required String dutyId,
    required String taskId,
    required TaskStatus newStatus,
  }) async {
    final taskRef = _firestore
        .collection('classes')
        .doc(classId)
        .collection('duties')
        .doc(dutyId)
        .collection('tasks')
        .doc(taskId);

    await taskRef.update({
      'status': newStatus.storageKey,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Update duty details and sync assignees
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

      final currentData = snapshot.data()!;
      final List<String> currentAssigneeIds = List<String>.from(currentData['assigneeIds'] ?? []);

      final updates = <String, dynamic>{
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
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
           final taskRef = dutyRef.collection('tasks').doc(uid); // Use UID as doc ID
           transaction.set(taskRef, {
             'id': uid, // Task ID is UID
             'classId': classId,
             'dutyId': dutyId,
             'uid': uid,
             'status': TaskStatus.incomplete.storageKey,
             'createdAt': DateTime.now().millisecondsSinceEpoch,
           });
        }

        // Remove old tasks
        for (final uid in toRemove) {
          final taskRef = dutyRef.collection('tasks').doc(uid);
          transaction.delete(taskRef);
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
}
