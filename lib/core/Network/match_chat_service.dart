import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

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
  MatchChatService({required this.accessToken, required this.matchId});

  static const String _baseRest = 'https://api.sportfinding.com/api/v1';
  static const String _baseWs = 'wss://api.sportfinding.com';

  final String accessToken;
  final String matchId;

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _channelSub;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  bool _isDisposed = false;
  bool _isReconnectScheduled = false;

  final _messageController = StreamController<RealtimeChatMessage>.broadcast();
  final _errorController = StreamController<String>.broadcast();
  final _connectedController = StreamController<void>.broadcast();

  Stream<RealtimeChatMessage> get onMessage => _messageController.stream;
  Stream<String> get onError => _errorController.stream;
  Stream<void> get onConnected => _connectedController.stream;

  Future<List<RealtimeChatMessage>> loadHistory() async {
    final uri = Uri.parse('$_baseRest/matches/$matchId/messages');
    final response = await http.get(
      uri,
      headers: <String, String>{
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load chat history: ${response.statusCode}');
    }

    final dynamic decoded = jsonDecode(response.body);
    final List<dynamic> items = decoded is List
        ? decoded
        : (decoded is Map<String, dynamic> && decoded['items'] is List
              ? decoded['items'] as List<dynamic>
              : <dynamic>[]);

    return items
        .whereType<Map>()
        .map((item) => RealtimeChatMessage.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  void connect() {
    if (_isDisposed || _channel != null) return;
    _reconnectTimer?.cancel();
    _isReconnectScheduled = false;
    final uri = Uri.parse(
      '$_baseWs/ws/matches/$matchId/chat?token=${Uri.encodeQueryComponent(accessToken)}',
    );

    _channel = IOWebSocketChannel.connect(
      uri,
      headers: <String, dynamic>{
        HttpHeaders.authorizationHeader: 'Bearer $accessToken',
      },
    );
    _channelSub = _channel!.stream.listen(
      (dynamic data) {
        if (data is! String) return;
        _handleServerEvent(jsonDecode(data) as Map<String, dynamic>);
      },
      onError: (Object error) {
        _errorController.add('WebSocket error: $error');
        _resetSocket();
        _scheduleReconnect();
      },
      onDone: () {
        _errorController.add('Connection closed');
        _resetSocket();
        _scheduleReconnect();
      },
      cancelOnError: true,
    );
  }

  void _handleServerEvent(Map<String, dynamic> event) {
    switch ('${event['type'] ?? ''}') {
      case 'connected':
        _reconnectAttempts = 0;
        _connectedController.add(null);
        break;
      case 'chat_message':
        _messageController.add(RealtimeChatMessage.fromJson(event));
        break;
      case 'error':
        _errorController.add('${event['detail'] ?? 'Unknown error'}');
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
      _errorController.add('Not connected. Reconnecting...');
      _scheduleReconnect();
      return false;
    }

    _channel?.sink.add(
      jsonEncode(<String, dynamic>{
        'type': 'chat_message',
        'content': trimmed,
      }),
    );
    return true;
  }

  void _resetSocket() {
    _channelSub?.cancel();
    _channelSub = null;
    _channel = null;
  }

  void _scheduleReconnect() {
    if (_isDisposed || _isReconnectScheduled) return;
    _isReconnectScheduled = true;
    _reconnectAttempts += 1;
    final seconds = _reconnectAttempts <= 1
        ? 1
        : (_reconnectAttempts <= 3 ? 2 : 5);
    _reconnectTimer = Timer(Duration(seconds: seconds), () {
      _isReconnectScheduled = false;
      if (_isDisposed || _channel != null) return;
      connect();
    });
  }

  void dispose() {
    _isDisposed = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _channelSub?.cancel();
    _channelSub = null;
    _channel?.sink.close();
    _channel = null;
    _messageController.close();
    _errorController.close();
    _connectedController.close();
  }
}
