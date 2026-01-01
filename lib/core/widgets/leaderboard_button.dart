import 'package:flutter/material.dart';
import '../models/class.dart';
import '../models/member.dart';
import 'package:mobile_classpal/features/class_view/leaderboard/screens/leaderboards_screen.dart';

/// Reusable leaderboard button widget
/// Navigates to LeaderboardsScreen on tap
class LeaderboardButton extends StatelessWidget {
  final Class classData;
  final Member currentMember;
  
  /// Whether to use dark theme (white icon on transparent/dark bg)
  final bool isDarkTheme;

  const LeaderboardButton({
    super.key,
    required this.classData,
    required this.currentMember,
    this.isDarkTheme = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LeaderboardsScreen(
            classData: classData,
            currentMember: currentMember,
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDarkTheme 
              ? Colors.white.withOpacity(0.1) 
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isDarkTheme 
              ? null 
              : Border.all(color: Colors.grey.shade200),
        ),
        child: Icon(
          Icons.emoji_events_outlined,
          color: isDarkTheme ? Colors.white : Colors.black87,
          size: 20,
        ),
      ),
    );
  }
}
