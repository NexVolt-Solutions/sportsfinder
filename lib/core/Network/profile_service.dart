import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:sport_finding/Data/Repositories/my_profile_Repository.dart';
import 'package:sport_finding/Data/model/UpdateProfile/update_profile_model.dart';
import 'package:sport_finding/Data/model/my_profile_model.dart';
import 'package:sport_finding/core/Network/api_service.dart';

class ProfileService extends ChangeNotifier {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  final MyProfileRepository _repository = MyProfileRepository(
    apiService: ApiService(),
  );

  UserProfileModel? profile;
  bool isLoading = false;
  String? errorMessage;

  String get id => profile?.id ?? 'default id';
  String get fullName => profile?.fullName ?? 'default name';
  String get email => profile?.email ?? 'default email';
  String get bio => profile?.bio ?? 'default bio';
  String get location => profile?.location ?? 'default location';

  String get avatarUrl => profile?.avatarUrl ?? '';
  bool get hasProfile => profile != null;
  bool get isAdmin => profile?.isAdmin == true;
  String get status => profile?.status ?? 'default status';
  List<dynamic> get sports => profile?.sports ?? [];
  int get totalReviews => profile?.totalReviews ?? 0;
  List<dynamic> get reviews => profile?.reviews ?? [];
  bool get notificationsEnabled => profile?.settings.notificationsEnabled ?? true;

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

      if (response != null && response is Map) {
        profile = UserProfileModel.fromJson(
          Map<String, dynamic>.from(response),
        );
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

  /// After a successful `PUT /users/me`, merge the response into [profile] so
  /// the UI shows sports/name/bio/avatar even when a follow-up `GET /users/me`
  /// still returns empty `sports` (or lags behind).
  void applySuccessfulProfileUpdate(UpdateProfileModel u) {
    final p = profile;
    if (p == null) return;

    final sportMaps = u.sports.isNotEmpty
        ? u.sports
              .map(
                (s) => <String, dynamic>{
                  'sport': s.sport,
                  'skill_level': s.skillLevel,
                },
              )
              .toList()
        : p.sports;

    profile = UserProfileModel(
      id: p.id,
      fullName: u.fullName.isNotEmpty ? u.fullName : p.fullName,
      email: p.email,
      bio: u.bio ?? p.bio,
      location: (u.location != null && u.location!.trim().isNotEmpty)
          ? u.location
          : p.location,
      avatarUrl: u.avatarUrl ?? p.avatarUrl,
      isAdmin: p.isAdmin,
      status: p.status,
      sports: sportMaps,
      totalReviews: p.totalReviews,
      reviews: p.reviews,
      stats: p.stats,
      actions: p.actions,
      settings: p.settings,
      navigation: p.navigation,
      cta: p.cta,
      createdAt: p.createdAt,
    );
    notifyListeners();
  }

  void updateNotificationPreference(bool enabled) {
    final p = profile;
    if (p == null) return;
    profile = UserProfileModel(
      id: p.id,
      fullName: p.fullName,
      email: p.email,
      bio: p.bio,
      location: p.location,
      avatarUrl: p.avatarUrl,
      isAdmin: p.isAdmin,
      status: p.status,
      sports: p.sports,
      totalReviews: p.totalReviews,
      reviews: p.reviews,
      stats: p.stats,
      actions: p.actions,
      settings: p.settings.copyWith(notificationsEnabled: enabled),
      navigation: p.navigation,
      cta: p.cta,
      createdAt: p.createdAt,
    );
    notifyListeners();
  }

  // --- call this on logout to wipe cached profile ---
  void clear() {
    profile = null;
    errorMessage = null;
    isLoading = false;
    notifyListeners();
  }
}
