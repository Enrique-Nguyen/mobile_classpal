// class model for Task, not in data form {
//   final String id;
//   final String? member_id;
//   final String? duty_id;
//   final TaskStatus status;
// }

enum TaskStatus {
  completed,
  pending, // pending approval
  incomplete,
}

extension TaskStatusExtension on TaskStatus {
  String get name {
    switch (this) {
      case TaskStatus.completed:
        return 'Completed';
      case TaskStatus.pending:
        return 'Pending';
      case TaskStatus.incomplete:
        return 'Incomplete';
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
