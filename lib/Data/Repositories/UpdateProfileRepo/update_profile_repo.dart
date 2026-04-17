// // import 'dart:developer';
// // import 'package:sport_finding/Data/model/UpdateProfile/update_profile_model.dart';
// // import 'package:sport_finding/core/Network/api_service.dart';

// // class UpdateProfileRepo {
// //   final ApiService _apiService = ApiService();

// //   Future<UpdateProfileModel> updateMyProfile({
// //     required Map<String, dynamic> data,
// //   }) async {
// //     try {
// //       log("🚀 UPDATE PROFILE API CALLED");
// //       log("📤 Request Data: $data");

// //       final response = await _apiService.put("/api/v1/users/me", data: data);

// //       log("📥 Response Received: $response");

// //       final model = UpdateProfileModel.fromJson(response);

// //       log("✅ Parsed Model: ${model.toString()}");

// //       return model;
// //     } catch (e, stackTrace) {
// //       log("❌ UPDATE PROFILE ERROR: $e");
// //       log("📍 STACK TRACE: $stackTrace");
// //       rethrow;
// //     }
// //   }
// // }
// import 'package:flutter/foundation.dart';
// import 'package:sport_finding/Data/model/UpdateProfile/update_profile_model.dart';
// import 'package:sport_finding/core/Network/api_service.dart';

// class UpdateProfileRepo {
//   final ApiService _apiService = ApiService();

//   Future<UpdateProfileModel> updateMyProfile({
//     required Map<String, dynamic> data,
//   }) async {
//     try {
//       final response = await _apiService.put("/api/v1/users/me", data: data);

//       debugPrint("✅ Update Profile Response: $response");

//       return UpdateProfileModel.fromJson(response);
//     } catch (e) {
//       debugPrint("❌ Update Profile Error: $e");
//       rethrow;
//     }
//   }
// }
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sport_finding/Data/model/UpdateProfile/update_profile_model.dart';
import 'package:sport_finding/core/Network/api_service.dart';

class UpdateProfileRepo {
  final ApiService _apiService = ApiService();

  Future<UpdateProfileModel> updateMyProfile({
    required String fullName,
    required String bio,
    String? sport,
    String? skillLevel,
    // Mobile
    File? imageFile,
    // Web
    List<int>? imageBytes,
    String? imageFileName,
  }) async {
    try {
      // ── Build text fields ──────────────────────────────────────────────
      final Map<String, String> fields = {
        'full_name': fullName,
        'bio': bio,
        if (sport != null) 'sport': sport,
        if (skillLevel != null) 'skill_level': skillLevel,
      };

      debugPrint("📦 [UpdateProfileRepo] Fields: $fields");
      debugPrint(
        "📦 [UpdateProfileRepo] Has image (mobile): ${imageFile != null}",
      );
      debugPrint(
        "📦 [UpdateProfileRepo] Has image (web)   : ${imageBytes != null}",
      );

      final response = await _apiService.putMultipart(
        "/api/v1/users/me",
        fields: fields,
        file: imageFile,
        fileBytes: imageBytes,
        fileName: imageFileName,
        fileField: "avatar", // ← match your API's expected field name
      );

      debugPrint("✅ [UpdateProfileRepo] Response: $response");

      return UpdateProfileModel.fromJson(response);
    } catch (e) {
      debugPrint("❌ [UpdateProfileRepo] Error: $e");
      rethrow;
    }
  }
}
