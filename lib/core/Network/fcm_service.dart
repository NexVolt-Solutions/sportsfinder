import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sport_finding/Data/Repositories/DeviceToken/device_token_repository.dart';
import 'package:sport_finding/Data/model/DeviceToken/device_token_model.dart';
import 'package:sport_finding/Data/model/discovery_match.dart';
import 'package:sport_finding/core/Network/fcm_local_notifications.dart';
import 'package:sport_finding/core/Network/notification_service.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/core/Storage/app_preferences.dart';
import 'package:sport_finding/core/utils/logger.dart';
import 'package:sport_finding/core/utils/network_errors.dart';

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
  Timer? _tokenRetryTimer;
  bool _isTokenSyncInFlight = false;
  int _tokenRetryAttempt = 0;
  bool _webTokenSyncBlockedByNetworkPolicy = false;
  DateTime? _tokenSyncHardFailureUntil;
  static const Duration _hardFailureCooldown = Duration(minutes: 30);
  static const List<Duration> _tokenRetryDelays = <Duration>[
    Duration(seconds: 1),
    Duration(seconds: 2),
    Duration(seconds: 5),
    Duration(seconds: 10),
    Duration(seconds: 20),
    Duration(seconds: 30),
  ];

  static const Set<String> _matchPushTypes = <String>{
    'match_invited',
    'match_joined',
    'match_invite_accepted',
    'match_invite_declined',
    'match_started',
    'player_removed',
  };

  Future<void> initialize({
    required NotificationService notificationService,
    required GlobalKey<NavigatorState> navigatorKey,
  }) async {
    if (_isInitialized) return;
    _isInitialized = true;

    final messaging = FirebaseMessaging.instance;
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    WidgetsBinding.instance.addObserver(_appLifecycleObserver);

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

    if (!kIsWeb) {
      await FcmLocalNotifications.init();
    }

    await _syncCurrentToken();

    _tokenRefreshSub = messaging.onTokenRefresh.listen((token) async {
      final ok = await _syncTokenToBackend(token);
      if (!ok) {
        _scheduleTokenRetry();
      }
    });

    _onMessageSub = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      AppLogger.info(
        'Foreground FCM received: ${message.messageId ?? 'no-id'}',
        tag: 'FcmService',
      );
      unawaited(FcmLocalNotifications.showForeground(message));
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
      _navigateForOpenedPush(message, navigatorKey);
    });

    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      AppLogger.info(
        'App opened from terminated state via FCM',
        tag: 'FcmService',
      );
      unawaited(notificationService.fetchNotifications());
      _navigateForOpenedPush(initialMessage, navigatorKey);
    }
  }

  /// Call after login, signup (with session), Google auth, or web token bootstrap.
  Future<void> registerTokenWithBackendIfAuthenticated() async {
    if (_isInHardFailureCooldown()) {
      AppLogger.warning(
        'Skipping FCM token sync: in hard-failure cooldown window',
        tag: 'FcmService',
      );
      return;
    }
    await _syncCurrentToken();
  }

  /// Call before clearing the backend session (still needs a valid access token).
  Future<void> deactivateForLogout() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      await _deviceTokenRepository.deactivateDeviceToken(fcmToken: token);
      AppLogger.success('FCM device token deactivated on server', tag: 'FcmService');
    } catch (e, stackTrace) {
      AppLogger.error(
        'FCM device deactivation failed (session may still clear locally)',
        tag: 'FcmService',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  void _navigateForOpenedPush(
    RemoteMessage message,
    GlobalKey<NavigatorState> navigatorKey,
  ) {
    Future<void> run() async {
      final nav = navigatorKey.currentState;
      if (nav == null) return;

      final access = await AppPreferences.getAccessToken();
      if (access == null || access.trim().isEmpty) {
        AppLogger.debug(
          'Skip FCM deep link: no backend session',
          tag: 'FcmService',
        );
        return;
      }

      final data = message.data;
      String dataString(String k) => (data[k] ?? '').toString().trim();
      final type = dataString('type').toLowerCase();
      final matchId = dataString('match_id');

      if (matchId.isNotEmpty && _matchPushTypes.contains(type)) {
        final title = message.notification?.title ?? '';
        final body = message.notification?.body ?? '';
        final stub = DiscoveryMatch.fromPushData(
          matchId: matchId,
          title: title,
          sportType: body,
          notificationBody: body,
        );
        nav.pushNamed(RoutesName.userMatchDetailsScreen, arguments: stub);
        return;
      }

      if (type == 'new_follower') {
        nav.pushNamed(RoutesName.followersScreen);
        return;
      }

      nav.pushNamed(RoutesName.notificationsScreen);
    }

    // Avoid post-frame callbacks here; on web hot restart the old view can be
    // disposed while this callback still fires.
    Future<void>.microtask(() {
      unawaited(run());
    });
  }

  Future<void> _syncCurrentToken() async {
    if (_isInHardFailureCooldown()) return;
    if (_isTokenSyncInFlight) return;
    _tokenRetryTimer?.cancel();
    _isTokenSyncInFlight = true;
    try {
      final token = await FirebaseMessaging.instance.getToken();
      final registered = await _syncTokenToBackend(token);
      if (!registered) {
        AppLogger.warning(
          'FCM device token not registered with backend (transient network). '
          'Scheduling retry.',
          tag: 'FcmService',
        );
        _scheduleTokenRetry();
        return;
      }
      _tokenRetryAttempt = 0;
    } catch (e, stackTrace) {
      if (_isHardFcmTokenFailure(e)) {
        _tokenSyncHardFailureUntil = DateTime.now().add(_hardFailureCooldown);
        _tokenRetryTimer?.cancel();
        _tokenRetryTimer = null;
        AppLogger.warning(
          'FCM token sync disabled due to hard Firebase Installations failure '
          '(FIS auth/unavailable). App will continue without push token temporarily '
          'and retry later.',
          tag: 'FcmService',
        );
        AppLogger.error(
          'FCM hard failure details',
          tag: 'FcmService',
          error: e,
          stackTrace: stackTrace,
        );
        return;
      }
      AppLogger.error(
        'FCM getToken failed. Will continue without token for now.',
        tag: 'FcmService',
        error: e,
        stackTrace: stackTrace,
      );
      _scheduleTokenRetry();
    } finally {
      _isTokenSyncInFlight = false;
    }
  }

  void _scheduleTokenRetry() {
    if (_tokenRetryTimer != null) return;
    final delay = _tokenRetryDelays[
      _tokenRetryAttempt.clamp(0, _tokenRetryDelays.length - 1)
    ];
    _tokenRetryAttempt += 1;
    AppLogger.warning(
      'Retrying FCM token sync in ${delay.inSeconds}s (attempt $_tokenRetryAttempt)',
      tag: 'FcmService',
    );
    _tokenRetryTimer = Timer(delay, () {
      _tokenRetryTimer = null;
      unawaited(_syncCurrentToken());
    });
  }

  late final WidgetsBindingObserver _appLifecycleObserver =
      _FcmLifecycleObserver(onResumed: () {
        if (_isInHardFailureCooldown() ||
            _isTokenSyncInFlight ||
            _tokenRetryTimer != null) {
          return;
        }
        unawaited(_syncCurrentToken());
      });

  bool _isInHardFailureCooldown() {
    final until = _tokenSyncHardFailureUntil;
    if (until == null) return false;
    if (DateTime.now().isAfter(until)) {
      _tokenSyncHardFailureUntil = null;
      return false;
    }
    return true;
  }

  bool _isHardFcmTokenFailure(Object error) {
    final value = error.toString().toLowerCase();
    return value.contains('fis_auth_error') ||
        value.contains('firebaseinstallationsexception') ||
        value.contains('firebase installations service is unavailable');
  }

  /// Returns `true` if the backend accepted the token or there was nothing to
  /// send. Returns `false` when a **transient** network error should trigger a
  /// retry (see [isTransientNetworkError]).
  Future<bool> _syncTokenToBackend(String? token) async {
    if (token == null || token.trim().isEmpty) {
      AppLogger.warning('FCM token unavailable', tag: 'FcmService');
      return true;
    }

    final access = await AppPreferences.getAccessToken();
    if (access == null || access.trim().isEmpty) {
      AppLogger.debug(
        'Skipping FCM registration: no backend access token',
        tag: 'FcmService',
      );
      return true;
    }

    AppLogger.debug(
      'FCM token len=${token.length} (registered after auth)',
      tag: 'FcmService',
    );
    final platform = _platformName();
    if (platform == null) {
      AppLogger.warning(
        'Skipping FCM token sync on unsupported platform',
        tag: 'FcmService',
      );
      return true;
    }
    if (kIsWeb && _webTokenSyncBlockedByNetworkPolicy) {
      AppLogger.debug(
        'Skipping FCM token sync on web after prior network/CORS failure',
        tag: 'FcmService',
      );
      return true;
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
      return true;
    } catch (e) {
      if (kIsWeb && _looksLikeBrowserNetworkPolicyFailure(e)) {
        _webTokenSyncBlockedByNetworkPolicy = true;
        AppLogger.warning(
          'FCM token sync blocked by browser network policy (likely CORS). '
          'Will skip further web sync attempts until app reload.',
          tag: 'FcmService',
        );
        return true;
      }
      if (isTransientNetworkError(e)) {
        return false;
      }
      AppLogger.error('Failed to sync FCM token', tag: 'FcmService', error: e);
      return true;
    }
  }

  bool _looksLikeBrowserNetworkPolicyFailure(Object error) {
    final value = error.toString().toLowerCase();
    return value.contains('failed to fetch') ||
        value.contains('clientexception') ||
        value.contains('xmlhttprequest error') ||
        value.contains('networkerror') ||
        value.contains('cors');
  }

  String? _platformName() {
    if (kIsWeb) return 'web';
    if (defaultTargetPlatform == TargetPlatform.android) return 'android';
    if (defaultTargetPlatform == TargetPlatform.iOS) return 'ios';
    return null;
  }

  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(_appLifecycleObserver);
    _tokenRetryTimer?.cancel();
    _tokenRetryTimer = null;
    await _onMessageOpenedSub?.cancel();
    await _onMessageSub?.cancel();
    await _tokenRefreshSub?.cancel();
  }
}

class _FcmLifecycleObserver extends WidgetsBindingObserver {
  _FcmLifecycleObserver({required this.onResumed});

  final VoidCallback onResumed;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      onResumed();
    }
  }
}
