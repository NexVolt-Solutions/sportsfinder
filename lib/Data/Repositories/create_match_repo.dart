import 'package:sport_finding/Data/model/create_match_request_model.dart';
import 'package:sport_finding/Data/model/create_match_response_model.dart';
import 'package:sport_finding/core/Network/api_service.dart';

class CreateMatchRepo {
  final ApiService _apiService = ApiService();

  /// ✅ Create Match API
  Future<CreateMatchResponseModel> createMatch(
    CreateMatchRequestModel request,
  ) async {
    final response = await _apiService.post(
      "/api/v1/matches",
      data: request.toJson(),
    );

    return CreateMatchResponseModel.fromJson(response);
  }
}
