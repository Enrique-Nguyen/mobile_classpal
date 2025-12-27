/// Represents a member's position on the leaderboard
/// Computed by summing all achievements for a given leaderboard period
class LeaderboardEntry {
  final int rank;
  final String memberUid;
  final String memberName;
  final String? memberAvatarUrl;
  final double totalPoints;
  final int achievementCount;
  final bool isCurrentUser;

  LeaderboardEntry({
    required this.rank,
    required this.memberUid,
    required this.memberName,
    this.memberAvatarUrl,
    required this.totalPoints,
    required this.achievementCount,
    this.isCurrentUser = false,
  });

  LeaderboardEntry copyWith({
    int? rank,
    String? memberUid,
    String? memberName,
    String? memberAvatarUrl,
    double? totalPoints,
    int? achievementCount,
    bool? isCurrentUser,
  }) {
    return LeaderboardEntry(
      rank: rank ?? this.rank,
      memberUid: memberUid ?? this.memberUid,
      memberName: memberName ?? this.memberName,
      memberAvatarUrl: memberAvatarUrl ?? this.memberAvatarUrl,
      totalPoints: totalPoints ?? this.totalPoints,
      achievementCount: achievementCount ?? this.achievementCount,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
    );
  }
}
