import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_header.dart';
import 'create_event_screen.dart';
import '../../../../core/models/class.dart';
import '../../../../core/models/member.dart';
import '../widgets/event_card.dart';

class Event {
  final String title;
  final String description;
  final String date;
  final String time;
  final String location;
  final int registeredCount;
  final int maxCount;
  final bool isJoinable;
  final String? category;
  final String? registrationEndDate;
  final String? registrationEndTime;
  final int? rewardPoints;

  Event({
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.location,
    required this.registeredCount,
    required this.maxCount,
    this.isJoinable = true,
    this.category,
    this.registrationEndDate,
    this.registrationEndTime,
    this.rewardPoints,
  });
}

class EventsScreenContent extends StatefulWidget {
  final Class classData;
  final Member currentMember;

  const EventsScreenContent({
    super.key,
    required this.classData,
    required this.currentMember,
  });

  @override
  State<EventsScreenContent> createState() => _EventsScreenContentState();
}

class _EventsScreenContentState extends State<EventsScreenContent> {
  final List<Event> _events = [
    Event(
      title: "Văn nghệ 20/11",
      description: "Tham dự đi để lấy điểm rèn luyện!",
      date: "Dec 1, 2024",
      time: "18:00",
      location: "Hội trường T45",
      registeredCount: 18,
      maxCount: 30,
      isJoinable: true,
      category: "Giải trí",
      registrationEndDate: "Nov 28, 2024",
      registrationEndTime: "23:59",
      rewardPoints: 15,
    ),
    Event(
      title: "Trường học không ma tóe",
      description: "Sự kiện của VTV",
      date: "Nov 30, 2024",
      time: "14:00",
      location: "Tập trung tại cổng trường",
      registeredCount: 22,
      maxCount: 30,
      isJoinable: false,
      category: "Tình nguyện",
      registrationEndDate: "Nov 27, 2024",
      registrationEndTime: "21:00",
      rewardPoints: 20,
    ),
    Event(
      title: "Talkshow về AI trong thời đại số",
      description: "Diễn giả nổi tiếng của Meta về trường",
      date: "Dec 5, 2024",
      time: "15:00",
      location: "Hội trường T35",
      registeredCount: 15,
      maxCount: 30,
      isJoinable: true,
      category: "Học tập",
      registrationEndDate: "Dec 3, 2024",
      registrationEndTime: "18:00",
      rewardPoints: 25,
    ),
  ];

  void _addEvent(Event newEvent) {
    setState(() {
      _events.insert(0, newEvent);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventsAddingScreen(
                classData: widget.classData,
              ),
            ),
          );
          if (result != null && result is Event) {
            _addEvent(result);
          }
        },
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Fixed header only
            CustomHeader(
              title: 'Events',
              subtitle: widget.classData.name,
            ),
            // Main content (scrollable)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    // Search bar (part of scrollable content)
                    TextField(
                      decoration: InputDecoration(
                        hintText: "Tìm kiếm sự kiện...",
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
                    const SizedBox(height: 20),
                    // Event cards
                    ..._events.map((event) => EventCard(
                      title: event.title,
                      description: event.description,
                      date: event.date,
                      time: event.time,
                      location: event.location,
                      registeredCount: event.registeredCount,
                      maxCount: event.maxCount,
                      isJoinable: event.isJoinable,
                      category: event.category,
                      registrationEndDate: event.registrationEndDate,
                      registrationEndTime: event.registrationEndTime,
                      rewardPoints: event.rewardPoints,
                    )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
