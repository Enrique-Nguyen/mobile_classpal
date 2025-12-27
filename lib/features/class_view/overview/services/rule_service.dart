import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_classpal/core/models/rule.dart';

class RuleService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static CollectionReference rulesRef(String classId) => _firestore.collection('classes').doc(classId).collection('rules');

  static Future<void> createRule({
    required String classId,
    required String name,
    required RuleType type,
    required double points,
  }) async {
    final docRef = rulesRef(classId).doc();
    final now = DateTime.now().millisecondsSinceEpoch;
    await docRef.set({
      'id': docRef.id,
      'name': name,
      'type': type.storageKey,
      'points': points,
      'classId': classId,
      'createdAt': now,
      'updatedAt': now,
    });
  }

  static Future<void> updateRule({
    required String classId,
    required String ruleId,
    required String name,
    required RuleType type,
    required double points,
  }) => rulesRef(classId).doc(ruleId).update({
      'name': name,
      'type': type.storageKey,
      'points': points,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });

  static Future<void> deleteRule({
    required String classId,
    required String ruleId,
  }) => rulesRef(classId).doc(ruleId).delete();

  static Stream<List<Rule>> getRules(String classId) {
    return rulesRef(classId)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => Rule.fromMap(doc.data() as Map<String, dynamic>)).toList());
  }
}
