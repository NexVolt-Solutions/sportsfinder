import 'dart:convert';

/// Picks a short, user-facing message from [ApiService] and similar exceptions
/// (e.g. FastAPI `{"detail":[{"msg":"..."}]}`) instead of dumping the full body.
String messageFromApiException(Object error) {
  final raw = error.toString();
  final extracted = _tryDecodeErrorPayload(raw);
  if (extracted != null) {
    final parsed = _messageFromDecodedJson(extracted);
    if (parsed != null && parsed.trim().isNotEmpty) {
      return _cleanValidationPrefix(parsed.trim());
    }
  }
  return _stripExceptionPrefix(raw);
}

dynamic _tryDecodeErrorPayload(String raw) {
  const prefixes = <String>[
    'Failed to create data: ',
    'Failed to update data: ',
    'Failed to load data: ',
    'Failed to delete data: ',
    'Failed to update: ',
    'Upload failed: ',
  ];
  for (final p in prefixes) {
    final idx = raw.indexOf(p);
    if (idx < 0) continue;
    final tail = raw.substring(idx + p.length).trim();
    try {
      return jsonDecode(tail);
    } catch (_) {
      // Not JSON after this prefix; try next
    }
  }
  final brace = raw.indexOf('{');
  if (brace >= 0) {
    try {
      return jsonDecode(raw.substring(brace));
    } catch (_) {}
  }
  return null;
}

String? _messageFromDecodedJson(dynamic decoded) {
  if (decoded is String) {
    return decoded;
  }
  if (decoded is! Map) {
    return null;
  }
  final m = Map<String, dynamic>.from(decoded);
  final topMessage = m['message'];
  if (topMessage is String && topMessage.trim().isNotEmpty) {
    return topMessage;
  }
  final err = m['error'];
  if (err is String && err.trim().isNotEmpty) {
    return err;
  }
  final detail = m['detail'];
  if (detail is String) {
    return detail;
  }
  if (detail is List) {
    final parts = <String>[];
    for (final item in detail) {
      if (item is Map) {
        final im = Map<String, dynamic>.from(item);
        final msg = im['msg'];
        if (msg is String && msg.trim().isNotEmpty) {
          parts.add(msg.trim());
        } else {
          final s = im['message'] ?? im['message_key'];
          if (s is String && s.trim().isNotEmpty) {
            parts.add(s.trim());
          }
        }
      } else if (item is String && item.trim().isNotEmpty) {
        parts.add(item.trim());
      }
    }
    if (parts.isNotEmpty) {
      return parts.join(' ');
    }
  }
  return null;
}

/// Strips common Pydantic-style prefixes for cleaner snackbars.
String _cleanValidationPrefix(String m) {
  const p = 'Value error, ';
  if (m.length > p.length && m.startsWith(p)) {
    return m.substring(p.length).trim();
  }
  return m;
}

String _stripExceptionPrefix(String raw) {
  const p = 'Exception: ';
  if (raw.startsWith(p)) {
    return raw.substring(p.length);
  }
  return raw;
}
