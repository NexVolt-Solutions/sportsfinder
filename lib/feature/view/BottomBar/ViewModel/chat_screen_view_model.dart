import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

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
  final List<ChatMessage> _messages = [];

  List<ChatMessage> get messages => List.unmodifiable(_messages);

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
