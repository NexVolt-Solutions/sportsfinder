import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sport_finding/Data/Repositories/Notification/notification_reop.dart';
import 'package:sport_finding/Data/Repositories/NotificationRead/notification_read_repository.dart';
import 'package:sport_finding/Data/Repositories/NotificationReadAll/notification_read_all_repository.dart';
import 'package:sport_finding/Data/Repositories/NotificationSettings/notification_settings_repository.dart';
import 'package:sport_finding/Data/model/Notification/notification_model.dart';
import 'package:sport_finding/Data/model/NotificationSettings/notification_settings_model.dart';
import 'package:sport_finding/core/Network/profile_service.dart';
import 'package:sport_finding/core/Storage/app_preferences.dart';
import 'package:sport_finding/core/utils/logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class NotificationService extends ChangeNotifier {
  NotificationService() {
    Future<void>.microtask(ensureRealtimeConnected);
  }

  final NotificationRepository _repo = NotificationRepository();
  final NotificationReadRepository _readRepository = NotificationReadRepository();
  final NotificationReadAllRepository _readAllRepository =
      NotificationReadAllRepository();
  final NotificationSettingsRepository _settingsRepository =
      NotificationSettingsRepository();
  static const String _baseWs = 'wss://api.sportfinding.com';

  List<NotificationModel> notifications = [];
  bool isLoading = false;
  bool isMarkingAllRead = false;
  bool isUpdatingPreference = false;
  bool _isRealtimeConnected = false;
  WebSocketChannel? _channel;
  Timer? _pingTimer;
  final Set<String> _hiddenNotificationIds = <String>{};
  DateTime? _notificationsClearedAt;

  int get unreadCount => notifications.where((item) => !item.isRead).length;
  bool get hasUnread => unreadCount > 0;
  bool get notificationsEnabled => ProfileService().notificationsEnabled;
  bool get isRealtimeConnected => _isRealtimeConnected;

  Future<void> ensureRealtimeConnected() async {
    if (_channel != null) return;
    final token = await AppPreferences.getAccessToken();
    if (token == null || token.isEmpty) return;

    final uri = Uri.parse(
      '$_baseWs/ws/notifications?token=${Uri.encodeQueryComponent(token)}',
    );

    try {
      _channel = WebSocketChannel.connect(uri);
      _channel!.stream.listen(
        (dynamic data) {
          if (data is! String) return;
          _handleRealtimeEvent(jsonDecode(data) as Map<String, dynamic>);
        },
        onError: (Object error) {
          AppLogger.error(
            'Notification WebSocket error',
            tag: 'NotificationService',
            error: error,
          );
          _cleanupRealtimeState();
        },
        onDone: () {
          AppLogger.warning(
            'Notification WebSocket closed',
            tag: 'NotificationService',
          );
          _cleanupRealtimeState();
        },
      );

      _pingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
        _channel?.sink.add(jsonEncode(<String, dynamic>{'type': 'ping'}));
      });
    } catch (e) {
      AppLogger.error(
        'Failed to connect notification WebSocket',
        tag: 'NotificationService',
        error: e,
      );
      _cleanupRealtimeState();
    }
  }

  void _handleRealtimeEvent(Map<String, dynamic> event) {
    switch ('${event['type'] ?? ''}') {
      case 'connected':
        _isRealtimeConnected = true;
        notifyListeners();
        return;
      case 'notification':
        final payload = event['payload'];
        final notificationMap = payload is Map<String, dynamic>
            ? payload
            : (payload is Map ? Map<String, dynamic>.from(payload) : event);
        final incoming = NotificationModel.fromJson(notificationMap);
        if (_shouldHideNotification(incoming)) return;
        final index = notifications.indexWhere((item) => item.id == incoming.id);
        if (index >= 0) {
          notifications[index] = incoming;
        } else {
          notifications = <NotificationModel>[incoming, ...notifications];
        }
        notifyListeners();
        return;
      case 'pong':
        return;
    }
  }

  void _cleanupRealtimeState() {
    _pingTimer?.cancel();
    _pingTimer = null;
    _channel = null;
    if (_isRealtimeConnected) {
      _isRealtimeConnected = false;
      notifyListeners();
    }
  }

  Future<void> fetchNotifications() async {
    AppLogger.info(
      'Fetching notifications from /api/v1/notifications',
      tag: 'NotificationService',
    );
    isLoading = true;
    notifyListeners();

    try {
      await _loadHiddenNotificationState();
      final response = await _repo.getNotifications();
      notifications = response.items.where((item) => !_shouldHideNotification(item)).toList();
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
    _hiddenNotificationIds.add(notificationId.trim());
    unawaited(AppPreferences.setHiddenNotificationIds(_hiddenNotificationIds.toList()));
    AppLogger.info(
      'Notification removed from local UI state: $notificationId',
      tag: 'NotificationService',
    );
    notifyListeners();
  }

  Future<void> clearAllNotifications() async {
    if (notifications.isEmpty) return;
    _notificationsClearedAt = DateTime.now().toUtc();
    _hiddenNotificationIds.clear();
    await AppPreferences.clearHiddenNotificationIds();
    await AppPreferences.setNotificationsClearedAt(_notificationsClearedAt);
    notifications = <NotificationModel>[];
    AppLogger.info(
      'All notifications cleared from persisted and local UI state',
      tag: 'NotificationService',
    );
    notifyListeners();
  }

  Future<void> _loadHiddenNotificationState() async {
    _hiddenNotificationIds
      ..clear()
      ..addAll(await AppPreferences.getHiddenNotificationIds());
    _notificationsClearedAt = await AppPreferences.getNotificationsClearedAt();
  }

  bool _shouldHideNotification(NotificationModel item) {
    final trimmedId = item.id.trim();
    if (trimmedId.isNotEmpty && _hiddenNotificationIds.contains(trimmedId)) {
      return true;
    }

    final clearedAt = _notificationsClearedAt;
    if (clearedAt == null) return false;
    return !item.createdAt.toUtc().isAfter(clearedAt);
  }

  @override
  void dispose() {
    _pingTimer?.cancel();
    _channel?.sink.close();
    super.dispose();
  }
}
