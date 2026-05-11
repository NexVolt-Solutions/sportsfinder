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

typedef MatchChatServiceFactory =
    MatchChatService Function(String accessToken, String targetUserId);
typedef AccessTokenProvider = Future<String?> Function();
typedef CurrentUserIdProvider = String Function();

class ChatScreenViewModel extends ChangeNotifier {
  ChatScreenViewModel({
    this.contactName = AppText.alexJohnson,
    this.isOnline = true,
    String? contactAvatarUrl,
    MatchChatServiceFactory? chatServiceFactory,
    AccessTokenProvider? accessTokenProvider,
    CurrentUserIdProvider? currentUserIdProvider,
  }) : _routeContactAvatarUrl = (() {
         final t = (contactAvatarUrl ?? '').trim();
         return t.isEmpty ? null : t;
       })(),
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
  bool _peerOnline = true;
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
  String _boundTargetUserId = '';
  int _localMessageCounter = 0;
  final Map<String, Timer> _pendingFailTimers = <String, Timer>{};
  static const Duration _pendingFailureTimeout = Duration(seconds: 12);
  final DirectMessagesRepository _directMessagesRepository =
      DirectMessagesRepository();
  final ChatUploadRepository _chatUploadRepository = ChatUploadRepository();

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isEmpty => _messages.isEmpty;
  bool get isConnected => _isConnected;
  String? get errorMessage => _errorMessage;
  bool get isRealtimeChatBound => _matchChatService != null;
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
    if (trimmedTargetUserId.isEmpty || _isBindingRealtime) return;
    _log('bindDirectChat start targetUserId=$trimmedTargetUserId');
    _boundTargetUserId = trimmedTargetUserId;
    _peerOnline = isOnline;
    _peerLastSeenUtc = null;
    _peerAvatarUrlFromMessages = null;

    final token = await _accessTokenProvider();
    if (token == null || token.isEmpty) {
      _log('bindDirectChat aborted: access token missing');
      return;
    }
    final myIdAtBind = _currentUserIdProvider();
    _log('bindDirectChat ctx myId=$myIdAtBind tokenLen=${token.length}');

    _isBindingRealtime = true;
    _errorMessage = null;
    notifyListeners();

    await _disposeRealtimeOnly();
    _log('old realtime state disposed');

    final service = _chatServiceFactory(token, trimmedTargetUserId);
    _matchChatService = service;

    try {
      final history = await service.loadHistory();
      _messages.clear();
      _messageIds.clear();
      for (final item in history) {
        _appendRealtimeMessage(item);
      }
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
      _errorMessage = 'Could not load direct chat history: $e';
      _log('direct history load failed: $e');
    }

    _connectedSub = service.onConnected.listen((_) {
      _isConnected = true;
      _errorMessage = null;
      _log('direct ws connected targetUserId=$_boundTargetUserId');
      notifyListeners();
    });

    _messageSub = service.onMessage.listen((msg) {
      final myId = _currentUserIdProvider();
      final isMine = myId.isNotEmpty && msg.senderId.trim() == myId.trim();
      _log(
        'direct ws message id=${msg.messageId} sender=${msg.senderId} '
        'isMine=$isMine myId=$myId targetUserId=$_boundTargetUserId len=${msg.content.length}',
      );
 
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
      _errorMessage = null;
      notifyListeners();
    });

    _presenceSub = service.onPresence.listen((ChatPresenceEvent e) {
      final peerId = _boundTargetUserId.trim();
      if (peerId.isEmpty || e.userId.trim() != peerId) return;
      final st = e.status.trim().toLowerCase();
      _peerOnline =
          st == 'online' || st == 'active' || st == 'available';
      _peerLastSeenUtc =
          _peerOnline ? null : (e.sentAt ?? DateTime.now().toUtc());
      ChatListScreenViewModel.applyPresenceForUser(
        subjectUserId: peerId,
        status: e.status,
        sentAt: e.sentAt,
      );
      notifyListeners();
    });

    _receiptSub = service.onReceipt.listen((ChatReceiptEvent r) {
      final mid = r.messageId.trim();
      if (mid.isEmpty) return;
      final idx = _messages.indexWhere((m) => (m.messageId ?? '').trim() == mid);
      if (idx < 0) return;
      final at = r.at ?? DateTime.now().toUtc();
      if (r.kind == 'read') {
        _messages[idx] = _messages[idx].copyWith(readAt: at);
      } else if (r.kind == 'delivered') {
        _messages[idx] = _messages[idx].copyWith(deliveredAt: at);
      } else {
        return;
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
    notifyListeners();
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
          'message_id': msg.messageId,
        },
      ),
    );
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
    final myId = _currentUserIdProvider();
    final isMine = myId.isNotEmpty && message.senderId.trim() == myId;
    _maybeCapturePeerAvatar(message);
    if (isMine && _reconcilePendingOutgoing(message, now)) {
      return;
    }

    final serverMessageId = id.isNotEmpty ? id : null;
    final localId = serverMessageId ?? 'rt_${now.microsecondsSinceEpoch}';
    final parsedType = _parseChatMessageType(message.messageType);
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
        readAt: message.readAt,
        deliveredAt: message.deliveredAt,
      ),
    );
  }

  void _maybeCapturePeerAvatar(RealtimeChatMessage message) {
    final myId = _currentUserIdProvider();
    final isMine = myId.isNotEmpty && message.senderId.trim() == myId;
    if (isMine) return;
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
      readAt: message.readAt,
      deliveredAt: message.deliveredAt,
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
    _disposeRealtimeOnly();
    super.dispose();
  }
}
