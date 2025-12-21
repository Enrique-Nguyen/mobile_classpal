import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_classpal/core/models/class_model.dart';
import 'package:mobile_classpal/core/models/member_model.dart';
import 'package:mobile_classpal/features/auth/providers/auth_provider.dart';
import 'dart:math';

class UserClassData {
  final ClassModel classModel;
  final MemberModel member;
  final Color borderColor;

  UserClassData({
    required this.classModel,
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
              MemberModel member = MemberModel.toObject(memberDoc.data());
              DocumentReference classRef = memberDoc.reference.parent.parent!;
              DocumentSnapshot classSnap = await classRef.get();

              if (classSnap.exists) {
                ClassModel classModel = ClassModel.toObject(
                  classSnap.data() as Map<String, dynamic>,
                );
                
                final int hash = classModel.classId.hashCode;
                final Random random = Random(hash);
                Color randomColor = Color.fromARGB(
                  255,
                  random.nextInt(100) + 100,
                  random.nextInt(100) + 100,
                  random.nextInt(100) + 100,
                );

                loadedData.add(
                  UserClassData(
                    classModel: classModel,
                    member: member,
                    borderColor: randomColor,
                  ),
                );
              }
            } catch (e) {
              debugPrint("Error parsing class data: $e");
            }
          }),
        );

        loadedData.sort(
          (a, b) => b.classModel.createdAt.compareTo(a.classModel.createdAt),
        );
        return loadedData;
      });
  });
}
