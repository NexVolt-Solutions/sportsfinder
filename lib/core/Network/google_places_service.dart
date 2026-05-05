import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:sport_finding/core/Constants/google_maps_config.dart';
import 'package:sport_finding/core/Network/places_search_result.dart';
import 'package:sport_finding/core/Network/google_places_web_bridge_stub.dart'
    if (dart.library.html) 'package:sport_finding/core/Network/google_places_web_bridge.dart';
import 'package:sport_finding/core/utils/logger.dart';

class GooglePlacesService {
  final GooglePlacesWebBridge _webBridge = GooglePlacesWebBridge();
  /// Forward geocoding (address -> lat/lng).
  Future<(double, double)?> geocodeAddress(String address) async {
    final q = address.trim();
    if (q.isEmpty) return null;
    if (GoogleMapsConfig.webServicesKey.isEmpty) return null;

    final uri = Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
      'address': q,
      'key': GoogleMapsConfig.webServicesKey,
    });

    final response = await http.get(uri);
    if (response.statusCode != 200) return null;
    final body = _decodeJson(response.body);
    final status = (body['status'] ?? '').toString();
    if (status != 'OK') return null;
    final results = body['results'];
    if (results is! List || results.isEmpty) return null;
    final first = results.first;
    if (first is! Map) return null;
    final geometry = first['geometry'];
    if (geometry is! Map) return null;
    final location = geometry['location'];
    if (location is! Map) return null;
    final lat = (location['lat'] as num?)?.toDouble();
    final lng = (location['lng'] as num?)?.toDouble();
    if (lat == null || lng == null) return null;
    return (lat, lng);
  }

  /// Reverse geocoding (lat/lng → address).
  Future<String?> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    if (GoogleMapsConfig.webServicesKey.isEmpty) {
      AppLogger.warning(
        'Google Maps web services key missing. Reverse geocoding skipped.',
        tag: 'GooglePlacesService',
      );
      return null;
    }

    final uri = Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
      'latlng': '$latitude,$longitude',
      'key': GoogleMapsConfig.webServicesKey,
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
    if (kIsWeb) {
      final webResult = await _webBridge.searchSuggestions(
        query: trimmed,
        apiKey: GoogleMapsConfig.apiKey,
      );
      if (webResult != null) {
        return webResult;
      }
    }
    if (GoogleMapsConfig.webServicesKey.isEmpty) {
      AppLogger.warning(
        'Google Maps web services key missing. Place autocomplete skipped.',
        tag: 'GooglePlacesService',
      );
      return const PlacesSearchResult(
        userMessage:
            'Set GOOGLE_MAPS_WEB_SERVICES_KEY in assets/config/maps.env (see GoogleMapsConfig). '
            'Plain HTTP calls need a key with Application restrictions = None and '
            'API restrictions = Places + Geocoding.',
        missingApiKey: true,
      );
    }

    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/autocomplete/json',
      {
        'input': trimmed,
        'key': GoogleMapsConfig.webServicesKey,
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

  /// Geocoding / Places **HTTP** do not send Android app attestation; "Android apps"
  /// key restrictions often still fail with the same error as website-only keys.
  static String _messageForRequestDenied(String errMsg) {
    final m = errMsg.trim();
    final lower = m.toLowerCase();
    const hint = '\n\nFix: Use the key in GOOGLE_MAPS_WEB_SERVICES_KEY. In Google Cloud → '
        'that key → Application restrictions: **None**. API restrictions: **Restrict key** and '
        'add **Places API** (the classic one — “100 million places”, *not* “Places API (New)”) '
        'and **Geocoding API**. Also enable “Places API” in APIs & Services → Library for this '
        'project. See GoogleMapsConfig.webServicesKey.';

    if (lower.isEmpty) {
      return 'Request denied. Check API restrictions include classic Places + Geocoding.$hint';
    }
    final isApiListWrong = lower.contains('referer') ||
        lower.contains('not authorized to use this api key') ||
        lower.contains('not authorized to use this service or api') ||
        lower.contains('api restrictions');
    if (isApiListWrong) {
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
