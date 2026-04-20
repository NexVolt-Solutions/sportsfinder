class NotificationModel {
  final String id;
  final String type;
  final Map<String, dynamic> payload;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.payload,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      payload: Map<String, dynamic>.from(json['payload'] ?? const {}),
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  bool get isInvitation {
    final normalized = type.trim().toUpperCase();
    return normalized.contains('INVITE');
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
    payload['sender_name'],
    payload['user_name'],
    payload['full_name'],
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
    if (message.isNotEmpty) return message;
    if (isMatchDeleted) {
      final sport = sportName.isNotEmpty ? sportName : 'match';
      return 'A $sport match you joined was deleted';
    }
    if (isInvitation) {
      final who = inviterName.isNotEmpty ? inviterName : 'Someone';
      final sport = sportName.isNotEmpty ? sportName : 'a match';
      return '$who invited you to join $sport';
    }
    return type.replaceAll('_', ' ').trim();
  }

  String get displaySubtitle {
    if (locationName.isNotEmpty) return locationName;
    if (sportName.isNotEmpty) return sportName;
    return '';
  }

  String get avatarLetter {
    final base = inviterName.isNotEmpty ? inviterName : displayTitle;
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
