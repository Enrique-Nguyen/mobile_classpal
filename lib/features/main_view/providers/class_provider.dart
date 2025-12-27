import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_classpal/core/models/class.dart';
import 'package:mobile_classpal/core/models/member.dart';
import 'package:mobile_classpal/features/auth/providers/auth_provider.dart';

class UserClassData {
  final Class classData;
  final Member member;
  final Color borderColor;

  UserClassData({
    required this.classData,
    required this.member,
    required this.borderColor,
  });
}

class ClassProvider {
  static final userClassesProvider = StreamProvider<List<UserClassData>>((ref) {
    final user = ref.watch(AuthStateProvider.currentUserProvider);
    if (user == null) return Stream.value([]);

    return FirebaseFirestore.instance
        .collectionGroup('members')
        .where('uid', isEqualTo: user.uid)
        .snapshots()
        .asyncMap((snapshot) async {
          List<UserClassData> loadedData = [];
          await Future.wait(
            snapshot.docs.map((memberDoc) async {
              try {
                Member member = Member.fromMap(memberDoc.data());
                DocumentReference classRef = memberDoc.reference.parent.parent!;
                DocumentSnapshot classSnap = await classRef.get();

                if (classSnap.exists) {
                  Class classObj = Class.fromMap(
                    classSnap.data() as Map<String, dynamic>,
                  );

                  // Map border color by role: owner=red, canBo=yellow, member=green
                  Color borderColor;
                  switch (member.role) {
                    case MemberRole.quanLyLop:
                      borderColor = Colors.red.shade400;
                      break;
                    case MemberRole.canBoLop:
                      borderColor = Colors.amber.shade600;
                      break;
                    case MemberRole.thanhVien:
                      borderColor = Colors.green.shade600;
                      break;
                  }

                  loadedData.add(
                    UserClassData(
                      classData: classObj,
                      member: member,
                      borderColor: borderColor,
                    ),
                  );
                }
              } catch (e) {
                debugPrint("Error parsing class data: $e");
              }
            }),
          );

          loadedData.sort(
            (a, b) => b.classData.createdAt.compareTo(a.classData.createdAt),
          );
          return loadedData;
        });
  });
}
