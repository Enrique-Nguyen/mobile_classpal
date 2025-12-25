import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_classpal/core/models/member.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Hàm Đăng ký
  Future<User?> signUp({
    required String email,
    required String password,
    required String userName,
  }) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = credential.user;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'userName': userName,
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        });
        await user.updateDisplayName(userName);
      }
      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception('Mật khẩu quá yếu.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('Email này đã được đăng ký.');
      }
      throw Exception(e.message);
    } catch (e) {
      throw Exception(
        'Lỗi hệ thống: $e',
      ).toString().replaceAll('Exception:', '');
    }
  }

  // Hàm Đăng nhập
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential')
        throw Exception('Email hoặc mật khẩu không chính xác.');
      throw Exception(e.message);
    }
  }

  // Hàm Đăng xuất
  Future<void> signOut(BuildContext context) async {
    try {
      print(_auth.currentUser);
      await _auth.signOut();
      if (context.mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/signin', (route) => false);
        print(_auth.currentUser);
      }
    } catch (e) {
      print("Lỗi đăng xuất: $e");
    }
  }

  static Future<Member?> getMember(String classId, String uid) async {
    final doc = await _firestore
      .collection('classes')
      .doc(classId)
      .collection('members')
      .doc(uid)
      .get();

    if (doc.exists)
      return Member.fromMap(doc.data()!);

    return null;
  }
}
