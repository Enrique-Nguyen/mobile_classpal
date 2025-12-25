import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_classpal/core/models/achievement.dart';
import 'package:mobile_classpal/core/models/leaderboard.dart';
import 'package:mobile_classpal/core/models/leaderboard_entry.dart';
import 'package:mobile_classpal/core/models/member.dart';

class LeaderboardService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============ LEADERBOARD OPERATIONS ============

  /// Create a new leaderboard period
  static Future<String> createLeaderboard(String classId, String name) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final leaderboardRef = _firestore
        .collection('classes')
        .doc(classId)
        .collection('leaderboards')
        .doc();

    await leaderboardRef.set({
      'id': leaderboardRef.id,
      'classId': classId,
      'name': name,
      'createdAt': now,
      'updatedAt': now,
    });

    return leaderboardRef.id;
  }

  /// Stream all leaderboards for a class, sorted by createdAt descending
  static Stream<List<Leaderboard>> streamLeaderboards(String classId) {
    return _firestore
        .collection('classes')
        .doc(classId)
        .collection('leaderboards')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Leaderboard.fromMap(doc.data()))
            .toList());
  }

  /// Get the current (most recent) leaderboard
  static Future<Leaderboard?> getCurrentLeaderboard(String classId) async {
    final snapshot = await _firestore
        .collection('classes')
        .doc(classId)
        .collection('leaderboards')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return Leaderboard.fromMap(snapshot.docs.first.data());
  }

  /// Update leaderboard name
  static Future<void> updateLeaderboardName(
    String classId,
    String leaderboardId,
    String newName,
  ) async {
    await _firestore
        .collection('classes')
        .doc(classId)
        .collection('leaderboards')
        .doc(leaderboardId)
        .update({
      'name': newName,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // ============ ACHIEVEMENT OPERATIONS ============

  /// Create an achievement when a task is approved
  static Future<void> createAchievement({
    required String classId,
    required String memberUid,
    required String title,
    required double points,
  }) async {
    // Get the current leaderboard
    final currentLeaderboard = await getCurrentLeaderboard(classId);
    if (currentLeaderboard == null) {
      // No leaderboard exists, skip creating achievement
      return;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final achievementRef = _firestore
        .collection('classes')
        .doc(classId)
        .collection('achievements')
        .doc();

    await achievementRef.set({
      'id': achievementRef.id,
      'classId': classId,
      'leaderboardId': currentLeaderboard.id,
      'memberUid': memberUid,
      'title': title,
      'points': points,
      'awardedAt': now,
    });
  }

  /// Stream achievements for a specific member in a specific leaderboard
  static Stream<List<Achievement>> streamMemberAchievements(
    String classId,
    String leaderboardId,
    String memberUid,
  ) {
    return _firestore
        .collection('classes')
        .doc(classId)
        .collection('achievements')
        .where('leaderboardId', isEqualTo: leaderboardId)
        .where('memberUid', isEqualTo: memberUid)
        .orderBy('awardedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Achievement.fromMap(doc.data()))
            .toList());
  }

  // ============ LEADERBOARD COMPUTATION ============

  /// Stream the leaderboard entries for a specific leaderboard period
  /// Computes rankings by summing all achievements per member
  static Stream<List<LeaderboardEntry>> streamLeaderboardEntries(
    String classId,
    String leaderboardId,
    String currentUserUid,
  ) {
    // Stream achievements for this leaderboard
    return _firestore
        .collection('classes')
        .doc(classId)
        .collection('achievements')
        .where('leaderboardId', isEqualTo: leaderboardId)
        .snapshots()
        .asyncMap((achievementSnapshot) async {
      // Aggregate points by member
      final Map<String, double> pointsByMember = {};
      final Map<String, int> countByMember = {};

      for (final doc in achievementSnapshot.docs) {
        final achievement = Achievement.fromMap(doc.data());
        pointsByMember[achievement.memberUid] =
            (pointsByMember[achievement.memberUid] ?? 0) + achievement.points;
        countByMember[achievement.memberUid] =
            (countByMember[achievement.memberUid] ?? 0) + 1;
      }

      // Fetch all members to get names
      final membersSnapshot = await _firestore
          .collection('classes')
          .doc(classId)
          .collection('members')
          .get();

      final memberMap = <String, Member>{};
      for (final doc in membersSnapshot.docs) {
        final member = Member.fromMap(doc.data());
        memberMap[member.uid] = member;
      }

      // Build entries list
      final entries = <LeaderboardEntry>[];
      for (final memberUid in pointsByMember.keys) {
        final member = memberMap[memberUid];
        entries.add(LeaderboardEntry(
          rank: 0, // Will be set after sorting
          memberUid: memberUid,
          memberName: member?.name ?? 'Thành viên',
          memberAvatarUrl: member?.avatarUrl,
          totalPoints: pointsByMember[memberUid] ?? 0,
          achievementCount: countByMember[memberUid] ?? 0,
          isCurrentUser: memberUid == currentUserUid,
        ));
      }

      // Sort by points descending
      entries.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));

      // Assign ranks
      for (int i = 0; i < entries.length; i++) {
        entries[i] = entries[i].copyWith(rank: i + 1);
      }

      return entries;
    });
  }

  /// Get top N entries for dashboard preview
  static Stream<List<LeaderboardEntry>> streamTopEntries(
    String classId,
    String currentUserUid, {
    int limit = 3,
  }) {
    // First get current leaderboard, then stream its entries
    return Stream.fromFuture(getCurrentLeaderboard(classId))
        .asyncExpand((leaderboard) {
      if (leaderboard == null) {
        return Stream.value(<LeaderboardEntry>[]);
      }
      return streamLeaderboardEntries(classId, leaderboard.id, currentUserUid)
          .map((entries) => entries.take(limit).toList());
    });
  }
}
