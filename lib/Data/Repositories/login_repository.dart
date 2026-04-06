// import 'package:sport_finding/core/Network/api_service.dart';

// class LoginRepository {
//   final ApiService apiService;
//   LoginRepository(this.apiService);

//   Future<void> postLogin(
//     String email,
//     String password,
//     String accessToken,
//     String refreshToken,
//     String tokenType,
//   ) async {
//     await apiService.post(
//       '/api/v1/auth/login',
//       data: {
//         "email": email,
//         "password": password,
//         "access_token": accessToken,
//         "refresh_token": refreshToken,
//         "token_type": tokenType,
//       },
//     );
//   }
// }
import 'package:sport_finding/core/network/api_service.dart';

class LoginRepository {
  final ApiService apiService;

  LoginRepository(this.apiService);

  Future<void> postLogin(String email, String password) async {
    final response = await apiService.post(
      "/api/v1/auth/login",
      data: {"email": email, "password": password},
    );
    print(response);
  }
}
