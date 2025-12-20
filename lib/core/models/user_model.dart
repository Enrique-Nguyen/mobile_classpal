class UserModel {
  final String uid;
  final String email;
  final String userName;

  final String? avatarUrl;

  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.userName,
    this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  // 1. Hàm chuyển từ Object sang Map để lưu lên Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'userName': userName,

      'avatarUrl': avatarUrl,

      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  // 2. Hàm chuyển từ Map của Firestore thành Object (UserModel)

  factory UserModel.toObject(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      userName: map['userName'] ?? '',

      avatarUrl: map['avatarUrl'],

      // Chuyển đổi số (timestamp) ngược lại thành DateTime
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        map['updatedAt'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }
}
