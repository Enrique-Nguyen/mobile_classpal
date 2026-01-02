import 'package:flutter/material.dart';
import 'package:mobile_classpal/core/models/duty.dart';
import 'package:mobile_classpal/core/models/task.dart';

enum DutyExtraType {
  location,
  amount
}

class DutyExtraInfo {
  final DutyExtraType type;
  final String value;

  const DutyExtraInfo({required this.type, required this.value});

  IconData get icon => type == DutyExtraType.location ? Icons.location_on_outlined : Icons.payments_outlined;
  String get label => type == DutyExtraType.location ? 'Địa điểm' : 'Số tiền';
}

class DutyWithTask {
  final Duty duty;
  final Task task;

  const DutyWithTask({
    required this.duty,
    required this.task,
  });
}

class DutyHelper {
  static DutyExtraInfo? parseNoteField(Duty d) {
    if (d.note == null || d.note!.isEmpty)
      return null;
    
    if (d.originType == "event") {
      return DutyExtraInfo(
        type: DutyExtraType.location,
        value: d.note!,
      );
    }
    else if (d.originType == "funds") {
      final amount = int.tryParse(d.note!) ?? 0;
      return DutyExtraInfo(
        type: DutyExtraType.amount,
        value: _formatCurrency(amount),
      );
    }

    return null;
  }

  static String _formatCurrency(int amount) {
    return '₫${amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }

  static bool shouldShowDuty(Duty duty, List<Task> tasks) {
    if (duty.isEnded)
      return false;
    
    // If no tasks or not all completed, always show
    if (tasks.isEmpty)
      return true;
    final allCompleted = tasks.every((t) => t.status == TaskStatus.completed);
    if (!allCompleted)
      return true;
    
    // All tasks completed - check if we're past midnight of the next day
    final now = DateTime.now();
    final endDate = DateTime(duty.endTime.year, duty.endTime.month, duty.endTime.day);
    final nextDayMidnight = endDate.add(const Duration(days: 1));

    return now.isBefore(nextDayMidnight);
  }
}
