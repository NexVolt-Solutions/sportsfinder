import 'package:sport_finding/Data/model/GoogleAuth/google_auth_request_model.dart';
import 'package:sport_finding/Data/model/GoogleAuth/google_auth_response_model.dart';
import 'package:sport_finding/core/Network/api_service.dart';

class GoogleAuthRepository {
  GoogleAuthRepository({required this.apiService});

  final ApiService apiService;

  Future<GoogleAuthResponseModel> loginWithGoogle(
    GoogleAuthRequestModel request,
  ) async {
    final response = await apiService.post(
      '/api/v1/auth/google',
      data: request.toJson(),
    );

    return GoogleAuthResponseModel.fromJson(
      Map<String, dynamic>.from(response as Map),
    );
  }
}
