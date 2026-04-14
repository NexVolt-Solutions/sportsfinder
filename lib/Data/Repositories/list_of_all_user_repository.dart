import 'package:sport_finding/Data/model/llst_of_all_user_model.dart';
import 'package:sport_finding/core/Network/api_service.dart';

class ListOfAllUserRepository {
  final ApiService apiService;
  ListOfAllUserRepository({required this.apiService});

  Future<ListOfAllUserModel> getAllUsers() async {
    final response = await apiService.get('/api/v1/users');
    return response;
  }
}
