class Duty {
  final String id;
  final String classId;
  final String name;
  final String? description;
  final DateTime startTime;
  final String ruleName;
  final double points;
  final String? note;
  final List<String> assigneeIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  Duty({
    required this.id,
    required this.classId,
    required this.name,
    this.description,
    required this.startTime,
    required this.ruleName,
    required this.points,
    this.note,
    required this.assigneeIds,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'classId': classId,
      'name': name,
      'description': description,
      'startTime': startTime.millisecondsSinceEpoch,
      'ruleName': ruleName,
      'points': points,
      'note': note,
      'assigneeIds': assigneeIds,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Duty.fromMap(Map<String, dynamic> map) {
    return Duty(
      id: map['id'] ?? '',
      classId: map['classId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'],
      startTime: DateTime.fromMillisecondsSinceEpoch(map['startTime'] ?? 0),
      ruleName: map['ruleName'] ?? '',
      points: (map['points'] ?? 0).toDouble(),
      note: map['note'],
      assigneeIds: List<String>.from(map['assigneeIds'] ?? []),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
    );
  }
}
