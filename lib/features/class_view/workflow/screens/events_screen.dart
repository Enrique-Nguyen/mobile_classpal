import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_header.dart';
import '../../../../core/models/class.dart';
import '../../../../core/models/member.dart';

class EventCard extends StatelessWidget {
  final String title;
  final String description;
  final String date;
  final String time;
  final String location;
  final int registeredCount;
  final int maxCount;
  final bool isJoinable;

  const EventCard({
    super.key,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.location,
    required this.registeredCount,
    required this.maxCount,
    this.isJoinable = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          // Description
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          // Info Row (Date & Location)
          Row(
            children: [
              _buildIconText(Icons.calendar_today_outlined, "$date\n$time"),
              const SizedBox(width: 24),
              _buildIconText(Icons.location_on_outlined, location),
            ],
          ),
          const SizedBox(height: 16),
          // Join Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: isJoinable
                    ? AppColors.primaryBlue
                    : const Color(0xFFEFF2F7),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isJoinable)
                    const Icon(Icons.check, color: Colors.white, size: 18),
                  if (isJoinable) const SizedBox(width: 8),
                  Text(
                    "JOIN",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: isJoinable
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Registration Progress
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Registered",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                Text(
                  "$registeredCount/$maxCount",
                  style: const TextStyle(
                    color: AppColors.successGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.primaryBlue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EventsScreenContent extends StatelessWidget {
  final Class classData;
  final Member currentMember;

  const EventsScreenContent({
    super.key,
    required this.classData,
    required this.currentMember,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header (consistent with other screens) - dynamic subtitle
            CustomHeader(
              title: 'Events & Attendance',
              subtitle: classData.name,
            ),
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search events...",
                  hintStyle: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.textSecondary,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),
            // List of Events
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: const [
                  EventCard(
                    title: "Văn nghệ 20/11",
                    description: "Tham dự đi để lấy điểm rèn luyện!",
                    date: "Dec 1, 2024",
                    time: "18:00 - 22:00",
                    location: "Hội trường T45",
                    registeredCount: 18,
                    maxCount: 30,
                    isJoinable: true,
                  ),
                  EventCard(
                    title: "Trường học không ma tóe",
                    description: "Sự kiện của VTV",
                    date: "Nov 30, 2024",
                    time: "14:00 - 17:00",
                    location: "Tập trung tại cổng trường",
                    registeredCount: 22,
                    maxCount: 30,
                    isJoinable: false,
                  ),
                  EventCard(
                    title: "Talkshow về AI trong thời đại số",
                    description: "Diễn giả nổi tiếng của Meta về trường",
                    date: "Dec 5, 2024",
                    time: "15:00 - 17:00",
                    location: "Hội trường T35",
                    registeredCount: 15,
                    maxCount: 30,
                    isJoinable: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
