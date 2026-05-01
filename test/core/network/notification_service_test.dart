import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sport_finding/core/Network/notification_service.dart';

import '../../helpers/fake_websocket_channel.dart';

void main() {
  group('NotificationService WebSocket', () {
    test('connect uses notifications ws path with header auth', () async {
      Uri? capturedUri;
      Map<String, dynamic>? capturedHeaders;
      final fake = FakeWebSocketChannel();

      final service = NotificationService(
        autoConnect: false,
        tokenProvider: () async => 'token-1',
        wsConnector: (uri, headers) {
          capturedUri = uri;
          capturedHeaders = headers;
          return fake;
        },
      );

      await service.ensureRealtimeConnected();

      expect(
        capturedUri.toString(),
        'wss://api.sportfinding.com/ws/notifications?token=token-1',
      );
      expect(
        capturedHeaders?[HttpHeaders.authorizationHeader],
        'Bearer token-1',
      );
      service.dispose();
    });

    test('connected event updates realtime connection state', () async {
      final fake = FakeWebSocketChannel();
      final service = NotificationService(
        autoConnect: false,
        tokenProvider: () async => 'token-1',
        wsConnector: (_, _) => fake,
      );

      await service.ensureRealtimeConnected();
      expect(service.isRealtimeConnected, isFalse);

      fake.emitJson('{"type":"connected","unread_count":3}');
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(service.isRealtimeConnected, isTrue);
      service.dispose();
    });

    test('notification envelope appends new notification item', () async {
      final fake = FakeWebSocketChannel();
      final service = NotificationService(
        autoConnect: false,
        tokenProvider: () async => 'token-1',
        wsConnector: (_, _) => fake,
      );

      await service.ensureRealtimeConnected();
      fake.emitJson(
        '{"type":"notification","notification_type":"match_joined","payload":{"match_id":"m1","joiner_name":"Ali","message":"Ali joined your match."}}',
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(service.notifications, hasLength(1));
      expect(service.notifications.first.type, 'match_joined');
      expect(service.notifications.first.matchId, 'm1');
      service.dispose();
    });

    test('reconnects after socket closes', () async {
      final channels = <FakeWebSocketChannel>[
        FakeWebSocketChannel(),
        FakeWebSocketChannel(),
      ];
      var connectCalls = 0;

      final service = NotificationService(
        autoConnect: false,
        tokenProvider: () async => 'token-1',
        wsConnector: (_, _) => channels[connectCalls++],
        reconnectDelayForAttempt: (_) => Duration.zero,
      );

      await service.ensureRealtimeConnected();
      await channels.first.emitDone();
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(connectCalls, greaterThanOrEqualTo(2));
      service.dispose();
    });
  });
}
