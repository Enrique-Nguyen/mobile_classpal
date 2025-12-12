import 'member_role.dart';

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
