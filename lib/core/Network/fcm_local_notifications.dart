import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Heads-up notifications while the app is in the foreground (FCM does not
/// show system banners by default in that case).
class FcmLocalNotifications {
  FcmLocalNotifications._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static bool get _supported {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  static Future<void> init() async {
    if (_initialized || !_supported) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: darwinInit,
    );

    await _plugin.initialize(settings: initSettings);

    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.createNotificationChannel(
      const AndroidNotificationChannel(
        'fcm_foreground',
        'Push notifications',
        description: 'Alerts while the app is open',
        importance: Importance.high,
      ),
    );

    _initialized = true;
  }

  static Future<void> showForeground(RemoteMessage message) async {
    if (!_initialized) return;

    final n = message.notification;
    var title = (n?.title ?? '').trim();
    var body = (n?.body ?? '').trim();
    if (title.isEmpty) {
      title = (message.data['title'] ?? '').toString().trim();
    }
    if (body.isEmpty) {
      body = (message.data['body'] ?? message.data['message'] ?? '')
          .toString()
          .trim();
    }
    if (title.isEmpty && body.isEmpty) return;
    if (title.isEmpty) title = 'SportFinding';

    const android = AndroidNotificationDetails(
      'fcm_foreground',
      'Push notifications',
      channelDescription: 'Alerts while the app is open',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const darwin = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(android: android, iOS: darwin);

    final id = message.messageId != null && message.messageId!.isNotEmpty
        ? message.messageId!.hashCode.abs() % 2147483647
        : DateTime.now().millisecondsSinceEpoch.remainder(2147483647);

    await _plugin.show(
      id: id,
      title: title,
      body: body.isEmpty ? null : body,
      notificationDetails: details,
      payload: jsonEncode(message.data),
    );
  }
}
