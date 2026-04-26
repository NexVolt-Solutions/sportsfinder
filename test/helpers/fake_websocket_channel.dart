import 'dart:async';

import 'package:web_socket_channel/web_socket_channel.dart';

class FakeWebSocketChannel implements WebSocketChannel {
  FakeWebSocketChannel() : _controller = StreamController<dynamic>.broadcast() {
    _sink = _FakeWebSocketSink(this);
  }

  final StreamController<dynamic> _controller;
  late final _FakeWebSocketSink _sink;

  final List<dynamic> sentMessages = <dynamic>[];
  bool isClosed = false;

  @override
  Stream get stream => _controller.stream;

  @override
  WebSocketSink get sink => _sink;

  @override
  String? get protocol => null;

  @override
  int? get closeCode => null;

  @override
  String? get closeReason => null;

  @override
  Future<void> get ready => Future<void>.value();

  void emitJson(String json) {
    if (!isClosed) {
      _controller.add(json);
    }
  }

  Future<void> emitDone() async {
    await _controller.close();
    isClosed = true;
  }

  void emitError(Object error) {
    if (!isClosed) {
      _controller.addError(error);
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeWebSocketSink implements WebSocketSink {
  _FakeWebSocketSink(this._channel);

  final FakeWebSocketChannel _channel;
  final Completer<void> _doneCompleter = Completer<void>();

  @override
  void add(data) {
    _channel.sentMessages.add(data);
  }

  @override
  void addError(error, [StackTrace? stackTrace]) {}

  @override
  Future addStream(Stream stream) async {
    await for (final item in stream) {
      add(item);
    }
  }

  @override
  Future close([int? closeCode, String? closeReason]) async {
    if (!_doneCompleter.isCompleted) {
      _doneCompleter.complete();
    }
    await _channel.emitDone();
  }

  @override
  Future get done => _doneCompleter.future;
}
