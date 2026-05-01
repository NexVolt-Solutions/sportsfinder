import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:intl/intl.dart';

class ChatThreadPreview {
  const ChatThreadPreview({
    required this.userName,
    this.matchId,
    this.targetUserId,
    required this.lastMessage,
    required this.lastTime,
    this.unreadCount = 0,
    this.isOnline = true,
  });

  final String userName;
  final String? matchId;
  final String? targetUserId;
  final String lastMessage;
  final String lastTime;
  final int unreadCount;
  final bool isOnline;

  ChatThreadPreview copyWith({
    String? userName,
    String? matchId,
    String? targetUserId,
    String? lastMessage,
    String? lastTime,
    int? unreadCount,
    bool? isOnline,
  }) {
    return ChatThreadPreview(
      userName: userName ?? this.userName,
      matchId: matchId ?? this.matchId,
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
    String? matchId,
    String? targetUserId,
    String? lastMessage,
    DateTime? lastAt,
    int unreadCount = 0,
    bool isOnline = true,
  }) {
    final trimmedName = userName.trim();
    final trimmedMatchId = (matchId ?? '').trim();
    final trimmedTargetUserId = (targetUserId ?? '').trim();
    if (trimmedName.isEmpty) return;
    final now = lastAt ?? DateTime.now();
    final formattedTime = DateFormat('h:mm a').format(now);
    final previewMessage = (lastMessage ?? 'Chat started').trim();

    final idx = _globalThreads.indexWhere((t) {
      if (trimmedMatchId.isNotEmpty) {
        return (t.matchId ?? '').trim() == trimmedMatchId;
      }
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
          matchId: trimmedMatchId.isNotEmpty ? trimmedMatchId : null,
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
        matchId: trimmedMatchId.isNotEmpty ? trimmedMatchId : null,
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
      '[ChatListVM] upsertThread user=$trimmedName matchId=${trimmedMatchId.isEmpty ? "direct" : trimmedMatchId} total=${_globalThreads.length}',
    );
    _notifyAllListeners();
  }

  void startOrOpenThread(String userName, {String? targetUserId}) {
    upsertThread(
      userName: userName,
      matchId: null,
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
