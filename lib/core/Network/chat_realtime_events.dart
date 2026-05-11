/// Merges top-level JSON with common nested envelopes (`payload`, `data`, `body`)
/// so receipt parsers match servers that nest fields.
Map<String, dynamic> _flattenWsEvent(Map<String, dynamic> json) {
  final out = Map<String, dynamic>.from(json);
  void merge(Object? blob) {
    if (blob is Map) {
      for (final e in blob.entries) {
        if (e.key is String) out[e.key as String] = e.value;
      }
    }
  }

  merge(json['payload']);
  merge(json['data']);
  merge(json['body']);
  return out;
}

String? _messageIdFromMap(Map<String, dynamic> m) {
  var id = '${m['message_id'] ?? m['messageId'] ?? m['id'] ?? ''}'.trim();
  if (id.isNotEmpty) return id;
  final nested = m['message'];
  if (nested is Map) {
    final nm = Map<String, dynamic>.from(nested);
    id = '${nm['id'] ?? nm['message_id'] ?? nm['messageId'] ?? ''}'.trim();
  }
  return id.isEmpty ? null : id;
}

bool _jsonTruthy(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  final s = '$v'.trim().toLowerCase();
  return s == 'true' || s == '1' || s == 'yes' || s == 'y';
}

DateTime? _parseUtc(dynamic v) {
  if (v == null) return null;
  final s = '$v'.trim();
  if (s.isEmpty) return null;
  return DateTime.tryParse(s)?.toUtc();
}

DateTime? _firstUtc(Map<String, dynamic> m, List<String> keys) {
  for (final k in keys) {
    final d = _parseUtc(m[k]);
    if (d != null) return d;
  }
  return null;
}

bool _readImplied(Map<String, dynamic> m) {
  if (_jsonTruthy(m['is_read'] ?? m['read'] ?? m['seen'])) return true;
  final st = '${m['status'] ?? m['receipt'] ?? m['state'] ?? ''}'
      .trim()
      .toLowerCase();
  if (st == 'read' || st == 'seen') return true;
  return _firstUtc(m, [
        'read_at',
        'readAt',
        'read_timestamp',
        'read_time',
        'seen_at',
        'seenAt',
      ]) !=
      null;
}

bool _deliveredImplied(Map<String, dynamic> m) {
  if (_jsonTruthy(m['is_delivered'] ?? m['delivered'] ?? m['received'])) {
    return true;
  }
  final st = '${m['delivery_status'] ?? m['delivery'] ?? ''}'
      .trim()
      .toLowerCase();
  if (st == 'delivered' || st == 'received') return true;
  return _firstUtc(m, [
        'delivered_at',
        'deliveredAt',
        'delivery_at',
        'deliveryAt',
      ]) !=
      null;
}

/// Side-channel events from direct/match chat WebSockets (not full chat lines).
class ChatPresenceEvent {
  const ChatPresenceEvent({
    required this.userId,
    required this.status,
    this.sentAt,
  });

  final String userId;
  /// Server values observed in the wild: `online`, `offline`, `away`, etc.
  final String status;
  final DateTime? sentAt;

  static ChatPresenceEvent? tryParse(Map<String, dynamic> json) {
    final uid = '${json['user_id'] ?? json['userId'] ?? ''}'.trim();
    if (uid.isEmpty) return null;
    final status = '${json['status'] ?? ''}'.trim();
    if (status.isEmpty) return null;
    final raw = json['sent_at'] ?? json['sentAt'];
    final sentAt = raw == null
        ? null
        : DateTime.tryParse('$raw')?.toUtc();
    return ChatPresenceEvent(userId: uid, status: status, sentAt: sentAt);
  }
}

class ChatReceiptEvent {
  const ChatReceiptEvent({
    required this.kind,
    required this.messageId,
    this.at,
  });

  /// `read` | `delivered`
  final String kind;
  final String messageId;
  final DateTime? at;

  static ChatReceiptEvent? tryParseRead(Map<String, dynamic> json) {
    final m = _flattenWsEvent(json);
    final id = _messageIdFromMap(m);
    if (id == null) return null;
    final raw = m['read_at'] ??
        m['readAt'] ??
        m['read_timestamp'] ??
        m['read_time'] ??
        m['seen_at'] ??
        m['seenAt'];
    final at = raw == null ? null : DateTime.tryParse('$raw')?.toUtc();
    return ChatReceiptEvent(kind: 'read', messageId: id, at: at);
  }

  static ChatReceiptEvent? tryParseDelivered(Map<String, dynamic> json) {
    final m = _flattenWsEvent(json);
    final id = _messageIdFromMap(m);
    if (id == null) return null;
    final raw = m['delivered_at'] ??
        m['deliveredAt'] ??
        m['delivery_at'] ??
        m['deliveryAt'];
    final at = raw == null ? null : DateTime.tryParse('$raw')?.toUtc();
    return ChatReceiptEvent(kind: 'delivered', messageId: id, at: at);
  }

  /// Only for unknown `type` values: requires read signal, not just `message_id`.
  static ChatReceiptEvent? tryParseReadIfImplied(Map<String, dynamic> json) {
    final m = _flattenWsEvent(json);
    final id = _messageIdFromMap(m);
    if (id == null || !_readImplied(m)) return null;
    final at = _firstUtc(m, [
          'read_at',
          'readAt',
          'read_timestamp',
          'read_time',
          'seen_at',
          'seenAt',
          'updated_at',
          'sent_at',
          'sentAt',
        ]) ??
        DateTime.now().toUtc();
    return ChatReceiptEvent(kind: 'read', messageId: id, at: at);
  }

  /// Only for unknown `type` values: requires delivered signal, not just `message_id`.
  static ChatReceiptEvent? tryParseDeliveredIfImplied(
    Map<String, dynamic> json,
  ) {
    final m = _flattenWsEvent(json);
    final id = _messageIdFromMap(m);
    if (id == null || !_deliveredImplied(m)) return null;
    final at = _firstUtc(m, [
          'delivered_at',
          'deliveredAt',
          'delivery_at',
          'deliveryAt',
          'updated_at',
          'sent_at',
          'sentAt',
        ]) ??
        DateTime.now().toUtc();
    return ChatReceiptEvent(kind: 'delivered', messageId: id, at: at);
  }
}
