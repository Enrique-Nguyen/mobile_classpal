/// Represents a leaderboard period (e.g., semester, month, or custom period)
/// The most recently created leaderboard is considered "current"
class Leaderboard {
  final String id;
  final String classId;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  Leaderboard({
    required this.id,
    required this.classId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'classId': classId,
      'name': name,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Leaderboard.fromMap(Map<String, dynamic> map) {
    return Leaderboard(
      id: map['id'] ?? '',
      classId: map['classId'] ?? '',
      name: map['name'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
    );
  }
}
