// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:html' as html;

import 'package:sport_finding/core/Constants/google_maps_config.dart';
import 'package:sport_finding/core/utils/logger.dart';

/// Loads Maps JS (`google_maps_flutter_web`) using [GoogleMapsConfig.apiKey].
///
/// Uses a timeout so startup never hangs forever when the script is blocked
/// (ad blockers, corporate filters, or flaky networks that never fire load/error).
Future<void> ensureGoogleMapsScriptLoaded() async {
  if (html.document.querySelector('script[data-sf-google-maps]') != null) {
    return;
  }
  final key = GoogleMapsConfig.apiKey.trim();
  if (key.isEmpty) return;

  final script = html.ScriptElement()
    ..setAttribute('data-sf-google-maps', 'true')
    ..async = true
    ..src =
        'https://maps.googleapis.com/maps/api/js?key=${Uri.encodeQueryComponent(key)}';

  final completer = Completer<void>();
  script.onLoad.listen((_) {
    if (!completer.isCompleted) completer.complete();
  });
  script.onError.listen((_) {
    if (!completer.isCompleted) {
      completer.completeError(StateError('Google Maps JavaScript API failed to load'));
    }
  });
  html.document.head!.append(script);
  try {
    await completer.future.timeout(const Duration(seconds: 25));
  } on TimeoutException {
    AppLogger.warning(
      'Google Maps JS did not load within 25s (blocked network or extension?). '
      'Continuing startup; map widgets may fail until reload.',
      tag: 'GoogleMapsJsLoader',
    );
    try {
      script.remove();
    } catch (_) {}
  }
}
