import 'dart:io' show File;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Network/chat_realtime_events.dart';
import 'package:sport_finding/core/Network/fcm_local_notifications.dart';
import 'package:sport_finding/core/Network/match_chat_service.dart';
import 'package:sport_finding/core/Network/profile_service.dart';
import 'package:sport_finding/core/Storage/app_preferences.dart';
import 'package:sport_finding/core/utils/date_time_formatters.dart';
import 'package:sport_finding/feature/view/BottomBar/ViewModel/chat_list_screen_view_model.dart';
import 'package:sport_finding/feature/widget/app_avatar.dart';
import 'package:sport_finding/Data/Repositories/Chat/direct_messages_repository.dart';
import 'package:sport_finding/Data/Repositories/Chat/chat_upload_repository.dart';
import 'dart:async';

enum ChatMessageType {
  text,
  image,
  file,
}

ChatMessageType _parseChatMessageType(String? raw) {
  final v = (raw ?? '').trim().toLowerCase();
  switch (v) {
    case 'image':
      return ChatMessageType.image;
    case 'file':
      return ChatMessageType.file;
    case 'text':
    default:
      return ChatMessageType.text;
  }
}

class ChatMessage {
  final String text;
  final String time;
  final String date;
  final bool isMe;
  final bool isPending;
  final bool isFailed;
  final String localId;
  final String? messageId;
  final bool isDeleted;
  final ChatMessageType type;
  final String? mediaUrl;
  final String? thumbnailUrl;
  final String? mimeType;
  final String? fileName;
  final int? sizeBytes;
  /// Server read receipt time (UTC), when the peer has read this outgoing message.
  final DateTime? readAt;
  /// Server delivery receipt (UTC), when the message reached the peer's device/server.
  final DateTime? deliveredAt;

  const ChatMessage({
    required this.text,
    required this.time,
    required this.date,
    required this.isMe,
    this.isPending = false,
    this.isFailed = false,
    this.localId = '',
    this.messageId,
    this.isDeleted = false,
    this.type = ChatMessageType.text,
    this.mediaUrl,
    this.thumbnailUrl,
    this.mimeType,
    this.fileName,
    this.sizeBytes,
    this.readAt,
    this.deliveredAt,
  });

  ChatMessage copyWith({
    String? text,
    String? time,
    String? date,
    bool? isMe,
    bool? isPending,
    bool? isFailed,
    String? localId,
    String? messageId,
    bool? isDeleted,
    ChatMessageType? type,
    String? mediaUrl,
    String? thumbnailUrl,
    String? mimeType,
    String? fileName,
    int? sizeBytes,
    DateTime? readAt,
    DateTime? deliveredAt,
  }) {
    return ChatMessage(
      text: text ?? this.text,
      time: time ?? this.time,
      date: date ?? this.date,
      isMe: isMe ?? this.isMe,
      isPending: isPending ?? this.isPending,
      isFailed: isFailed ?? this.isFailed,
      localId: localId ?? this.localId,
      messageId: messageId ?? this.messageId,
      isDeleted: isDeleted ?? this.isDeleted,
      type: type ?? this.type,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      mimeType: mimeType ?? this.mimeType,
      fileName: fileName ?? this.fileName,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      readAt: readAt ?? this.readAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
    );
  }
}

/// In-memory: reopening a direct chat shows the last list immediately while REST/WS
/// reconnect. Cleared on logout / thread removed / clear-chat.
class ChatScreenMessagesCache {
  ChatScreenMessagesCache._();

  static final Map<String, ChatScreenCacheSnapshot> _byTargetUserId = {};

  static ChatScreenCacheSnapshot? peek(String targetUserId) {
    final id = targetUserId.trim();
    if (id.isEmpty) return null;
    final s = _byTargetUserId[id];
    if (s == null || s.messages.isEmpty) return null;
    return s;
  }

  static void save(
    String targetUserId,
    List<ChatMessage> messages,
    Set<String> messageIds,
    int localMessageCounter,
  ) {
    final id = targetUserId.trim();
    if (id.isEmpty) return;
    if (messages.isEmpty) {
      _byTargetUserId.remove(id);
      return;
    }
    _byTargetUserId[id] = ChatScreenCacheSnapshot(
      messages: List<ChatMessage>.from(messages),
      messageIds: Set<String>.from(messageIds),
      localMessageCounter: localMessageCounter,
    );
  }

  static void invalidate(String targetUserId) {
    final id = targetUserId.trim();
    if (id.isEmpty) return;
    _byTargetUserId.remove(id);
  }

  static void clearAll() {
    _byTargetUserId.clear();
  }
}

class ChatScreenCacheSnapshot {
  const ChatScreenCacheSnapshot({
    required this.messages,
    required this.messageIds,
    required this.localMessageCounter,
  });

  final List<ChatMessage> messages;
  final Set<String> messageIds;
  final int localMessageCounter;
}

typedef MatchChatServiceFactory =
    MatchChatService Function(String accessToken, String targetUserId);
typedef AccessTokenProvider = Future<String?> Function();
typedef CurrentUserIdProvider = String Function();

class ChatScreenViewModel extends ChangeNotifier {
  ChatScreenViewModel({
    this.contactName = AppText.alexJohnson,
    this.isOnline = false,
    String? contactAvatarUrl,
    MatchChatServiceFactory? chatServiceFactory,
    AccessTokenProvider? accessTokenProvider,
    CurrentUserIdProvider? currentUserIdProvider,
  }) : _routeContactAvatarUrl = (() {
         final t = (contactAvatarUrl ?? '').trim();
         return t.isEmpty ? null : t;
       })(),
       _peerOnline = isOnline,
       _chatServiceFactory = chatServiceFactory ??
           ((accessToken, targetUserId) => MatchChatService(
                 accessToken: accessToken,
                 targetUserId: targetUserId,
               )),
       _accessTokenProvider =
           accessTokenProvider ?? AppPreferences.getAccessToken,
       _currentUserIdProvider = currentUserIdProvider ??
           (() => ProfileService().profile?.id.trim() ?? '');

  final String contactName;
  final bool isOnline;
  final String? _routeContactAvatarUrl;
  String? _peerAvatarUrlFromMessages;
  bool _peerOnline;
  DateTime? _peerLastSeenUtc;
  final MatchChatServiceFactory _chatServiceFactory;
  final AccessTokenProvider _accessTokenProvider;
  final CurrentUserIdProvider _currentUserIdProvider;

  final List<ChatMessage> _messages = [];
  final Set<String> _messageIds = <String>{};
  MatchChatService? _matchChatService;
  StreamSubscription<void>? _connectedSub;
  StreamSubscription<RealtimeChatMessage>? _messageSub;
  StreamSubscription<String>? _errorSub;
  StreamSubscription<ChatPresenceEvent>? _presenceSub;
  StreamSubscription<ChatReceiptEvent>? _receiptSub;
  bool _isConnected = false;
  String? _errorMessage;
  bool _isBindingRealtime = false;
  /// Invalidates in-flight [bindDirectChat] after [dispose] or a new bind cycle.
  Object? _bindLease;
  bool _vmDisposed = false;
  String _boundTargetUserId = '';
  /// Dedup WS `message_read` frames for peer messages (per thread bind).
  final Set<String> _readReceiptSentForMessageIds = <String>{};
  int _localMessageCounter = 0;
  final Map<String, Timer> _pendingFailTimers = <String, Timer>{};
  static const Duration _pendingFailureTimeout = Duration(seconds: 12);
  static const Duration _peerOfflinePresenceDebounce = Duration(milliseconds: 1600);
  static const Duration _peerOfflineSnapshotDebounce = Duration(milliseconds: 4500);
  static const Duration _suppressSnapshotOfflineAfterConnect = Duration(seconds: 4);
  /// REST gap-fill while the socket is up; avoids a history fetch on every reconnect.
  static const Duration _historyGapFillInterval = Duration(seconds: 12);
  Timer? _peerOfflineDebounce;
  Timer? _historyGapFillTimer;
  DateTime? _initialHistoryLoadedAt;
  DateTime? _suppressPeerOfflineSnapshotUntil;
  final DirectMessagesRepository _directMessagesRepository =
      DirectMessagesRepository();
  final ChatUploadRepository _chatUploadRepository = ChatUploadRepository();

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isEmpty => _messages.isEmpty;
  bool get isConnected => _isConnected;
  String? get errorMessage => _errorMessage;
  bool get isRealtimeChatBound => _matchChatService != null;
  /// WebSocket / presence: peer has connectivity (affects sent-message ticks).
  bool get peerOnline => _peerOnline;

  String get activeChatSubtitle {
    if (!_isConnected) return 'Connecting...';
    if (_peerOnline) return 'Online';
    if (_peerLastSeenUtc != null) {
      return 'Last seen ${DateTimeFormatters.relativeLabel(_peerLastSeenUtc!.toLocal())}';
    }
    return 'Offline';
  }

  /// Resolved peer avatar for header / thread row (route arg, else latest peer `sender_avatar` from WS/history).
  String? get contactDisplayAvatarUrl {
    final peer = normalizeImageUrl(_peerAvatarUrlFromMessages);
    if (peer != null && peer.isNotEmpty) return peer;
    return normalizeImageUrl(_routeContactAvatarUrl);
  }

  void _log(String message) {
    debugPrint('[ChatScreenVM] $message');
  }

  bool _shouldEmitReadReceiptsNow() {
    if (_vmDisposed) return false;
    final s = WidgetsBinding.instance.lifecycleState;
    return s == null || s == AppLifecycleState.resumed;
  }

  /// Tells the server this user has seen the peer's message (direct WS §5.4).
  /// Skips when app is backgrounded so we do not mark read from a notification
  /// pipeline alone.
  void _sendReadReceiptForPeerMessageIfNeeded(String? rawMessageId) {
    if (!_shouldEmitReadReceiptsNow()) return;
    final id = (rawMessageId ?? '').trim();
    if (id.isEmpty) return;
    if (_readReceiptSentForMessageIds.contains(id)) return;
    final svc = _matchChatService;
    if (svc == null) return;
    if (!svc.sendReadReceipt(id)) return;
    _readReceiptSentForMessageIds.add(id);
    _log('read receipt sent for peer message id=$id');
  }

  void _flushReadReceiptsForLoadedPeerMessages() {
    if (!_shouldEmitReadReceiptsNow()) return;
    for (final m in _messages) {
      if (m.isMe || m.isDeleted) continue;
      _sendReadReceiptForPeerMessageIfNeeded(m.messageId);
    }
  }

  /// When the app returns to foreground on an open chat, send reads that were
  /// skipped while backgrounded (and after [pullMissedMessages] adds rows).
  void flushPendingReadReceipts() {
    _flushReadReceiptsForLoadedPeerMessages();
  }

  /// True when this row is **our** message in a 1:1 thread.
  ///
  /// Prefer **peer comparison** when the bound peer id is known: on this
  /// socket only the peer and the authenticated user exist, so any
  /// `sender_id` that is not the peer is ours. This must run **before**
  /// [ProfileService] id — profile id can be missing, stale, or wrong while
  /// `sender_id` from the server is always correct (fixes pending never
  /// reconciling and self-echo shown as incoming).
  bool _isDirectMessageFromMe(RealtimeChatMessage message) {
    final sender = message.senderId.trim();
    if (sender.isEmpty) return false;
    final peer = _boundTargetUserId.trim();
    if (peer.isNotEmpty) {
      if (sender == peer) return false;
      return true;
    }
    final myId = _currentUserIdProvider().trim();
    return myId.isNotEmpty && sender == myId;
  }

  String _receiptMyUserIdFor(RealtimeChatMessage message) {
    if (_isDirectMessageFromMe(message)) {
      final s = message.senderId.trim();
      if (s.isNotEmpty) return s;
    }
    return _currentUserIdProvider().trim();
  }

  void sendMessage(String text) {
    _log(
      'sendMessage called (bound=${_matchChatService != null}, connected=$_isConnected, len=${text.trim().length})',
    );
    if (_matchChatService == null) {
      _errorMessage =
          'This chat is not connected to the backend yet.';
      _log('send blocked: service not bound');
      notifyListeners();
      return;
    }

    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    _errorMessage = null;
    final sent = _matchChatService!.sendMessage(trimmed);
    if (sent) {
      _log('message queued as pending');
      _appendPendingOutgoing(trimmed);
    } else {
      _log('message send failed immediately');
      _appendFailedOutgoing(trimmed);
    }
    notifyListeners();
  }

  Future<void> sendImageAttachment(XFile xFile) async {
    if (_matchChatService == null) {
      _errorMessage = 'This chat is not connected to the backend yet.';
      notifyListeners();
      return;
    }
    _errorMessage = null;
    notifyListeners();

    final fileName =
        (xFile.name).trim().isNotEmpty ? xFile.name.trim() : 'image';

    try {
      final targetUserId = _boundTargetUserId.trim();
      if (targetUserId.isEmpty) {
        throw Exception('Chat target user id missing');
      }
      final ChatAttachmentUploadResult upload;
      if (kIsWeb) {
        final bytes = await xFile.readAsBytes();
        upload = await _chatUploadRepository.uploadDirectChatAttachment(
          targetUserId: targetUserId,
          fileName: fileName,
          bytes: bytes,
        );
      } else {
        final path = xFile.path.trim();
        if (path.isEmpty) throw Exception('Missing image path');
        upload = await _chatUploadRepository.uploadDirectChatAttachment(
          targetUserId: targetUserId,
          fileName: fileName,
          file: File(path),
        );
      }

      final url = upload.mediaUrl.trim();
      final mime = upload.mimeType;
      final returnedName = upload.fileName ?? fileName;
      final sizeBytes = upload.sizeBytes;

      final sent = _matchChatService!.sendChatMessage(
        content: url,
        messageType: 'image',
        mediaUrl: url,
        fileName: returnedName,
        mimeType: mime,
        sizeBytes: sizeBytes,
      );

      if (sent) {
        _appendPendingOutgoing(
          url,
          type: ChatMessageType.image,
          mediaUrl: url,
          fileName: returnedName,
          mimeType: mime,
          sizeBytes: sizeBytes,
        );
      } else {
        _appendFailedOutgoing(
          url,
          type: ChatMessageType.image,
          mediaUrl: url,
          fileName: returnedName,
          mimeType: mime,
          sizeBytes: sizeBytes,
        );
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to upload image.';
      notifyListeners();
      return;
    }
  }

  Future<void> sendFileAttachment(PlatformFile file) async {
    if (_matchChatService == null) {
      _errorMessage = 'This chat is not connected to the backend yet.';
      notifyListeners();
      return;
    }
    _errorMessage = null;
    notifyListeners();

    final fileName = (file.name).trim().isNotEmpty ? file.name.trim() : 'file';

    try {
      final targetUserId = _boundTargetUserId.trim();
      if (targetUserId.isEmpty) {
        throw Exception('Chat target user id missing');
      }

      final ChatAttachmentUploadResult upload;
      if (kIsWeb) {
        final bytes = file.bytes;
        if (bytes == null || bytes.isEmpty) {
          throw Exception('Missing file bytes');
        }
        upload = await _chatUploadRepository.uploadDirectChatAttachment(
          targetUserId: targetUserId,
          fileName: fileName,
          bytes: bytes,
        );
      } else {
        final path = (file.path ?? '').trim();
        if (path.isEmpty) throw Exception('Missing file path');
        upload = await _chatUploadRepository.uploadDirectChatAttachment(
          targetUserId: targetUserId,
          fileName: fileName,
          file: File(path),
        );
      }

      final url = upload.mediaUrl.trim();
      final mime = upload.mimeType;
      final returnedName = upload.fileName ?? fileName;
      final sizeBytes = upload.sizeBytes ?? file.size;

      final sent = _matchChatService!.sendChatMessage(
        content: url,
        messageType: 'file',
        mediaUrl: url,
        fileName: returnedName,
        sizeBytes: sizeBytes,
        mimeType: mime,
      );

      if (sent) {
        _appendPendingOutgoing(
          url,
          type: ChatMessageType.file,
          mediaUrl: url,
          fileName: returnedName,
          sizeBytes: sizeBytes,
          mimeType: mime,
        );
      } else {
        _appendFailedOutgoing(
          url,
          type: ChatMessageType.file,
          mediaUrl: url,
          fileName: returnedName,
          sizeBytes: sizeBytes,
          mimeType: mime,
        );
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to upload file.';
      notifyListeners();
      rethrow;
    }
  }

  void retryMessage(String localId) {
    _log('retryMessage localId=$localId');
    final index = _messages.indexWhere((item) => item.localId == localId);
    if (index < 0) return;
    final target = _messages[index];
    if (!target.isFailed || target.text.trim().isEmpty) return;

    final sent = _matchChatService?.sendMessage(target.text.trim()) ?? false;
    if (!sent) {
      _errorMessage = 'Retry failed. Still reconnecting...';
      _log('retry failed: still disconnected');
      notifyListeners();
      return;
    }

    _log('retry accepted; back to pending');
    _messages[index] = target.copyWith(isFailed: false, isPending: true);
    _schedulePendingFailure(localId);
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
        time: DateTimeFormatters.chatTime(now),
        date: DateTimeFormatters.chatDate(now),
        isMe: false,
      ),
    );
    notifyListeners();
  }

  Future<void> bindDirectChat(String targetUserId) async {
    final trimmedTargetUserId = targetUserId.trim();
    if (trimmedTargetUserId.isEmpty || _isBindingRealtime || _vmDisposed) {
      return;
    }
    _log('bindDirectChat start targetUserId=$trimmedTargetUserId');
    _boundTargetUserId = trimmedTargetUserId;
    _readReceiptSentForMessageIds.clear();
    _peerOnline = isOnline;
    _peerLastSeenUtc = null;
    _peerAvatarUrlFromMessages = null;

    final token = await _accessTokenProvider();
    if (token == null || token.isEmpty) {
      _log('bindDirectChat aborted: access token missing');
      return;
    }
    if (_vmDisposed) return;
    final myIdAtBind = _currentUserIdProvider();
    _log('bindDirectChat ctx myId=$myIdAtBind tokenLen=${token.length}');

    final cached = ChatScreenMessagesCache.peek(trimmedTargetUserId);
    if (cached != null) {
      _messages
        ..clear()
        ..addAll(cached.messages);
      _messageIds
        ..clear()
        ..addAll(cached.messageIds);
      _localMessageCounter = cached.localMessageCounter;
      _reschedulePendingTimersForCurrentMessages();
      _log(
        'bindDirectChat seeded from cache count=${_messages.length}',
      );
      notifyListeners();
    }

    _isBindingRealtime = true;
    _errorMessage = null;
    notifyListeners();

    await _disposeRealtimeOnly();
    _log('old realtime state disposed');
    _initialHistoryLoadedAt = null;
    _suppressPeerOfflineSnapshotUntil = null;

    if (_vmDisposed) {
      _isBindingRealtime = false;
      return;
    }

    final lease = Object();
    _bindLease = lease;

    final service = _chatServiceFactory(token, trimmedTargetUserId);
    _matchChatService = service;

    try {
      final history = await service.loadHistory();
      if (_vmDisposed || !identical(_bindLease, lease)) {
        _isBindingRealtime = false;
        return;
      }
      _initialHistoryLoadedAt = DateTime.now();
      final preserved = _messages
          .where((m) => m.isPending || m.isFailed)
          .toList();
      _messages.clear();
      _messageIds.clear();
      for (final item in history) {
        _appendRealtimeMessage(item);
      }
      for (final m in preserved) {
        if (m.isFailed) {
          _messages.add(m);
          continue;
        }
        if (m.isPending) {
          if (_messages.any((x) => x.localId == m.localId)) {
            continue;
          }
          final echoed = _messages.any(
            (x) =>
                x.isMe &&
                !x.isPending &&
                (x.messageId ?? '').trim().isNotEmpty &&
                x.type == m.type &&
                (m.type == ChatMessageType.text
                    ? x.text.trim() == m.text.trim()
                    : ((x.fileName ?? '').trim().isNotEmpty &&
                            (x.fileName ?? '').trim() ==
                                (m.fileName ?? '').trim()) ||
                        ((x.mediaUrl ?? '').trim().isNotEmpty &&
                            (x.mediaUrl ?? '').trim() ==
                                (m.mediaUrl ?? '').trim())),
          );
          if (!echoed) {
            _messages.add(m);
          }
        }
      }
      _reschedulePendingTimersForCurrentMessages();
      _log('direct history loaded count=${history.length}');
      ChatListScreenViewModel.upsertThread(
        userName: contactName,
        targetUserId: _boundTargetUserId,
        avatarUrl: contactDisplayAvatarUrl,
        lastMessage: history.isNotEmpty ? history.last.content : 'Chat started',
        lastAt: history.isNotEmpty ? history.last.sentAt : DateTime.now(),
        unreadCount: 0,
        isOnline: _peerOnline,
      );
    } catch (e) {
      if (_vmDisposed || !identical(_bindLease, lease)) {
        _isBindingRealtime = false;
        return;
      }
      _errorMessage = 'Could not load direct chat history: $e';
      _log('direct history load failed: $e');
    }

    if (_vmDisposed || !identical(_bindLease, lease)) {
      _isBindingRealtime = false;
      return;
    }

    _connectedSub = service.onConnected.listen((_) {
      _isConnected = true;
      _errorMessage = null;
      _suppressPeerOfflineSnapshotUntil = DateTime.now().add(
        _suppressSnapshotOfflineAfterConnect,
      );
      _log('direct ws connected targetUserId=$_boundTargetUserId');
      notifyListeners();
      _startHistoryGapFillTimer(service);
      _flushReadReceiptsForLoadedPeerMessages();
    });

    _messageSub = service.onMessage.listen((msg) {
      final isMine = _isDirectMessageFromMe(msg);
      final myId = _currentUserIdProvider().trim();
      _log(
        'direct ws message id=${msg.messageId} sender=${msg.senderId} '
        'isMine=$isMine myId=${myId.isEmpty ? "(peer-heuristic)" : myId} '
        'targetUserId=$_boundTargetUserId len=${msg.content.length}',
      );

      // Backend often emits presence_update with the viewer's own user_id, so
      // peer online state never updates. Any live message from the peer
      // implies they are reachable now.
      if (!isMine) {
        _applyPeerPresenceFromLiveMessage(msg.sentAt);
      }

      if (!kIsWeb && !isMine) {
        _maybeNotifyIncomingDirectChatWhileBackgrounded(msg);
      }
      _appendRealtimeMessage(msg);
      ChatListScreenViewModel.upsertThread(
        userName: contactName,
        targetUserId: _boundTargetUserId,
        avatarUrl: contactDisplayAvatarUrl,
        lastMessage: msg.content,
        lastAt: msg.sentAt,
        unreadCount: 0,
        isOnline: _peerOnline,
      );
      if (!isMine) {
        _sendReadReceiptForPeerMessageIfNeeded(msg.messageId);
      }
      _errorMessage = null;
      notifyListeners();
    });

    _presenceSub = service.onPresence.listen((ChatPresenceEvent e) {
      final peerId = _boundTargetUserId.trim();
      final myId = _currentUserIdProvider().trim();
      final subject = e.userId.trim();
      if (peerId.isEmpty) return;
      // Ignore self-echo presence on this socket (common server behaviour).
      if (myId.isNotEmpty && subject == myId) return;
      if (subject != peerId) return;
      final st = e.status.trim().toLowerCase();
      final nowOnline =
          st == 'online' || st == 'active' || st == 'available';

      if (nowOnline) {
        _peerOfflineDebounce?.cancel();
        _peerOfflineDebounce = null;
        _peerOnline = true;
        _peerLastSeenUtc = null;
        _suppressPeerOfflineSnapshotUntil = null;
        ChatListScreenViewModel.applyPresenceForUser(
          subjectUserId: peerId,
          status: e.status,
          sentAt: e.sentAt,
        );
        if (!_vmDisposed) {
          notifyListeners();
        }
        return;
      }

      // Stale `presence_snapshot` often arrives milliseconds after connect while
      // the peer is actively on another device; ignore offline snapshots briefly.
      final until = _suppressPeerOfflineSnapshotUntil;
      if (e.fromSnapshot &&
          until != null &&
          DateTime.now().isBefore(until)) {
        return;
      }

      final offlineWait = e.fromSnapshot
          ? _peerOfflineSnapshotDebounce
          : _peerOfflinePresenceDebounce;

      _peerOfflineDebounce?.cancel();
      _peerOfflineDebounce = Timer(offlineWait, () {
        _peerOfflineDebounce = null;
        if (_vmDisposed) return;
        if (_boundTargetUserId.trim() != peerId) return;
        _peerOnline = false;
        _peerLastSeenUtc = e.sentAt ?? DateTime.now().toUtc();
        ChatListScreenViewModel.applyPresenceForUser(
          subjectUserId: peerId,
          status: e.status,
          sentAt: e.sentAt,
          immediate: true,
        );
        if (!_vmDisposed) {
          notifyListeners();
        }
      });
    });

    _receiptSub = service.onReceipt.listen((ChatReceiptEvent r) {
      final mid = r.messageId.trim();
      if (mid.isEmpty) return;
      final idx = _messages.indexWhere((m) => (m.messageId ?? '').trim() == mid);
      if (idx < 0) return;
      final at = r.at ?? DateTime.now().toUtc();
      final row = _messages[idx];
      if (r.kind == 'read') {
        _messages[idx] = row.copyWith(readAt: at);
      } else if (r.kind == 'delivered') {
        _messages[idx] = row.copyWith(deliveredAt: at);
      } else {
        return;
      }
      // Read/delivery on our outgoing messages means the peer is active in this thread.
      if (row.isMe) {
        _applyPeerPresenceFromLiveMessage(at);
      }
      notifyListeners();
    });

    _errorSub = service.onError.listen((err) {
      _isConnected = false;
      _errorMessage = err;
      _log('direct ws error: $err');
      notifyListeners();
    });

    _log('calling direct service.connect()');
    service.connect();
    _isBindingRealtime = false;
    _log('bindDirectChat done');
    if (!_vmDisposed) {
      notifyListeners();
    }
  }

  void _applyPeerPresenceFromLiveMessage(DateTime sentAt) {
    final peerId = _boundTargetUserId.trim();
    if (peerId.isEmpty || _vmDisposed) return;
    _peerOfflineDebounce?.cancel();
    _peerOfflineDebounce = null;
    _peerOnline = true;
    _peerLastSeenUtc = null;
    ChatListScreenViewModel.applyPresenceForUser(
      subjectUserId: peerId,
      status: 'online',
      sentAt: sentAt.toUtc(),
    );
    if (!_vmDisposed) {
      notifyListeners();
    }
  }

  void _startHistoryGapFillTimer(MatchChatService service) {
    _historyGapFillTimer?.cancel();
    _historyGapFillTimer = Timer.periodic(_historyGapFillInterval, (_) {
      if (_vmDisposed || _matchChatService != service) return;
      unawaited(_mergeMissedHistoryFromRest(service));
    });
  }

  void _stopHistoryGapFillTimer() {
    _historyGapFillTimer?.cancel();
    _historyGapFillTimer = null;
  }

  /// WebSocket can stay connected briefly when the user backgrounds the app on
  /// a chat screen. FCM alone does not fire unless the **server** sends a push;
  /// this covers that gap for direct messages only.
  void _maybeNotifyIncomingDirectChatWhileBackgrounded(
    RealtimeChatMessage msg,
  ) {
    final state = WidgetsBinding.instance.lifecycleState;
    final background = state != null && state != AppLifecycleState.resumed;
    if (!background) return;
    final title = msg.senderName.trim().isNotEmpty
        ? msg.senderName.trim()
        : AppText.sportFinding;
    final raw = msg.content.trim();
    if (raw.isEmpty) return;
    final body = raw.length > 120 ? '${raw.substring(0, 117)}...' : raw;
    unawaited(
      FcmLocalNotifications.showSimple(
        title: title,
        body: body,
        payload: <String, dynamic>{
          'type': 'direct_chat',
          'sender_id': msg.senderId,
          'target_user_id': _boundTargetUserId,
          'message_id': msg.messageId,
        },
      ),
    );
  }

  /// Fetches any messages missed while the WebSocket was down or the app was
  /// backgrounded (REST gap-fill; same as post-connect merge).
  Future<void> pullMissedMessages() async {
    final service = _matchChatService;
    if (service == null || _vmDisposed) return;
    await _mergeMissedHistoryFromRest(service);
  }

  Future<void> _mergeMissedHistoryFromRest(MatchChatService service) async {
    final anchor = _initialHistoryLoadedAt;
    if (anchor != null) {
      final sinceFirstPage = DateTime.now().difference(anchor);
      if (sinceFirstPage < const Duration(seconds: 1)) {
        _log(
          'skip post-connect history merge (${sinceFirstPage.inMilliseconds}ms '
          'since initial page — avoids duplicate bulk load)',
        );
        return;
      }
    }
    try {
      final history = await service.loadHistory();
      if (_vmDisposed || _matchChatService != service) return;
      var added = false;
      for (final item in history) {
        final id = item.messageId.trim();
        if (id.isNotEmpty && _messageIds.contains(id)) continue;
        _appendRealtimeMessage(item);
        added = true;
      }
      if (added && !_vmDisposed) {
        _log('direct history merge after WS connect applied new rows');
        notifyListeners();
        _flushReadReceiptsForLoadedPeerMessages();
      }
    } catch (e) {
      _log('merge history after WS connect failed: $e');
    }
  }

  void _appendRealtimeMessage(RealtimeChatMessage message) {
    final id = message.messageId.trim();
    if (id.isNotEmpty && !_messageIds.add(id)) {
      // Forward-compat: backend may send deletion/read events for an existing message.
      if (message.isDeleted) {
        final idx = _messages.indexWhere((m) => (m.messageId ?? '').trim() == id);
        if (idx >= 0) {
          _messages[idx] = _messages[idx].copyWith(
            text: '',
            isDeleted: true,
            isPending: false,
            isFailed: false,
          );
        }
      } else if (message.readAt != null || message.deliveredAt != null) {
        final idx = _messages.indexWhere((m) => (m.messageId ?? '').trim() == id);
        if (idx >= 0) {
          _messages[idx] = _messages[idx].copyWith(
            readAt: message.readAt ?? _messages[idx].readAt,
            deliveredAt: message.deliveredAt ?? _messages[idx].deliveredAt,
          );
        }
      }
      _maybeCapturePeerAvatar(message);
      notifyListeners();
      return;
    }

    final now = message.sentAt.toLocal();
    final isMine = _isDirectMessageFromMe(message);
    _maybeCapturePeerAvatar(message);
    if (isMine && _reconcilePendingOutgoing(message, now)) {
      return;
    }

    final serverMessageId = id.isNotEmpty ? id : null;
    final localId = serverMessageId ?? 'rt_${now.microsecondsSinceEpoch}';
    final parsedType = _parseChatMessageType(message.messageType);
    final rdDelNew = message.receiptTimesForUi(_receiptMyUserIdFor(message));
    _messages.add(
      ChatMessage(
        text: message.content,
        time: DateTimeFormatters.chatTime(now),
        date: DateTimeFormatters.chatDate(now),
        isMe: isMine,
        localId: localId,
        messageId: serverMessageId,
        isDeleted: message.isDeleted,
        type: parsedType,
        mediaUrl: message.mediaUrl,
        thumbnailUrl: message.thumbnailUrl,
        mimeType: message.mimeType,
        fileName: message.fileName,
        sizeBytes: message.sizeBytes,
        readAt: rdDelNew.$1,
        deliveredAt: rdDelNew.$2,
      ),
    );
  }

  void _maybeCapturePeerAvatar(RealtimeChatMessage message) {
    if (_isDirectMessageFromMe(message)) return;
    final av = (message.senderAvatar ?? '').trim();
    if (av.isEmpty) return;
    _peerAvatarUrlFromMessages = av;
  }

  void _appendPendingOutgoing(
    String content, {
    ChatMessageType type = ChatMessageType.text,
    String? mediaUrl,
    String? thumbnailUrl,
    String? mimeType,
    String? fileName,
    int? sizeBytes,
  }) {
    final now = DateTime.now();
    _localMessageCounter += 1;
    _messages.add(
      ChatMessage(
        text: content,
        time: DateTimeFormatters.chatTime(now),
        date: DateTimeFormatters.chatDate(now),
        isMe: true,
        isPending: true,
        localId: 'local_${_localMessageCounter}_${now.microsecondsSinceEpoch}',
        type: type,
        mediaUrl: mediaUrl,
        thumbnailUrl: thumbnailUrl,
        mimeType: mimeType,
        fileName: fileName,
        sizeBytes: sizeBytes,
      ),
    );
    _schedulePendingFailure(_messages.last.localId);
    if (_boundTargetUserId.isNotEmpty) {
      ChatListScreenViewModel.upsertThread(
        userName: contactName,
        targetUserId: _boundTargetUserId,
        avatarUrl: contactDisplayAvatarUrl,
        lastMessage: type == ChatMessageType.text ? content : (fileName ?? ''),
        lastAt: DateTime.now(),
        unreadCount: 0,
        isOnline: _peerOnline,
      );
    }
    _log('pending message added localId=${_messages.last.localId}');
  }

  void _appendFailedOutgoing(
    String content, {
    ChatMessageType type = ChatMessageType.text,
    String? mediaUrl,
    String? thumbnailUrl,
    String? mimeType,
    String? fileName,
    int? sizeBytes,
  }) {
    final now = DateTime.now();
    _localMessageCounter += 1;
    _messages.add(
      ChatMessage(
        text: content,
        time: DateTimeFormatters.chatTime(now),
        date: DateTimeFormatters.chatDate(now),
        isMe: true,
        isFailed: true,
        localId: 'local_${_localMessageCounter}_${now.microsecondsSinceEpoch}',
        type: type,
        mediaUrl: mediaUrl,
        thumbnailUrl: thumbnailUrl,
        mimeType: mimeType,
        fileName: fileName,
        sizeBytes: sizeBytes,
      ),
    );
    _log('failed message added (immediate)');
  }

  void _reschedulePendingTimersForCurrentMessages() {
    for (final t in _pendingFailTimers.values) {
      t.cancel();
    }
    _pendingFailTimers.clear();
    for (final m in _messages) {
      if (m.isPending && m.localId.trim().isNotEmpty) {
        _schedulePendingFailure(m.localId.trim());
      }
    }
  }

  void _schedulePendingFailure(String localId) {
    _pendingFailTimers.remove(localId)?.cancel();
    _pendingFailTimers[localId] = Timer(_pendingFailureTimeout, () {
      final index = _messages.indexWhere((item) => item.localId == localId);
      if (index < 0) return;
      final item = _messages[index];
      if (!item.isPending) return;
      _messages[index] = item.copyWith(isPending: false, isFailed: true);
      _errorMessage = 'A message failed to deliver. Tap to retry.';
      _log('pending timed out -> failed localId=$localId');
      notifyListeners();
    });
  }

  bool _reconcilePendingOutgoing(
    RealtimeChatMessage message,
    DateTime sentAtLocal,
  ) {
    final content = message.content.trim();
    if (content.isEmpty) return false;
    final pendingIndex = _messages.indexWhere(
      (item) => item.isMe && item.isPending && item.text.trim() == content,
    );
    if (pendingIndex < 0) return false;
    final localId = _messages[pendingIndex].localId;
    _pendingFailTimers.remove(localId)?.cancel();
    final parsedType = _parseChatMessageType(message.messageType);
    final rdDel = message.receiptTimesForUi(_receiptMyUserIdFor(message));
    _messages[pendingIndex] = _messages[pendingIndex].copyWith(
      isPending: false,
      isFailed: false,
      time: DateTimeFormatters.chatTime(sentAtLocal),
      date: DateTimeFormatters.chatDate(sentAtLocal),
      messageId: message.messageId.trim().isEmpty ? null : message.messageId.trim(),
      type: parsedType,
      mediaUrl: message.mediaUrl,
      thumbnailUrl: message.thumbnailUrl,
      mimeType: message.mimeType,
      fileName: message.fileName,
      sizeBytes: message.sizeBytes,
      readAt: rdDel.$1,
      deliveredAt: rdDel.$2,
    );
    _log('pending reconciled with server ack localId=$localId');
    return true;
  }

  Future<void> deleteMessage(
    ChatMessage message, {
    required DeleteMessageScope scope,
  }) async {
    final idx = _messages.indexWhere((m) => m.localId == message.localId);
    if (idx < 0) return;

    final removed = _messages.removeAt(idx);
    notifyListeners();

    // Local-only message (pending/failed) or missing IDs: just delete locally.
    final targetUserId = _boundTargetUserId.trim();
    final messageId = (removed.messageId ?? '').trim();
    if (targetUserId.isEmpty || messageId.isEmpty) {
      return;
    }

    try {
      await _directMessagesRepository.deleteDirectMessage(
        userId: targetUserId,
        messageId: messageId,
        scope: scope,
      );
    } catch (e) {
      // rollback
      _messages.insert(idx, removed);
      _errorMessage = 'Failed to delete message.';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteMessages(
    List<ChatMessage> messages, {
    required DeleteMessageScope scope,
  }) async {
    if (messages.isEmpty) return;

    // Snapshot current state for rollback
    final before = List<ChatMessage>.from(_messages);

    final idsToDelete = messages
        .map((m) => m.localId.trim())
        .where((id) => id.isNotEmpty)
        .toSet();

    if (idsToDelete.isEmpty) return;

    // Optimistic remove locally
    _messages.removeWhere((m) => idsToDelete.contains(m.localId.trim()));
    notifyListeners();

    // Delete server-side only for those that have server IDs
    final targetUserId = _boundTargetUserId.trim();
    if (targetUserId.isEmpty) return;

    try {
      for (final m in messages) {
        final messageId = (m.messageId ?? '').trim();
        if (messageId.isEmpty) continue;
        await _directMessagesRepository.deleteDirectMessage(
          userId: targetUserId,
          messageId: messageId,
          scope: scope,
        );
      }
    } catch (e) {
      _log('deleteMessages failed scope=$scope err=$e');
      _messages
        ..clear()
        ..addAll(before);
      _errorMessage = 'Failed to delete message(s).';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _disposeRealtimeOnly() async {
    _log('disposeRealtimeOnly start');
    _bindLease = null;
    _stopHistoryGapFillTimer();
    _peerOfflineDebounce?.cancel();
    _peerOfflineDebounce = null;
    for (final timer in _pendingFailTimers.values) {
      timer.cancel();
    }
    _pendingFailTimers.clear();
    await _connectedSub?.cancel();
    await _messageSub?.cancel();
    await _errorSub?.cancel();
    await _presenceSub?.cancel();
    await _receiptSub?.cancel();
    _connectedSub = null;
    _messageSub = null;
    _errorSub = null;
    _presenceSub = null;
    _receiptSub = null;
    _matchChatService?.dispose();
    _matchChatService = null;
    _isConnected = false;
    _log('disposeRealtimeOnly done');
  }

  @override
  void dispose() {
    _log('dispose called');
    _vmDisposed = true;
    ChatScreenMessagesCache.save(
      _boundTargetUserId,
      _messages,
      _messageIds,
      _localMessageCounter,
    );
    _bindLease = null;
    _disposeRealtimeOnly();
    super.dispose();
  }
}
