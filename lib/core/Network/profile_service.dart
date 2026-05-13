import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sport_finding/Data/Repositories/my_profile_repository.dart';
import 'package:sport_finding/Data/model/UpdateProfile/update_profile_model.dart';
import 'package:sport_finding/Data/model/my_profile_model.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Network/api_service.dart';
import 'package:sport_finding/core/Storage/app_preferences.dart';
import 'package:sport_finding/core/utils/network_errors.dart';
import 'package:sport_finding/feature/widget/app_avatar.dart';

class ProfileService extends ChangeNotifier {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal() {
    Future<void>.microtask(_hydrateFallbackLocation);
  }

  final MyProfileRepository _repository = MyProfileRepository(
    apiService: ApiService(),
  );

  UserProfileModel? profile;
  bool isLoading = false;
  String? errorMessage;
  String? _fallbackLocation;

  String get id => profile?.id ?? 'default id';
  String get fullName => profile?.fullName ?? 'default name';
  String get email => profile?.email ?? 'default email';
  String get bio => profile?.bio ?? 'default bio';
  String get location {
    final apiLocation = profile?.location?.trim();
    if (apiLocation != null && apiLocation.isNotEmpty) return apiLocation;
    final fallback = _fallbackLocation?.trim();
    if (fallback != null && fallback.isNotEmpty) return fallback;
    return AppText.profilePlaceholderLocation;
  }

  String get avatarUrl => normalizeImageUrl(profile?.avatarUrl) ?? '';
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

      const maxAttempts = 5;
      for (var attempt = 0; attempt < maxAttempts; attempt++) {
        if (attempt > 0) {
          final backoff = Duration(milliseconds: 500 * (1 << (attempt - 1)));
          log(
            'Profile fetch retry after $backoff (attempt ${attempt + 1}/$maxAttempts)',
            name: 'ProfileService',
          );
          await Future<void>.delayed(backoff);
        }
        try {
          final response = await _repository.getMyProfile();
          log('Profile API Response: $response', name: 'ProfileService');

          if (response != null && response is Map) {
            profile = UserProfileModel.fromJson(
              Map<String, dynamic>.from(response),
            );
            await _hydrateFallbackLocation();
            log('✅ Profile loaded: ${profile?.fullName}', name: 'ProfileService');
            errorMessage = null;
          } else {
            errorMessage = 'Empty response from server';
            log('Empty response from server', name: 'ProfileService');
          }
          break;
        } catch (e) {
          final transient = isTransientNetworkError(e);
          final willRetry = transient && attempt < maxAttempts - 1;
          if (willRetry) {
            log(
              'Transient network error loading profile, will retry: $e',
              name: 'ProfileService',
            );
            continue;
          }
          errorMessage = e.toString();
          log('❌ Error: $errorMessage', name: 'ProfileService');
          rethrow;
        }
      }
    } catch (e) {
      if (errorMessage == null || errorMessage!.isEmpty) {
        errorMessage = e.toString();
        log('❌ Error: $errorMessage', name: 'ProfileService');
      }
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
      avatarUrl: normalizeImageUrl(u.avatarUrl) ?? p.avatarUrl,
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

  /// Bumps cached [profile.stats] after follow/unfollow/remove-follower so the
  /// profile tab reflects counts immediately (without waiting for a full refetch).
  void adjustSocialStats({int followersDelta = 0, int followingDelta = 0}) {
    final p = profile;
    if (p == null) return;
    if (followersDelta == 0 && followingDelta == 0) return;

    final s = p.stats;
    var nf = s.followers + followersDelta;
    if (nf < 0) nf = 0;
    var nfol = s.following + followingDelta;
    if (nfol < 0) nfol = 0;

    final newStats = Stats(
      followers: nf,
      following: nfol,
      matches: s.matches,
      rating: s.rating,
    );

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
      stats: newStats,
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
    _fallbackLocation = null;
    errorMessage = null;
    isLoading = false;
    notifyListeners();
  }

  Future<void> _hydrateFallbackLocation() async {
    final prev = _fallbackLocation;
    final fromStorage =
        await AppPreferences.getCurrentLocationName() ??
        await AppPreferences.getCurrentLocationText();
    _fallbackLocation = fromStorage?.trim();
    final changed = (prev ?? '') != (_fallbackLocation ?? '');
    final apiLocation = profile?.location?.trim() ?? '';
    if (changed && apiLocation.isEmpty) {
      notifyListeners();
    }
  }
}
