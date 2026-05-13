class NotificationModel {
  final String id;
  final String type;
  final Map<String, dynamic> payload;
  final bool isRead;
  final DateTime createdAt;

  /// When the API includes this, the client can drop rows not meant for the
  /// logged-in account (defense in depth). Null = legacy / token-only scope.
  final String? recipientUserId;

  NotificationModel({
    required this.id,
    required this.type,
    required this.payload,
    required this.isRead,
    required this.createdAt,
    this.recipientUserId,
  });

  /// Whether this row should appear for [currentUserId] (from `/users/me`).
  /// If [recipientUserId] is absent, we assume the API already scoped by token.
  bool isAddressedToCurrentUser(String? currentUserId) {
    final r = recipientUserId?.trim();
    if (r == null || r.isEmpty) return true;
    final u = currentUserId?.trim();
    if (u == null || u.isEmpty) return true;
    return r == u;
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final rawPayload = json['payload'];
    final payloadMap = rawPayload is Map
        ? Map<String, dynamic>.from(rawPayload)
        : <String, dynamic>{};
    final rawData = json['data'];
    final dataMap = rawData is Map
        ? Map<String, dynamic>.from(rawData)
        : <String, dynamic>{};
    final mergedPayload = <String, dynamic>{
      ...dataMap,
      ...payloadMap,
      if (json['sender'] is Map) 'sender': json['sender'],
      if (json['user'] is Map) 'user': json['user'],
      if (json['inviter'] is Map) 'inviter': json['inviter'],
      if (json['full_name'] != null) 'full_name': json['full_name'],
      if (json['name'] != null) 'name': json['name'],
      if (json['sender_name'] != null) 'sender_name': json['sender_name'],
      if (json['inviter_name'] != null) 'inviter_name': json['inviter_name'],
      if (json['message'] != null) 'message': json['message'],
      if (json['body'] != null) 'body': json['body'],
      if (json['text'] != null) 'text': json['text'],
    };

    final recipient = _parseRecipientId(json);

    return NotificationModel(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      payload: mergedPayload,
      isRead: json['is_read'] ?? false,
      createdAt:
          DateTime.tryParse('${json['created_at'] ?? ''}') ?? DateTime.now(),
      recipientUserId: recipient,
    );
  }

  static String? _parseRecipientId(Map<String, dynamic> json) {
    String? pick(dynamic v) {
      final s = v?.toString().trim();
      if (s == null || s.isEmpty || s.toLowerCase() == 'null') return null;
      return s;
    }

    final direct = pick(json['recipient_id']) ??
        pick(json['recipient_user_id']) ??
        pick(json['user_id']) ??
        pick(json['account_id']);
    if (direct != null) return direct;

    final recipient = json['recipient'];
    if (recipient is Map) {
      final id = recipient['id'] ?? recipient['user_id'];
      return pick(id);
    }
    return null;
  }

  NotificationModel copyWith({
    String? id,
    String? type,
    Map<String, dynamic>? payload,
    bool? isRead,
    DateTime? createdAt,
    String? recipientUserId,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      payload: payload ?? this.payload,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      recipientUserId: recipientUserId ?? this.recipientUserId,
    );
  }

  bool get isInvitation {
    final normalized = type.trim().toUpperCase();
    return normalized.contains('INVITE');
  }

  bool get isFollowNotification {
    final normalized = type.trim().toUpperCase();
    return normalized.contains('FOLLOW');
  }

  /// In-app / push type for DM alerts (bell badge excludes these; chat tab includes them).
  bool get isDirectMessageNotification {
    final n = type.trim().toLowerCase();
    if (n.isEmpty) return false;
    return n == 'direct_message' || n.contains('direct_message');
  }

  bool get isMatchDeleted {
    final normalized = type.trim().toUpperCase();
    return normalized.contains('DELETE') ||
        normalized.contains('CANCEL') ||
        normalized.contains('REMOVED');
  }

  String get matchId => _readString([
    payload['match_id'],
    payload['matchId'],
    _nested(payload['match'], 'id'),
    _nested(payload['match_data'], 'id'),
  ]);

  String get inviterName => _readString([
    payload['inviter_name'],
    payload['follower_name'],
    payload['actor_name'],
    payload['sender_full_name'],
    payload['inviterFullName'],
    payload['host_name'],
    payload['sender_name'],
    payload['user_name'],
    payload['full_name'],
    payload['name'],
    _nested(payload['inviter'], 'full_name'),
    _nested(payload['inviter'], 'name'),
    _nested(payload['sender'], 'full_name'),
    _nested(payload['sender'], 'name'),
    _nested(payload['user'], 'full_name'),
    _nested(payload['user'], 'name'),
  ]);

  String get actorName => _readString([
    payload['follower_name'],
    payload['followed_by_name'],
    payload['follow_back_name'],
    payload['actor_name'],
    payload['from_user_name'],
    payload['from_name'],
    payload['initiator_name'],
    payload['sender_full_name'],
    payload['sender_name'],
    payload['user_name'],
    payload['full_name'],
    payload['name'],
    _nested(payload['follower'], 'full_name'),
    _nested(payload['follower'], 'name'),
    _nested(payload['actor'], 'full_name'),
    _nested(payload['actor'], 'name'),
    _nested(payload['from_user'], 'full_name'),
    _nested(payload['from_user'], 'name'),
    _nested(payload['sender'], 'full_name'),
    _nested(payload['sender'], 'name'),
    _nested(payload['user'], 'full_name'),
    _nested(payload['user'], 'name'),
  ]);

  String get inviterAvatarUrl => _readString([
    payload['avatar_url'],
    payload['sender_avatar_url'],
    _nested(payload['sender'], 'avatar_url'),
    _nested(payload['user'], 'avatar_url'),
  ]);

  String get sportName => _readString([
    payload['sport'],
    payload['sport_name'],
    _nested(payload['match'], 'sport'),
    _nested(payload['match_data'], 'sport'),
  ]);

  String get locationName => _readString([
    payload['location'],
    payload['location_name'],
    _nested(payload['match'], 'location'),
    _nested(payload['match'], 'location_name'),
    _nested(payload['match_data'], 'location'),
    _nested(payload['match_data'], 'location_name'),
  ]);

  String get message => _readString([
    payload['message'],
    payload['body'],
    payload['text'],
  ]);

  String get displayTitle {
    if (isFollowNotification) {
      final who = actorName.isNotEmpty ? actorName : inviterName;
      if (who.isNotEmpty) return '$who started following you';
      return 'New follower';
    }
    if (isMatchDeleted) {
      final sport = sportName.isNotEmpty ? sportName : 'match';
      return 'A $sport match you joined was deleted';
    }
    if (isInvitation) {
      final who = inviterName.isNotEmpty ? inviterName : 'Someone';
      final sport = sportName.isNotEmpty ? sportName : 'a match';
      return '$who invited you to join $sport';
    }
    if (message.isNotEmpty) return message;
    return type.replaceAll('_', ' ').trim();
  }

  String get displaySubtitle {
    if (locationName.isNotEmpty) return locationName;
    if (sportName.isNotEmpty) return sportName;
    return '';
  }

  String get avatarLetter {
    final base = actorName.isNotEmpty
        ? actorName
        : inviterName.isNotEmpty
        ? inviterName
        : displayTitle;
    if (base.trim().isEmpty) return '?';
    return base.trim()[0].toUpperCase();
  }

  static dynamic _nested(dynamic source, String key) {
    if (source is Map<String, dynamic>) return source[key];
    if (source is Map) return source[key];
    return null;
  }

  static String _readString(List<dynamic> values) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty && text.toLowerCase() != 'null') {
        return text;
      }
    }
    return '';
  }
}

class NotificationResponseModel {
  final List<NotificationModel> items;
  final int total;
  final int page;
  final int limit;
  final bool hasNext;
  final bool hasPrev;

  NotificationResponseModel({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.hasNext,
    required this.hasPrev,
  });

  factory NotificationResponseModel.fromJson(Map<String, dynamic> json) {
    return NotificationResponseModel(
      items: (json['items'] as List)
          .map((e) => NotificationModel.fromJson(e))
          .toList(),
      total: json['total'] ?? 0,
      page: json['page'] ?? 0,
      limit: json['limit'] ?? 0,
      hasNext: json['has_next'] ?? false,
      hasPrev: json['has_prev'] ?? false,
    );
  }
}

extension NotificationModelListX on List<NotificationModel> {
  List<NotificationModel> withoutNotificationId(String notificationId) {
    final trimmedId = notificationId.trim();
    if (trimmedId.isEmpty) return List<NotificationModel>.from(this);
    return where((item) => item.id.trim() != trimmedId).toList();
  }

  List<NotificationModel> withNotificationMarkedRead(String notificationId) {
    final trimmedId = notificationId.trim();
    if (trimmedId.isEmpty) return List<NotificationModel>.from(this);
    return map((item) {
      if (item.id.trim() != trimmedId) return item;
      if (item.isRead) return item;
      return item.copyWith(isRead: true);
    }).toList();
  }

  List<NotificationModel> allMarkedRead() {
    return map((item) => item.isRead ? item : item.copyWith(isRead: true))
        .toList();
  }
}
