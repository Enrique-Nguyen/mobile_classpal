enum TaskStatus {
  completed,
  pending,
  incomplete;

  factory TaskStatus.fromDisplayName(String displayName) {
    switch (displayName) {
      case 'Hoàn thành':
        return TaskStatus.completed;
      case 'Đang chờ':
        return TaskStatus.pending;
      case 'Chưa hoàn thành':
        return TaskStatus.incomplete;
      default:
        return TaskStatus.incomplete;
    }
  }

  factory TaskStatus.fromStorageKey(String storageKey) {
    switch (storageKey) {
      case 'completed':
        return TaskStatus.completed;
      case 'pending':
        return TaskStatus.pending;
      case 'incomplete':
        return TaskStatus.incomplete;
      default:
        return TaskStatus.incomplete;
    }
  }

  factory TaskStatus.fromTaskString(String taskString) {
    switch (taskString) {
      case 'Hoàn thành' || 'completed':
        return TaskStatus.completed;
      case 'Đang chờ' || 'pending':
        return TaskStatus.pending;
      case 'Chưa hoàn thành' || 'incomplete':
        return TaskStatus.incomplete;
      default:
        return TaskStatus.incomplete;
    }
  }
}

extension TaskStatusExtension on TaskStatus {
  String get storageKey {
    switch (this) {
      case TaskStatus.completed:
        return 'completed';
      case TaskStatus.pending:
        return 'pending';
      case TaskStatus.incomplete:
        return 'incomplete';
    }
  }

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
  final String classId;
  final String uid;
  final TaskStatus status;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.classId,
    required this.uid,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'classId': classId,
      'uid': uid,
      'status': status.displayName,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] ?? '',
      classId: map['classId'] ?? '',
      uid: map['uid'] ?? '',
      status: TaskStatus.fromTaskString(map['status']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
    );
  }
}
