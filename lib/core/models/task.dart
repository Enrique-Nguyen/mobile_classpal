enum TaskStatus {
  completed,
  pending,
  incomplete,
}

extension TaskStatusExtension on TaskStatus {
  String get name {
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
  final String name;
  final String? description;
  final TaskStatus status;
  final DateTime startTime;
  final String? note;
  final String ruleName;
  final double points;

  Task({
    required this.id,
    required this.name,
    this.description,
    required this.status,
    required this.startTime,
    this.note,
    required this.ruleName,
    required this.points,
  });
}
