import 'package:flutter/material.dart';
import 'package:sport_finding/Data/Repositories/Notification/notification_reop.dart';
import 'package:sport_finding/Data/Repositories/NotificationRead/notification_read_repository.dart';
import 'package:sport_finding/Data/Repositories/NotificationReadAll/notification_read_all_repository.dart';
import 'package:sport_finding/Data/Repositories/NotificationSettings/notification_settings_repository.dart';
import 'package:sport_finding/Data/model/Notification/notification_model.dart';
import 'package:sport_finding/Data/model/NotificationSettings/notification_settings_model.dart';
import 'package:sport_finding/core/Network/profile_service.dart';
import 'package:sport_finding/core/utils/logger.dart';

class NotificationService extends ChangeNotifier {
  final NotificationRepository _repo = NotificationRepository();
  final NotificationReadRepository _readRepository = NotificationReadRepository();
  final NotificationReadAllRepository _readAllRepository =
      NotificationReadAllRepository();
  final NotificationSettingsRepository _settingsRepository =
      NotificationSettingsRepository();

  List<NotificationModel> notifications = [];
  bool isLoading = false;
  bool isMarkingAllRead = false;
  bool isUpdatingPreference = false;

  int get unreadCount => notifications.where((item) => !item.isRead).length;
  bool get hasUnread => unreadCount > 0;
  bool get notificationsEnabled => ProfileService().notificationsEnabled;

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

  Future<String?> markAsRead(String notificationId) async {
    final trimmedId = notificationId.trim();
    if (trimmedId.isEmpty) return null;

    final target = notifications.where((item) => item.id.trim() == trimmedId);
    if (target.isEmpty || target.first.isRead) {
      return null;
    }

    try {
      final response = await _readRepository.markAsRead(notificationId: trimmedId);
      notifications = notifications.withNotificationMarkedRead(trimmedId);
      notifyListeners();
      return response.message;
    } catch (e) {
      AppLogger.error(
        'Failed to mark notification as read: $trimmedId',
        tag: 'NotificationService',
        error: e,
      );
      rethrow;
    }
  }

  Future<String?> markAllAsRead() async {
    if (isMarkingAllRead || !hasUnread) return null;

    isMarkingAllRead = true;
    notifyListeners();

    try {
      final response = await _readAllRepository.markAllAsRead();
      notifications = notifications.allMarkedRead();
      return response.message;
    } catch (e) {
      AppLogger.error(
        'Failed to mark all notifications as read',
        tag: 'NotificationService',
        error: e,
      );
      rethrow;
    } finally {
      isMarkingAllRead = false;
      notifyListeners();
    }
  }

  Future<String?> updateNotificationPreference(bool enabled) async {
    if (isUpdatingPreference) return null;

    isUpdatingPreference = true;
    notifyListeners();

    try {
      final response = await _settingsRepository.updateNotificationPreference(
        request: NotificationSettingsRequestModel(
          notificationsEnabled: enabled,
        ),
      );
      ProfileService().updateNotificationPreference(
        response.notificationsEnabled ?? enabled,
      );
      return response.message;
    } catch (e) {
      AppLogger.error(
        'Failed to update notification preference',
        tag: 'NotificationService',
        error: e,
      );
      rethrow;
    } finally {
      isUpdatingPreference = false;
      notifyListeners();
    }
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
