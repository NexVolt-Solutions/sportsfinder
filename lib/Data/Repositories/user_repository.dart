import 'package:sport_finding/Data/model/user_model.dart';

import '../../core/network/api_service.dart';

class UserRepository {
  final ApiService apiService;

  UserRepository(this.apiService);

  Future<List<UserModel>> getUsers() async {
    final response = await apiService.get("/users");

    /// 🔥 Handle both List & Map
    if (response is List) {
      return response.map((json) => UserModel.fromJson(json)).toList();
    } else if (response is Map<String, dynamic>) {
      final data = response['data'];

      if (data is List) {
        return data.map((json) => UserModel.fromJson(json)).toList();
      } else {
        throw Exception("Invalid data format inside map");
      }
    } else {
      throw Exception("Unexpected response format");
    }
  }
}
