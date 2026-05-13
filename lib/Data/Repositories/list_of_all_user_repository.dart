// ignore_for_file: avoid_print

import 'package:sport_finding/Data/model/llst_of_all_user_model.dart';
import 'package:sport_finding/core/Network/api_service.dart';

class ListOfAllUserRepository {
  final ApiService apiService;

  ListOfAllUserRepository({required this.apiService});

  Future<ListOfAllUserModel> getAllUsers() async {
    try {
      print("========== GET ALL USERS REQUEST ==========");
      print("Endpoint: /api/v1/users");

      final response = await apiService.get('/api/v1/users');

      print("========== GET ALL USERS RESPONSE ==========");
      print(response);
      print("========== GET ALL USERS COMPLETED ==========");

      return ListOfAllUserModel.fromJson(
        Map<String, dynamic>.from(response as Map),
      );
    } catch (e, stackTrace) {
      print("========== GET ALL USERS ERROR ==========");
      print("Error: $e");
      print("StackTrace: $stackTrace");
      rethrow;
    }
  }
}
