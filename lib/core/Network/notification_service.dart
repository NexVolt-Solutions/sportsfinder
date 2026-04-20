import 'package:flutter/material.dart';
import 'package:sport_finding/Data/Repositories/Notification/notification_reop.dart';
import 'package:sport_finding/Data/model/Notification/notification_model.dart';
import 'package:sport_finding/core/utils/logger.dart';

class NotificationService extends ChangeNotifier {
  final NotificationRepository _repo = NotificationRepository();

  List<NotificationModel> notifications = [];
  bool isLoading = false;

  Future<void> fetchNotifications() async {
    AppLogger.info(
      'Fetching notifications from /api/v1/notifications',
      tag: 'NotificationService',
    );
    isLoading = true;
    notifyListeners();

    try {
      final response = await _repo.getNotifications();
      notifications = response.items;
      AppLogger.success(
        'Notifications fetched successfully: ${notifications.length} item(s)',
        tag: 'NotificationService',
      );
      if (notifications.isEmpty) {
        AppLogger.warning(
          'No notifications found for current user',
          tag: 'NotificationService',
        );
      }
    } catch (e) {
      AppLogger.error(
        'Failed to fetch notifications',
        tag: 'NotificationService',
        error: e,
      );
    }

    isLoading = false;
    notifyListeners();
  }

  void removeNotificationById(String notificationId) {
    final next = notifications.withoutNotificationId(notificationId);
    if (next.length == notifications.length) {
      AppLogger.debug(
        'No notification removed because id was not found: $notificationId',
        tag: 'NotificationService',
      );
      return;
    }

    notifications = next;
    AppLogger.info(
      'Notification removed from local UI state: $notificationId',
      tag: 'NotificationService',
    );
    notifyListeners();
  }
}
