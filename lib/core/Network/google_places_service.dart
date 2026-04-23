import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sport_finding/core/Constants/google_maps_config.dart';
import 'package:sport_finding/core/Network/places_search_result.dart';
import 'package:sport_finding/core/utils/logger.dart';

class GooglePlacesService {
  /// Reverse geocoding (lat/lng → address).
  Future<String?> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    if (!GoogleMapsConfig.hasApiKey) {
      AppLogger.warning(
        'Google Maps API key missing. Reverse geocoding skipped.',
        tag: 'GooglePlacesService',
      );
      return null;
    }

    final uri = Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
      'latlng': '$latitude,$longitude',
      'key': GoogleMapsConfig.apiKey,
    });

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch current address');
    }

    final body = _decodeJson(response.body);
    final st = (body['status'] ?? '').toString();
    if (st == 'REQUEST_DENIED' || st == 'INVALID_REQUEST') {
      AppLogger.warning(
        'Geocoding: $st ${body['error_message'] ?? ''}',
        tag: 'GooglePlacesService',
      );
      return null;
    }
    final results = body['results'];
    if (results is! List || results.isEmpty) {
      return null;
    }

    final first = results.first;
    if (first is! Map) return null;
    return (first['formatted_address'] ?? '').toString().trim();
  }

  /// Google Places **Autocomplete** (legacy) — needs Places API + billing enabled in Cloud Console.
  Future<PlacesSearchResult> searchPlaceSuggestions(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return const PlacesSearchResult();
    }
    if (!GoogleMapsConfig.hasApiKey) {
      AppLogger.warning(
        'Google Maps API key missing. Place autocomplete skipped.',
        tag: 'GooglePlacesService',
      );
      return const PlacesSearchResult(
        userMessage:
            'Add a Google Maps API key: set GOOGLE_MAPS_API_KEY_ANDROID / _IOS / _WEB in '
            'assets/config/maps.env, or use --dart-define (see GoogleMapsConfig). '
            'Enable Places + Geocoding API for each key.',
        missingApiKey: true,
      );
    }

    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/autocomplete/json',
      {
        'input': trimmed,
        'key': GoogleMapsConfig.apiKey,
      },
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      return PlacesSearchResult(
        userMessage: 'Location search failed (HTTP ${response.statusCode}).',
      );
    }

    final body = _decodeJson(response.body);
    final status = (body['status'] ?? '').toString();
    final errMsg = (body['error_message'] ?? '').toString().trim();

    if (status == 'OK' || status == 'ZERO_RESULTS') {
      final predictions = body['predictions'];
      if (predictions is! List) {
        return const PlacesSearchResult();
      }
      final items = <String>[];
      for (final prediction in predictions) {
        if (prediction is! Map) continue;
        final description = (prediction['description'] ?? '').toString().trim();
        if (description.isNotEmpty) {
          items.add(description);
        }
      }
      if (items.isEmpty && status == 'ZERO_RESULTS') {
        return PlacesSearchResult(
          userMessage: 'No locations found for "$trimmed".',
        );
      }
      return PlacesSearchResult(suggestions: items);
    }

    AppLogger.warning(
      'Places Autocomplete: $status $errMsg',
      tag: 'GooglePlacesService',
    );

    if (status == 'REQUEST_DENIED') {
      return PlacesSearchResult(
        userMessage: _messageForRequestDenied(errMsg),
      );
    }
    if (status == 'OVER_QUERY_LIMIT') {
      return const PlacesSearchResult(
        userMessage: 'Search quota exceeded. Try again later.',
      );
    }
    if (status == 'INVALID_REQUEST') {
      return PlacesSearchResult(
        userMessage: errMsg.isNotEmpty
            ? errMsg
            : 'Invalid place search request.',
      );
    }

    return PlacesSearchResult(
      userMessage: errMsg.isNotEmpty
          ? errMsg
          : 'Could not search locations (status: $status).',
    );
  }

  /// Google returns "empty referer" when the key is restricted to **HTTP referrers** (web)
  /// but the Places web service is called from the mobile app (no browser referer).
  static String _messageForRequestDenied(String errMsg) {
    final m = errMsg.trim();
    final lower = m.toLowerCase();
    const hint = '\n\nFor mobile apps: do not restrict this key to "Websites" only (that '
        'causes "empty referer"). In Google Cloud → Credentials, use an API key with '
        'Application restrictions set to "Android apps" (your package name + SHA-1), '
        'or "None" for testing. Ensure Places API + Geocoding API are enabled for that key.';

    if (lower.isEmpty) {
      return 'Request denied. Enable Places API and allow this key for your app.$hint';
    }
    if (lower.contains('referer') || lower.contains('not authorized to use this api key')) {
      return '$m$hint';
    }
    return m;
  }

  static Map<String, dynamic> _decodeJson(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }
    return <String, dynamic>{};
  }
}
