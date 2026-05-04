import 'package:flutter/material.dart';
import 'package:sport_finding/Data/model/my_profile_model.dart';
import 'package:sport_finding/core/Network/profile_service.dart';
import 'package:sport_finding/core/utils/logger.dart';

class BottomBarScreenViewModel extends ChangeNotifier {
  BottomBarScreenViewModel();
  int _selectedIndex = 2;

  int get selectedIndex => _selectedIndex;

  static const int homeIndex = 2;

  void setSelectedIndex(int index) {
    if (_selectedIndex == index) return;
    _selectedIndex = index;
    notifyListeners();
  }

  bool get isHomeSelected => _selectedIndex == homeIndex;

  UserProfileModel? profile;
  // Easy getters for the view.
  bool isLoading = false;
  String? errorMessage;
  String get userName => profile?.fullName ?? '';
  String get userImage => profile?.avatarUrl ?? '';
  String get userEmail => profile?.email ?? '';
  String get userBio => profile?.bio ?? '';
  String get userLocation => profile?.location ?? '';

  Future<void> fetchMyProfile() async {
    if (ProfileService().profile != null) {
      profile = ProfileService().profile;
      notifyListeners();
      return;
    }
    _setProfileLoading(true);
    errorMessage = null;
    try {
      await ProfileService().fetchMyProfile();
      AppLogger.debug('Fetched profile response', tag: 'BottomBarScreenVM');
      profile = ProfileService().profile;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      _setProfileLoading(false);
    }
  }

  void _setProfileLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
}
