import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_classpal/core/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
        UserModel newUser = UserModel(
          uid: user.uid, // Lấy ID từ Auth gán sang
          email: email,
          userName: userName,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
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
      print(credential.user);
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('Không tìm thấy tài khoản.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Sai mật khẩu.');
      }
      throw Exception(e.message); // Hiển thị lỗi gốc nếu không bắt được
    }
  }

  // Hàm Đăng xuất
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
