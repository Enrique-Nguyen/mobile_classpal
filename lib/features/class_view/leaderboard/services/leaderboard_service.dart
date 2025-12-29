import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_classpal/core/models/achievement.dart';
import 'package:mobile_classpal/core/models/leaderboard.dart';
import 'package:mobile_classpal/core/models/leaderboard_entry.dart';
import 'package:mobile_classpal/core/models/member.dart';

class LeaderboardService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<String> createLeaderboard(String classId, String name) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final leaderboardRef = _firestore
      .collection('classes')
      .doc(classId)
      .collection('leaderboards')
      .doc();

    await leaderboardRef.set({
      'leaderboardId': leaderboardRef.id,
      'classId': classId,
      'name': name,
      'createdAt': now,
      'updatedAt': now,
    });

    return leaderboardRef.id;
  }

  static Stream<List<Leaderboard>> streamLeaderboards(String classId) {
    return _firestore
      .collection('classes')
      .doc(classId)
      .collection('leaderboards')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => Leaderboard.fromMap(doc.data())).toList());
  }

  static Future<Leaderboard?> getCurrentLeaderboard(String classId) async {
    final snapshot = await _firestore
      .collection('classes')
      .doc(classId)
      .collection('leaderboards')
      .orderBy('createdAt', descending: true)
      .get();

    if (snapshot.docs.isEmpty) return null;
    return Leaderboard.fromMap(snapshot.docs.first.data());
  }

  static Future<void> updateLeaderboardName({
    required String classId,
    required String leaderboardId,
    required String newName,
  }) async {
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

  static Future<void> createAchievement({
    required String classId,
    required String memberUid,
    required String title,
    required double points,
  }) async {
    final currentLeaderboard = await getCurrentLeaderboard(classId);
    if (currentLeaderboard == null) {
      return;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final achievementRef = _firestore
      .collection('classes')
      .doc(classId)
      .collection('achievements')
      .doc();

    await achievementRef.set({
      'achievementId': achievementRef.id,
      'classId': classId,
      'leaderboardId': currentLeaderboard.leaderboardId,
      'memberUid': memberUid,
      'title': title,
      'points': points,
      'awardedAt': now,
    });
  }

  static Stream<List<Achievement>> streamMemberAchievements({
    required String classId,
    required String leaderboardId,
    required String memberUid,
  }) {
    return _firestore
      .collection('classes')
      .doc(classId)
      .collection('achievements')
      .where('leaderboardId', isEqualTo: leaderboardId)
      .where('memberUid', isEqualTo: memberUid)
      .orderBy('awardedAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => Achievement.fromMap(doc.data())).toList());
  }

  static Stream<List<LeaderboardEntry>> streamLeaderboardEntries({
    required String classId,
    required String leaderboardId,
    required String currentUserUid,
  }) {
    return _firestore
      .collection('classes')
      .doc(classId)
      .collection('achievements')
      .where('leaderboardId', isEqualTo: leaderboardId)
      .snapshots()
      .asyncMap((achievementSnapshot) async {
        final Map<String, double> pointsByMember = {};
        final Map<String, int> countByMember = {};

        for (final doc in achievementSnapshot.docs) {
          final achievement = Achievement.fromMap(doc.data());
          pointsByMember[achievement.memberUid] = (pointsByMember[achievement.memberUid] ?? 0) + achievement.points;
          countByMember[achievement.memberUid] = (countByMember[achievement.memberUid] ?? 0) + 1;
        }

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

        final entries = <LeaderboardEntry>[];
        for (final memberUid in pointsByMember.keys) {
          final member = memberMap[memberUid];
          entries.add(LeaderboardEntry(
            rank: 0,
            memberUid: memberUid,
            memberName: member?.name ?? 'Thành viên',
            memberAvatarUrl: member?.avatarUrl,
            totalPoints: pointsByMember[memberUid] ?? 0,
            achievementCount: countByMember[memberUid] ?? 0,
            isCurrentUser: memberUid == currentUserUid,
          ));
        }

        entries.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));

        for (int i = 0; i < entries.length; i++) {
          entries[i] = entries[i].copyWith(rank: i + 1);
        }

        return entries;
      });
  }

  static Stream<List<LeaderboardEntry>> streamTopEntries({
    required String classId,
    required String currentUserUid,
    int limit = 3,
  }) {
    return Stream.fromFuture(getCurrentLeaderboard(classId))
      .asyncExpand((leaderboard) {
        if (leaderboard == null)
          return Stream.value(<LeaderboardEntry>[]);

        return streamLeaderboardEntries(
          classId: classId,
          leaderboardId: leaderboard.leaderboardId,
          currentUserUid: currentUserUid,
        ).map((entries) => entries.take(limit).toList());
      });
  }
}
