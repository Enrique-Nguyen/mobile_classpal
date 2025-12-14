class Event {
  final String id;
  final String classId;
  final String name;
  final String? description;
  final double maxQuantity;
  final DateTime signupEndTime;
  final DateTime startTime;
  final String ruleName;
  final double points;

  Event({
    required this.id,
    required this.classId,
    required this.name,
    this.description,
    required this.maxQuantity,
    required this.signupEndTime,
    required this.startTime,
    required this.ruleName,
    required this.points,
  });
}
