import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Hàm Đăng ký
  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      // Xử lý lỗi cụ thể của Firebase
      if (e.code == 'weak-password') {
        throw Exception('Mật khẩu quá yếu.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('Email này đã được đăng ký.');
      }
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
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
