import 'package:sport_finding/Data/model/list_of_all_matches_model.dart';
import 'package:sport_finding/core/Network/api_service.dart';

class MatchesRepo {
  final ApiService _apiService = ApiService();

  Future<MatchesResponse> getMatches({
    String type = "all",
    String? sport,
    String? skillLevel,
    String? dateFrom,
    String? dateTo,
    double? lat,
    double? lng,
    int radiusKm = 20,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = {
      "type": type,
      "radius_km": radiusKm.toString(),
      "page": page.toString(),
      "limit": limit.toString(),
      if (sport != null) "sport": sport,
      if (skillLevel != null) "skill_level": skillLevel,
      if (dateFrom != null) "date_from": dateFrom,
      if (dateTo != null) "date_to": dateTo,
      if (lat != null) "lat": lat.toString(),
      if (lng != null) "lng": lng.toString(),
    };

    final uri = Uri(
      path: "/api/v1/matches",
      queryParameters: queryParams,
    ).toString();

    final response = await _apiService.get(uri);
    return MatchesResponse.fromJson(response);
  }
}
