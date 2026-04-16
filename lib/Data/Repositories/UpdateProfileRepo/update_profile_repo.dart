// import 'dart:developer';
// import 'package:sport_finding/Data/model/UpdateProfile/update_profile_model.dart';
// import 'package:sport_finding/core/Network/api_service.dart';

// class UpdateProfileRepo {
//   final ApiService _apiService = ApiService();

//   Future<UpdateProfileModel> updateMyProfile({
//     required Map<String, dynamic> data,
//   }) async {
//     try {
//       log("🚀 UPDATE PROFILE API CALLED");
//       log("📤 Request Data: $data");

//       final response = await _apiService.put("/api/v1/users/me", data: data);

//       log("📥 Response Received: $response");

//       final model = UpdateProfileModel.fromJson(response);

//       log("✅ Parsed Model: ${model.toString()}");

//       return model;
//     } catch (e, stackTrace) {
//       log("❌ UPDATE PROFILE ERROR: $e");
//       log("📍 STACK TRACE: $stackTrace");
//       rethrow;
//     }
//   }
// }
import 'package:flutter/foundation.dart';
import 'package:sport_finding/Data/model/UpdateProfile/update_profile_model.dart';
import 'package:sport_finding/core/Network/api_service.dart';

class UpdateProfileRepo {
  final ApiService _apiService = ApiService();

  Future<UpdateProfileModel> updateMyProfile({
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _apiService.put("/api/v1/users/me", data: data);

      debugPrint("✅ Update Profile Response: $response");

      return UpdateProfileModel.fromJson(response);
    } catch (e) {
      debugPrint("❌ Update Profile Error: $e");
      rethrow;
    }
  }
}
