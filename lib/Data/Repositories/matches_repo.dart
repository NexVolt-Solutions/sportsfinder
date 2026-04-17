import 'package:sport_finding/core/Network/api_service.dart';
import '../model/all_matches_model.dart';
import '../model/match_detail_model.dart';

class MatchesRepo {
  final ApiService _apiService = ApiService();

  /// ================= GET ALL MATCHES =================
  Future<AllMatchesResponse> getAllMatches({
    String type = "all",
    String? sport,
    String? skillLevel,
    double? lat,
    double? lng,
    int page = 1,
    int limit = 20,
    int radiusKm = 20,
  }) async {
    try {
      print("========== GET MATCHES REQUEST ==========");
      print("Endpoint: /api/v1/matches");

      final queryParams = {
        "type": type,
        "sport": sport,
        "skill_level": skillLevel,
        "lat": lat,
        "lng": lng,
        "page": page,
        "limit": limit,
        "radius_km": radiusKm,
      }..removeWhere((k, v) => v == null);

      print("Query Params: $queryParams");

      final uri = Uri(
        path: "/api/v1/matches",
        queryParameters: queryParams.map((k, v) => MapEntry(k, v.toString())),
      );

      print("Final URI: $uri");

      final response = await _apiService.get(uri.toString());

      print("========== GET MATCHES RESPONSE ==========");
      print("Response Type: ${response.runtimeType}");
      print(response);
      print("========== GET MATCHES COMPLETED ==========");

      if (response == null) {
        print("❌ API Response is NULL");
        throw Exception("API returned null when fetching matches");
      }

      if (response is! Map<String, dynamic>) {
        print("❌ Unexpected response type: ${response.runtimeType}");
        throw Exception(
          "Expected Map<String, dynamic> but got ${response.runtimeType}",
        );
      }

      final model = AllMatchesResponse.fromJson(response);

      print("✅ Parsed Matches Model: $model");

      return model;
    } catch (e, stackTrace) {
      print("========== GET MATCHES ERROR ==========");
      print("Error: $e");
      print("StackTrace: $stackTrace");
      rethrow;
    }
  }

  /// GET /api/v1/matches/{match_id} — full detail including [participants].
  Future<MatchDetailResponse> getMatch(String matchId) async {
    if (matchId.isEmpty) {
      throw ArgumentError('matchId is empty');
    }
    final response = await _apiService.get('/api/v1/matches/$matchId');
    if (response is! Map<String, dynamic>) {
      throw Exception('Unexpected match detail response');
    }
    return MatchDetailResponse.fromJson(response);
  }
}
