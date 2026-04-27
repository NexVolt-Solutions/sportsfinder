import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sport_finding/core/Network/match_chat_service.dart';

import '../../helpers/fake_websocket_channel.dart';

void main() {
  group('MatchChatService', () {
    test('connect uses ws endpoint with query token and auth header', () {
      Uri? capturedUri;
      Map<String, dynamic>? capturedHeaders;
      final fake = FakeWebSocketChannel();

      final service = MatchChatService(
        accessToken: 'abc123',
        matchId: 'match-1',
        wsConnector: (uri, headers) {
          capturedUri = uri;
          capturedHeaders = headers;
          return fake;
        },
      );

      service.connect();

      expect(
        capturedUri.toString(),
        'wss://api.sportfinding.com/ws/matches/match-1/chat?token=abc123',
      );
      expect(
        capturedHeaders?[HttpHeaders.authorizationHeader],
        'Bearer abc123',
      );
      service.dispose();
    });

    test('emits connected and chat message events from socket payloads', () async {
      final fake = FakeWebSocketChannel();
      final service = MatchChatService(
        accessToken: 'token',
        matchId: 'm1',
        wsConnector: (_, __) => fake,
      );

      final connectedFuture = service.onConnected.first;
      final messageFuture = service.onMessage.first;

      service.connect();
      fake.emitJson('{"type":"connected"}');
      fake.emitJson(
        jsonEncode(<String, dynamic>{
          'type': 'chat_message',
          'message_id': 'msg-1',
          'sender_id': 'u1',
          'sender_name': 'John',
          'content': 'Hello',
          'sent_at': '2026-04-24T12:34:56+00:00',
        }),
      );

      await connectedFuture;
      final message = await messageFuture;
      expect(message.messageId, 'msg-1');
      expect(message.content, 'Hello');
      service.dispose();
    });

    test('sendMessage writes expected payload to socket', () {
      final fake = FakeWebSocketChannel();
      final service = MatchChatService(
        accessToken: 'token',
        matchId: 'm1',
        wsConnector: (_, __) => fake,
      );
      service.connect();

      final sent = service.sendMessage('Hi there');
      expect(sent, isTrue);
      expect(fake.sentMessages, hasLength(1));
      expect(
        fake.sentMessages.single,
        '{"type":"chat_message","content":"Hi there"}',
      );
      service.dispose();
    });

    test('reconnects after socket close', () async {
      final channels = <FakeWebSocketChannel>[
        FakeWebSocketChannel(),
        FakeWebSocketChannel(),
      ];
      var connectCalls = 0;

      final service = MatchChatService(
        accessToken: 'token',
        matchId: 'm1',
        wsConnector: (_, __) => channels[connectCalls++],
        reconnectDelayForAttempt: (_) => Duration.zero,
      );
      service.connect();
      await channels.first.emitDone();
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(connectCalls, greaterThanOrEqualTo(2));
      service.dispose();
    });
  });
}
