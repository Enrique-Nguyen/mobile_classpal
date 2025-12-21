import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_classpal/core/models/class_model.dart';

class ClassService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _generateJoinCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random();
    return String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))),
    );
  }

  // Hàm Tạo Lớp
  Future<void> createClass(String name) async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception("Bạn chưa đăng nhập!");
    String joinCode = _generateJoinCode();
    try {
      // 1. Tạo tham chiếu document mới (tự sinh ID)
      DocumentReference classRef = _firestore.collection('classes').doc();
      DateTime now = DateTime.now();

      // 2. Chuẩn bị dữ liệu lớp học
      ClassModel newClass = ClassModel(
        classId: classRef.id,
        name: name,
        joinCode: joinCode,
        createdAt: now,
        updatedAt: now,
      );

      // 3. Lấy thông tin User hiện tại (để lưu vào bảng Member)
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();
      if (!userDoc.exists)
        throw Exception("Không tìm thấy thông tin người dùng!");

      // UserModel userModel = UserModel.toObject(
      //   userDoc.data() as Map<String, dynamic>,
      // );

      // 4. Bắt đầu Batch Write (Ghi 2 nơi cùng lúc)
      WriteBatch batch = _firestore.batch();

      // Thao tác A: Ghi thông tin lớp vào collection 'classes'
      batch.set(classRef, newClass.toMap());

      // Thao tác B: Ghi người tạo vào sub-collection 'members' với vai trò OWNER
      DocumentReference memberRef = classRef
          .collection('members')
          .doc(currentUser.uid);

      batch.set(memberRef, {
        'uid': currentUser.uid,
        'name': currentUser.displayName,
        'role': 'Quản lý lớp',
        'joinedAt': now.millisecondsSinceEpoch,
        'updateAt': now.millisecondsSinceEpoch,
        // 'cachedName': userModel
        //     .userName, // Lưu tên để hiển thị nhanh danh sách thành viên
        // 'cachedAvatar': userModel.avatarUrl,
      });

      // 5. Thực thi
      await batch.commit();
    } catch (e) {
      throw Exception("Lỗi tạo lớp: $e");
    }
  }

  Future<void> joinClass(String codeInput) async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception("Bạn chưa đăng nhập!");

    try {
      // 1. Tìm lớp học dựa trên joinCode
      QuerySnapshot classQuery = await _firestore
          .collection('classes')
          .where('joinCode', isEqualTo: codeInput)
          .limit(1)
          .get();

      if (classQuery.docs.isEmpty) {
        throw Exception("Mã lớp không tồn tại!");
      }

      // Lấy thông tin lớp tìm được
      DocumentSnapshot classDoc = classQuery.docs.first;
      String classId = classDoc.id;

      // 2. Tạo tham chiếu đến vị trí thành viên trong Sub-collection
      DocumentReference memberRef = _firestore
          .collection('classes')
          .doc(classId)
          .collection('members')
          .doc(currentUser.uid);

      // 3. Kiểm tra xem đã tham gia chưa (để tránh ghi đè ngày gia nhập cũ)
      DocumentSnapshot memberSnapshot = await memberRef.get();
      if (memberSnapshot.exists) {
        throw Exception("Bạn đã là thành viên của lớp này rồi!");
      }

      // 4. Lấy thông tin user hiện tại
      DateTime now = DateTime.now();

      // 5. Ghi thông tin vào Sub-collection 'members'
      // Không cần dùng Batch vì chỉ ghi 1 nơi, dùng set là đủ.
      await memberRef.set({
        'uid': currentUser.uid,
        'name': currentUser.displayName ?? "Unknown",
        'role': 'Thành viên lớp',
        'joinedAt': now.millisecondsSinceEpoch,
        'updateAt': now.millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception("${e}").toString().replaceAll('Exception:', "");
    }
  }
}
