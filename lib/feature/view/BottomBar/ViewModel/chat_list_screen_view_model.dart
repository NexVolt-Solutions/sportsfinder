import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatThreadPreview {
  const ChatThreadPreview({
    required this.userName,
    required this.lastMessage,
    required this.lastTime,
    this.unreadCount = 0,
    this.isOnline = true,
  });

  final String userName;
  final String lastMessage;
  final String lastTime;
  final int unreadCount;
  final bool isOnline;

  ChatThreadPreview copyWith({
    String? userName,
    String? lastMessage,
    String? lastTime,
    int? unreadCount,
    bool? isOnline,
  }) {
    return ChatThreadPreview(
      userName: userName ?? this.userName,
      lastMessage: lastMessage ?? this.lastMessage,
      lastTime: lastTime ?? this.lastTime,
      unreadCount: unreadCount ?? this.unreadCount,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}

class ChatListScreenViewModel extends ChangeNotifier {
  final List<ChatThreadPreview> _threads = [];

  List<ChatThreadPreview> get threads => List.unmodifiable(_threads);
  bool get hasThreads => _threads.isNotEmpty;

  void startOrOpenThread(String userName) {
    final idx = _threads.indexWhere(
      (t) => t.userName.toLowerCase() == userName.toLowerCase(),
    );
    final now = DateFormat('h:mm a').format(DateTime.now());
    if (idx >= 0) return;
    _threads.insert(
      0,
      ChatThreadPreview(
        userName: userName,
        lastMessage: 'Chat started',
        lastTime: now,
        unreadCount: 0,
        isOnline: true,
      ),
    );
    notifyListeners();
  }

  void updateThreadFromOutgoing(String userName, String message) {
    final idx = _threads.indexWhere(
      (t) => t.userName.toLowerCase() == userName.toLowerCase(),
    );
    final now = DateFormat('h:mm a').format(DateTime.now());
    if (idx < 0) {
      _threads.insert(
        0,
        ChatThreadPreview(
          userName: userName,
          lastMessage: message,
          lastTime: now,
          unreadCount: 0,
          isOnline: true,
        ),
      );
    } else {
      final updated = _threads[idx].copyWith(
        lastMessage: message,
        lastTime: now,
        unreadCount: 0,
      );
      _threads
        ..removeAt(idx)
        ..insert(0, updated);
    }
    notifyListeners();
  }
}
