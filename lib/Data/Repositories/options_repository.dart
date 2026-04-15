import 'package:sport_finding/Data/model/options_model.dart';
import 'package:sport_finding/core/Network/api_service.dart';

class OptionsRepository {
  final ApiService _apiService = ApiService();

  /// Fetch skills and sports from API
  Future<OptionsModel> getOptions() async {
    try {
      print("========== OPTIONS API REQUEST ==========");
      print("GET /api/v1/options/");

      final response = await _apiService.get('/api/v1/options/');

      print("========== OPTIONS API RESPONSE ==========");
      print("Raw Response: $response");

      final model = OptionsModel.fromJson(response);

      print("Parsed Skills: ${model.skills}");
      print("Parsed Sports: ${model.sports}");
      print("========== OPTIONS API COMPLETED ==========");

      return model;
    } catch (e, stackTrace) {
      print("========== OPTIONS API ERROR ==========");
      print("Error: $e");
      print("StackTrace: $stackTrace");

      throw Exception('Failed to fetch options: $e');
    }
  }

  /// Fetch only skills
  Future<List<String>> getSkills() async {
    try {
      print("========== GET SKILLS API REQUEST ==========");
      print("GET /api/v1/options/");

      final response = await _apiService.get('/api/v1/options/');

      final skills = List<String>.from(response['skills'] ?? []);

      print("Skills Response: $skills");
      print("========== GET SKILLS API COMPLETED ==========");

      return skills;
    } catch (e, stackTrace) {
      print("========== GET SKILLS API ERROR ==========");
      print("Error: $e");
      print("StackTrace: $stackTrace");

      throw Exception('Failed to fetch skills: $e');
    }
  }

  /// Fetch only sports
  Future<List<String>> getSports() async {
    try {
      print("========== GET SPORTS API REQUEST ==========");
      print("GET /api/v1/options/");

      final response = await _apiService.get('/api/v1/options/');

      final sports = List<String>.from(response['sports'] ?? []);

      print("Sports Response: $sports");
      print("========== GET SPORTS API COMPLETED ==========");

      return sports;
    } catch (e, stackTrace) {
      print("========== GET SPORTS API ERROR ==========");
      print("Error: $e");
      print("StackTrace: $stackTrace");

      throw Exception('Failed to fetch sports: $e');
    }
  }
}
