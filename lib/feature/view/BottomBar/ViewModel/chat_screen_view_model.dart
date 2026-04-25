import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Network/match_chat_service.dart';
import 'package:sport_finding/core/Network/profile_service.dart';
import 'package:sport_finding/core/Storage/app_preferences.dart';

import 'dart:async';

class ChatMessage {
  final String text;
  final String time;
  final String date;
  final bool isMe;

  const ChatMessage({
    required this.text,
    required this.time,
    required this.date,
    required this.isMe,
  });
}

class ChatScreenViewModel extends ChangeNotifier {
  ChatScreenViewModel({
    this.contactName = AppText.alexJohnson,
    this.isOnline = true,
  });

  final String contactName;
  final bool isOnline;

  final List<ChatMessage> _messages = [];
  final Set<String> _messageIds = <String>{};
  MatchChatService? _matchChatService;
  StreamSubscription<void>? _connectedSub;
  StreamSubscription<RealtimeChatMessage>? _messageSub;
  StreamSubscription<String>? _errorSub;
  bool _isConnected = false;
  String? _errorMessage;
  bool _isBindingRealtime = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isEmpty => _messages.isEmpty;
  bool get isConnected => _isConnected;
  String? get errorMessage => _errorMessage;
  bool get isRealtimeChatBound => _matchChatService != null;

  void sendMessage(String text) {
    if (_matchChatService == null) {
      _errorMessage =
          'This chat is not connected to the backend yet. WebSocket chat is only active when a matchId is opened.';
      notifyListeners();
      return;
    }

    _errorMessage = null;
    _matchChatService!.sendMessage(text);
    notifyListeners();
  }

  String get lastMessageOrFallback =>
      _messages.isNotEmpty ? _messages.last.text : 'Chat started';

  /// Call this when you receive a message from another user (e.g. via socket/API)
  void receiveMessage(String text) {
    final now = DateTime.now();
    _messages.add(
      ChatMessage(
        text: text,
        time: DateFormat('h:mm a').format(now),
        date: DateFormat('d MMMM yyyy').format(now),
        isMe: false,
      ),
    );
    notifyListeners();
  }

  Future<void> bindMatchChat(String matchId) async {
    final trimmedMatchId = matchId.trim();
    if (trimmedMatchId.isEmpty || _isBindingRealtime) return;

    final token = await AppPreferences.getAccessToken();
    if (token == null || token.isEmpty) return;

    _isBindingRealtime = true;
    _errorMessage = null;
    notifyListeners();

    await _disposeRealtimeOnly();

    final service = MatchChatService(
      accessToken: token,
      matchId: trimmedMatchId,
    );
    _matchChatService = service;

    try {
      final history = await service.loadHistory();
      _messages.clear();
      _messageIds.clear();
      for (final item in history) {
        _appendRealtimeMessage(item);
      }
    } catch (e) {
      _errorMessage = 'Could not load chat history: $e';
    }

    _connectedSub = service.onConnected.listen((_) {
      _isConnected = true;
      notifyListeners();
    });

    _messageSub = service.onMessage.listen((msg) {
      _appendRealtimeMessage(msg);
      notifyListeners();
    });

    _errorSub = service.onError.listen((err) {
      _errorMessage = err;
      notifyListeners();
    });

    service.connect();
    _isBindingRealtime = false;
    notifyListeners();
  }

  void _appendRealtimeMessage(RealtimeChatMessage message) {
    final id = message.messageId.trim();
    if (id.isNotEmpty && !_messageIds.add(id)) {
      return;
    }

    final now = message.sentAt.toLocal();
    final myId = ProfileService().profile?.id.trim() ?? '';
    _messages.add(
      ChatMessage(
        text: message.content,
        time: DateFormat('h:mm a').format(now),
        date: DateFormat('d MMMM yyyy').format(now),
        isMe: myId.isNotEmpty && message.senderId.trim() == myId,
      ),
    );
  }

  Future<void> _disposeRealtimeOnly() async {
    await _connectedSub?.cancel();
    await _messageSub?.cancel();
    await _errorSub?.cancel();
    _connectedSub = null;
    _messageSub = null;
    _errorSub = null;
    _matchChatService?.dispose();
    _matchChatService = null;
    _isConnected = false;
  }

  @override
  void dispose() {
    _disposeRealtimeOnly();
    super.dispose();
  }
}
