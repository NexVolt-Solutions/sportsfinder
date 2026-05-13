class DirectChatsResponse {
  const DirectChatsResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.hasNext,
    required this.hasPrev,
  });

  final List<DirectChatConversation> items;
  final int total;
  final int page;
  final int limit;
  final bool hasNext;
  final bool hasPrev;

  factory DirectChatsResponse.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = (rawItems is List ? rawItems : const <dynamic>[])
        .whereType<Map>()
        .map((e) => DirectChatConversation.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return DirectChatsResponse(
      items: items,
      total: int.tryParse('${json['total'] ?? 0}') ?? 0,
      page: int.tryParse('${json['page'] ?? 1}') ?? 1,
      limit: int.tryParse('${json['limit'] ?? items.length}') ?? items.length,
      hasNext: json['has_next'] == true,
      hasPrev: json['has_prev'] == true,
    );
  }
}

class DirectChatConversation {
  const DirectChatConversation({
    required this.user,
    this.lastMessageId,
    required this.lastMessage,
    this.lastMessageSenderId,
    this.lastMessageSentAt,
    this.unreadFromApi,
  });

  final ChatUserSummary user;
  final String? lastMessageId;
  final String lastMessage;
  final String? lastMessageSenderId;
  final DateTime? lastMessageSentAt;

  /// When non-null, the API included an unread count for this peer (use as-is,
  /// including `0` after read). When null, the client keeps prior local badge.
  final int? unreadFromApi;

  factory DirectChatConversation.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];
    return DirectChatConversation(
      user: ChatUserSummary.fromJson(
        userJson is Map ? Map<String, dynamic>.from(userJson) : <String, dynamic>{},
      ),
      lastMessageId: _trimOrNull(json['last_message_id']),
      lastMessage: (json['last_message'] ?? '').toString(),
      lastMessageSenderId: _trimOrNull(json['last_message_sender_id']),
      lastMessageSentAt: DateTime.tryParse('${json['last_message_sent_at'] ?? ''}'),
      unreadFromApi: _parseOptionalUnreadCount(json),
    );
  }
}

 
int? _parseOptionalUnreadCount(Map<String, dynamic> json) {
  const keys = <String>[
    'unread_count',
    'unreadCount',
    'unread_messages',
    'unreadMessages',
  ];
  for (final key in keys) {
    if (!json.containsKey(key)) continue;
    final v = json[key];
    if (v == null) return 0;
    if (v is int) return v < 0 ? 0 : v;
    if (v is num) return v.toInt() < 0 ? 0 : v.toInt();
    final n = int.tryParse(v.toString().trim());
    if (n != null) return n < 0 ? 0 : n;
    return 0;
  }
  return null;
}

class ChatUserSummary {
  const ChatUserSummary({
    required this.id,
    required this.fullName,
    this.avatarUrl,
    this.avgRating,
  });

  final String id;
  final String fullName;
  final String? avatarUrl;
  final double? avgRating;

  factory ChatUserSummary.fromJson(Map<String, dynamic> json) {
    return ChatUserSummary(
      id: (json['id'] ?? '').toString(),
      fullName: (json['full_name'] ?? '').toString(),
      avatarUrl: _trimOrNull(json['avatar_url']),
      avgRating: json['avg_rating'] is num ? (json['avg_rating'] as num).toDouble() : null,
    );
  }
}

String? _trimOrNull(dynamic value) {
  final t = (value ?? '').toString().trim();
  return t.isEmpty ? null : t;
}

