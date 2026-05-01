import 'package:flutter/material.dart';
import 'package:sport_finding/Data/Repositories/list_of_all_user_repository.dart';
import 'package:sport_finding/Data/model/llst_of_all_user_model.dart';

class AllMemberScreenViewModel extends ChangeNotifier {
  AllMemberScreenViewModel({required ListOfAllUserRepository repository})
    : _repository = repository {
    fetchUsers();
  }

  final ListOfAllUserRepository _repository;

  List<Items> _allUsers = <Items>[];
  List<Items> _visibleUsers = <Items>[];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  List<Items> get users => List<Items>.unmodifiable(_visibleUsers);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchUsers() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _repository.getAllUsers();
      _allUsers = response.items ?? <Items>[];
      _applySearch();
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
      _allUsers = <Items>[];
      _visibleUsers = <Items>[];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchUsers(String query) {
    _searchQuery = query.trim().toLowerCase();
    _applySearch();
    notifyListeners();
  }

  void _applySearch() {
    if (_searchQuery.isEmpty) {
      _visibleUsers = List<Items>.from(_allUsers);
      return;
    }

    _visibleUsers = _allUsers.where((user) {
      final name = (user.fullName ?? '').toLowerCase();
      final location = (user.location ?? '').toLowerCase();
      final sports = (user.sports ?? <Sports>[])
          .map((sport) => (sport.sport ?? '').toLowerCase())
          .join(' ');

      return name.contains(_searchQuery) ||
          location.contains(_searchQuery) ||
          sports.contains(_searchQuery);
    }).toList();
  }
}
