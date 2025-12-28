import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_classpal/core/models/notification.dart';
import 'package:mobile_classpal/features/class_view/overview/services/notification_service.dart';

class NotificationProvider {
  /// Stream thông báo của user theo ưu tiên
  static final notificationsStreamProvider = StreamProvider
    .family<List<Notification>, ({String classId, String uid})>((ref, params) {
      return NotificationService.streamUserNotifications(params.classId, params.uid);
    });

  /// Stream số lượng thông báo chưa đọc
  static final unseenCountStreamProvider = StreamProvider.family<int, ({String classId, String uid})>((ref, params) {
    return NotificationService.streamUnseenCount(params.classId, params.uid);
  });

  /// Stream 3 thông báo mới nhất cho dashboard
  static final latestNotificationsProvider = StreamProvider
    .family<List<Notification>, ({String classId, String uid})>((ref, params) {
      return NotificationService.streamLatestNotifications(params.classId, params.uid, limit: 3);
    });
}
