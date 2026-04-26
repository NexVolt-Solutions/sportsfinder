import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sport_finding/core/Network/match_chat_service.dart';
import 'package:sport_finding/feature/view/BottomBar/ViewModel/chat_screen_view_model.dart';

class _StubMatchChatService extends MatchChatService {
  _StubMatchChatService({required this.sendResult})
    : super(accessToken: 't', matchId: 'm');

  bool sendResult;
  bool connectCalled = false;

  final StreamController<void> _connected = StreamController<void>.broadcast();
  final StreamController<RealtimeChatMessage> _message =
      StreamController<RealtimeChatMessage>.broadcast();
  final StreamController<String> _error = StreamController<String>.broadcast();

  @override
  Stream<void> get onConnected => _connected.stream;

  @override
  Stream<RealtimeChatMessage> get onMessage => _message.stream;

  @override
  Stream<String> get onError => _error.stream;

  @override
  Future<List<RealtimeChatMessage>> loadHistory() async => <RealtimeChatMessage>[];

  @override
  void connect() {
    connectCalled = true;
    _connected.add(null);
  }

  @override
  bool sendMessage(String content) => sendResult;

  void emitIncoming(RealtimeChatMessage message) => _message.add(message);

  @override
  void dispose() {
    _connected.close();
    _message.close();
    _error.close();
    super.dispose();
  }
}

void main() {
  group('ChatScreenViewModel', () {
    test('send success creates a pending local message', () async {
      late _StubMatchChatService service;
      final vm = ChatScreenViewModel(
        accessTokenProvider: () async => 'token',
        currentUserIdProvider: () => 'me-1',
        chatServiceFactory: (_, __) {
          service = _StubMatchChatService(sendResult: true);
          return service;
        },
      );

      await vm.bindMatchChat('match-1');
      vm.sendMessage('hello');

      expect(service.connectCalled, isTrue);
      expect(vm.messages, hasLength(1));
      expect(vm.messages.first.text, 'hello');
      expect(vm.messages.first.isPending, isTrue);
      expect(vm.messages.first.isFailed, isFalse);
    });

    test('send failure creates failed local message', () async {
      final vm = ChatScreenViewModel(
        accessTokenProvider: () async => 'token',
        currentUserIdProvider: () => 'me-1',
        chatServiceFactory: (_, __) => _StubMatchChatService(sendResult: false),
      );

      await vm.bindMatchChat('match-1');
      vm.sendMessage('hello');

      expect(vm.messages, hasLength(1));
      expect(vm.messages.first.isFailed, isTrue);
      expect(vm.messages.first.isPending, isFalse);
    });

    test('incoming echoed message reconciles pending bubble', () async {
      late _StubMatchChatService service;
      final vm = ChatScreenViewModel(
        accessTokenProvider: () async => 'token',
        currentUserIdProvider: () => 'me-1',
        chatServiceFactory: (_, __) {
          service = _StubMatchChatService(sendResult: true);
          return service;
        },
      );

      await vm.bindMatchChat('match-1');
      vm.sendMessage('hello');

      service.emitIncoming(
        RealtimeChatMessage(
          messageId: 'm-1',
          senderId: 'me-1',
          senderName: 'Me',
          content: 'hello',
          sentAt: DateTime.now(),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(vm.messages, hasLength(1));
      expect(vm.messages.first.isPending, isFalse);
      expect(vm.messages.first.isFailed, isFalse);
    });

    test('retry failed message sets it back to pending on success', () async {
      late _StubMatchChatService service;
      final vm = ChatScreenViewModel(
        accessTokenProvider: () async => 'token',
        currentUserIdProvider: () => 'me-1',
        chatServiceFactory: (_, __) {
          service = _StubMatchChatService(sendResult: false);
          return service;
        },
      );

      await vm.bindMatchChat('match-1');
      vm.sendMessage('hello');
      expect(vm.messages.first.isFailed, isTrue);

      service.sendResult = true;
      vm.retryMessage(vm.messages.first.localId);

      expect(vm.messages.first.isFailed, isFalse);
      expect(vm.messages.first.isPending, isTrue);
    });
  });
}
