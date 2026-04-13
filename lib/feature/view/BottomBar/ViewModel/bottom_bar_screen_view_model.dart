import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sport_finding/Data/Repositories/my_profile_repository.dart';
import 'package:sport_finding/Data/model/my_profile_model.dart';

class BottomBarScreenViewModel extends ChangeNotifier {
  final MyProfileRepository repository;
  BottomBarScreenViewModel(this.repository);
  int _selectedIndex = 2;

  int get selectedIndex => _selectedIndex;

  static const int homeIndex = 2;

  void setSelectedIndex(int index) {
    if (_selectedIndex == index) return;
    _selectedIndex = index;
    notifyListeners();
  }

  bool get isHomeSelected => _selectedIndex == homeIndex;

  MyProfileModel? profile;
  // ✅ easy getters for the view
  bool isLoading = false;
  String? errorMessage;
  String get userName => profile?.fullName ?? '';
  String get userImage => profile?.avatarUrl ?? '';
  String get userEmail => profile?.email ?? '';
  String get userBio => profile?.bio ?? '';
  String get userLocation => profile?.location ?? '';

  Future<void> fetchMyProfile() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final response = await repository.getMyProfile();
      log(response.toString(), name: "response");
      profile = MyProfileModel.fromJson(response);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
