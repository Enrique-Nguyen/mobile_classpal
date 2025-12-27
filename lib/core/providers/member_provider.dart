import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_classpal/core/models/member.dart';

class MemberProvider {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final currentMemberStreamProvider = StreamProvider.family<Member?, ({String classId, String uid})>((ref, params) {
    return _firestore
      .collection('classes')
      .doc(params.classId)
      .collection('members')
      .doc(params.uid)
      .snapshots()
      .map((snap) {
        if (!snap.exists)
          return null;

        final data = snap.data();
        if (data == null)
          return null;

        return Member.fromMap({...data, 'classId': params.classId});
      });
  });

  static final classExistsStreamProvider = StreamProvider.family<bool, String>((ref, classId) {
    return _firestore
      .collection('classes')
      .doc(classId)
      .snapshots()
      .map((snap) => snap.exists);
  });
}

