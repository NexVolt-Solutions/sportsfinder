import 'dart:convert';

/// Web client (Firebase / Google Cloud). Use as `serverClientId` in [GoogleSignIn.instance.initialize]
/// so the ID token’s `aud` is this value; the API must verify Google tokens with the same audience.
const String kGoogleOauth2WebClientId =
    '147032468406-cj792ti9lqaldlonhl93p04vuui6rufv.apps.googleusercontent.com';

const String kGoogleOauth2AndroidClientId =
    '147032468406-fihnfqa7oqnmi0vg838peck2kiqb8dp6.apps.googleusercontent.com';

/// Your API must verify Google ID tokens with this audience (same as the Web client).
const String kGoogleIdTokenExpectedAudience = kGoogleOauth2WebClientId;

/// Decodes a Google ID token JWT payload and returns the `aud` claim (no signature check).
String? idTokenGoogleAud(String idToken) {
  try {
    final parts = idToken.split('.');
    if (parts.length < 2) return null;
    var p = parts[1];
    final m = p.length % 4;
    if (m != 0) p = p + ('=' * (4 - m));
    final map =
        json.decode(utf8.decode(base64Url.decode(p))) as Map<String, dynamic>;
    return map['aud'] as String?;
  } catch (_) {
    return null;
  }
}
