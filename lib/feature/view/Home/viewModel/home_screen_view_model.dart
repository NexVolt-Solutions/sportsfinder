import 'package:flutter/material.dart';
import 'package:sport_finding/Data/Repositories/my_profile_Repository.dart';
import 'package:sport_finding/Data/Repositories/matches_repo.dart';
import 'package:sport_finding/Data/model/all_matches_model.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/Data/model/match.dart';
import 'package:sport_finding/Data/model/sport.dart';
import 'package:sport_finding/core/Network/profile_service.dart';

class HomeScreenViewModel extends ChangeNotifier {
  final MyProfileRepository repository;

  HomeScreenViewModel({required this.repository}) {
    // ✅ Delegate to the singleton — won't re-fetch if already loaded
    final service = ProfileService();
    service.fetchMyProfile();

    // Listen to ProfileService changes and rebuild this ViewModel
    service.addListener(_onProfileServiceChanged);

    Future.microtask(_loadUpcomingMatches);
  }

  final MatchesRepo _matchesRepo = MatchesRepo();

  /// Matches from GET /api/v1/matches with [scheduled_at] strictly after now (UTC).
  List<AllMatches> matches = [];

  bool matchesLoading = false;
  String? matchesError;

  // Add this getter anywhere — in the ViewModel or as a helper
  String get timeGreeting {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return "Hey, Good Morning";
    if (hour >= 12 && hour < 17) return "Hey, Good Afternoon";
    if (hour >= 17 && hour < 21) return "Hey, Good Evening";
    return "Hey, Good Night";
  }

  void _onProfileServiceChanged() {
    _resortMatches();
    notifyListeners();
  }

  @override
  void dispose() {
    ProfileService().removeListener(_onProfileServiceChanged);
    super.dispose();
  }

  bool isSelected = false;

  List<Match> matcheData = [
    Match(imagePath: AppAssets.addIcon, title: AppText.filters),
    Match(imagePath: AppAssets.matchesIcon, title: AppText.filters),
  ];

  final List<Sport> sports = [
    Sport(imagePath: AppAssets.footBallIcon, title: AppText.football),
    Sport(imagePath: AppAssets.basketBallIcon, title: AppText.basketball),
    Sport(imagePath: AppAssets.tableTennisIcon, title: AppText.tennis),
    Sport(imagePath: AppAssets.volleyBallIcon, title: AppText.volleyball),
    Sport(imagePath: AppAssets.batIcon, title: AppText.cricket),
  ];

  Future<void> _loadUpcomingMatches() async {
    matchesLoading = true;
    matchesError = null;
    notifyListeners();

    try {
      final res = await _matchesRepo.getAllMatches(page: 1, limit: 20);
      final nowUtc = DateTime.now().toUtc();

      matches =
          res.items.where((m) {
            final start = m.scheduledStartUtc;
            return start != null && start.isAfter(nowUtc);
          }).toList();

      _resortMatches();
    } catch (e) {
      matchesError = e.toString();
      matches = [];
    } finally {
      matchesLoading = false;
      notifyListeners();
    }
  }

  void _resortMatches() {
    if (matches.isEmpty) return;

    final myId = ProfileService().profile?.id;

    matches.sort((a, b) {
      if (myId != null && myId.isNotEmpty) {
        final aMine = a.host.id == myId;
        final bMine = b.host.id == myId;
        if (aMine != bMine) return aMine ? -1 : 1;
      }
      final ta = a.scheduledStartUtc;
      final tb = b.scheduledStartUtc;
      if (ta == null && tb == null) return 0;
      if (ta == null) return 1;
      if (tb == null) return -1;
      return ta.compareTo(tb);
    });
  }

  ProfileService get profileService => ProfileService();

  String get fullName => profileService.fullName;
  String get avatarUrl => profileService.avatarUrl;
  bool get isLoading => profileService.isLoading;
  String? get errorMessage => profileService.errorMessage;
}
