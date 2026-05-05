import 'dart:async';
import 'dart:html' as html;
import 'dart:js';
import 'package:sport_finding/core/Network/places_search_result.dart';

class GooglePlacesWebBridge {
  static const _mapsScriptId = 'google-maps-js-sdk';
  Object? _autocompleteService;

  Future<PlacesSearchResult?> searchSuggestions({
    required String query,
    required String apiKey,
  }) async {
    final q = query.trim();
    if (q.isEmpty) return const PlacesSearchResult();
    if (apiKey.trim().isEmpty) {
      return const PlacesSearchResult(
        userMessage: 'Missing Google Maps web API key.',
        missingApiKey: true,
      );
    }

    final loaded = await _ensureMapsPlacesLoaded(apiKey.trim());
    if (!loaded) {
      return const PlacesSearchResult(
        userMessage:
            'Could not load Google Maps JS SDK. Check browser key/domain restrictions.',
      );
    }

    final service = _ensureAutocompleteService();
    if (service == null) {
      return const PlacesSearchResult(
        userMessage: 'Google Places service is unavailable in browser.',
      );
    }

    final result = await _fetchPredictions(service, q);
    return result;
  }

  Future<bool> _ensureMapsPlacesLoaded(String apiKey) async {
    if (_hasMapsPlacesReady()) return true;

    final existing = html.document.getElementById(_mapsScriptId);
    if (existing is html.ScriptElement) {
      return _waitForMapsPlacesReady();
    }

    final completer = Completer<bool>();
    final script = html.ScriptElement()
      ..id = _mapsScriptId
      ..async = true
      ..defer = true
      ..src =
          'https://maps.googleapis.com/maps/api/js?key=$apiKey&libraries=places';

    script.onError.first.then((_) {
      if (!completer.isCompleted) completer.complete(false);
    });
    script.onLoad.first.then((_) {
      if (!completer.isCompleted) completer.complete(_hasMapsPlacesReady());
    });

    html.document.head?.append(script);
    final loaded = await completer.future;
    if (!loaded) return false;
    return _waitForMapsPlacesReady();
  }

  Future<bool> _waitForMapsPlacesReady() async {
    for (var i = 0; i < 20; i++) {
      if (_hasMapsPlacesReady()) return true;
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    return false;
  }

  bool _hasMapsPlacesReady() {
    final google = context['google'];
    if (google == null) return false;
    final maps = (google as JsObject)['maps'];
    if (maps == null) return false;
    final places = (maps as JsObject)['places'];
    if (places == null) return false;
    final ctor = (places as JsObject)['AutocompleteService'];
    return ctor != null;
  }

  Object? _ensureAutocompleteService() {
    if (_autocompleteService != null) return _autocompleteService;

    final google = context['google'];
    if (google == null) return null;
    final maps = (google as JsObject)['maps'];
    if (maps == null) return null;
    final places = (maps as JsObject)['places'];
    if (places == null) return null;
    final ctor = (places as JsObject)['AutocompleteService'];
    if (ctor == null) return null;
    _autocompleteService = JsObject(ctor as JsFunction, <Object?>[]);
    return _autocompleteService;
  }

  Future<PlacesSearchResult> _fetchPredictions(
    Object service,
    String query,
  ) async {
    final completer = Completer<PlacesSearchResult>();
    final request = JsObject.jsify(<String, Object>{'input': query});
    final callback = JsFunction.withThis((_, dynamic predictions, dynamic status) {
      final statusText = (status ?? '').toString();
      if (statusText == 'OK') {
        final items = <String>[];
        if (predictions is JsArray) {
          for (final dynamic item in predictions) {
            if (item is JsObject) {
              final description = (item['description'] ?? '').toString().trim();
              if (description.isNotEmpty) items.add(description);
            }
          }
        }
        completer.complete(PlacesSearchResult(suggestions: items));
        return;
      }
      if (statusText == 'ZERO_RESULTS') {
        completer.complete(
          const PlacesSearchResult(userMessage: 'No locations found.'),
        );
        return;
      }
      completer.complete(
        PlacesSearchResult(
          userMessage:
              'Location search unavailable on web (Google status: $statusText).',
        ),
      );
    });

    (service as JsObject).callMethod('getPlacePredictions', <Object?>[
      request,
      callback,
    ]);

    return completer.future.timeout(
      const Duration(seconds: 6),
      onTimeout: () => const PlacesSearchResult(
        userMessage: 'Location search timed out. Please try again.',
      ),
    );
  }
}
