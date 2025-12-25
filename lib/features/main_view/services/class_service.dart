import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_classpal/core/models/class.dart';
import 'package:mobile_classpal/core/models/member.dart';

class MemberCounts {
  final int total;
  final int managers;
  final int canBos;

  const MemberCounts({
    required this.total,
    required this.managers,
    required this.canBos,
  });

  const MemberCounts.empty() : total = 0, managers = 0, canBos = 0;
}

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
      Class newClass = Class(
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

  /// Stream danh sách thành viên, ánh xạ và sắp xếp theo role.
  Stream<List<Member>> getClassMembersStream(String classId) {
    try {
      return _firestore
          .collection('classes')
          .doc(classId)
          .collection('members')
          .snapshots()
          .map((snapshot) {
            final members = snapshot.docs.map((doc) {
              final data = doc.data();

              final uid = data['uid'] as String? ?? doc.id;
              final name = data['name'] as String? ?? '';
              final avatarUrl = data['avatarUrl'] as String?;
              final roleRaw = data['role'] as String? ?? '';
              final joinedAtMillis = data['joinedAt'] as int?;
              final updatedAtMillis = data['updatedAt'] as int?;

              final joinedAt = joinedAtMillis != null
                  ? DateTime.fromMillisecondsSinceEpoch(joinedAtMillis)
                  : DateTime.fromMillisecondsSinceEpoch(0);
              final updatedAt = updatedAtMillis != null
                  ? DateTime.fromMillisecondsSinceEpoch(updatedAtMillis)
                  : DateTime.fromMillisecondsSinceEpoch(0);

              MemberRole role = MemberRole.fromString(roleRaw);

              return Member(
                uid: uid,
                name: name,
                avatarUrl: avatarUrl,
                classId: classId,
                role: role,
                joinedAt: joinedAt,
                updatedAt: updatedAt,
              );
            }).toList();

            final priority = {
              MemberRole.quanLyLop: 0,
              MemberRole.canBoLop: 1,
              MemberRole.thanhVien: 2,
            };

            members.sort((a, b) {
              final pa = priority[a.role] ?? 99;
              final pb = priority[b.role] ?? 99;
              if (pa != pb) return pa.compareTo(pb);
              return a.name.toLowerCase().compareTo(b.name.toLowerCase());
            });

            return members;
          });
    } catch (e) {
      // If mapping fails, emit empty stream with error
      return Stream.error('Lỗi khi stream danh sách thành viên: $e');
    }
  }

  Stream<MemberCounts> getClassMemberCountsStream(String classId) {
    return _firestore
        .collection('classes')
        .doc(classId)
        .collection('members')
        .snapshots()
        .map((snapshot) {
          int total = snapshot.docs.length;
          int managers = 0;
          int canBos = 0;

          for (final doc in snapshot.docs) {
            final data = doc.data();
            final roleRaw = (data['role'] as String?) ?? '';
            if (roleRaw.contains("Quản lý lớp"))
              managers++;
            else if (roleRaw.contains('Cán bộ lớp')) {
              canBos++;
            }
          }
          return MemberCounts(total: total, managers: managers, canBos: canBos);
        });
  }

  static const String _roleOwner = 'Quản lý lớp';
  static const String _roleCanBo = 'Cán bộ lớp';
  static const String _roleMember = 'Thành viên';

  Future<void> _ensureCurrentUserIsOwner(String classId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Bạn chưa đăng nhập!');
    final doc = await _firestore
        .collection('classes')
        .doc(classId)
        .collection('members')
        .doc(user.uid)
        .get();
    if (!doc.exists) throw Exception('Bạn không phải thành viên lớp này.');
    final role = (doc.data()?['role'] as String?) ?? '';
    if (!role.contains(_roleOwner))
      throw Exception('Chỉ Quản lý lớp mới thực hiện được thao tác này.');
  }

  // Promote member -> Cán bộ
  Future<void> promoteToCanBo({
    required String classId,
    required String memberId,
  }) async {
    await _ensureCurrentUserIsOwner(classId);
    final memberRef = _firestore
        .collection('classes')
        .doc(classId)
        .collection('members')
        .doc(memberId);
    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(memberRef);
      if (!snap.exists) throw Exception('Thành viên không tồn tại.');
      final role = (snap.data()?['role'] as String?) ?? '';
      if (role.contains(_roleOwner))
        throw Exception('Không thể thay đổi vai trò của Quản lý lớp.');
      if (role.contains(_roleCanBo)) throw Exception('Đã là Cán bộ lớp.');
      tx.update(memberRef, {
        'role': _roleCanBo,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    });
  }

  // Demote Cán bộ -> Thành viên
  Future<void> demoteCanBo({
    required String classId,
    required String memberId,
  }) async {
    await _ensureCurrentUserIsOwner(classId);
    final memberRef = _firestore
        .collection('classes')
        .doc(classId)
        .collection('members')
        .doc(memberId);
    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(memberRef);
      if (!snap.exists) throw Exception('Thành viên không tồn tại.');
      final role = (snap.data()?['role'] as String?) ?? '';
      if (!role.contains(_roleCanBo))
        throw Exception('Người này không phải Cán bộ lớp.');
      tx.update(memberRef, {
        'role': _roleMember,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    });
  }

  // Transfer ownership
  Future<void> transferOwnership({
    required String classId,
    required String newOwnerId,
  }) async {
    final current = _auth.currentUser;
    if (current == null) throw Exception('Bạn chưa đăng nhập!');
    if (current.uid == newOwnerId) throw Exception('Bạn đã là Quản lý lớp.');
    await _ensureCurrentUserIsOwner(classId);

    final classRef = _firestore.collection('classes').doc(classId);
    final currentOwnerRef = classRef.collection('members').doc(current.uid);
    final newOwnerRef = classRef.collection('members').doc(newOwnerId);

    await _firestore.runTransaction((tx) async {
      final newSnap = await tx.get(newOwnerRef);
      if (!newSnap.exists) throw Exception('Người nhận quyền không tồn tại.');
      tx.update(currentOwnerRef, {
        'role': _roleMember,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
      tx.update(newOwnerRef, {
        'role': _roleOwner,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
      tx.update(classRef, {
        'ownerId': newOwnerId,
        'updatedAtMillis': DateTime.now().millisecondsSinceEpoch,
      });
    });
  }

  // Remove (kick) member
  Future<void> removeMember({
    required String classId,
    required String memberId,
  }) async {
    final current = _auth.currentUser;
    if (current == null) throw Exception('Bạn chưa đăng nhập!');
    await _ensureCurrentUserIsOwner(classId);
    if (current.uid == memberId)
      throw Exception(
        'Không thể mời chính mình ra khỏi lớp. Vui lòng chuyển quyền trước.',
      );
    final targetRef = _firestore
        .collection('classes')
        .doc(classId)
        .collection('members')
        .doc(memberId);
    final snap = await targetRef.get();
    if (!snap.exists) throw Exception('Thành viên không tồn tại.');
    final role = (snap.data()?['role'] as String?) ?? '';
    if (role.contains(_roleOwner))
      throw Exception('Không thể mời Quản lý lớp ra khỏi lớp.');
    await targetRef.delete();
  }

  // Leave class (self)
  Future<void> leaveClass({required String classId}) async {
    final current = _auth.currentUser;
    if (current == null) throw Exception('Bạn chưa đăng nhập!');
    final memberRef = _firestore
        .collection('classes')
        .doc(classId)
        .collection('members')
        .doc(current.uid);
    final snap = await memberRef.get();
    if (!snap.exists) throw Exception('Bạn không phải thành viên lớp này.');
    final role = (snap.data()?['role'] as String?) ?? '';
    if (role.contains(_roleOwner))
      throw Exception('Quản lý lớp phải chuyển quyền trước khi rời lớp.');
    await memberRef.delete();
  }

  // Delete / dissolve class (only owner)
  Future<void> deleteClass({required String classId}) async {
    final current = _auth.currentUser;
    if (current == null) throw Exception('Bạn chưa đăng nhập!');

    await _ensureCurrentUserIsOwner(classId);

    final classRef = _firestore.collection('classes').doc(classId);

    // Delete the class document first so clients detect dissolution
    await classRef.delete();

    // Then delete members subcollection in batches (best-effort cleanup)
    final membersCol = classRef.collection('members');
    final membersSnap = await membersCol.get();
    final batchSize = 500;
    int processed = 0;

    while (processed < membersSnap.docs.length) {
      final batch = _firestore.batch();
      final chunk = membersSnap.docs.skip(processed).take(batchSize);
      for (final doc in chunk) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      processed += chunk.length;
    }
  }
}
