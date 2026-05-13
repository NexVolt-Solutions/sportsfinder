import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:sport_finding/Data/model/Option/options_model.dart';
import 'package:sport_finding/core/Network/api_service.dart';

class OptionsRepository {
  final ApiService _apiService = ApiService();

  void _log(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }

  Future<OptionsModel> getOptions() async {
    _log("========== OPTIONS API REQUEST ==========");
    _log("GET /api/v1/options/");

    final response = await _apiService.get('/api/v1/options/');
    if (response is! Map) {
      throw Exception('Unexpected options response');
    }

    _log("========== OPTIONS API RESPONSE ==========");
    _log("Raw Response: $response");

    final model = OptionsModel.fromJson(Map<String, dynamic>.from(response));

    if (model.skills.isEmpty && model.sports.isEmpty) {
      throw Exception('Options response did not include skills or sports');
    }

    _log("Parsed Skills: ${model.skills}");
    _log("Parsed Sports: ${model.sports}");
    _log("========== OPTIONS API COMPLETED ==========");

    return model;
  }

  /// Fetch only skills
  Future<List<String>> getSkills() async {
    try {
      _log("========== GET SKILLS API REQUEST ==========");
      _log("GET /api/v1/options/");

      final response = await _apiService.get('/api/v1/options/');

      final skills = List<String>.from(response['skills'] ?? []);

      _log("Skills Response: $skills");
      _log("========== GET SKILLS API COMPLETED ==========");

      return skills;
    } catch (e, stackTrace) {
      _log("========== GET SKILLS API ERROR ==========");
      _log("Error: $e");
      _log("StackTrace: $stackTrace");

      throw Exception('Failed to fetch skills: $e');
    }
  }

  /// Fetch only sports
  Future<List<String>> getSports() async {
    try {
      _log("========== GET SPORTS API REQUEST ==========");
      _log("GET /api/v1/options/sports");

      final sports = (await getSportOptions(
        active: true,
      )).map((sport) => sport.name).toList();

      _log("Sports Response: $sports");
      _log("========== GET SPORTS API COMPLETED ==========");

      return sports;
    } catch (e, stackTrace) {
      _log("========== GET SPORTS API ERROR ==========");
      _log("Error: $e");
      _log("StackTrace: $stackTrace");

      throw Exception('Failed to fetch sports: $e');
    }
  }

  Future<List<SportOptionModel>> getSportOptions({
    String? category,
    bool? active,
    bool? popular,
  }) async {
    _log("========== GET SPORTS OPTIONS API REQUEST ==========");
    final queryParams = <String, String>{
      if (category != null && category.trim().isNotEmpty)
        'category': category.trim(),
      if (active != null) 'active': active.toString(),
      if (popular != null) 'popular': popular.toString(),
    };
    final uri = Uri(
      path: '/api/v1/options/sports',
      queryParameters: queryParams.isEmpty ? null : queryParams,
    );
    _log("GET $uri");

    final response = await _apiService.get(uri.toString());
    final list = response is List ? response : <dynamic>[];
    final sports =
        list
            .whereType<Map>()
            .map(
              (item) =>
                  SportOptionModel.fromJson(Map<String, dynamic>.from(item)),
            )
            .where((sport) => sport.name.trim().isNotEmpty)
            .toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    _log("Sports Options Response: ${sports.map((e) => e.name).toList()}");
    _log("========== GET SPORTS OPTIONS API COMPLETED ==========");
    return sports;
  }
}
