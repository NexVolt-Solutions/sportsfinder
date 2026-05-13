import 'dart:async';

import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sport_finding/Data/Repositories/Chat/direct_chats_repository.dart';
import 'package:sport_finding/Data/model/chat/direct_chats_model.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Storage/app_preferences.dart';

class ChatThreadPreview {
  const ChatThreadPreview({
    required this.userName,
    this.targetUserId,
    this.avatarUrl,
    required this.lastMessage,
    required this.lastTime,
    this.lastAtIso,
    this.lastSeenIso,
    this.unreadCount = 0,
    this.isOnline = false,
  });

  final String userName;
  final String? targetUserId;
  final String? avatarUrl;
  final String lastMessage;
  final String lastTime;
  final String? lastAtIso;
  /// When peer is offline, last presence `sent_at` from WebSocket (UTC ISO).
  final String? lastSeenIso;
  final int unreadCount;
  final bool isOnline;

  ChatThreadPreview copyWith({
    String? userName,
    String? targetUserId,
    String? avatarUrl,
    String? lastMessage,
    String? lastTime,
    String? lastAtIso,
    String? lastSeenIso,
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
      lastSeenIso: lastSeenIso ?? this.lastSeenIso,
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
    'lastSeenIso': lastSeenIso,
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
      lastSeenIso: (json['lastSeenIso'] ?? '').toString().trim().isEmpty
          ? null
          : (json['lastSeenIso'] ?? '').toString().trim(),
      unreadCount: int.tryParse((json['unreadCount'] ?? '0').toString()) ?? 0,
      isOnline: json['isOnline'] is bool ? (json['isOnline'] as bool) : false,
    );
  }
}

class ChatListScreenViewModel extends ChangeNotifier {
  static final List<ChatThreadPreview> _globalThreads = <ChatThreadPreview>[];
  static final Set<ChatListScreenViewModel> _listeners =
      <ChatListScreenViewModel>{};
  static bool _hydrationStarted = false;
  static bool _hydratedOnce = false;
  static Timer? _webNotifyCoalesceTimer;
  static Timer? _backendChatMergeDebounce;
  static const Duration _backendChatMergeDebounceDuration =
      Duration(milliseconds: 500);
  static final DirectChatsRepository _backendChatMergeRepo =
      DirectChatsRepository();
  static bool _backendChatMergeInFlight = false;
  static final Map<String, Timer> _presenceOfflineDebounceTimers = {};
  static const Duration _presenceOfflineDebounce = Duration(milliseconds: 1500);
  /// Dedupe client-side unread bumps (same message id redelivered across sockets).
  static final Set<String> _unreadBumpKeys = <String>{};
  static const int _maxUnreadBumpKeys = 4000;
  /// Web: batch WS bursts; post-frame delivery avoids scheduling paints while
  /// the CanvasKit view is mid-dispose (hot restart / route swap).
  static const Duration _webNotifyCoalesce = Duration(milliseconds: 80);
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

  /// Sum of per-thread unread badges (drives the Chat tab indicator).
  static int get totalDirectChatUnread => _globalThreads.fold<int>(
        0,
        (sum, t) => sum + t.unreadCount,
      );

  /// Bumps when [totalDirectChatUnread] may have changed (tab bar listens).
  static final ValueNotifier<int> directChatUnreadListenable =
      ValueNotifier<int>(0);

  static void _syncDirectChatUnreadSignal() {
    final next = totalDirectChatUnread;
    if (directChatUnreadListenable.value != next) {
      directChatUnreadListenable.value = next;
    }
  }

  /// Merges `/api/v1/chats` into the in-memory thread list so another device
  /// (e.g. web send) or a push notification is reflected without opening the thread.
  /// Primary: [ChatThreadPreview.lastAtIso] (newest first). Tie-break: [ChatThreadPreview.targetUserId].
  static int compareThreadsByRecency(ChatThreadPreview a, ChatThreadPreview b) {
    final ai = DateTime.tryParse((a.lastAtIso ?? '').trim());
    final bi = DateTime.tryParse((b.lastAtIso ?? '').trim());
    final aid = (a.targetUserId ?? '').trim();
    final bid = (b.targetUserId ?? '').trim();
    if (ai != null && bi != null) {
      final c = bi.compareTo(ai);
      if (c != 0) return c;
      return aid.compareTo(bid);
    }
    if (ai != null) return -1;
    if (bi != null) return 1;
    return aid.compareTo(bid);
  }

  static void scheduleMergeDirectChatsFromBackend() {
    _backendChatMergeDebounce?.cancel();
    _backendChatMergeDebounce = Timer(_backendChatMergeDebounceDuration, () {
      _backendChatMergeDebounce = null;
      unawaited(mergeDirectChatsFromBackendNow());
    });
  }

  static Future<void> mergeDirectChatsFromBackendNow() async {
    if (_backendChatMergeInFlight) return;
    _backendChatMergeInFlight = true;
    try {
      final res = await _backendChatMergeRepo.getDirectChats(
        page: 1,
        limit: 100,
      );
      final byId = <String, ChatThreadPreview>{};
      for (final t in _globalThreads) {
        final id = (t.targetUserId ?? '').trim();
        if (id.isNotEmpty) byId[id] = t;
      }
      for (final c in res.items) {
        final p = _conversationToPreview(c);
        if (p == null) continue;
        final id = (p.targetUserId ?? '').trim();
        if (id.isEmpty) continue;
        final prev = byId[id];
        final int apiUnread = c.unreadFromApi ?? 0;
        if (prev != null) {
          final apiAt = DateTime.tryParse((p.lastAtIso ?? '').trim());
          final localAt = DateTime.tryParse((prev.lastAtIso ?? '').trim());
          final preferLocal =
              localAt != null && (apiAt == null || !localAt.isBefore(apiAt));
          if (preferLocal) {
            final mergedUnread =
                apiUnread > prev.unreadCount ? apiUnread : prev.unreadCount;
            final pAvatar = (p.avatarUrl ?? '').trim();
            byId[id] = prev.copyWith(
              unreadCount: mergedUnread,
              isOnline: prev.isOnline || p.isOnline,
              lastSeenIso: prev.lastSeenIso ?? p.lastSeenIso,
              avatarUrl: pAvatar.isNotEmpty ? p.avatarUrl : prev.avatarUrl,
              userName:
                  prev.userName.trim().isNotEmpty ? prev.userName : p.userName,
              targetUserId: id,
            );
            continue;
          }
        }
        byId[id] = p.copyWith(
          unreadCount: apiUnread,
          isOnline: prev?.isOnline ?? p.isOnline,
          lastSeenIso: prev?.lastSeenIso ?? p.lastSeenIso,
        );
      }
      final ordered = byId.values.toList()
        ..sort(compareThreadsByRecency);
      _globalThreads
        ..clear()
        ..addAll(ordered);
      _persistThreads();
      _notifyAllListeners();
      debugPrint(
        '[ChatListVM] mergeDirectChatsFromBackend rows=${_globalThreads.length}',
      );
    } catch (e) {
      debugPrint('[ChatListVM] mergeDirectChatsFromBackend failed: $e');
    } finally {
      _backendChatMergeInFlight = false;
    }
  }

  static void _notifyAllListeners() {
    void deliver() {
      _syncDirectChatUnreadSignal();
      if (kIsWeb) {
        try {
          if (PlatformDispatcher.instance.views.isEmpty) return;
        } catch (_) {
          return;
        }
      }
      for (final vm in _listeners.toList(growable: false)) {
        if (vm._isDisposed) continue;
        try {
          vm.notifyListeners();
        } catch (_) {
          // Stale notifier or widget unmount during notify; skip.
        }
      }
    }

    // Web: coalesce bursts, then deliver on the next frame so we are not in the
    // same scheduler turn as embed/view teardown (reduces EngineFlutterView asserts).
    if (kIsWeb) {
      _webNotifyCoalesceTimer?.cancel();
      _webNotifyCoalesceTimer = Timer(_webNotifyCoalesce, () {
        _webNotifyCoalesceTimer = null;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          deliver();
        });
      });
    } else {
      deliver();
    }
  }

  static void upsertThread({
    required String userName,
    String? targetUserId,
    String? avatarUrl,
    String? lastMessage,
    DateTime? lastAt,
    int? unreadCount,
    bool? isOnline,
    String? lastSeenIso,
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
    final existingUnread = idx < 0 ? 0 : _globalThreads[idx].unreadCount;
    final resolvedUnread = unreadCount ?? existingUnread;
    final existingLastSeen = idx < 0 ? null : _globalThreads[idx].lastSeenIso;
    final resolvedLastSeen = lastSeenIso ?? existingLastSeen;
    final existingAvatar = idx < 0 ? null : _globalThreads[idx].avatarUrl;
    final existingTrimmed = (existingAvatar ?? '').trim();
    final resolvedAvatar = trimmedAvatarUrl.isNotEmpty
        ? trimmedAvatarUrl
        : (existingTrimmed.isNotEmpty ? existingTrimmed : null);
    final existingOnline = idx < 0 ? false : _globalThreads[idx].isOnline;
    final resolvedOnline = isOnline ?? existingOnline;

    if (idx < 0) {
      _globalThreads.insert(
        0,
        ChatThreadPreview(
          userName: trimmedName,
          targetUserId: trimmedTargetUserId.isNotEmpty ? trimmedTargetUserId : null,
          avatarUrl: resolvedAvatar,
          lastMessage: previewMessage.isEmpty ? 'Chat started' : previewMessage,
          lastTime: formattedTime,
          lastAtIso: lastAtIso,
          lastSeenIso: resolvedLastSeen,
          unreadCount: resolvedUnread,
          isOnline: resolvedOnline,
        ),
      );
    } else {
      final updated = _globalThreads[idx].copyWith(
        userName: trimmedName,
        targetUserId: trimmedTargetUserId.isNotEmpty ? trimmedTargetUserId : null,
        avatarUrl: resolvedAvatar,
        lastMessage: previewMessage.isEmpty ? 'Chat started' : previewMessage,
        lastTime: formattedTime,
        lastAtIso: lastAtIso,
        lastSeenIso: resolvedLastSeen,
        unreadCount: resolvedUnread,
        isOnline: resolvedOnline,
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

   static void applyPresenceForUser({
    required String subjectUserId,
    required String status,
    DateTime? sentAt,
    bool immediate = false,
  }) {
    final uid = subjectUserId.trim();
    if (uid.isEmpty) return;
    final normalized = status.trim().toLowerCase();
    final isOnline =
        normalized == 'online' ||
        normalized == 'active' ||
        normalized == 'available';

    if (isOnline) {
      _presenceOfflineDebounceTimers.remove(uid)?.cancel();
      _applyPresenceForUserNow(
        subjectUserId: uid,
        isOnline: true,
        sentAt: sentAt,
      );
      return;
    }

    if (immediate) {
      _presenceOfflineDebounceTimers.remove(uid)?.cancel();
      _applyPresenceForUserNow(
        subjectUserId: uid,
        isOnline: false,
        sentAt: sentAt,
      );
      return;
    }

    _presenceOfflineDebounceTimers.remove(uid)?.cancel();
    _presenceOfflineDebounceTimers[uid] = Timer(_presenceOfflineDebounce, () {
      _presenceOfflineDebounceTimers.remove(uid);
      _applyPresenceForUserNow(
        subjectUserId: uid,
        isOnline: false,
        sentAt: sentAt,
      );
    });
  }

  static void _applyPresenceForUserNow({
    required String subjectUserId,
    required bool isOnline,
    DateTime? sentAt,
  }) {
    final uid = subjectUserId.trim();
    if (uid.isEmpty) return;
    final lastSeenIso = !isOnline && sentAt != null
        ? sentAt.toUtc().toIso8601String()
        : null;

    final idx = _globalThreads.indexWhere(
      (t) => (t.targetUserId ?? '').trim() == uid,
    );
    if (idx < 0) return;

    final existing = _globalThreads[idx];
    final mergedLastSeen = lastSeenIso ?? existing.lastSeenIso;
    final updated = existing.copyWith(
      isOnline: isOnline,
      lastSeenIso: isOnline ? null : mergedLastSeen,
    );
    final sameOnline = updated.isOnline == existing.isOnline;
    final sameLastSeen =
        (updated.lastSeenIso ?? '') == (existing.lastSeenIso ?? '');
    if (sameOnline && sameLastSeen) return;

    _globalThreads[idx] = updated;
    _persistThreads();
    _notifyAllListeners();
  }

  static bool _tryConsumeUnreadBumpKey(String key) {
    if (key.isEmpty) return true;
    if (_unreadBumpKeys.contains(key)) return false;
    if (_unreadBumpKeys.length >= _maxUnreadBumpKeys) {
      _unreadBumpKeys.clear();
    }
    _unreadBumpKeys.add(key);
    return true;
  }

  /// Clears in-memory threads, unread dedupe, and tab badge. Prefs are cleared
  /// by [AppPreferences.clearAuthSession]; call this so static state matches.
  static void clearSessionState() {
    _globalThreads.clear();
    _unreadBumpKeys.clear();
    _hydratedOnce = false;
    _hydrationStarted = false;
    _backendChatMergeDebounce?.cancel();
    _backendChatMergeDebounce = null;
    _syncDirectChatUnreadSignal();
    _notifyAllListeners();
  }

  static void incrementUnread({
    required String userName,
    String? targetUserId,
    String? avatarUrl,
    String? lastMessage,
    DateTime? lastAt,
    String? messageId,
  }) {
    final trimmedTargetUserId = (targetUserId ?? '').trim();
    final mid = (messageId ?? '').trim();
    if (mid.isEmpty) {
      scheduleMergeDirectChatsFromBackend();
      return;
    }
    final dedupeKey = '$trimmedTargetUserId|$mid';
    if (!_tryConsumeUnreadBumpKey(dedupeKey)) return;

    final idx = _globalThreads.indexWhere((t) {
      if (trimmedTargetUserId.isNotEmpty) {
        return (t.targetUserId ?? '').trim() == trimmedTargetUserId;
      }
      return t.userName.trim().toLowerCase() == userName.trim().toLowerCase();
    });
    final next = (idx >= 0 ? _globalThreads[idx].unreadCount : 0) + 1;
    upsertThread(
      userName: userName,
      targetUserId: targetUserId,
      avatarUrl: avatarUrl,
      lastMessage: lastMessage,
      lastAt: lastAt,
      unreadCount: next,
    );
  }

  /// Updates persisted thread preview after **Clear Chat** (local messages only).
  static void recordThreadClearedLocally({
    required String userName,
    String? targetUserId,
  }) {
    final trimmedTarget = (targetUserId ?? '').trim();
    final trimmedName = userName.trim();
    if (trimmedName.isEmpty) return;

    final idx = _globalThreads.indexWhere((t) {
      if (trimmedTarget.isNotEmpty) {
        return (t.targetUserId ?? '').trim() == trimmedTarget;
      }
      return t.userName.trim().toLowerCase() == trimmedName.toLowerCase();
    });
    if (idx < 0) return;

    final now = DateTime.now();
    final formattedTime = DateFormat('h:mm a').format(now);
    final lastAtIso = now.toUtc().toIso8601String();
    final existing = _globalThreads[idx];
    final updated = existing.copyWith(
      lastMessage: AppText.chatClearedPreview,
      lastTime: formattedTime,
      lastAtIso: lastAtIso,
      unreadCount: 0,
    );
    _globalThreads
      ..removeAt(idx)
      ..insert(0, updated);
    _persistThreads();
    _notifyAllListeners();
  }

  static void markRead({
    required String userName,
    String? targetUserId,
  }) {
    final trimmedTargetUserId = (targetUserId ?? '').trim();
    final idx = _globalThreads.indexWhere((t) {
      if (trimmedTargetUserId.isNotEmpty) {
        return (t.targetUserId ?? '').trim() == trimmedTargetUserId;
      }
      return t.userName.trim().toLowerCase() == userName.trim().toLowerCase();
    });
    if (idx < 0) return;
    if (_globalThreads[idx].unreadCount == 0) return;
    final updated = _globalThreads[idx].copyWith(unreadCount: 0);
    _globalThreads
      ..removeAt(idx)
      ..insert(idx, updated);
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

  /// Removes several threads in one persist/notify cycle (local list only).
  static void removeThreadsBatch(Iterable<ChatThreadPreview> threads) {
    final targetIds = <String>{};
    final nameKeys = <String>{};
    for (final t in threads) {
      final tid = (t.targetUserId ?? '').trim();
      if (tid.isNotEmpty) {
        targetIds.add(tid);
      } else {
        final n = t.userName.trim().toLowerCase();
        if (n.isNotEmpty) nameKeys.add(n);
      }
    }
    if (targetIds.isEmpty && nameKeys.isEmpty) return;

    final before = _globalThreads.length;
    _globalThreads.removeWhere((thread) {
      final tt = (thread.targetUserId ?? '').trim();
      if (tt.isNotEmpty) return targetIds.contains(tt);
      return nameKeys.contains(thread.userName.trim().toLowerCase());
    });
    if (_globalThreads.length != before) {
      _persistThreads();
      _notifyAllListeners();
    }
  }

  void startOrOpenThread(
    String userName, {
    String? targetUserId,
    String? avatarUrl,
  }) {
    upsertThread(
      userName: userName,
      targetUserId: targetUserId,
      avatarUrl: avatarUrl,
      lastMessage: 'Chat started',
      lastAt: DateTime.now(),
      unreadCount: 0,
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

      if (replace) {
        _globalThreads.clear();
        for (final c in res.items) {
          final p = _conversationToPreview(c);
          if (p == null) continue;
          final mergedUnread = c.unreadFromApi ?? 0;
          _globalThreads.add(p.copyWith(unreadCount: mergedUnread));
        }
      } else {
        final mapped = res.items
            .map(_conversationToPreview)
            .whereType<ChatThreadPreview>()
            .toList();
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

      _globalThreads.sort(compareThreadsByRecency);

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
      lastSeenIso: null,
      unreadCount: c.unreadFromApi ?? 0,
      isOnline: false,
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _listeners.remove(this);
    super.dispose();
  }
}

/// Coordinates list-level WebSocket bindings with fullscreen [ChatScreen] so the
/// same peer is not subscribed twice (duplicate events / battery drain).
class ChatListRealtimeCoordinator {
  ChatListRealtimeCoordinator._();

  static String? _fullScreenDirectTargetUserId;

  /// Set by [ChatListScreen] while mounted so other entry points (e.g. bottom-bar FAB)
  /// can drop list-level sockets before opening fullscreen chat.
  static Future<void> Function(String targetUserId)? disposeListSocketForTargetUser;

  /// Re-binds list-level sockets after fullscreen chat closes (FAB / deep links).
  static Future<void> Function()? syncEmbeddedListRealtimeNow;

  static String? get fullScreenDirectTargetUserId =>
      _fullScreenDirectTargetUserId;

  static bool matchesFullscreen(String targetUserId) {
    final t = targetUserId.trim();
    if (t.isEmpty) return false;
    return _fullScreenDirectTargetUserId == t;
  }

  static void beginFullScreenDirectChat(String targetUserId) {
    final t = targetUserId.trim();
    _fullScreenDirectTargetUserId = t.isEmpty ? null : t;
  }

  static void endFullScreenDirectChat(String targetUserId) {
    final t = targetUserId.trim();
    if (t.isEmpty) return;
    if (_fullScreenDirectTargetUserId == t) {
      _fullScreenDirectTargetUserId = null;
    }
  }

  static Future<void> disposeListSocketIfBound(String targetUserId) async {
    final f = disposeListSocketForTargetUser;
    if (f == null) return;
    await f(targetUserId);
  }

  static Future<void> syncEmbeddedNowIfRegistered() async {
    final f = syncEmbeddedListRealtimeNow;
    if (f == null) return;
    await f();
  }
}
