class MemberModel {
  final String uid;
  final String classId;
  final String role;
  final String name;
  // final String? avatarUrl;  // Ảnh đại diện (Cache từ User)
  final DateTime joinedAt;
  final DateTime updatedAt;

  MemberModel({
    required this.uid,
    required this.classId,
    required this.role,
    required this.name,
    // this.avatarUrl,
    required this.joinedAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'classId': classId,
      'role': role,
      'name': name,
      // 'avatarUrl': avatarUrl,
      'joinedAt': joinedAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory MemberModel.toObject(Map<String, dynamic> map) {
    return MemberModel(
      uid: map['uid'] ?? '',
      classId: map['classId'] ?? '',
      role: map['role'] ?? 'memberMoMemberModel',
      name: map['name'] ?? 'Thành viên',
      // avatarUrl: map['avatarUrl'], // Có thể null
      joinedAt: DateTime.fromMillisecondsSinceEpoch(
        map['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        map['updatedAt'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }
}
