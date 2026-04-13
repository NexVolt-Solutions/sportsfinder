// lib/core/Services/profile_service.dart

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:sport_finding/Data/Repositories/my_profile_Repository.dart';
import 'package:sport_finding/Data/model/my_profile_model.dart';
import 'package:sport_finding/core/Network/api_service.dart';

class ProfileService extends ChangeNotifier {
  // ✅ Singleton — one instance shared across the whole app
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  final MyProfileRepository _repository = MyProfileRepository(
    apiService: ApiService(),
  );

  // --- state ---
  MyProfileModel? profile;
  bool isLoading = false;
  String? errorMessage;

  // --- getters ---
  String get fullName => profile?.fullName ?? 'default name';
  String get avatarUrl => profile?.avatarUrl ?? 'default avatar url';
  String get email => profile?.email ?? 'default email';
  String get bio => profile?.bio ?? 'default bio';
  String get location => profile?.location ?? 'default location';
  bool get hasProfile => profile != null;

  // --- fetch (safe to call multiple times — skips if already loaded) ---
  Future<void> fetchMyProfile({bool forceRefresh = false}) async {
    if (isLoading) return; // already in flight
    if (profile != null && !forceRefresh) return; // already loaded

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // ApiService reads 'access_token' from SharedPreferences automatically
      log('Fetching profile...', name: 'ProfileService');
      final response = await _repository.getMyProfile();
      log('Profile API Response: $response', name: 'ProfileService');

      if (response != null) {
        profile = MyProfileModel.fromJson(response);
        log('✅ Profile loaded: ${profile?.fullName}', name: 'ProfileService');
        errorMessage = null;
      } else {
        errorMessage = 'Empty response from server';
        log('Empty response from server', name: 'ProfileService');
      }
    } catch (e) {
      errorMessage = e.toString();
      log('❌ Error: $errorMessage', name: 'ProfileService');
      // Re-throw so caller knows there was an error
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // --- call this on logout to wipe cached profile ---
  void clear() {
    profile = null;
    errorMessage = null;
    isLoading = false;
    notifyListeners();
  }
}
