import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatThreadPreview {
  const ChatThreadPreview({
    required this.userName,
    this.targetUserId,
    required this.lastMessage,
    required this.lastTime,
    this.unreadCount = 0,
    this.isOnline = true,
  });

  final String userName;
  final String? targetUserId;
  final String lastMessage;
  final String lastTime;
  final int unreadCount;
  final bool isOnline;

  ChatThreadPreview copyWith({
    String? userName,
    String? targetUserId,
    String? lastMessage,
    String? lastTime,
    int? unreadCount,
    bool? isOnline,
  }) {
    return ChatThreadPreview(
      userName: userName ?? this.userName,
      targetUserId: targetUserId ?? this.targetUserId,
      lastMessage: lastMessage ?? this.lastMessage,
      lastTime: lastTime ?? this.lastTime,
      unreadCount: unreadCount ?? this.unreadCount,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}

class ChatListScreenViewModel extends ChangeNotifier {
  static final List<ChatThreadPreview> _globalThreads = <ChatThreadPreview>[];
  static final Set<ChatListScreenViewModel> _listeners =
      <ChatListScreenViewModel>{};

  ChatListScreenViewModel() {
    _listeners.add(this);
  }

  List<ChatThreadPreview> get threads => List.unmodifiable(_globalThreads);
  bool get hasThreads => _globalThreads.isNotEmpty;

  static void _notifyAllListeners() {
    for (final vm in _listeners) {
      vm.notifyListeners();
    }
  }

  static void upsertThread({
    required String userName,
    String? targetUserId,
    String? lastMessage,
    DateTime? lastAt,
    int unreadCount = 0,
    bool isOnline = true,
  }) {
    final trimmedName = userName.trim();
    final trimmedTargetUserId = (targetUserId ?? '').trim();
    if (trimmedName.isEmpty) return;
    final now = lastAt ?? DateTime.now();
    final formattedTime = DateFormat('h:mm a').format(now);
    final previewMessage = (lastMessage ?? 'Chat started').trim();

    final idx = _globalThreads.indexWhere((t) {
      if (trimmedTargetUserId.isNotEmpty) {
        return (t.targetUserId ?? '').trim() == trimmedTargetUserId;
      }
      return t.userName.toLowerCase() == trimmedName.toLowerCase();
    });
    if (idx < 0) {
      _globalThreads.insert(
        0,
        ChatThreadPreview(
          userName: trimmedName,
          targetUserId: trimmedTargetUserId.isNotEmpty ? trimmedTargetUserId : null,
          lastMessage: previewMessage.isEmpty ? 'Chat started' : previewMessage,
          lastTime: formattedTime,
          unreadCount: unreadCount,
          isOnline: isOnline,
        ),
      );
    } else {
      final updated = _globalThreads[idx].copyWith(
        userName: trimmedName,
        targetUserId: trimmedTargetUserId.isNotEmpty ? trimmedTargetUserId : null,
        lastMessage: previewMessage.isEmpty ? 'Chat started' : previewMessage,
        lastTime: formattedTime,
        unreadCount: unreadCount,
        isOnline: isOnline,
      );
      _globalThreads
        ..removeAt(idx)
        ..insert(0, updated);
    }
    debugPrint(
      '[ChatListVM] upsertThread user=$trimmedName targetUserId=$trimmedTargetUserId total=${_globalThreads.length}',
    );
    _notifyAllListeners();
  }

  static void removeThread({
    String? targetUserId,
    String? userName,
  }) {
    final trimmedTargetUserId = (targetUserId ?? '').trim();
    final trimmedUserName = (userName ?? '').trim().toLowerCase();
    _globalThreads.removeWhere((thread) {
      if (trimmedTargetUserId.isNotEmpty) {
        return (thread.targetUserId ?? '').trim() == trimmedTargetUserId;
      }
      if (trimmedUserName.isNotEmpty) {
        return thread.userName.trim().toLowerCase() == trimmedUserName;
      }
      return false;
    });
    _notifyAllListeners();
  }

  void startOrOpenThread(String userName, {String? targetUserId}) {
    upsertThread(
      userName: userName,
      targetUserId: targetUserId,
      lastMessage: 'Chat started',
      lastAt: DateTime.now(),
      unreadCount: 0,
      isOnline: true,
    );
  }

  void updateThreadFromOutgoing(String userName, String message) {
    // Legacy method kept for compatibility; no-op without match context.
  }

  @override
  void dispose() {
    _listeners.remove(this);
    super.dispose();
  }
}
