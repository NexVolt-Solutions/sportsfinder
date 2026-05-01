import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:sport_finding/Data/model/UpdateProfile/update_profile_model.dart';
import 'package:sport_finding/core/Network/api_service.dart';
import 'package:sport_finding/core/utils/edit_profile_sports_mapping.dart';

class UpdateProfileRepo {
  final ApiService _apiService = ApiService();

  /// `PUT /api/v1/users/me` — multipart: `full_name`, `bio`, `sports` (JSON array
  /// string), optional `avatar` file.
  Future<UpdateProfileModel> updateMyProfile({
    required String fullName,
    required String bio,
    String? sportUi,
    String? skillUi,
    String? location,
    File? imageFile,
    List<int>? imageBytes,
    String? imageFileName,
  }) async {
    try {
      final Map<String, String> fields = {
        'full_name': fullName,
        'bio': bio,
      };

      if (location != null && location.trim().isNotEmpty) {
        fields['location'] = location.trim();
      }

      if (sportUi != null &&
          sportUi.isNotEmpty &&
          skillUi != null &&
          skillUi.isNotEmpty) {
        final payload = [
          {
            'sport': uiSportToApiToken(sportUi),
            'skill_level': uiSkillToApiToken(skillUi),
          },
        ];
        fields['sports'] = jsonEncode(payload);
      }

      debugPrint('📦 [UpdateProfileRepo] Fields: $fields');
      debugPrint(
        '📦 [UpdateProfileRepo] Has image (mobile): ${imageFile != null}',
      );
      debugPrint(
        '📦 [UpdateProfileRepo] Has image (web)   : ${imageBytes != null}',
      );

      final response = await _apiService.putMultipart(
        '/api/v1/users/me',
        fields: fields,
        file: imageFile,
        fileBytes: imageBytes,
        fileName: imageFileName,
        fileField: 'avatar',
      );

      debugPrint('✅ [UpdateProfileRepo] Response: $response');

      return UpdateProfileModel.fromJson(
        Map<String, dynamic>.from(response),
      );
    } catch (e) {
      debugPrint('❌ [UpdateProfileRepo] Error: $e');
      rethrow;
    }
  }
}
