class Leaderboard {
  final String leaderboardId;
  final String classId;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  Leaderboard({
    required this.leaderboardId,
    required this.classId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'leaderboardId': leaderboardId,
      'classId': classId,
      'name': name,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Leaderboard.fromMap(Map<String, dynamic> map) {
    return Leaderboard(
      leaderboardId: map['leaderboardId'] ?? '',
      classId: map['classId'] ?? '',
      name: map['name'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
    );
  }
}
