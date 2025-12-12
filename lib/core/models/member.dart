class Member {
  final String id;
  final String name;
  final String? image;
  final String? classId; // User is member of certain class with class_id
  final String? userId;

  Member({
    required this.id,
    required this.name,
    this.image,
    this.classId,
    this.userId,
  });

  const Member.empty()
      : id = '',
        name = '',
        image = null,
        classId = null,
        userId = null;

  const Member.init({
    required this.id,
    required this.name,
    this.image,
    this.classId,
    this.userId,
  });
}
