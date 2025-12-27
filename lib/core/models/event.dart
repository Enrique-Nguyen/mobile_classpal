class Event {
  final String id;
  final String classId;
  final String name;
  final String? description;
  final String? location;
  final double maxQuantity;
  final DateTime signupEndTime;
  final DateTime startTime;
  final String ruleName;
  final double points;
  final DateTime createdAt;
  final DateTime updatedAt;

  Event({
    required this.id,
    required this.classId,
    required this.name,
    this.description,
    this.location,
    required this.maxQuantity,
    required this.signupEndTime,
    required this.startTime,
    required this.ruleName,
    required this.points,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'classId': classId,
      'name': name,
      'description': description,
      'location': location,
      'maxQuantity': maxQuantity,
      'signupEndTime': signupEndTime.millisecondsSinceEpoch,
      'startTime': startTime.millisecondsSinceEpoch,
      'ruleName': ruleName,
      'points': points,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'] ?? '',
      classId: map['classId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'],
      location: map['location'],
      maxQuantity: (map['maxQuantity'] ?? 0).toDouble(),
      signupEndTime: DateTime.fromMillisecondsSinceEpoch(map['signupEndTime'] ?? 0),
      startTime: DateTime.fromMillisecondsSinceEpoch(map['startTime'] ?? 0),
      ruleName: map['ruleName'] ?? '',
      points: (map['points'] ?? 0).toDouble(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
    );
  }
}
