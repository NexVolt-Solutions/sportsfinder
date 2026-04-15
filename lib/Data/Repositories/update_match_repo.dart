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
      print("========== UPDATE MATCH REPO REQUEST ==========");
      print("Match ID: $matchId");
      print("Endpoint: /api/v1/matches/$matchId");
      print("Request Data: $data");

      final response = await _apiService.put(
        "/api/v1/matches/$matchId",
        data: data,
      );

      /// 📥 RESPONSE LOG
      print("========== UPDATE MATCH REPO RESPONSE ==========");
      print(response);
      print("========== UPDATE MATCH REPO END ==========");

      final model = UpdateMatchModel.fromJson(response);

      print("Parsed Model ID: ${model.id}");
      print("Parsed Title: ${model.title}");

      return model;
    } catch (e, stackTrace) {
      /// ❌ ERROR LOG
      print("========== UPDATE MATCH REPO ERROR ==========");
      print("Error: $e");
      print(stackTrace);
      rethrow;
    }
  }
}
