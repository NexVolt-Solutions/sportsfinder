import 'dart:developer';
import 'package:sport_finding/core/Network/api_service.dart';
import '../model/update_match_model.dart';

class UpdateMatchRepo {
  final ApiService _apiService = ApiService();

  Future<UpdateMatchModel> updateMatch({
    required String matchId,
    required Map<String, dynamic> data,
  }) async {
    try {
      /// 📤 REQUEST LOG
      log(
        "========== UPDATE MATCH REPO REQUEST ==========",
        name: 'UpdateMatchRepo',
      );
      log("Match ID: $matchId", name: 'UpdateMatchRepo');
      log("Endpoint: /api/v1/matches/$matchId", name: 'UpdateMatchRepo');
      log("Request Data: $data", name: 'UpdateMatchRepo');

      final response = await _apiService.put(
        "/api/v1/matches/$matchId",
        data: data,
      );

      /// 📥 RESPONSE LOG
      log(
        "========== UPDATE MATCH REPO RESPONSE ==========",
        name: 'UpdateMatchRepo',
      );
      log("Response type: ${response.runtimeType}", name: 'UpdateMatchRepo');
      log("$response", name: 'UpdateMatchRepo');
      log(
        "========== UPDATE MATCH REPO END ==========",
        name: 'UpdateMatchRepo',
      );

      // ✅ Validate response
      if (response == null) {
        log("API Response is null", name: 'UpdateMatchRepo', level: 1000);
        throw Exception("API returned null when updating match");
      }

      if (response is! Map<String, dynamic>) {
        log(
          "Unexpected response type: ${response.runtimeType}",
          name: 'UpdateMatchRepo',
          level: 1000,
        );
        throw Exception(
          "Expected Map<String, dynamic> but got ${response.runtimeType}",
        );
      }

      final model = UpdateMatchModel.fromJson(response);

      log("Parsed Model ID: ${model.id}", name: 'UpdateMatchRepo');
      log("Parsed Title: ${model.title}", name: 'UpdateMatchRepo');

      return model;
    } catch (e, stackTrace) {
      /// ❌ ERROR LOG
      log(
        "========== UPDATE MATCH REPO ERROR ==========\nError: $e",
        name: 'UpdateMatchRepo',
        level: 1000,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
