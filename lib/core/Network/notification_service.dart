import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:sport_finding/Data/Repositories/Notification/notification_reop.dart';
import 'package:sport_finding/Data/Repositories/NotificationRead/notification_read_repository.dart';
import 'package:sport_finding/Data/Repositories/NotificationReadAll/notification_read_all_repository.dart';
import 'package:sport_finding/Data/Repositories/NotificationSettings/notification_settings_repository.dart';
import 'package:sport_finding/Data/model/Notification/notification_model.dart';
import 'package:sport_finding/Data/model/NotificationSettings/notification_settings_model.dart';
import 'package:sport_finding/core/Network/api_service.dart';
import 'package:sport_finding/core/Network/profile_service.dart';
import 'package:sport_finding/core/Storage/app_preferences.dart';
import 'package:sport_finding/core/utils/logger.dart';
import 'package:sport_finding/core/utils/reconnect_scheduler.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

typedef NotificationWsConnector =
    WebSocketChannel Function(Uri uri, Map<String, dynamic> headers);
typedef NotificationReconnectDelayForAttempt = Duration Function(int attempt);
typedef NotificationTokenProvider = Future<String?> Function();

class NotificationService extends ChangeNotifier {
  final NotificationRepository _repo = NotificationRepository();
  final NotificationReadRepository _readRepository = NotificationReadRepository();
  final NotificationReadAllRepository _readAllRepository =
      NotificationReadAllRepository();
  final NotificationSettingsRepository _settingsRepository =
      NotificationSettingsRepository();
  final NotificationWsConnector _wsConnector;
  final NotificationTokenProvider _tokenProvider;
  final Duration _pingInterval;
  final String _baseWs;

  List<NotificationModel> notifications = [];
  bool isLoading = false;
  bool isMarkingAllRead = false;
  bool isUpdatingPreference = false;
  bool _isRealtimeConnected = false;
  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _channelSub;
  Timer? _pingTimer;
  late final ReconnectScheduler _reconnectScheduler;
  bool _isDisposed = false;
  DateTime? _retryAfter;
  String? _lastSocketErrorFingerprint;
  final Set<String> _hiddenNotificationIds = <String>{};
  DateTime? _notificationsClearedAt;

  int get unreadCount => notifications.where((item) => !item.isRead).length;
  bool get hasUnread => unreadCount > 0;
  bool get notificationsEnabled => ProfileService().notificationsEnabled;
  bool get isRealtimeConnected => _isRealtimeConnected;

  NotificationService._internal({
    required NotificationWsConnector wsConnector,
    required NotificationReconnectDelayForAttempt reconnectDelayForAttempt,
    required NotificationTokenProvider tokenProvider,
    required Duration pingInterval,
    required bool autoConnect,
    required String restBaseUrl,
  }) : _wsConnector = wsConnector,
       _tokenProvider = tokenProvider,
       _pingInterval = pingInterval,
       _baseWs = _toWsBase(restBaseUrl) {
    _reconnectScheduler = ReconnectScheduler(
      delayForAttempt: reconnectDelayForAttempt,
    );
    if (autoConnect) {
      Future<void>.microtask(ensureRealtimeConnected);
    }
  }

  factory NotificationService({
    NotificationWsConnector? wsConnector,
    NotificationReconnectDelayForAttempt? reconnectDelayForAttempt,
    NotificationTokenProvider? tokenProvider,
    bool autoConnect = true,
    Duration pingInterval = const Duration(seconds: 30),
    String? restBaseUrl,
  }) {
    return NotificationService._internal(
      wsConnector: wsConnector ?? _defaultWsConnector,
      reconnectDelayForAttempt:
          reconnectDelayForAttempt ?? _defaultReconnectDelay,
      tokenProvider: tokenProvider ?? AppPreferences.getAccessToken,
      pingInterval: pingInterval,
      autoConnect: autoConnect,
      restBaseUrl: (restBaseUrl ?? ApiService().baseUrl).trim(),
    );
  }
  static WebSocketChannel _defaultWsConnector(
    Uri uri,
    Map<String, dynamic> headers,
  ) {
    if (kIsWeb) {
      return WebSocketChannel.connect(uri);
    }
    return IOWebSocketChannel.connect(uri, headers: headers);
  }

  static Duration _defaultReconnectDelay(int attempt) {
    if (attempt <= 1) return const Duration(seconds: 1);
    if (attempt <= 3) return const Duration(seconds: 2);
    return const Duration(seconds: 5);
  }

  static String _toWsBase(String restBaseUrl) {
    final uri = Uri.parse(restBaseUrl);
    final wsScheme = uri.scheme == 'https' ? 'wss' : 'ws';
    return uri.replace(scheme: wsScheme, path: '', query: null).toString();
  }

  Uri _notificationsWsUri(String token) {
    return Uri.parse(
      '$_baseWs/ws/notifications?token=${Uri.encodeQueryComponent(token)}',
    );
  }

  Map<String, dynamic> _authHeaders(String token) {
    return <String, dynamic>{HttpHeaders.authorizationHeader: 'Bearer $token'};
  }

  Future<void> ensureRealtimeConnected() async {
    if (_isDisposed || _channel != null) return;
    if (_retryAfter != null && DateTime.now().isBefore(_retryAfter!)) return;
    _reconnectScheduler.cancel();
    final token = await _tokenProvider();
    if (token == null || token.isEmpty) return;

    try {
      _channel = _wsConnector(
        _notificationsWsUri(token),
        _authHeaders(token),
      );
      _channelSub = _channel!.stream.listen(
        (dynamic data) {
          if (data is! String) return;
          _handleRealtimeEvent(jsonDecode(data) as Map<String, dynamic>);
        },
        onError: (Object error) {
          _handleSocketError(error);
        },
        onDone: () {
          _handleSocketDone();
        },
        cancelOnError: true,
      );

      _pingTimer = Timer.periodic(_pingInterval, (_) {
        try {
          _channel?.sink.add(jsonEncode(<String, dynamic>{'type': 'ping'}));
        } catch (e) {
          _handleSocketError(e);
        }
      });
      final dynamic dynamicChannel = _channel;
      final dynamic readyFuture = dynamicChannel?.ready;
      if (readyFuture is Future) {
        unawaited(
          readyFuture.catchError((Object e) {
            _handleSocketError(e);
          }),
        );
      }
    } catch (e) {
      AppLogger.error(
        'Failed to connect notification WebSocket',
        tag: 'NotificationService',
        error: e,
      );
      _cleanupRealtimeState();
      _scheduleReconnect();
    }
  }

  void _handleRealtimeEvent(Map<String, dynamic> event) {
    switch ('${event['type'] ?? ''}') {
      case 'connected':
        _reconnectScheduler.resetAttempts();
        _setRealtimeConnected(true);
        return;
      case 'notification':
        final incoming = _notificationFromRealtimeEvent(event);
        if (_shouldHideNotification(incoming)) return;
        _upsertNotification(incoming);
        notifyListeners();
        return;
      case 'pong':
        return;
      case 'error':
        AppLogger.warning(
          'Notification socket error event: ${event['detail'] ?? 'unknown'}',
          tag: 'NotificationService',
        );
        return;
    }
  }

  void _cleanupRealtimeState() {
    _pingTimer?.cancel();
    _pingTimer = null;
    _channelSub?.cancel();
    _channelSub = null;
    _channel = null;
    _setRealtimeConnected(false);
  }

  void _setRealtimeConnected(bool value) {
    if (_isRealtimeConnected == value) return;
    _isRealtimeConnected = value;
    notifyListeners();
  }

  void _handleSocketError(Object error) {
    _applyTemporaryBackoffIfNeeded(error);
    final fingerprint = error.toString();
    if (_lastSocketErrorFingerprint == fingerprint) {
      _cleanupRealtimeState();
      _scheduleReconnect();
      return;
    }
    _lastSocketErrorFingerprint = fingerprint;
    AppLogger.error(
      'Notification WebSocket error',
      tag: 'NotificationService',
      error: error,
    );
    _cleanupRealtimeState();
    _scheduleReconnect();
  }

  void _handleSocketDone() {
    final closeCode = _channel?.closeCode;
    AppLogger.warning(
      'Notification WebSocket closed (code=$closeCode)',
      tag: 'NotificationService',
    );
    _cleanupRealtimeState();
    if (_shouldReconnect(closeCode)) {
      _scheduleReconnect();
    }
  }

  void _applyTemporaryBackoffIfNeeded(Object error) {
    if (error is SocketException &&
        error.message.toLowerCase().contains('failed host lookup')) {
      _retryAfter = DateTime.now().add(const Duration(seconds: 30));
      AppLogger.warning(
        'Notification WebSocket host lookup failed; retrying in 30s.',
        tag: 'NotificationService',
      );
    } else {
      _retryAfter = null;
    }
  }

  NotificationModel _notificationFromRealtimeEvent(Map<String, dynamic> event) {
    final payload = event['payload'];
    final notificationType = '${event['notification_type'] ?? ''}'.trim();
    final payloadMap = payload is Map<String, dynamic>
        ? payload
        : (payload is Map ? Map<String, dynamic>.from(payload) : <String, dynamic>{});
    final notificationMap = <String, dynamic>{
      ...payloadMap,
      if (payloadMap['id'] == null)
        'id': '${notificationType.isNotEmpty ? notificationType : 'notification'}_${DateTime.now().microsecondsSinceEpoch}',
      if (payloadMap['type'] == null)
        'type': notificationType.isNotEmpty ? notificationType : '${event['type'] ?? 'notification'}',
      if (payloadMap['payload'] == null) 'payload': payloadMap,
      if (payloadMap['is_read'] == null) 'is_read': false,
      if (payloadMap['created_at'] == null)
        'created_at': DateTime.now().toUtc().toIso8601String(),
    };
    return NotificationModel.fromJson(notificationMap);
  }

  void _upsertNotification(NotificationModel incoming) {
    final index = notifications.indexWhere((item) => item.id == incoming.id);
    if (index >= 0) {
      notifications[index] = incoming;
    } else {
      notifications = <NotificationModel>[incoming, ...notifications];
    }
    _sortNotificationsNewestFirst();
  }

  /// Newest first so Today/Yesterday/Earlier sections show latest at the top.
  void _sortNotificationsNewestFirst() {
    notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  void _scheduleReconnect() {
    _reconnectScheduler.schedule(
      canSchedule: () => !_isDisposed && _channel == null,
      onFire: ensureRealtimeConnected,
    );
  }

  bool _shouldReconnect(int? closeCode) {
    if (closeCode == 4001) {
      return false;
    }
    return true;
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
      _sortNotificationsNewestFirst();
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

    final profile = ProfileService();
    final previous = profile.notificationsEnabled;

    isUpdatingPreference = true;
    profile.updateNotificationPreference(enabled);
    notifyListeners();

    try {
      final response = await _settingsRepository.updateNotificationPreference(
        request: NotificationSettingsRequestModel(notificationsEnabled: enabled),
      );
      final server = response.notificationsEnabled;
      if (server != null && server != enabled) {
        profile.updateNotificationPreference(server);
      }
      final msg = response.message.trim();
      return msg.isNotEmpty ? msg : 'Notification preference updated';
    } catch (e) {
      profile.updateNotificationPreference(previous);
      AppLogger.error(
        'Failed to update notification preference on server',
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
    _isDisposed = true;
    _reconnectScheduler.cancel();
    _channelSub?.cancel();
    _channelSub = null;
    _pingTimer?.cancel();
    _channel?.sink.close();
    super.dispose();
  }
}
