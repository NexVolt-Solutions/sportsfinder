import 'package:sport_finding/core/Network/api_service.dart';

class LoginRepository {
  final ApiService apiService;

  LoginRepository({required this.apiService});

  Future<Map<String, dynamic>> loginUser(
    String email,
    String password,
    String accessToken,
    String refreshToken,
    String tokenType,
  ) async {
    try {
      print("========== LOGIN API REQUEST ==========");
      print("Endpoint: /api/v1/auth/login");
      print("Email: $email");
      print("Password: ${'*' * password.length}");

      final requestBody = {
        'email': email,
        'password': password,
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'tokentype': tokenType,
      };

      print("Request Body: $requestBody");

      final response = await apiService.post(
        '/api/v1/auth/login',
        data: requestBody,
      );

      print("========== LOGIN API RESPONSE ==========");
      print(response);

      final accessTokenFromResponse =
          response['access_token'] ??
          response['accessToken'] ??
          response['token'] ??
          '';

      final refreshTokenFromResponse =
          response['refresh_token'] ?? response['refreshToken'] ?? '';

      final tokenTypeFromResponse =
          response['token_type'] ?? response['tokenType'] ?? 'Bearer';

      final result = {
        'accessToken': accessTokenFromResponse,
        'refreshToken': refreshTokenFromResponse,
        'tokenType': tokenTypeFromResponse,
        'message': response['message'] ?? 'Login successful',
      };

      print("Access Token: ${result['accessToken']}");
      print("Refresh Token: ${result['refreshToken']}");
      print("Token Type: ${result['tokenType']}");
      print("Message: ${result['message']}");
      print("========== LOGIN API COMPLETED ==========");

      return result;
    } catch (e, stackTrace) {
      print("========== LOGIN API ERROR ==========");
      print("Error: $e");
      print("StackTrace: $stackTrace");
      rethrow;
    }
  }
}
