import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sport_finding/core/utils/logger.dart';

class GooglePlacesService {
  static const String _apiKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');

  bool get hasApiKey => _apiKey.trim().isNotEmpty;

  Future<String?> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    if (!hasApiKey) {
      AppLogger.warning(
        'Google Maps API key missing. Reverse geocoding skipped.',
        tag: 'GooglePlacesService',
      );
      return null;
    }

    final uri = Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
      'latlng': '$latitude,$longitude',
      'key': _apiKey,
    });

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch current address');
    }

    final body = jsonDecode(response.body);
    final results = body['results'];
    if (results is! List || results.isEmpty) {
      return null;
    }

    final first = results.first;
    if (first is! Map) return null;
    return (first['formatted_address'] ?? '').toString().trim();
  }

  Future<List<String>> searchPlaceSuggestions(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const <String>[];
    if (!hasApiKey) {
      AppLogger.warning(
        'Google Maps API key missing. Place autocomplete skipped.',
        tag: 'GooglePlacesService',
      );
      return const <String>[];
    }

    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/autocomplete/json',
      {
        'input': trimmed,
        'key': _apiKey,
      },
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to search places');
    }

    final body = jsonDecode(response.body);
    final predictions = body['predictions'];
    if (predictions is! List) return const <String>[];

    final items = <String>[];
    for (final prediction in predictions) {
      if (prediction is! Map) continue;
      final description = (prediction['description'] ?? '').toString().trim();
      if (description.isNotEmpty) {
        items.add(description);
      }
    }
    return items;
  }
}
