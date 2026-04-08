import 'package:sport_finding/core/Network/api_service.dart';

class LoginRepository {
  final ApiService apiService;

  LoginRepository({required this.apiService});

  Future<String?> loginUser(
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
      return response['message'];
    } catch (e) {
      return e.toString();
    }
  }
}
