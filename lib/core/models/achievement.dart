class Achievement {
  final String id;
  final String leaderboardId;  // Which leaderboard period this belongs to
  final String memberUid;      // Who earned it
  final String title;          // Description of what was done (e.g., duty name)
  final double points;         // Points awarded
  final DateTime awardedAt;

  Achievement({
    required this.id,
    required this.leaderboardId,
    required this.memberUid,
    required this.title,
    required this.points,
    required this.awardedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'leaderboardId': leaderboardId,
      'memberUid': memberUid,
      'title': title,
      'points': points,
      'awardedAt': awardedAt.millisecondsSinceEpoch,
    };
  }

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'] ?? '',
      leaderboardId: map['leaderboardId'] ?? '',
      memberUid: map['memberUid'] ?? '',
      title: map['title'] ?? '',
      points: (map['points'] ?? 0).toDouble(),
      awardedAt: DateTime.fromMillisecondsSinceEpoch(map['awardedAt'] ?? 0),
    );
  }
}
