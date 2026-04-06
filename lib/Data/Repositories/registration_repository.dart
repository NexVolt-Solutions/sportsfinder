// import 'dart:io';
// import 'package:sport_finding/core/Network/api_service.dart';

// class RegistrationRepository {
//   final ApiService apiService;

//   RegistrationRepository(this.apiService);
//   Future<void> registerWithImage({
//     required String fullName,
//     required String email,
//     required String phoneNumber,
//     required String password,
//     required String confirmPassword,
//     required bool acceptTerms,
//     File? image,
//   }) async {
//     await apiService.postMultipart(
//       "/api/v1/auth/register",
//       fields: {
//         "full_name": fullName,
//         "email": email,
//         "phone_number": phoneNumber,
//         "password": password,
//         "confirm_password": confirmPassword,
//         "accept_terms": acceptTerms.toString(),
//       },
//       file: image,
//       fileField: "avatar_url",
//     );
//   }
// }
import 'dart:io';
import 'package:sport_finding/core/network/api_service.dart';

class RegistrationRepository {
  final ApiService apiService;

  RegistrationRepository(this.apiService);

  Future<void> registerWithImage({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    required String confirmPassword,
    required bool acceptTerms,
    File? image,
  }) async {
    await apiService.postMultipart(
      "/api/v1/auth/register",
      fields: {
        "full_name": fullName,
        "email": email,
        "phone_number": phoneNumber,
        "password": password,
        "confirm_password": confirmPassword,
        "accept_terms": acceptTerms.toString(),
      },
      file: image,
      fileField: "avatar", // 🔥 confirm with backend
    );
  }
}
