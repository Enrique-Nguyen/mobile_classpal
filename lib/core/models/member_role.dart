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
