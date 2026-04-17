// lib/core/Network/list_of_all_user_service.dart

import 'dart:developer';
import 'dart:math' show asin, cos, pi, pow, sin, sqrt;
import 'package:flutter/material.dart';
import 'package:sport_finding/Data/model/llst_of_all_user_model.dart';
import 'package:sport_finding/core/Network/api_service.dart';
import 'package:sport_finding/core/Storage/app_preferences.dart';
import 'package:sport_finding/core/Network/profile_service.dart';

class ListOfAllUserService extends ChangeNotifier {
  // ✅ Singleton
  static final ListOfAllUserService _instance =
      ListOfAllUserService._internal();
  factory ListOfAllUserService() => _instance;
  ListOfAllUserService._internal();

  final ApiService _apiService = ApiService();

  // --- raw state ---
  List<Items> _allUsers = [];
  bool isLoading = false;
  String? errorMessage;

  // --- recent profile views (stored locally) ---
  final List<Items> _recentlyViewed = [];

  // ─────────────────────────────────────────────
  // PUBLIC FILTERED LISTS
  // ─────────────────────────────────────────────

  /// Users within 20 km of the current user
  List<Items> get nearbyPlayers {
    final currentLocation = ProfileService().location;
    if (currentLocation.isEmpty) return [];

    return _allUsers.where((user) {
      if (user.location == null || user.location!.isEmpty) return false;
      final distance = _distanceKm(currentLocation, user.location!);
      return distance != null && distance <= 20.0;
    }).toList();
  }

  /// Users who share at least one sport with the current user
  List<Items> get recommendedPlayers {
    final currentSports = ProfileService().profile?.sports ?? [];
    if (currentSports.isEmpty) return _allUsers; // fallback: show all

    final currentSportNames = currentSports
        .map((s) => s.sport?.toLowerCase().trim())
        .whereType<String>()
        .toSet();

    return _allUsers.where((user) {
      final userSports = user.sports ?? [];
      return userSports.any(
        (s) => currentSportNames.contains(s.sport?.toLowerCase().trim()),
      );
    }).toList();
  }

  /// Users whose profiles the current user has viewed
  List<Items> get recentPlayers => List.unmodifiable(_recentlyViewed);

  /// All users (unfiltered)
  List<Items> get allUsers => List.unmodifiable(_allUsers);

  // ─────────────────────────────────────────────
  // FETCH
  // ─────────────────────────────────────────────

  /// [search] is passed as the API `search` query (optional).
  Future<void> fetchAllUsers({
    bool forceRefresh = false,
    String? search,
    int page = 1,
    int limit = 100,
  }) async {
    if (isLoading) {
      log('⏳ Already loading — skipped', name: 'ListOfAllUserService');
      return;
    }
    if (_allUsers.isNotEmpty && !forceRefresh) {
      log(
        '✅ Already loaded ${_allUsers.length} users — skipped (use forceRefresh:true to reload)',
        name: 'ListOfAllUserService',
      );
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // ── token check ───────────────────────────────────────────────
      final token = await AppPreferences.getAccessToken();
      log(
        '🔑 Token: ${token != null ? "FOUND (${token.substring(0, token.length.clamp(0, 20))}...)" : "NULL — request will be unauthenticated"}',
        name: 'ListOfAllUserService',
      );

      // ── request (browse public users; excludes current user per API) ──
      final q = Uri(
        path: '/api/v1/users',
        queryParameters: <String, String>{
          'page': '$page',
          'limit': '${limit.clamp(1, 100)}',
          if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        },
      ).toString();
      log('🌐 GET $q', name: 'ListOfAllUserService');

      final response = await _apiService.get(q);

      // ── raw response ──────────────────────────────────────────────
      log(
        '📦 Raw response type: ${response.runtimeType}',
        name: 'ListOfAllUserService',
      );
      log('📦 Raw response: $response', name: 'ListOfAllUserService');

      if (response == null) {
        log(
          '❌ Response is null — API returned nothing',
          name: 'ListOfAllUserService',
        );
        errorMessage = 'Null response';
        return;
      }

      // ── parse ─────────────────────────────────────────────────────
      final model = ListOfAllUserModel.fromJson(response);
      _allUsers = model.items ?? [];

      log('✅ Parsed ${_allUsers.length} users', name: 'ListOfAllUserService');
      log(
        '📄 Pagination → total:${model.total} page:${model.page} limit:${model.limit} hasNext:${model.hasNext}',
        name: 'ListOfAllUserService',
      );

      // ── print each user ───────────────────────────────────────────
      for (int i = 0; i < _allUsers.length; i++) {
        final u = _allUsers[i];
        log(
          '👤 [$i] id:${u.id} | name:${u.fullName} | location:${u.location} | sports:${u.sports?.map((s) => "${s.sport}(${s.skillLevel})").join(", ")} | rating:${u.avgRating} | following:${u.isFollowing}',
          name: 'ListOfAllUserService',
        );
      }

      // ── filtered lists preview ────────────────────────────────────
      log(
        '📍 nearbyPlayers     → ${nearbyPlayers.length} users',
        name: 'ListOfAllUserService',
      );
      log(
        '⭐ recommendedPlayers → ${recommendedPlayers.length} users',
        name: 'ListOfAllUserService',
      );
      log(
        '🕐 recentPlayers     → ${recentPlayers.length} users',
        name: 'ListOfAllUserService',
      );
    } catch (e, stack) {
      errorMessage = e.toString();
      log('❌ Error: $e', name: 'ListOfAllUserService');
      log('📋 Stack: $stack', name: 'ListOfAllUserService');
    } finally {
      isLoading = false;
      notifyListeners();
      log(
        '🏁 fetchAllUsers done — isLoading:false',
        name: 'ListOfAllUserService',
      );
    }
  }

  // ─────────────────────────────────────────────
  // RECENT PLAYERS — call this when user views a profile
  // ─────────────────────────────────────────────

  /// Call this from PublicProfileScreen or PrivateProfileScreen
  /// when the current user views another user's profile.
  void recordProfileView(Items viewedUser) {
    // Remove if already in list (move to front)
    _recentlyViewed.removeWhere((u) => u.id == viewedUser.id);
    _recentlyViewed.insert(0, viewedUser);

    // Keep only last 20
    if (_recentlyViewed.length > 20) {
      _recentlyViewed.removeLast();
    }

    notifyListeners();
    log('Recorded view: ${viewedUser.fullName}', name: 'ListOfAllUserService');
  }

  /// Clear recent history (e.g. on logout)
  void clear() {
    _allUsers = [];
    _recentlyViewed.clear();
    errorMessage = null;
    isLoading = false;
    notifyListeners();
  }

  // ─────────────────────────────────────────────
  // DISTANCE HELPER — Haversine formula
  // ─────────────────────────────────────────────

  /// Parses "lat,lng" strings and returns distance in km.
  /// Returns null if parsing fails.
  double? _distanceKm(String locationA, String locationB) {
    try {
      final a = _parseLatLng(locationA);
      final b = _parseLatLng(locationB);
      if (a == null || b == null) return null;

      const earthRadius = 6371.0; // km
      final dLat = _toRad(b.$1 - a.$1);
      final dLng = _toRad(b.$2 - a.$2);

      final h =
          pow(sin(dLat / 2), 2) +
          cos(_toRad(a.$1)) * cos(_toRad(b.$1)) * pow(sin(dLng / 2), 2);

      return 2 * earthRadius * asin(sqrt(h));
    } catch (_) {
      return null;
    }
  }

  (double, double)? _parseLatLng(String location) {
    // Expects "latitude,longitude" e.g. "33.7215,73.0433"
    final parts = location.split(',');
    if (parts.length != 2) return null;
    final lat = double.tryParse(parts[0].trim());
    final lng = double.tryParse(parts[1].trim());
    if (lat == null || lng == null) return null;
    return (lat, lng);
  }

  double _toRad(double deg) => deg * pi / 180;
}

// extension ItemsSafeDefaults on Items {
//   String get safeName => fullName ?? 'Unknown Player';
//   String get safeLocation => location ?? 'Location unknown';
//   String get safeAvatar => avatarUrl ?? '';
//   String get safeBio => bio ?? 'No bio available';
//   String get safeId => id ?? '';
//   double get safeRating => (avgRating ?? 0).toDouble();
//   int get safeGames => totalGamesPlayed ?? 0;
//   bool get safeFollowing => isFollowing ?? false;

//   String get firstSport => sports?.isNotEmpty == true
//       ? (sports!.first.sport ?? 'Unknown Sport')
//       : 'Unknown Sport';

//   String get firstSkill => sports?.isNotEmpty == true
//       ? (sports!.first.skillLevel ?? 'Unknown Level')
//       : 'Unknown Level';

//   /// All sport names joined — e.g. "Football · Basketball"
//   String get allSports => sports?.isNotEmpty == true
//       ? sports!.map((s) => s.sport ?? '').where((s) => s.isNotEmpty).join(' · ')
//       : 'No sports listed';
// }
