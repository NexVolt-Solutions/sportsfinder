// Google Maps keys: [apiKey] = SDK / general; [webServicesKey] = Places + Geocoding HTTP.
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sport_finding/core/utils/logger.dart';

class GoogleMapsConfig {
  GoogleMapsConfig._();

  static const String _defineGeneric = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );
  static const String _defineAndroid = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY_ANDROID',
    defaultValue: '',
  );
  static const String _defineIos = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY_IOS',
    defaultValue: '',
  );
  static const String _defineWeb = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY_WEB',
    defaultValue: '',
  );
  /// Optional override for Geocoding + Places Autocomplete **HTTP** only (`dart-define`).
  static const String _defineWebServices = String.fromEnvironment(
    'GOOGLE_MAPS_WEB_SERVICES_KEY',
    defaultValue: '',
  );

  /// Maps SDK (Android manifest / iOS plist) and default fallback.
  static String get apiKey {
    final generic = _defineGeneric.trim();
    if (generic.isNotEmpty) return generic;

    final fromDefine = _defineKeyForCurrentPlatform();
    if (fromDefine.isNotEmpty) return fromDefine;

    final fromFile = _dotenvKeyForCurrentPlatform();
    if (fromFile.isNotEmpty) return fromFile;

    final legacy = dotenv.env['GOOGLE_MAPS_API_KEY']?.trim() ?? '';
    return legacy;
  }

  /// Use for **only** `maps.googleapis.com` Geocoding + Places Autocomplete (legacy) HTTP.
  ///
  /// Those endpoints do **not** receive Android/iOS app attestation from a plain
  /// [`http.get`], so Google often rejects keys with **Application → Android apps**
  /// (same `REQUEST_DENIED` / "empty referer" as a web-only key).
  ///
  /// **Fix:** create a **second** API key in Cloud Console: **Application restrictions → None**,
  /// **API restrictions → Places API + Geocoding API** (only). Put it in
  /// `GOOGLE_MAPS_WEB_SERVICES_KEY` in [assets/config/maps.env]. Keep your existing
  /// Android-restricted key for [apiKey] / Maps SDK in the manifest.
  static String get webServicesKey {
    final d = _defineWebServices.trim();
    if (d.isNotEmpty) return d;
    final f = dotenv.env['GOOGLE_MAPS_WEB_SERVICES_KEY']?.trim() ?? '';
    if (f.isNotEmpty) return f;
    return apiKey;
  }

  static String _defineKeyForCurrentPlatform() {
    if (kIsWeb) return _defineWeb.trim();
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => _defineAndroid.trim(),
      TargetPlatform.iOS => _defineIos.trim(),
      TargetPlatform.macOS || TargetPlatform.windows || TargetPlatform.linux =>
        _defineWeb.trim(),
      TargetPlatform.fuchsia => _defineWeb.trim(),
    };
  }

  static String _dotenvKeyForCurrentPlatform() {
    if (kIsWeb) {
      return dotenv.env['GOOGLE_MAPS_API_KEY_WEB']?.trim() ?? '';
    }
    return switch (defaultTargetPlatform) {
      TargetPlatform.android =>
        dotenv.env['GOOGLE_MAPS_API_KEY_ANDROID']?.trim() ?? '',
      TargetPlatform.iOS => dotenv.env['GOOGLE_MAPS_API_KEY_IOS']?.trim() ?? '',
      TargetPlatform.macOS ||
      TargetPlatform.windows ||
      TargetPlatform.linux ||
      TargetPlatform.fuchsia =>
        dotenv.env['GOOGLE_MAPS_API_KEY_WEB']?.trim() ?? '',
    };
  }

  static bool get hasApiKey => apiKey.isNotEmpty;

  static Future<void> loadEnv() async {
    try {
      await dotenv.load(fileName: 'assets/config/maps.env');
    } catch (e, st) {
      AppLogger.warning(
        'Could not load assets/config/maps.env ($e). Copy maps.env.example or use --dart-define. '
        'See [GoogleMapsConfig] doc comment.',
        tag: 'GoogleMapsConfig',
      );
      AppLogger.debug('$st', tag: 'GoogleMapsConfig');
    }
  }
}
