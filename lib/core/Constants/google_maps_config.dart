 
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

  /// Call once after [WidgetsFlutterBinding.ensureInitialized], before [runApp].
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
