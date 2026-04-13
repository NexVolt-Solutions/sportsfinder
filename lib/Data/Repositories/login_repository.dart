import 'package:sport_finding/core/Network/api_service.dart';

class LoginRepository {
  final ApiService apiService;

  LoginRepository({required this.apiService});

  Future<Map<String, dynamic>> loginUser(
    String email,
    String password,
    String accessToken,
    String refreshToken,
    String tokentype,
  ) async {
    try {
      final response = await apiService.post(
        '/api/v1/auth/login',
        data: {
          'email': email,
          'password': password,
          'accessToken': accessToken,
          'refreshToken': refreshToken,
          'tokentype': tokentype,
        },
      );
      
      // Extract tokens from response
      return {
        'accessToken': response['access_token'] ?? '',
        'refreshToken': response['refresh_token'] ?? '',
        'tokenType': response['token_type'] ?? 'Bearer',
        'message': response['message'] ?? 'Login successful',
      };
    } catch (e) {
      rethrow;
    }
  }
}
