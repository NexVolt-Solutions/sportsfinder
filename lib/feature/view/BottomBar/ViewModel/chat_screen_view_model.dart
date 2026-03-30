import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:sport_finding/core/Constants/app_text.dart';

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

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isEmpty => _messages.isEmpty;

  void sendMessage(String text) {
    final now = DateTime.now();
    _messages.add(
      ChatMessage(
        text: text,
        time: DateFormat('h:mm a').format(now), // e.g. "6:30 PM"
        date: DateFormat('d MMMM yyyy').format(now), // e.g. "20 July 2026"
        isMe: true,
      ),
    );
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
}
