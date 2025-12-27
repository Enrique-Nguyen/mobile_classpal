class Class {
  final String classId;
  final String name;
  final String joinCode;
  final DateTime createdAt;
  final DateTime updatedAt;

  Class({
    required this.classId,
    required this.name,
    required this.joinCode,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'classId': classId,
      'name': name,
      'joinCode': joinCode,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Class.fromMap(Map<String, dynamic> map) {
    return Class(
      classId: map['classId'] ?? '',
      name: map['name'] ?? '',
      joinCode: map['joinCode'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        map['updatedAt'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  Class.empty()
      : classId = '',
        name = '',
        joinCode = '',
        createdAt = DateTime.fromMillisecondsSinceEpoch(0),
        updatedAt = DateTime.fromMillisecondsSinceEpoch(0);
}
