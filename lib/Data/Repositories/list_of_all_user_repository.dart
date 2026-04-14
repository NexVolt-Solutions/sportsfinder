import 'package:sport_finding/core/Network/api_service.dart';

class ListOfAllUserRepository {
  final ApiService apiService;
  ListOfAllUserRepository({required this.apiService});

  Future<dynamic> getAllUsers() async {
    final response = await apiService.get('/api/v1/users');
    return response;
  }
}
