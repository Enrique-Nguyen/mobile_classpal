class Duty {
  final String id;
  final String classId;
  final String? note;
  final String name;
  final String? description;
  final DateTime startTime;
  final String ruleName;
  final double points;

  Duty({
    required this.id,
    required this.classId,
    this.note,
    required this.name,
    this.description,
    required this.startTime,
    required this.ruleName,
    required this.points,
  });
}
