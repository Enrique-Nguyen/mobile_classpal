import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_classpal/core/models/notification.dart';
import 'package:mobile_classpal/features/class_view/overview/services/notification_service.dart';

class NotificationProvider {
  static final notificationsStreamProvider = StreamProvider
    .family<List<Notification>, ({String classId, String uid})>((ref, params) {
      return NotificationService.streamUserNotifications(params.classId, params.uid);
    });

  static final unseenCountStreamProvider = StreamProvider.family<int, ({String classId, String uid})>((ref, params) {
    return NotificationService.streamUnseenCount(params.classId, params.uid);
  });

  static final latestNotificationsProvider = StreamProvider
    .family<List<Notification>, ({String classId, String uid})>((ref, params) {
      return NotificationService.streamLatestNotifications(
        classId: params.classId,
        uid: params.uid,
        limit: 3,
      );
    });
}
