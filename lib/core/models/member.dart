enum MemberRole {
  quanLyLop,
  canBoLop,
  thanhVien;

  String get displayName {
    switch (this) {
      case MemberRole.quanLyLop:
        return 'Quản lý lớp';
      case MemberRole.canBoLop:
        return 'Cán bộ lớp';
      case MemberRole.thanhVien:
        return 'Thành viên';
    }
  }

  static MemberRole fromString(String role) {
    switch (role) {
      case 'quanLyLop' || "Quản lý lớp":
        return MemberRole.quanLyLop;
      case 'canBoLop' || "Cán bộ lớp":
        return MemberRole.canBoLop;
      default:
        return MemberRole.thanhVien;
    }
  }

  String toJson() => name;
}

class Member {
  final String uid;
  final String name;
  final String? avatarUrl;
  final String classId;
  final MemberRole role;
  final DateTime joinedAt;
  final DateTime updatedAt;

  Member({
    required this.uid,
    required this.name,
    this.avatarUrl,
    required this.classId,
    required this.role,
    required this.joinedAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'avatarUrl': avatarUrl,
      'classId': classId,
      'role': role.displayName,
      'joinedAt': joinedAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Member.fromMap(Map<String, dynamic> map) {
    return Member(
      uid: map['uid'] ?? '',
      name: map['name'] ?? 'Thành viên',
      avatarUrl: map['avatarUrl'],
      classId: map['classId'] ?? '',
      role: MemberRole.fromString(map['role'] ?? ''),
      joinedAt: DateTime.fromMillisecondsSinceEpoch(
        map['joinedAt'] ??
            map['createdAt'] ??
            DateTime.now().millisecondsSinceEpoch,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        map['updatedAt'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  Member.empty()
    : uid = '',
      name = '',
      avatarUrl = null,
      classId = '',
      role = MemberRole.thanhVien,
      joinedAt = DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt = DateTime.fromMillisecondsSinceEpoch(0);

  Member copyWith({
    String? uid,
    String? name,
    String? avatarUrl,
    String? classId,
    MemberRole? role,
    DateTime? joinedAt,
    DateTime? updatedAt,
  }) {
    return Member(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      classId: classId ?? this.classId,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
