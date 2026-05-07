import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sport_finding/Data/Repositories/Chat/direct_chats_repository.dart';
import 'package:sport_finding/Data/model/chat/direct_chats_model.dart';
import 'package:sport_finding/core/Storage/app_preferences.dart';

class ChatThreadPreview {
  const ChatThreadPreview({
    required this.userName,
    this.targetUserId,
    this.avatarUrl,
    required this.lastMessage,
    required this.lastTime,
    this.lastAtIso,
    this.unreadCount = 0,
    this.isOnline = true,
  });

  final String userName;
  final String? targetUserId;
  final String? avatarUrl;
  final String lastMessage;
  final String lastTime;
  final String? lastAtIso;
  final int unreadCount;
  final bool isOnline;

  ChatThreadPreview copyWith({
    String? userName,
    String? targetUserId,
    String? avatarUrl,
    String? lastMessage,
    String? lastTime,
    String? lastAtIso,
    int? unreadCount,
    bool? isOnline,
  }) {
    return ChatThreadPreview(
      userName: userName ?? this.userName,
      targetUserId: targetUserId ?? this.targetUserId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      lastMessage: lastMessage ?? this.lastMessage,
      lastTime: lastTime ?? this.lastTime,
      lastAtIso: lastAtIso ?? this.lastAtIso,
      unreadCount: unreadCount ?? this.unreadCount,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'userName': userName,
    'targetUserId': targetUserId,
    'avatarUrl': avatarUrl,
    'lastMessage': lastMessage,
    'lastTime': lastTime,
    'lastAtIso': lastAtIso,
    'unreadCount': unreadCount,
    'isOnline': isOnline,
  };

  static ChatThreadPreview? tryFromJson(Map<String, dynamic> json) {
    final name = (json['userName'] ?? '').toString().trim();
    if (name.isEmpty) return null;
    return ChatThreadPreview(
      userName: name,
      targetUserId: (json['targetUserId'] ?? '').toString().trim().isEmpty
          ? null
          : (json['targetUserId'] ?? '').toString().trim(),
      avatarUrl: (json['avatarUrl'] ?? '').toString().trim().isEmpty
          ? null
          : (json['avatarUrl'] ?? '').toString().trim(),
      lastMessage: (json['lastMessage'] ?? 'Chat started').toString(),
      lastTime: (json['lastTime'] ?? '').toString(),
      lastAtIso: (json['lastAtIso'] ?? '').toString().trim().isEmpty
          ? null
          : (json['lastAtIso'] ?? '').toString().trim(),
      unreadCount: int.tryParse((json['unreadCount'] ?? '0').toString()) ?? 0,
      isOnline: json['isOnline'] is bool ? (json['isOnline'] as bool) : true,
    );
  }
}

class ChatListScreenViewModel extends ChangeNotifier {
  static final List<ChatThreadPreview> _globalThreads = <ChatThreadPreview>[];
  static final Set<ChatListScreenViewModel> _listeners =
      <ChatListScreenViewModel>{};
  static bool _hydrationStarted = false;
  static bool _hydratedOnce = false;
  bool _isDisposed = false;

  final DirectChatsRepository _directChatsRepository = DirectChatsRepository();

  bool _isLoadingRemote = false;
  String? _remoteError;
  int _remotePage = 1;
  bool _remoteHasNext = true;

  ChatListScreenViewModel() {
    _listeners.add(this);
    _ensureHydrated();
  }

  List<ChatThreadPreview> get threads => List.unmodifiable(_globalThreads);
  bool get hasThreads => _globalThreads.isNotEmpty;
  bool get isLoadingRemote => _isLoadingRemote;
  String? get remoteError => _remoteError;

  void _ensureHydrated() {
    if (_hydratedOnce || _hydrationStarted) return;
    _hydrationStarted = true;
    Future<void>(() async {
      final raw = await AppPreferences.getChatThreads();
      if (raw.isEmpty) {
        _hydratedOnce = true;
        _hydrationStarted = false;
        return;
      }
      if (_globalThreads.isNotEmpty) {
        _hydratedOnce = true;
        _hydrationStarted = false;
        return;
      }

      final parsed = <ChatThreadPreview>[];
      for (final m in raw) {
        final t = ChatThreadPreview.tryFromJson(m);
        if (t != null) parsed.add(t);
      }
      if (parsed.isNotEmpty) {
        _globalThreads
          ..clear()
          ..addAll(parsed);
      }
      _hydratedOnce = true;
      _hydrationStarted = false;
      if (_listeners.contains(this) && !_isDisposed) {
        // Notify only if we're still alive; also refresh any other listeners.
        _notifyAllListeners();
      }
    });
  }

  static void _persistThreads() {
    Future<void>(() async {
      await AppPreferences.setChatThreads(
        _globalThreads.map((t) => t.toJson()).toList(),
      );
    });
  }

  static void _notifyAllListeners() {
    for (final vm in _listeners) {
      vm.notifyListeners();
    }
  }

  static void upsertThread({
    required String userName,
    String? targetUserId,
    String? avatarUrl,
    String? lastMessage,
    DateTime? lastAt,
    int unreadCount = 0,
    bool isOnline = true,
  }) {
    final trimmedName = userName.trim();
    final trimmedTargetUserId = (targetUserId ?? '').trim();
    final trimmedAvatarUrl = (avatarUrl ?? '').trim();
    if (trimmedName.isEmpty) return;
    final now = lastAt ?? DateTime.now();
    final formattedTime = DateFormat('h:mm a').format(now);
    final lastAtIso = now.toUtc().toIso8601String();
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
          avatarUrl: trimmedAvatarUrl.isNotEmpty ? trimmedAvatarUrl : null,
          lastMessage: previewMessage.isEmpty ? 'Chat started' : previewMessage,
          lastTime: formattedTime,
          lastAtIso: lastAtIso,
          unreadCount: unreadCount,
          isOnline: isOnline,
        ),
      );
    } else {
      final updated = _globalThreads[idx].copyWith(
        userName: trimmedName,
        targetUserId: trimmedTargetUserId.isNotEmpty ? trimmedTargetUserId : null,
        avatarUrl: trimmedAvatarUrl.isNotEmpty ? trimmedAvatarUrl : null,
        lastMessage: previewMessage.isEmpty ? 'Chat started' : previewMessage,
        lastTime: formattedTime,
        lastAtIso: lastAtIso,
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
    _persistThreads();
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
    _persistThreads();
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

  Future<void> refreshDirectChats({int limit = 20}) async {
    _remotePage = 1;
    _remoteHasNext = true;
    _remoteError = null;
    await _fetchDirectChats(page: _remotePage, limit: limit, replace: true);
  }

  Future<void> loadMoreDirectChats({int limit = 20}) async {
    if (_isLoadingRemote || !_remoteHasNext) return;
    await _fetchDirectChats(page: _remotePage + 1, limit: limit, replace: false);
  }

  Future<void> deleteConversation({
    required String targetUserId,
  }) async {
    final trimmed = targetUserId.trim();
    if (trimmed.isEmpty) return;

    final existingIndex = _globalThreads.indexWhere(
      (t) => (t.targetUserId ?? '').trim() == trimmed,
    );
    if (existingIndex < 0) return;

    final removed = _globalThreads.removeAt(existingIndex);
    _persistThreads();
    _notifyAllListeners();

    try {
      await _directChatsRepository.deleteDirectConversation(userId: trimmed);
    } catch (e) {
      // rollback on failure
      _globalThreads.insert(existingIndex, removed);
      _persistThreads();
      _notifyAllListeners();
      rethrow;
    }
  }

  Future<void> _fetchDirectChats({
    required int page,
    required int limit,
    required bool replace,
  }) async {
    if (_isLoadingRemote) return;
    _isLoadingRemote = true;
    _remoteError = null;
    notifyListeners();

    try {
      final DirectChatsResponse res = await _directChatsRepository.getDirectChats(
        page: page,
        limit: limit,
      );

      final mapped = res.items
          .map(_conversationToPreview)
          .whereType<ChatThreadPreview>()
          .toList();

      if (replace) {
        _globalThreads
          ..clear()
          ..addAll(mapped);
      } else {
        // De-dupe by targetUserId if present, else by name.
        for (final t in mapped) {
          final exists = _globalThreads.any((e) {
            final a = (e.targetUserId ?? '').trim();
            final b = (t.targetUserId ?? '').trim();
            if (a.isNotEmpty && b.isNotEmpty) return a == b;
            return e.userName.trim().toLowerCase() == t.userName.trim().toLowerCase();
          });
          if (!exists) _globalThreads.add(t);
        }
      }

      _remotePage = res.page;
      _remoteHasNext = res.hasNext;
      _persistThreads();
      _notifyAllListeners();
    } catch (e) {
      _remoteError = e.toString();
      notifyListeners();
    } finally {
      _isLoadingRemote = false;
      notifyListeners();
    }
  }

  static ChatThreadPreview? _conversationToPreview(DirectChatConversation c) {
    final name = c.user.fullName.trim();
    final targetUserId = c.user.id.trim();
    if (name.isEmpty || targetUserId.isEmpty) return null;

    final lastAt = c.lastMessageSentAt?.toLocal();
    final now = DateTime.now();
    final dt = lastAt ?? now;
    final formattedTime = DateFormat('h:mm a').format(dt);
    final lastAtIso = dt.toUtc().toIso8601String();
    final lastMessage = c.lastMessage.trim().isEmpty ? 'Chat started' : c.lastMessage.trim();

    return ChatThreadPreview(
      userName: name,
      targetUserId: targetUserId,
      avatarUrl: (c.user.avatarUrl ?? '').trim().isEmpty ? null : c.user.avatarUrl!.trim(),
      lastMessage: lastMessage,
      lastTime: formattedTime,
      lastAtIso: lastAtIso,
      unreadCount: 0,
      isOnline: true,
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _listeners.remove(this);
    super.dispose();
  }
}
