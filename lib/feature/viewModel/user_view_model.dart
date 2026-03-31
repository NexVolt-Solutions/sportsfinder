import 'package:flutter/material.dart';
import 'package:sport_finding/Data/Repositories/user_repository.dart';
import 'package:sport_finding/Data/model/user_model.dart';

class UserViewModel extends ChangeNotifier {
  final UserRepository repository;

  UserViewModel(this.repository);

  List<UserModel> users = [];
  bool isLoading = false;
  String error = '';

  Future<void> fetchUsers() async {
    isLoading = true;
    notifyListeners();

    try {
      users = await repository.getUsers();
      error = '';
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }
}
