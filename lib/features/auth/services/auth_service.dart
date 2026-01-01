import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_classpal/core/models/member.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  //Biến cờ để kiểm tra xem đã initialize chưa (Tránh gọi 2 lần gây lỗi)
  static bool _isGoogleInitialized = false;
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

    if (doc.exists) return Member.fromMap(doc.data()!);

    return null;
  }

  Future<User?> signInWithGoogle() async {
    try {
      // BƯỚC 1: Gọi initialize đúng 1 lần duy nhất
      if (!_isGoogleInitialized) {
        print("Đang khởi tạo cấu hình Google Sign In...");

        await _googleSignIn.initialize(
          serverClientId:
              '654195767460-246d0r15u0opauutfl00qmtos6mr3en0.apps.googleusercontent.com',
          // Các tham số khác có thể để null
        );

        _isGoogleInitialized = true; // Đánh dấu đã khởi tạo xong
      }

      // BƯỚC 2: Gọi authenticate (Sau khi đã init)
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate(
        scopeHint: ['email', 'profile', 'openid'],
      );

      // BƯỚC 3: Lấy quyền truy cập (Authorization)
      final GoogleSignInClientAuthorization? authz = await googleUser
          .authorizationClient
          .authorizationForScopes(['email', 'profile', 'openid']);

      if (authz == null) {
        throw Exception("Không thể lấy Access Token");
      }

      // BƯỚC 4: Lấy ID Token (Authentication)
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // BƯỚC 5: Tạo Credential và Đăng nhập Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: authz.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      final User? user = userCredential.user;

      // BƯỚC 6: Lưu vào Firestore
      if (user != null) {
        final userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
        if (!userDoc.exists) {
          await _firestore.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'email': user.email,
            'userName': user.displayName ?? "No Name",
            'createdAt': DateTime.now(),
            'updatedAt': DateTime.now(),
          });
        }
      }
      return user;
    } catch (e) {
      print("Google Sign In Error: $e");
      return null;
    }
  }
}
