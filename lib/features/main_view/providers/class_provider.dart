import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_classpal/core/models/class_model.dart';
import 'package:mobile_classpal/core/models/member_model.dart';
import 'package:mobile_classpal/features/auth/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

// Model to group class and member data
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

final firestoreProvider = Provider((ref) => FirebaseFirestore.instance);

// Provider to fetch user's classes
final userClassesProvider = StreamProvider<List<UserClassData>>((ref) {
  final user = ref.watch(AuthStateProvider.currentUserProvider);
  if (user == null) return Stream.value([]);

  final firestore = ref.watch(firestoreProvider);

  return firestore
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
            
            // Helper function for color generation
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

// Persistence Key
const String _kSelectedClassIdKey = 'selected_class_id';

// Notifier for Selected Class ID with Persistence
class SelectedClassIdNotifier extends Notifier<String?> {
  @override
  String? build() {
    _loadFromPrefs();
    return null;
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString(_kSelectedClassIdKey);
  }

  Future<void> setSelectedClassId(String? classId) async {
    state = classId;
    final prefs = await SharedPreferences.getInstance();
    if (classId != null) {
      await prefs.setString(_kSelectedClassIdKey, classId);
    } else {
      await prefs.remove(_kSelectedClassIdKey);
    }
  }
}

final selectedClassIdProvider =
    NotifierProvider<SelectedClassIdNotifier, String?>(SelectedClassIdNotifier.new);

// Provider to get the current selected class details
final selectedClassProvider = Provider<UserClassData?>((ref) {
  final selectedId = ref.watch(selectedClassIdProvider);
  if (selectedId == null) return null;

  final classesAsync = ref.watch(userClassesProvider);
  return classesAsync.when(
    data: (classes) {
      if (classes.isEmpty) return null;
      try {
        return classes.firstWhere(
          (c) => c.classModel.classId == selectedId,
        );
      } catch (_) {
        return classes.first; // Fallback
      }
    },
    loading: () => null,
    error: (_, __) => null,
  );
});
