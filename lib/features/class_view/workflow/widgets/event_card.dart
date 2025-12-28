import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/event.dart';
import '../screens/event_details_screen.dart';
import '../services/event_service.dart';

class EventCard extends StatelessWidget {
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
  final Event? event;
  final String? classId;
  final String? memberUid;
  final bool isAdmin;

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
    this.category,
    this.registrationEndDate,
    this.registrationEndTime,
    this.rewardPoints,
    this.event,
    this.classId,
    this.memberUid,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (event != null && classId != null && memberUid != null)
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventDetailsScreen(
                    event: event!,
                    classId: classId!,
                    memberUid: memberUid!,
                    isAdmin: isAdmin,
                  ),
                ),
              );
            }
          : null,
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
            // Category and Reward Points (if available)
            if (category != null || rewardPoints != null)
              Row(
                children: [
                  if (category != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.label_outline,
                            size: 14,
                            color: AppColors.primaryBlue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            category!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (category != null && rewardPoints != null)
                    const SizedBox(width: 8),
                  if (rewardPoints != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_outline,
                            size: 14,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$rewardPoints điểm',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.amber,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            if (category != null || rewardPoints != null)
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
            // Join/Unjoin Buttons
            SizedBox(
              width: double.infinity,
              height: 48,
              child: (event != null && classId != null && memberUid != null)
                  ? StreamBuilder<bool>(
                      stream: EventService.streamIsRegistered(classId!, event!.id, memberUid!),
                      builder: (context, snapshot) {
                        final isJoined = snapshot.data ?? false;
                        
                        if (isJoined) {
                          return ElevatedButton(
                            onPressed: () async {
                              try {
                                await EventService.unregisterFromEvent(
                                  classId: classId!,
                                  eventId: event!.id,
                                  memberUid: memberUid!,
                                );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Bạn đã hủy tham gia sự kiện'),
                                      backgroundColor: Colors.orange,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Lỗi: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6B6B),
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
                                  "HỦY THAM GIA",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return ElevatedButton(
                            onPressed: () async {
                              try {
                                await EventService.registerForEvent(
                                  classId: classId!,
                                  eventId: event!.id,
                                  memberUid: memberUid!,
                                );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Bạn đã tham gia sự kiện thành công!'),
                                      backgroundColor: AppColors.successGreen,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Lỗi: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
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
                          );
                        }
                      },
                    )
                  : ElevatedButton(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.info_outline, color: Colors.grey, size: 18),
                          SizedBox(width: 8),
                          Text(
                            "XEM CHI TIẾT",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                              color: Colors.grey,
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
