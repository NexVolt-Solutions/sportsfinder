import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sport_finding/Data/Repositories/DeviceToken/device_token_repository.dart';
import 'package:sport_finding/Data/model/DeviceToken/device_token_model.dart';
import 'package:sport_finding/core/Network/notification_service.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/core/utils/logger.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  AppLogger.info(
    'Background FCM received: ${message.messageId ?? 'no-id'}',
    tag: 'FcmService',
  );
}

class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();
  final DeviceTokenRepository _deviceTokenRepository = DeviceTokenRepository();

  StreamSubscription<RemoteMessage>? _onMessageOpenedSub;
  StreamSubscription<RemoteMessage>? _onMessageSub;
  StreamSubscription<String>? _tokenRefreshSub;
  bool _isInitialized = false;

  Future<void> initialize({
    required NotificationService notificationService,
    required GlobalKey<NavigatorState> navigatorKey,
  }) async {
    if (_isInitialized) return;
    _isInitialized = true;

    final messaging = FirebaseMessaging.instance;
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    AppLogger.info(
      'Notification permission: ${settings.authorizationStatus.name}',
      tag: 'FcmService',
    );

    await _syncCurrentToken();

    _tokenRefreshSub = messaging.onTokenRefresh.listen((token) async {
      await _syncTokenToBackend(token);
    });

    _onMessageSub = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      AppLogger.info(
        'Foreground FCM received: ${message.messageId ?? 'no-id'}',
        tag: 'FcmService',
      );
      unawaited(notificationService.fetchNotifications());
    });

    _onMessageOpenedSub = FirebaseMessaging.onMessageOpenedApp.listen((
      RemoteMessage message,
    ) {
      AppLogger.info(
        'FCM opened app: ${message.messageId ?? 'no-id'}',
        tag: 'FcmService',
      );
      unawaited(notificationService.fetchNotifications());
      navigatorKey.currentState?.pushNamed(RoutesName.notificationsScreen);
    });

    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      AppLogger.info(
        'App opened from terminated state via FCM',
        tag: 'FcmService',
      );
      unawaited(notificationService.fetchNotifications());
      navigatorKey.currentState?.pushNamed(RoutesName.notificationsScreen);
    }
  }

  Future<void> _syncCurrentToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      await _syncTokenToBackend(token);
    } catch (e, stackTrace) {
      AppLogger.error(
        'FCM getToken failed. Will continue without token for now.',
        tag: 'FcmService',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _syncTokenToBackend(String? token) async {
    if (token == null || token.trim().isEmpty) {
      AppLogger.warning('FCM token unavailable', tag: 'FcmService');
      return;
    }

    AppLogger.debug('FCM token: $token', tag: 'FcmService');
    final platform = _platformName();
    if (platform == null) {
      AppLogger.warning(
        'Skipping FCM token sync on unsupported platform',
        tag: 'FcmService',
      );
      return;
    }

    try {
      final response = await _deviceTokenRepository.registerDeviceToken(
        request: DeviceTokenRequestModel(token: token, platform: platform),
      );
      AppLogger.success(
        response.message?.isNotEmpty == true
            ? response.message!
            : 'FCM token synced',
        tag: 'FcmService',
      );
    } catch (e) {
      AppLogger.error('Failed to sync FCM token', tag: 'FcmService', error: e);
    }
  }

  String? _platformName() {
    if (kIsWeb) return 'web';
    if (defaultTargetPlatform == TargetPlatform.android) return 'android';
    if (defaultTargetPlatform == TargetPlatform.iOS) return 'ios';
    return null;
  }

  Future<void> dispose() async {
    await _onMessageOpenedSub?.cancel();
    await _onMessageSub?.cancel();
    await _tokenRefreshSub?.cancel();
  }
}
