// ignore_for_file: use_null_aware_elements

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math' show Random, min;
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:http/http.dart' as http;
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Network/api_service.dart';
import 'package:sport_finding/core/Network/chat_connectivity_gate.dart';
import 'package:sport_finding/core/Network/chat_realtime_events.dart';
import 'package:sport_finding/core/Network/profile_service.dart';
import 'package:sport_finding/core/utils/network_errors.dart';
import 'package:sport_finding/core/utils/reconnect_scheduler.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

typedef ChatWsConnector =
    WebSocketChannel Function(Uri uri, Map<String, dynamic> headers);
typedef ReconnectDelayForAttempt = Duration Function(int attempt);

bool _chatJsonTruthy(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  final s = '$v'.trim().toLowerCase();
  return s == 'true' || s == '1' || s == 'yes' || s == 'y';
}

DateTime? _chatParseUtc(dynamic v) {
  if (v == null) return null;
  final s = '$v'.trim();
  if (s.isEmpty) return null;
  return DateTime.tryParse(s)?.toUtc();
}

DateTime? _chatFirstUtc(Map<String, dynamic> json, List<String> keys) {
  for (final k in keys) {
    final d = _chatParseUtc(json[k]);
    if (d != null) return d;
  }
  return null;
}

class ChatHistoryException implements Exception {
  ChatHistoryException(this.statusCode);
  final int statusCode;

  @override
  String toString() => 'Failed to load chat history: $statusCode';
}

class RealtimeChatMessage {
  RealtimeChatMessage({
    required this.messageId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.sentAt,
    this.messageType,
    this.mediaUrl,
    this.thumbnailUrl,
    this.mimeType,
    this.fileName,
    this.sizeBytes,
    this.senderAvatar,
    this.isDeleted = false,
    this.deletedAt,
    this.deletedScope,
    this.deliveredAt,
    this.readAt,
  });

  final String messageId;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String content;
  final DateTime sentAt;
  final String? messageType; // "text" | "image" | "file"
  final String? mediaUrl;
  final String? thumbnailUrl;
  final String? mimeType;
  final String? fileName;
  final int? sizeBytes;
  final bool isDeleted;
  final DateTime? deletedAt;
  /// REST: `me` | `everyone`. WS `message_deleted`: typically `everyone`.
  final String? deletedScope;
  final DateTime? deliveredAt;
  final DateTime? readAt;

  factory RealtimeChatMessage.fromJson(Map<String, dynamic> json) {
    final deletedForEveryone = _chatJsonTruthy(json['deleted_for_everyone']);
    final isDeletedRaw =
        json['is_deleted'] ?? json['deleted'] ?? deletedForEveryone;
    final isDeleted = isDeletedRaw is bool
        ? isDeletedRaw
        : ('$isDeletedRaw'.toLowerCase() == 'true');
    final sentAt =
        DateTime.tryParse('${json['sent_at'] ?? ''}') ?? DateTime.now();
    final sentUtc = sentAt.toUtc();

    var readAt = _chatFirstUtc(json, [
      'read_at',
      'readAt',
      'read_timestamp',
      'read_time',
      'seen_at',
      'seenAt',
    ]);
    final readStatus =
        '${json['status'] ?? json['receipt'] ?? json['state'] ?? ''}'
            .trim()
            .toLowerCase();
    if (readAt == null &&
        (_chatJsonTruthy(json['is_read'] ?? json['read'] ?? json['seen']) ||
            readStatus == 'read' ||
            readStatus == 'seen')) {
      readAt = _chatFirstUtc(json, [
            'updated_at',
            'delivered_at',
            'deliveredAt',
            'sent_at',
            'sentAt',
          ]) ??
          sentUtc;
    }

    var deliveredAt = _chatFirstUtc(json, [
      'delivered_at',
      'deliveredAt',
      'delivery_at',
      'deliveryAt',
    ]);
    final deliveryStatus =
        '${json['delivery_status'] ?? json['delivery'] ?? ''}'
            .trim()
            .toLowerCase();
    if (deliveredAt == null &&
        (_chatJsonTruthy(
              json['is_delivered'] ?? json['delivered'] ?? json['received'],
            ) ||
            deliveryStatus == 'delivered' ||
            deliveryStatus == 'received')) {
      deliveredAt = _chatFirstUtc(json, ['updated_at', 'sent_at', 'sentAt']) ??
          sentUtc;
    }

    final mid =
        '${json['message_id'] ?? json['id'] ?? json['messageId'] ?? ''}'.trim();

    final explicitMsgType =
        '${json['message_type'] ?? json['messageType'] ?? ''}'.trim();
    final topType = '${json['type'] ?? ''}'.trim().toLowerCase();
    final resolvedMessageType = explicitMsgType.isNotEmpty
        ? explicitMsgType
        : (topType.isEmpty || topType == 'chat_message'
              ? null
              : '${json['type']}'.trim());

    final deletedAt = _chatFirstUtc(json, [
      'deleted_at',
      'deletedAt',
      'deleted_for_everyone_at',
      'deletedForEveryoneAt',
    ]);

    return RealtimeChatMessage(
      messageId: mid,
      senderId: '${json['sender_id'] ?? json['senderId'] ?? ''}',
      senderName: '${json['sender_name'] ?? json['senderName'] ?? ''}',
      senderAvatar:
          (json['sender_avatar'] ?? json['senderAvatar'])?.toString(),
      content: '${json['content'] ?? ''}',
      sentAt: sentAt,
      messageType: resolvedMessageType,
      mediaUrl: (json['media_url'] ?? json['mediaUrl'] ?? json['file_url'])
          ?.toString(),
      thumbnailUrl:
          (json['thumbnail_url'] ?? json['thumbnailUrl'] ?? json['thumb_url'])
              ?.toString(),
      mimeType: (json['mime_type'] ?? json['mimeType'] ?? json['mime'])
          ?.toString(),
      fileName: (json['file_name'] ?? json['fileName'] ?? json['filename'])
          ?.toString(),
      sizeBytes: json['size_bytes'] is num
          ? (json['size_bytes'] as num).toInt()
          : (json['sizeBytes'] is num
                ? (json['sizeBytes'] as num).toInt()
                : null),
      isDeleted: isDeleted,
      deletedAt: deletedAt,
      deletedScope:
          (json['deleted_scope'] ?? json['deletedScope'] ?? json['scope'])
              ?.toString(),
      deliveredAt: deliveredAt,
      readAt: readAt,
    );
  }
}

extension RealtimeChatMessageUiReceipts on RealtimeChatMessage {
  /// Read / delivered timestamps for tick UI. When the server echoes our message
  /// without receipt fields, use [sentAt] as a minimum "server accepted" delivery
  /// time (double grey tick) until explicit read receipts arrive.
  (DateTime? read, DateTime? delivered) receiptTimesForUi(String myUserId) {
    final mine =
        myUserId.trim().isNotEmpty && senderId.trim() == myUserId.trim();
    if (!mine) return (readAt, deliveredAt);
    if (readAt != null || deliveredAt != null) return (readAt, deliveredAt);
    return (readAt, sentAt.toUtc());
  }
}

class MatchChatService {
  /// Sockets that have completed the server `connected` handshake — used to push
  /// foreground/background presence on app lifecycle (best-effort; server may ignore).
  static final Set<MatchChatService> _clientPresenceTargets =
      <MatchChatService>{};

  /// Notify all open direct-chat WebSockets that this user is [status] (`online` / `offline`).
  static void broadcastClientPresence(String status) {
    final normalized = status.trim().toLowerCase();
    if (normalized.isEmpty) return;
    for (final s in List<MatchChatService>.from(_clientPresenceTargets)) {
      if (s._isDisposed) {
        _clientPresenceTargets.remove(s);
        continue;
      }
      s._sendClientPresenceFrame(normalized);
    }
  }

  /// When DNS / radio drops, every open DM socket fails at once; without a
  /// shared cooldown they all reconnect on the same 1s timer and spam the OS.
  static DateTime _earliestGlobalWsConnect =
      DateTime.fromMillisecondsSinceEpoch(0);
  static int _globalNetworkFailStreak = 0;
  static DateTime? _lastGlobalCooldownBump;

  static Duration _globalCooldownRemaining() {
    final now = DateTime.now();
    if (now.isBefore(_earliestGlobalWsConnect)) {
      return _earliestGlobalWsConnect.difference(now);
    }
    return Duration.zero;
  }

  static final Random _reconnectJitter = Random();

  static void _noteTransientNetworkFailure() {
    final now = DateTime.now();
    if (_lastGlobalCooldownBump != null &&
        now.difference(_lastGlobalCooldownBump!) <
            const Duration(milliseconds: 500)) {
      return;
    }
    _lastGlobalCooldownBump = now;
    _globalNetworkFailStreak =
        (_globalNetworkFailStreak + 1).clamp(1, 8);
    const caps = <int>[3, 5, 10, 20, 40, 60, 90, 120];
    final i = _globalNetworkFailStreak - 1;
    final sec = caps[i < caps.length ? i : caps.length - 1];
    final proposed = now.add(Duration(seconds: sec));
    if (proposed.isAfter(_earliestGlobalWsConnect)) {
      _earliestGlobalWsConnect = proposed;
    }
  }

  static void _clearGlobalNetworkCooldown() {
    _globalNetworkFailStreak = 0;
    _earliestGlobalWsConnect =
        DateTime.fromMillisecondsSinceEpoch(0);
    _lastGlobalCooldownBump = null;
  }

  static Uri _wsUriForLog(Uri uri) =>
      uri.replace(queryParameters: const <String, dynamic>{});

  MatchChatService({
    required this.accessToken,
    this.targetUserId,
    ChatWsConnector? wsConnector,
    ReconnectDelayForAttempt? reconnectDelayForAttempt,
    String? restBaseUrl,
  }) : _wsConnector = wsConnector ?? _defaultWsConnector {
    final baseRestUrl = (restBaseUrl ?? ApiService().baseUrl).trim();
    _baseRest = '$baseRestUrl/api/v1';
    _baseWs = _toWsBase(baseRestUrl);
    _reconnectScheduler = ReconnectScheduler(
      delayForAttempt: reconnectDelayForAttempt ?? _defaultReconnectDelay,
    );
  }

  final String? targetUserId;
  late final String _baseRest;
  late final String _baseWs;

  final String accessToken;
  final ChatWsConnector _wsConnector;

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _channelSub;
  late final ReconnectScheduler _reconnectScheduler;
  bool _isDisposed = false;
  bool _offlineResumeWaiter = false;

  final _messageController = StreamController<RealtimeChatMessage>.broadcast();
  final _errorController = StreamController<String>.broadcast();
  final _connectedController = StreamController<void>.broadcast();
  final _presenceController = StreamController<ChatPresenceEvent>.broadcast();
  final _receiptController = StreamController<ChatReceiptEvent>.broadcast();

  /// Suppress duplicate `chat_message` frames (server or multi-listener echo).
  final LinkedHashSet<String> _recentChatMessageIds = LinkedHashSet<String>();
  static const int _maxRecentChatMessageIds = 128;

  bool _takeChatMessageIdIfNew(String messageId) {
    final id = messageId.trim();
    if (id.isEmpty) return true;
    if (_recentChatMessageIds.contains(id)) return false;
    _recentChatMessageIds.add(id);
    while (_recentChatMessageIds.length > _maxRecentChatMessageIds) {
      _recentChatMessageIds.remove(_recentChatMessageIds.first);
    }
    return true;
  }

  Stream<RealtimeChatMessage> get onMessage => _messageController.stream;
  Stream<String> get onError => _errorController.stream;
  Stream<void> get onConnected => _connectedController.stream;
  Stream<ChatPresenceEvent> get onPresence => _presenceController.stream;
  Stream<ChatReceiptEvent> get onReceipt => _receiptController.stream;

  String get _chatPath {
    final resolvedTargetUserId = targetUserId?.trim() ?? '';
    if (resolvedTargetUserId.isNotEmpty) {
      return '/ws/users/$resolvedTargetUserId/chat';
    }
    throw StateError('MatchChatService requires a non-empty targetUserId.');
  }

  static WebSocketChannel _defaultWsConnector(
    Uri uri,
    Map<String, dynamic> headers,
  ) {
    final safeUri = _wsUriForLog(uri);
    if (kIsWeb) {
      debugPrint('[MatchChatService] [WS] Web connector -> $safeUri');
      return WebSocketChannel.connect(uri);
    }
    debugPrint('[MatchChatService] [WS] IO connector -> $safeUri');
    return IOWebSocketChannel.connect(uri, headers: headers);
  }

  static Duration _defaultReconnectDelay(int attempt) {
    final safeAttempt = attempt < 1 ? 1 : attempt;
    final cappedPow = min(6, safeAttempt - 1);
    final seconds = min(60, 1 << cappedPow);
    final jitterMs = _reconnectJitter.nextInt(500);
    return Duration(seconds: seconds, milliseconds: jitterMs);
  }

  static String _userVisibleWsError(Object e) {
    if (isTransientNetworkError(e)) {
      return AppText.chatNetworkUnreachable;
    }
    return 'WebSocket error: $e';
  }

  static String _toWsBase(String restBaseUrl) {
    final uri = Uri.parse(restBaseUrl);
    final wsScheme = uri.scheme == 'https' ? 'wss' : 'ws';
    return uri.replace(scheme: wsScheme, path: '', query: null).toString();
  }

  /// Loads DM history. [before] is keyset pagination (message uuid), newest-first pages.
  Future<List<RealtimeChatMessage>> loadHistory({
    int page = 1,
    int limit = 20,
    String? before,
  }) async {
    final activeTargetUserId = targetUserId?.trim() ?? '';
    if (activeTargetUserId.isEmpty) {
      throw Exception('Chat history requires targetUserId.');
    }
    final safePage = page < 1 ? 1 : page;
    final safeLimit = limit.clamp(1, 100);
    final q = <String, String>{
      'page': '$safePage',
      'limit': '$safeLimit',
    };
    final b = before?.trim() ?? '';
    if (b.isNotEmpty) q['before'] = b;
    final uri = Uri.parse(
      '$_baseRest/users/$activeTargetUserId/messages',
    ).replace(queryParameters: q);
    debugPrint('[MatchChatService] [History] GET $uri');
    final response = await http.get(
      uri,
      headers: <String, String>{
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      debugPrint(
        '[MatchChatService] [History] failed status=${response.statusCode}',
      );
      throw ChatHistoryException(response.statusCode);
    }

    final dynamic decoded = jsonDecode(response.body);
    final List<dynamic> items = decoded is List
        ? decoded
        : (decoded is Map<String, dynamic> && decoded['items'] is List
              ? decoded['items'] as List<dynamic>
              : <dynamic>[]);

    final history = items
        .whereType<Map>()
        .map(
          (item) =>
              RealtimeChatMessage.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
    // API returns newest-first; UI (and mobile VM) expect chronological order.
    history.sort((a, b) => a.sentAt.compareTo(b.sentAt));
    debugPrint(
      '[MatchChatService] [History] loaded count=${history.length} targetUserId=$targetUserId',
    );
    return history;
  }

  void _emitError(String message) {
    if (_errorController.isClosed) return;
    _errorController.add(message);
  }

  void connect() {
    if (_isDisposed || _channel != null) {
      debugPrint(
        '[MatchChatService] [WS] skip connect (disposed=$_isDisposed hasChannel=${_channel != null}) targetUserId=$targetUserId',
      );
      return;
    }
    final cooldown = _globalCooldownRemaining();
    if (cooldown > Duration.zero) {
      debugPrint(
        '[MatchChatService] [WS] defer connect ${cooldown.inMilliseconds}ms '
        '(shared network cooldown) targetUserId=$targetUserId',
      );
      _reconnectScheduler.schedule(
        canSchedule: () => !_isDisposed && _channel == null,
        onFire: connect,
        overrideDelay: cooldown,
      );
      return;
    }
    _reconnectScheduler.cancel();
    if (!kIsWeb && !ChatConnectivityGate.instance.appearsReachable) {
      _emitError(AppText.chatNoInternetConnection);
      if (!_offlineResumeWaiter) {
        _offlineResumeWaiter = true;
        ChatConnectivityGate.instance.whenReachable(() {
          _offlineResumeWaiter = false;
          if (!_isDisposed && _channel == null) {
            connect();
          }
        });
      }
      return;
    }

    final pathUri = Uri.parse('$_baseWs$_chatPath');
    final uri = kIsWeb
        ? pathUri.replace(
            queryParameters: <String, String>{'token': accessToken},
          )
        : pathUri;

    debugPrint('[MatchChatService] [WS] connecting path=$_chatPath');
    try {
      _channel = _wsConnector(uri, <String, dynamic>{
        HttpHeaders.authorizationHeader: 'Bearer $accessToken',
      });
    } catch (e) {
      debugPrint('[MatchChatService] [WS] connect ctor failed $e');
      _emitError(_userVisibleWsError(e));
      _resetSocket();
      if (!_isDisposed) {
        _scheduleReconnect(triggerError: e);
      }
      return;
    }
    _channelSub = _channel!.stream.listen(
      (dynamic data) {
        if (_isDisposed) return;
        if (data is! String) return;
        debugPrint('[MatchChatService] [WS] event raw=$data');
        try {
          final decoded = jsonDecode(data);
          if (decoded is Map<String, dynamic>) {
            _handleServerEvent(decoded);
          }
        } catch (e) {
          debugPrint('[MatchChatService] [WS] bad frame: $e');
        }
      },
      onError: (Object error) {
        debugPrint('[MatchChatService] [WS] error $error');
        if (_isDisposed) {
          _resetSocket();
          return;
        }
        _emitError(_userVisibleWsError(error));
        _resetSocket();
        _scheduleReconnect(triggerError: error);
      },
      onDone: () {
        final closeCode = _channel?.closeCode;
        debugPrint('[MatchChatService] [WS] done/closed code=$closeCode');
        if (_isDisposed) {
          _resetSocket();
          return;
        }
        final message = _messageForCloseCode(closeCode);
        _emitError(message);
        _resetSocket();
        if (_shouldReconnect(closeCode)) {
          _scheduleReconnect();
        }
      },
      cancelOnError: true,
    );
    final dynamic dynamicChannel = _channel;
    final dynamic readyFuture = dynamicChannel?.ready;
    if (readyFuture is Future) {
      unawaited(
        readyFuture.catchError((Object e) {
          if (_isDisposed) return;
          _emitError(_userVisibleWsError(e));
          _resetSocket();
          _scheduleReconnect(triggerError: e);
        }),
      );
    }
  }

  void _handleServerEvent(Map<String, dynamic> event) {
    if (_isDisposed) return;
    debugPrint(
      '[MatchChatService] [WS] parsed event type=${event['type']} targetUserId=$targetUserId',
    );
    switch ('${event['type'] ?? ''}') {
      case 'connected':
        _reconnectScheduler.resetAttempts();
        _clearGlobalNetworkCooldown();
        if (!_isDisposed) {
          _clientPresenceTargets.add(this);
        }
        if (!_connectedController.isClosed) {
          _connectedController.add(null);
        }
        debugPrint('[MatchChatService] [WS] connected acknowledged');
        break;
      case 'chat_message':
        final mid =
            '${event['message_id'] ?? event['id'] ?? event['messageId'] ?? ''}'
                .trim();
        if (!_takeChatMessageIdIfNew(mid)) {
          debugPrint(
            '[MatchChatService] [WS] skip duplicate chat_message id=$mid',
          );
          break;
        }
        if (!_messageController.isClosed) {
          _messageController.add(RealtimeChatMessage.fromJson(event));
        }
        final sid = '${event['sender_id'] ?? ''}'.trim();
        final peer = targetUserId?.trim() ?? '';
        final delivery = peer.isEmpty
            ? 'unknown_ctx'
            : (sid == peer ? 'from_peer' : 'from_self_echo');
        debugPrint(
          '[MatchChatService] [WS] chat_message_delivery=$delivery '
          'message_id=$mid sender=$sid target_peer=$peer',
        );
        break;
      // Forward-compat: treat delete/read/delivered as events that the UI can react to.
      case 'message_deleted':
        if (!_messageController.isClosed) {
          final merged = Map<String, dynamic>.from(event);
          merged['is_deleted'] = true;
          final mid =
              '${merged['message_id'] ?? merged['id'] ?? merged['messageId'] ?? ''}'
                  .trim();
          if (mid.isNotEmpty) merged['message_id'] = mid;
          _messageController.add(RealtimeChatMessage.fromJson(merged));
        }
        break;
      case 'presence_update':
        final presence = ChatPresenceEvent.tryParse(event, fromSnapshot: false);
        if (presence != null && !_presenceController.isClosed) {
          _presenceController.add(presence);
        }
        break;
      case 'presence_snapshot':
        final snap = ChatPresenceEvent.tryParse(event, fromSnapshot: true);
        if (snap != null && !_presenceController.isClosed) {
          _presenceController.add(snap);
        }
        break;
      case 'message_read':
      case 'read_receipt':
      case 'read':
      case 'chat_read':
      case 'chat_message_read':
        final read = ChatReceiptEvent.tryParseRead(event);
        if (read != null && !_receiptController.isClosed) {
          _receiptController.add(read);
        }
        break;
      case 'message_delivered':
      case 'delivered':
      case 'delivery_ack':
      case 'message_received':
      case 'chat_delivered':
        final delivered = ChatReceiptEvent.tryParseDelivered(event);
        if (delivered != null && !_receiptController.isClosed) {
          _receiptController.add(delivered);
        }
        break;
      case 'typing_start':
      case 'typing_stop':
        break;
      case 'error':
        _emitError('${event['detail'] ?? 'Unknown error'}');
        debugPrint('[MatchChatService] [WS] server error ${event['detail']}');
        break;
      default:
        final readImp = ChatReceiptEvent.tryParseReadIfImplied(event);
        if (readImp != null && !_receiptController.isClosed) {
          _receiptController.add(readImp);
          break;
        }
        final delImp = ChatReceiptEvent.tryParseDeliveredIfImplied(event);
        if (delImp != null && !_receiptController.isClosed) {
          _receiptController.add(delImp);
        }
        break;
    }
  }

  void _sendClientPresenceFrame(String status) {
    if (_isDisposed || _channel == null) return;
    // Server currently rejects client-originated `presence_update` on web
    // ("Unsupported message type."); skip until the API accepts this frame.
    if (kIsWeb) return;
    final myId = ProfileService().profile?.id.trim() ?? '';
    if (myId.isEmpty) return;
    try {
      _channel!.sink.add(
        jsonEncode(<String, dynamic>{
          'type': 'presence_update',
          'user_id': myId,
          'status': status,
          'sent_at': DateTime.now().toUtc().toIso8601String(),
        }),
      );
      debugPrint(
        '[MatchChatService] [WS] client presence sent status=$status targetUserId=$targetUserId',
      );
    } catch (e) {
      debugPrint('[MatchChatService] [WS] client presence send failed: $e');
    }
  }

  bool sendMessage(String content) {
    return sendChatMessage(content: content);
  }

  /// Sends a chat message payload.
  ///
  /// For attachments, pass `messageType` as `"image"` or `"file"` and include
  /// `mediaUrl` (and optional metadata). For forward compatibility, we include
  /// these fields even if the backend currently ignores them.
  bool sendChatMessage({
    required String content,
    String messageType = 'text',
    String? mediaUrl,
    String? thumbnailUrl,
    String? mimeType,
    String? fileName,
    int? sizeBytes,
  }) {
    final trimmed = content.trim();
    final trimmedType = messageType.trim().isEmpty
        ? 'text'
        : messageType.trim().toLowerCase();
    if (trimmed.isEmpty && (mediaUrl ?? '').trim().isEmpty) return false;
    if (trimmed.length > 1000) {
      _emitError('Message too long (max 1000 characters)');
      return false;
    }
    if (_channel == null) {
      debugPrint(
        '[MatchChatService] [WS] send blocked: no channel. scheduling reconnect',
      );
      _emitError('Not connected. Reconnecting...');
      _scheduleReconnect();
      return false;
    }

    debugPrint(
      '[MatchChatService] [WS] send message type=$trimmedType len=${trimmed.length} hasMedia=${(mediaUrl ?? '').trim().isNotEmpty}',
    );
    _channel?.sink.add(
      jsonEncode(<String, dynamic>{
        'type': 'chat_message',
        'content': trimmed,
        'message_type': trimmedType,
        if (mediaUrl?.trim().isNotEmpty ?? false) 'media_url': mediaUrl!.trim(),
        if (thumbnailUrl?.trim().isNotEmpty ?? false)
          'thumbnail_url': thumbnailUrl!.trim(),
        if (mimeType?.trim().isNotEmpty ?? false) 'mime_type': mimeType!.trim(),
        if (fileName?.trim().isNotEmpty ?? false) 'file_name': fileName!.trim(),
        if (sizeBytes != null) 'size_bytes': sizeBytes,
      }),
    );
    return true;
  }

  /// Direct chat WS (§5.4): notify peer that this user read [messageId].
  /// Server responds with canonical `message_read` broadcast.
  bool sendReadReceipt(String messageId) {
    final id = messageId.trim();
    if (id.isEmpty || _isDisposed || _channel == null) return false;
    _channel!.sink.add(
      jsonEncode(<String, dynamic>{
        'type': 'message_read',
        'message_id': id,
      }),
    );
    return true;
  }

  /// Optional client ack: use only if the backend requires it before it
  /// broadcasts [message_delivered] to the sender. Most deployments infer
  /// delivery server-side when the message is persisted or pushed to the peer.
  bool sendDeliveredReceipt(String messageId) {
    final id = messageId.trim();
    if (id.isEmpty || _isDisposed || _channel == null) return false;
    _channel!.sink.add(
      jsonEncode(<String, dynamic>{
        'type': 'message_delivered',
        'message_id': id,
      }),
    );
    return true;
  }

  void _resetSocket() {
    debugPrint('[MatchChatService] [WS] reset socket');
    _clientPresenceTargets.remove(this);
    _channelSub?.cancel();
    _channelSub = null;
    _channel = null;
  }

  void _scheduleReconnect({Object? triggerError}) {
    if (triggerError != null && isTransientNetworkError(triggerError)) {
      _noteTransientNetworkFailure();
    }
    final wait = _globalCooldownRemaining();
    debugPrint('[MatchChatService] [WS] schedule reconnect');
    _reconnectScheduler.schedule(
      canSchedule: () => !_isDisposed && _channel == null,
      onFire: connect,
      overrideDelay: wait > Duration.zero ? wait : null,
    );
  }

  bool _shouldReconnect(int? closeCode) {
    if (closeCode == 4001 || closeCode == 4003 || closeCode == 4004) {
      return false;
    }
    return true;
  }

  String _messageForCloseCode(int? closeCode) {
    switch (closeCode) {
      case 4001:
        return 'Session expired. Please sign in again.';
      case 4003:
        return 'Access denied for this chat.';
      case 4004:
        return 'Chat target was not found.';
      default:
        return 'Connection closed';
    }
  }

  void dispose() {
    debugPrint('[MatchChatService] dispose targetUserId=$targetUserId');
    _isDisposed = true;
    _offlineResumeWaiter = false;
    _clientPresenceTargets.remove(this);
    _recentChatMessageIds.clear();
    _reconnectScheduler.cancel();
    _channelSub?.cancel();
    _channelSub = null;
    _channel?.sink.close();
    _channel = null;
    _messageController.close();
    _errorController.close();
    _connectedController.close();
    _presenceController.close();
    _receiptController.close();
  }
}
