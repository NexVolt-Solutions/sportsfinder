import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:http/http.dart' as http;
import 'package:sport_finding/core/Network/api_service.dart';
import 'package:sport_finding/core/utils/reconnect_scheduler.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

typedef ChatWsConnector =
    WebSocketChannel Function(Uri uri, Map<String, dynamic> headers);
typedef ReconnectDelayForAttempt = Duration Function(int attempt);

class ChatHistoryException implements Exception {
  ChatHistoryException(this.statusCode);
  final int statusCode;

  @override
  String toString() => 'Failed to load chat history: $statusCode';
}

class RealtimeChatMessage {
  RealtimeChatMessage({
    required this.messageId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.sentAt,
    this.senderAvatar,
  });

  final String messageId;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String content;
  final DateTime sentAt;

  factory RealtimeChatMessage.fromJson(Map<String, dynamic> json) {
    return RealtimeChatMessage(
      messageId: '${json['message_id'] ?? ''}',
      senderId: '${json['sender_id'] ?? ''}',
      senderName: '${json['sender_name'] ?? ''}',
      senderAvatar: json['sender_avatar']?.toString(),
      content: '${json['content'] ?? ''}',
      sentAt: DateTime.tryParse('${json['sent_at'] ?? ''}') ?? DateTime.now(),
    );
  }
}

class MatchChatService {
  MatchChatService({
    required this.accessToken,
    this.targetUserId,
    ChatWsConnector? wsConnector,
    ReconnectDelayForAttempt? reconnectDelayForAttempt,
    String? restBaseUrl,
  }) : _wsConnector = wsConnector ?? _defaultWsConnector {
    final baseRestUrl = (restBaseUrl ?? ApiService().baseUrl).trim();
    _baseRest = '$baseRestUrl/api/v1';
    _baseWs = _toWsBase(baseRestUrl);
    _reconnectScheduler = ReconnectScheduler(
      delayForAttempt: reconnectDelayForAttempt ?? _defaultReconnectDelay,
    );
  }

  final String? targetUserId;
  late final String _baseRest;
  late final String _baseWs;

  final String accessToken;
  final ChatWsConnector _wsConnector;

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _channelSub;
  late final ReconnectScheduler _reconnectScheduler;
  bool _isDisposed = false;

  final _messageController = StreamController<RealtimeChatMessage>.broadcast();
  final _errorController = StreamController<String>.broadcast();
  final _connectedController = StreamController<void>.broadcast();

  Stream<RealtimeChatMessage> get onMessage => _messageController.stream;
  Stream<String> get onError => _errorController.stream;
  Stream<void> get onConnected => _connectedController.stream;

  String get _chatPath {
    final resolvedTargetUserId = targetUserId?.trim() ?? '';
    if (resolvedTargetUserId.isNotEmpty) {
      return '/ws/users/$resolvedTargetUserId/chat';
    }
    throw StateError('MatchChatService requires a non-empty targetUserId.');
  }

  static WebSocketChannel _defaultWsConnector(
    Uri uri,
    Map<String, dynamic> headers,
  ) {
    if (kIsWeb) {
      debugPrint('[MatchChatService] [WS] Web connector -> $uri');
      return WebSocketChannel.connect(uri);
    }
    debugPrint('[MatchChatService] [WS] IO connector -> $uri');
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

  Future<List<RealtimeChatMessage>> loadHistory() async {
    final activeTargetUserId = targetUserId?.trim() ?? '';
    if (activeTargetUserId.isEmpty) {
      throw Exception('Chat history requires targetUserId.');
    }
    final uri = Uri.parse('$_baseRest/users/$activeTargetUserId/messages');
    debugPrint('[MatchChatService] [History] GET $uri');
    final response = await http.get(
      uri,
      headers: <String, String>{
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      debugPrint(
        '[MatchChatService] [History] failed status=${response.statusCode}',
      );
      throw ChatHistoryException(response.statusCode);
    }

    final dynamic decoded = jsonDecode(response.body);
    final List<dynamic> items = decoded is List
        ? decoded
        : (decoded is Map<String, dynamic> && decoded['items'] is List
              ? decoded['items'] as List<dynamic>
              : <dynamic>[]);

    final history = items
        .whereType<Map>()
        .map(
          (item) =>
              RealtimeChatMessage.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
    debugPrint(
      '[MatchChatService] [History] loaded count=${history.length} targetUserId=$targetUserId',
    );
    return history;
  }

  void connect() {
    if (_isDisposed || _channel != null) {
      debugPrint(
        '[MatchChatService] [WS] skip connect (disposed=$_isDisposed hasChannel=${_channel != null}) targetUserId=$targetUserId',
      );
      return;
    }
    _reconnectScheduler.cancel();
    final uri = Uri.parse(
      '$_baseWs$_chatPath?token=${Uri.encodeQueryComponent(accessToken)}',
    );

    debugPrint('[MatchChatService] [WS] connecting path=$_chatPath');
    _channel = _wsConnector(
      uri,
      <String, dynamic>{HttpHeaders.authorizationHeader: 'Bearer $accessToken'},
    );
    _channelSub = _channel!.stream.listen(
      (dynamic data) {
        if (data is! String) return;
        debugPrint('[MatchChatService] [WS] event raw=$data');
        _handleServerEvent(jsonDecode(data) as Map<String, dynamic>);
      },
      onError: (Object error) {
        debugPrint('[MatchChatService] [WS] error $error');
        _errorController.add('WebSocket error: $error');
        _resetSocket();
        _scheduleReconnect();
      },
      onDone: () {
        final closeCode = _channel?.closeCode;
        debugPrint('[MatchChatService] [WS] done/closed code=$closeCode');
        final message = _messageForCloseCode(closeCode);
        _errorController.add(message);
        _resetSocket();
        if (_shouldReconnect(closeCode)) {
          _scheduleReconnect();
        }
      },
      cancelOnError: true,
    );
  }

  void _handleServerEvent(Map<String, dynamic> event) {
    debugPrint(
      '[MatchChatService] [WS] parsed event type=${event['type']} targetUserId=$targetUserId',
    );
    switch ('${event['type'] ?? ''}') {
      case 'connected':
        _reconnectScheduler.resetAttempts();
        _connectedController.add(null);
        debugPrint('[MatchChatService] [WS] connected acknowledged');
        break;
      case 'chat_message':
        _messageController.add(RealtimeChatMessage.fromJson(event));
        debugPrint(
          '[MatchChatService] [WS] incoming messageId=${event['message_id']} sender=${event['sender_id']}',
        );
        break;
      case 'error':
        _errorController.add('${event['detail'] ?? 'Unknown error'}');
        debugPrint('[MatchChatService] [WS] server error ${event['detail']}');
        break;
    }
  }

  bool sendMessage(String content) {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return false;
    if (trimmed.length > 1000) {
      _errorController.add('Message too long (max 1000 characters)');
      return false;
    }
    if (_channel == null) {
      debugPrint(
        '[MatchChatService] [WS] send blocked: no channel. scheduling reconnect',
      );
      _errorController.add('Not connected. Reconnecting...');
      _scheduleReconnect();
      return false;
    }

    debugPrint('[MatchChatService] [WS] send message len=${trimmed.length}');
    _channel?.sink.add(
      jsonEncode(<String, dynamic>{'type': 'chat_message', 'content': trimmed}),
    );
    return true;
  }

  void _resetSocket() {
    debugPrint('[MatchChatService] [WS] reset socket');
    _channelSub?.cancel();
    _channelSub = null;
    _channel = null;
  }

  void _scheduleReconnect() {
    debugPrint('[MatchChatService] [WS] schedule reconnect');
    _reconnectScheduler.schedule(
      canSchedule: () => !_isDisposed && _channel == null,
      onFire: connect,
    );
  }

  bool _shouldReconnect(int? closeCode) {
    if (closeCode == 4001 || closeCode == 4003 || closeCode == 4004) {
      return false;
    }
    return true;
  }

  String _messageForCloseCode(int? closeCode) {
    switch (closeCode) {
      case 4001:
        return 'Session expired. Please sign in again.';
      case 4003:
        return 'Access denied for this chat.';
      case 4004:
        return 'Chat target was not found.';
      default:
        return 'Connection closed';
    }
  }

  void dispose() {
    debugPrint('[MatchChatService] dispose targetUserId=$targetUserId');
    _isDisposed = true;
    _reconnectScheduler.cancel();
    _channelSub?.cancel();
    _channelSub = null;
    _channel?.sink.close();
    _channel = null;
    _messageController.close();
    _errorController.close();
    _connectedController.close();
  }
}
