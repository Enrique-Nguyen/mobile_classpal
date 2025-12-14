enum MemberRole {
  quanLyLop,
  canBoLop,
  thanhVien
}

extension MemberRoleExtension on MemberRole {
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
}

class Member {
  final String id;
  final String name;
  final String? image;
  final String? classId;
  final String? userId;
  final MemberRole role;

  Member({
    required this.id,
    required this.name,
    this.image,
    this.classId,
    this.userId,
    required this.role,
  });

  const Member.empty()
      : id = '',
        name = '',
        image = null,
        classId = null,
        userId = null,
        role = MemberRole.thanhVien;

  const Member.init({
    required this.id,
    required this.name,
    this.image,
    this.classId,
    this.userId,
    required this.role,
  });
}
