// ignore_for_file: avoid_print

import 'package:sport_finding/Data/model/create_match_request_model.dart';
import 'package:sport_finding/core/Network/api_service.dart';

class CreateMatchRepo {
  final ApiService _api = ApiService();

  Future<MatchModel> createMatch(Map<String, dynamic> data) async {
    try {
      // 📤 Request Logs
      print("========== CREATE MATCH REQUEST ==========");
      print("Endpoint: /api/v1/matches");
      print("Request Data: $data");

      final response = await _api.post('/api/v1/matches', data: data);

      // 📥 Response Logs
      print("========== CREATE MATCH RESPONSE ==========");
      print("Response: $response");

      if (response == null) {
        print("❌ API returned NULL response");
        throw Exception('API returned null response');
      }

      if (response is! Map<String, dynamic>) {
        print("❌ Unexpected response type: ${response.runtimeType}");
        throw Exception(
          'Unexpected API response type: ${response.runtimeType}',
        );
      }

      final match = MatchModel.fromJson(response);

      // ✅ Parsed Data Log
      print("========== MATCH PARSED SUCCESS ==========");
      print("Match ID: ${match.id}");
      print("Full Match Data: $match");

      return match;
    } catch (e, stackTrace) {
      // ❌ Error Logs
      print("========== CREATE MATCH ERROR ==========");
      print("Error: $e");
      print("StackTrace: $stackTrace");

      rethrow;
    }
  }
}
