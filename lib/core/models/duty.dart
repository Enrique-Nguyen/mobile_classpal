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
  final DateTime? signupEndTime; // For event-origin duties

  /// Whether the duty has been manually ended by admin
  bool get isEnded => endedAt != null;

  /// Whether the deadline has passed
  bool get isExpired => DateTime.now().isAfter(endTime);

  /// Whether duty originated from another action (event or fund)
  bool get isFromOrigin => originId != null && originType != null;

  /// Whether duty originated from an event
  bool get isFromEvent => originType == 'event';

  /// Whether duty originated from a fund payment
  bool get isFromFund => originType == 'funds';

  /// Whether signup time has ended (for event-origin duties)
  bool get signupHasEnded => signupEndTime != null && DateTime.now().isAfter(signupEndTime!);

  /// Whether admin can edit this duty
  /// - Cannot edit if ended or past deadline
  /// - Non-origin duties: always editable (if not ended/expired)
  /// - Event duties: editable after signup ends (if not ended/expired)
  /// - Fund duties: never editable (data comes from fund)
  bool get canEdit {
    if (isEnded || isExpired) return false;
    return !isFromOrigin || (isFromEvent && signupHasEnded);
  }

  /// Whether admin can end this duty
  /// - Non-origin duties: always
  /// - Event duties: only after signup ends
  /// - Fund duties: always
  bool get canEndDuty => !isFromEvent || signupHasEnded;

  /// Whether duty needs assignees (event signup ended with no signups)
  bool get needsAssignees => isFromEvent && signupHasEnded && assigneeIds.isEmpty;

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
    this.signupEndTime,
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
      'signupEndTime': signupEndTime?.millisecondsSinceEpoch,
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
      endedAt: map['endedAt'] != null ? DateTime.fromMillisecondsSinceEpoch(map['endedAt']) : null,
      signupEndTime: map['signupEndTime'] != null ? DateTime.fromMillisecondsSinceEpoch(map['signupEndTime']) : null,
    );
  }
}
