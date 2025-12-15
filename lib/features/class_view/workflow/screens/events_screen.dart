import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_header.dart';
import 'create_event_screen.dart';
import 'event_details_screen.dart';
import '../../../../core/models/class.dart';
import '../../../../core/models/member.dart';

class Event {
  final String title;
  final String description;
  final String date;
  final String time;
  final String location;
  final int registeredCount;
  final int maxCount;
  final bool isJoinable;

  Event({
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.location,
    required this.registeredCount,
    required this.maxCount,
    this.isJoinable = true,
  });
}

class EventCard extends StatefulWidget {
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
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  late bool _isJoined;

  @override
  void initState() {
    super.initState();
    _isJoined = !widget.isJoinable;
  }

  void _handleJoin() {
    setState(() {
      _isJoined = true;
    });
  }

  void _handleUnjoin() {
    setState(() {
      _isJoined = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailsScreen(
              event: Event(
                title: widget.title,
                description: widget.description,
                date: widget.date,
                time: widget.time,
                location: widget.location,
                registeredCount: widget.registeredCount,
                maxCount: widget.maxCount,
                isJoinable: widget.isJoinable,
              ),
            ),
          ),
        );
      },
      child: Container(
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
            widget.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          // Description
          Text(
            widget.description,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          // Info Row (Date & Location)
          Row(
            children: [
              _buildIconText(Icons.calendar_today_outlined, "${widget.date}\n${widget.time}"),
              const SizedBox(width: 24),
              _buildIconText(Icons.location_on_outlined, widget.location),
            ],
          ),
          const SizedBox(height: 16),
          // Join/Unjoin Buttons
          SizedBox(
            width: double.infinity,
            height: 48,
            child: _isJoined
                ? Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEFF2F7),
                            disabledBackgroundColor: const Color(0xFFEFF2F7),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            "ĐÃ THAM GIA",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _handleUnjoin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6B6B),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            "HỦY THAM GIA",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : ElevatedButton(
                    onPressed: _handleJoin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text(
                          "THAM GIA",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            color: Colors.white,
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
                  "Đã đăng ký",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                Text(
                  "${widget.registeredCount}/${widget.maxCount}",
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
      time: "18:00 - 22:00",
      location: "Hội trường T45",
      registeredCount: 18,
      maxCount: 30,
      isJoinable: true,
    ),
    Event(
      title: "Trường học không ma tóe",
      description: "Sự kiện của VTV",
      date: "Nov 30, 2024",
      time: "14:00 - 17:00",
      location: "Tập trung tại cổng trường",
      registeredCount: 22,
      maxCount: 30,
      isJoinable: false,
    ),
    Event(
      title: "Talkshow về AI trong thời đại số",
      description: "Diễn giả nổi tiếng của Meta về trường",
      date: "Dec 5, 2024",
      time: "15:00 - 17:00",
      location: "Hội trường T35",
      registeredCount: 15,
      maxCount: 30,
      isJoinable: true,
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
