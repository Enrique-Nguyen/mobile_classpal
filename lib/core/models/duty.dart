class Duty {
  final String id;
  final String classId;
  final String? originId;
  final String? originType;
  final String name;
  final String? note;
  final String? description;
  final DateTime startTime;
  final DateTime endTime; // Deadline
  final String ruleName;
  final double points;
  final List<String> assigneeIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? endedAt; // When admin manually ends the duty

  /// Whether the duty has been manually ended by admin
  bool get isEnded => endedAt != null;

  /// Whether the deadline has passed
  bool get isExpired => DateTime.now().isAfter(endTime);

  Duty({
    required this.id,
    required this.classId,
    required this.name,
    this.originId,
    this.originType,
    this.description,
    required this.startTime,
    required this.endTime,
    required this.ruleName,
    required this.points,
    this.note,
    required this.assigneeIds,
    required this.createdAt,
    required this.updatedAt,
    this.endedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'classId': classId,
      'name': name,
      'originId': originId,
      'originType': originType,
      'description': description,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,
      'ruleName': ruleName,
      'points': points,
      'note': note,
      'assigneeIds': assigneeIds,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'endedAt': endedAt?.millisecondsSinceEpoch,
    };
  }

  factory Duty.fromMap(Map<String, dynamic> map) {
    return Duty(
      id: map['id'] ?? '',
      classId: map['classId'] ?? '',
      name: map['name'] ?? '',
      originId: map['originId'],
      originType: map['originType'],
      description: map['description'],
      startTime: DateTime.fromMillisecondsSinceEpoch(map['startTime'] ?? 0),
      endTime: DateTime.fromMillisecondsSinceEpoch(map['endTime'] ?? 0),
      ruleName: map['ruleName'] ?? '',
      points: (map['points'] ?? 0).toDouble(),
      note: map['note'],
      assigneeIds: List<String>.from(map['assigneeIds'] ?? []),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
      endedAt: map['endedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['endedAt']) 
          : null,
    );
  }
}
