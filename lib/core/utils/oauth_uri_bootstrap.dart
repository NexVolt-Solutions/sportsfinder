import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sport_finding/core/Network/fcm_service.dart';
import 'package:sport_finding/core/Storage/app_preferences.dart';

/// Reads OAuth tokens from the current browser URL (query string and/or hash
/// fragment). Many providers put tokens in the fragment only.
///
/// Returns `true` if a non-empty access token was persisted.
Future<bool> consumeOAuthTokensFromCurrentUri() async {
  if (!kIsWeb) return false;

  final uri = Uri.base;
  final merged = Map<String, String>.from(uri.queryParameters);
  final frag = uri.fragment.trim();
  if (frag.isNotEmpty) {
    merged.addAll(Uri.splitQueryString(frag));
  }

  final accessToken =
      (merged['access_token'] ?? merged['token'] ?? '').trim();
  if (accessToken.isEmpty) return false;

  final refreshToken =
      (merged['refresh_token'] ?? merged['refreshToken'] ?? '').trim();
  final tokenType =
      (merged['token_type'] ?? merged['tokenType'] ?? 'Bearer').trim();

  await AppPreferences.saveAuthTokens(
    accessToken: accessToken,
    refreshToken: refreshToken.isNotEmpty ? refreshToken : null,
    tokenType: tokenType.isNotEmpty ? tokenType : 'Bearer',
  );
  await FcmService.instance.registerTokenWithBackendIfAuthenticated();
  return true;
}
