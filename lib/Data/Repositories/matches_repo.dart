import 'package:sport_finding/core/Network/api_service.dart';
import '../model/all_matches_model.dart';

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

    final uri = Uri(
      path: "/api/v1/matches",
      queryParameters: queryParams.map((k, v) => MapEntry(k, v.toString())),
    );

    final response = await _apiService.get(uri.toString());

    return AllMatchesResponse.fromJson(response);
  }
}
