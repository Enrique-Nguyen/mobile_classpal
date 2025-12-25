import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_header.dart';
import 'create_event_screen.dart';
import '../../../../core/models/class.dart';
import '../../../../core/models/member.dart';
import '../../../../core/models/event.dart';
import '../widgets/event_card.dart';
import '../services/event_service.dart';

class EventsScreenContent extends ConsumerStatefulWidget {
  final Class classData;
  final Member currentMember;

  const EventsScreenContent({
    super.key,
    required this.classData,
    required this.currentMember,
  });

  @override
  ConsumerState<EventsScreenContent> createState() => _EventsScreenContentState();
}

class _EventsScreenContentState extends ConsumerState<EventsScreenContent> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  Stream<List<Event>> get _eventsStream => EventService.streamEvents(widget.classData.classId);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Event> _filterEvents(List<Event> events) {
    if (_searchQuery.isEmpty) return events;
    return events.where((event) {
      return event.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('MMM d, yyyy').format(dateTime);
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final canManage = widget.currentMember.role == MemberRole.quanLyLop || 
                      widget.currentMember.role == MemberRole.canBoLop;

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: canManage ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventsAddingScreen(
                classData: widget.classData,
                currentMember: widget.currentMember,
              ),
            ),
          );
        },
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ) : null,
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
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const SizedBox(height: 10),
                  // Search bar (part of scrollable content)
                  TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
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
                  // Event cards from Firebase
                  StreamBuilder<List<Event>>(
                    stream: _eventsStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Lỗi: ${snapshot.error}'));
                      }

                      final events = _filterEvents(snapshot.data ?? []);

                      if (events.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.event_note,
                                  size: 64,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isEmpty
                                      ? 'Chưa có sự kiện nào'
                                      : 'Không tìm thấy sự kiện',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: events.map((event) {
                          return StreamBuilder<int>(
                            stream: EventService.streamRegisteredCount(
                              widget.classData.classId,
                              event.id,
                            ),
                            builder: (context, countSnapshot) {
                              final registeredCount = countSnapshot.data ?? 0;
                              final isJoinable = DateTime.now().isBefore(event.signupEndTime);

                              return EventCard(
                                title: event.name,
                                description: event.description ?? '',
                                date: _formatDate(event.startTime),
                                time: _formatTime(event.startTime),
                                location: event.location ?? '',
                                registeredCount: registeredCount,
                                maxCount: event.maxQuantity.toInt(),
                                isJoinable: isJoinable,
                                category: event.ruleName,
                                registrationEndDate: _formatDate(event.signupEndTime),
                                registrationEndTime: _formatTime(event.signupEndTime),
                                rewardPoints: event.points.toInt(),
                                event: event,
                                classId: widget.classData.classId,
                                memberUid: widget.currentMember.uid,
                              );
                            },
                          );
                        }).toList(),
                      );
                    },
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
