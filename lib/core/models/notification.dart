enum NotificationType {
  duty,
  event,
  fund;

  String get displayName {
    switch (this) {
      case NotificationType.duty:
        return 'NHIỆM VỤ';
      case NotificationType.event:
        return 'SỰ KIỆN';
      case NotificationType.fund:
        return 'QUỸ';
    }
  }

  static NotificationType fromString(String type) {
    switch (type) {
      case 'duty':
        return NotificationType.duty;
      case 'event':
        return NotificationType.event;
      case 'fund':
        return NotificationType.fund;
      default:
        return NotificationType.duty;
    }
  }
}

class Notification {
  final String notificationId;
  final String uid; // recipient member uid
  final NotificationType type;
  final String title;
  final String subtitle;
  final String? referenceId;
  final DateTime? signupEndTime;
  final DateTime? startTime;
  final DateTime createdAt;
  final DateTime? seenAt;

  Notification({
    required this.notificationId,
    required this.uid,
    required this.type,
    required this.title,
    required this.subtitle,
    this.referenceId,
    this.signupEndTime,
    this.startTime,
    required this.createdAt,
    this.seenAt,
  });

  bool get isSeen => seenAt != null;

  Map<String, dynamic> toMap() {
    return {
      'notificationId': notificationId,
      'uid': uid,
      'type': type.name,
      'title': title,
      'subtitle': subtitle,
      'referenceId': referenceId,
      'signupEndTime': signupEndTime?.millisecondsSinceEpoch,
      'startTime': startTime?.millisecondsSinceEpoch,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'seenAt': seenAt?.millisecondsSinceEpoch,
    };
  }

  factory Notification.fromMap(Map<String, dynamic> map) {
    return Notification(
      notificationId: map['notificationId'] ?? '',
      uid: map['uid'] ?? '',
      type: NotificationType.fromString(map['type'] ?? 'duty'),
      title: map['title'] ?? '',
      subtitle: map['subtitle'] ?? '',
      referenceId: map['referenceId'],
      signupEndTime: map['signupEndTime'] != null
        ? DateTime.fromMillisecondsSinceEpoch(map['signupEndTime'])
        : null,
      startTime: map['startTime'] != null
        ? DateTime.fromMillisecondsSinceEpoch(map['startTime'])
        : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      seenAt: map['seenAt'] != null
        ? DateTime.fromMillisecondsSinceEpoch(map['seenAt'])
        : null,
    );
  }

  Notification copyWith({
    String? notificationId,
    String? uid,
    NotificationType? type,
    String? title,
    String? subtitle,
    String? referenceId,
    DateTime? signupEndTime,
    DateTime? startTime,
    DateTime? createdAt,
    DateTime? seenAt,
  }) {
    return Notification(
      notificationId: notificationId ?? this.notificationId,
      uid: uid ?? this.uid,
      type: type ?? this.type,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      referenceId: referenceId ?? this.referenceId,
      signupEndTime: signupEndTime ?? this.signupEndTime,
      startTime: startTime ?? this.startTime,
      createdAt: createdAt ?? this.createdAt,
      seenAt: seenAt ?? this.seenAt,
    );
  }
}
