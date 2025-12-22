enum TaskStatus {
  completed,
  pending,
  incomplete,
}

extension TaskStatusExtension on TaskStatus {
  String get displayName {
    switch (this) {
      case TaskStatus.completed:
        return 'Hoàn thành';
      case TaskStatus.pending:
        return 'Đang chờ';
      case TaskStatus.incomplete:
        return 'Chưa hoàn thành';
    }
  }
}

class Task {
  final String id;
  final String dutyId;
  final String classId;
  final String uid;
  final String name;
  final String? description;
  final TaskStatus status;
  final DateTime startTime;
  final String? note;
  final String ruleName;
  final double points;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.dutyId,
    required this.classId,
    required this.uid,
    required this.name,
    this.description,
    required this.status,
    required this.startTime,
    this.note,
    required this.ruleName,
    required this.points,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dutyId': dutyId,
      'classId': classId,
      'uid': uid,
      'name': name,
      'description': description,
      'status': status.name,
      'startTime': startTime.millisecondsSinceEpoch,
      'note': note,
      'ruleName': ruleName,
      'points': points,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] ?? '',
      dutyId: map['dutyId'] ?? '',
      classId: map['classId'] ?? '',
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      description: map['description'],
      status: TaskStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => TaskStatus.incomplete,
      ),
      startTime: DateTime.fromMillisecondsSinceEpoch(map['startTime'] ?? 0),
      note: map['note'],
      ruleName: map['ruleName'] ?? '',
      points: (map['points'] ?? 0).toDouble(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
    );
  }
}
