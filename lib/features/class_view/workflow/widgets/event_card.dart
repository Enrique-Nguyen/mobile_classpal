import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../screens/event_details_screen.dart';
import '../screens/events_screen.dart';

class EventCard extends StatefulWidget {
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
                category: widget.category,
                registrationEndDate: widget.registrationEndDate,
                registrationEndTime: widget.registrationEndTime,
                rewardPoints: widget.rewardPoints,
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
            // Category and Reward Points (if available)
            if (widget.category != null || widget.rewardPoints != null)
              Row(
                children: [
                  if (widget.category != null) ...[
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
                            widget.category!,
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
                  if (widget.category != null && widget.rewardPoints != null)
                    const SizedBox(width: 8),
                  if (widget.rewardPoints != null) ...[
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
                            '${widget.rewardPoints} điểm',
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
            if (widget.category != null || widget.rewardPoints != null)
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
              child: _isJoined ?
                  //  Row(
                  //     children: [
                  //       Expanded(
                  //         child: ElevatedButton(
                  //           onPressed: null,
                  //           style: ElevatedButton.styleFrom(
                  //             backgroundColor: const Color(0xFFEFF2F7),
                  //             disabledBackgroundColor: const Color(0xFFEFF2F7),
                  //             elevation: 0,
                  //             shape: RoundedRectangleBorder(
                  //               borderRadius: BorderRadius.circular(14),
                  //             ),
                  //           ),
                  //           child: const Text(
                  //             "ĐÃ THAM GIA",
                  //             style: TextStyle(
                  //               fontSize: 14,
                  //               fontWeight: FontWeight.bold,
                  //               letterSpacing: 1,
                  //               color: AppColors.textSecondary,
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //       const SizedBox(width: 12),
                  //       Expanded(
                  //         child: ElevatedButton(
                  //           onPressed: _handleUnjoin,
                  //           style: ElevatedButton.styleFrom(
                  //             backgroundColor: const Color(0xFFFF6B6B),
                  //             elevation: 0,
                  //             shape: RoundedRectangleBorder(
                  //               borderRadius: BorderRadius.circular(14),
                  //             ),
                  //           ),
                  //           child: const Text(
                  //             "HỦY THAM GIA",
                  //             style: TextStyle(
                  //               fontSize: 14,
                  //               fontWeight: FontWeight.bold,
                  //               letterSpacing: 1,
                  //               color: Colors.white,
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   )
                    ElevatedButton(
                      onPressed: _handleUnjoin,
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
