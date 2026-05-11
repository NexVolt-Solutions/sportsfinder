import 'package:flutter/material.dart';
import 'package:sport_finding/Data/Repositories/matches_repo.dart';
import 'package:sport_finding/Data/model/all_matches_model.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/Data/model/match.dart';
import 'package:sport_finding/Data/model/sport.dart';
import 'package:sport_finding/core/Network/deleted_matches_service.dart';
import 'package:sport_finding/core/Network/platform_options_store.dart';
import 'package:sport_finding/core/Network/profile_service.dart';

class HomeScreenViewModel extends ChangeNotifier {
  HomeScreenViewModel() {
    // Defer so ProfileService does not notify during the first home build
    // (avoids "setState during build" in listeners such as [AllUpcommingMatchesViewModel]).
    final service = ProfileService();
    Future<void>.microtask(() => service.fetchMyProfile());

    // Listen to ProfileService changes and rebuild this ViewModel
    service.addListener(_onProfileServiceChanged);
    DeletedMatchesService().addListener(_onDeletedMatchesChanged);

    Future.microtask(_loadUpcomingMatches);
    Future.microtask(_loadSports);
  }

  final MatchesRepo _matchesRepo = MatchesRepo();

  /// Matches from GET /api/v1/matches with [scheduled_at] strictly after now (UTC).
  List<AllMatches> matches = [];

  bool matchesLoading = false;
  String? matchesError;
  String? sportsError;
  bool hasMoreUpcoming = false;

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

  void _onDeletedMatchesChanged() {
    matches.removeWhere((m) => DeletedMatchesService().isDeleted(m.id));
    notifyListeners();
  }

  @override
  void dispose() {
    ProfileService().removeListener(_onProfileServiceChanged);
    DeletedMatchesService().removeListener(_onDeletedMatchesChanged);
    super.dispose();
  }

  bool isSelected = false;

  List<Match> matcheData = [
    Match(imagePath: AppAssets.addIcon, title: AppText.filters),
    Match(imagePath: AppAssets.matchesIcon, title: AppText.filters),
  ];

  List<Sport> sports = [];

  Future<void> _loadSports() async {
    try {
      sportsError = null;
      final options = await PlatformOptionsStore.instance.load();
      sports = options.sportOptions
          .where((sport) => sport.isPopular)
          .take(5)
          .map(
            (sport) => Sport(
              id: sport.id,
              iconKey: sport.iconKey,
              category: sport.category,
              isPopular: sport.isPopular,
              imagePath: _assetForSport(sport.iconKey),
              title: sport.name,
            ),
          )
          .toList();
    } catch (e) {
      sportsError = e.toString();
      sports = [];
    } finally {
      notifyListeners();
    }
  }

  Future<void> _loadUpcomingMatches() async {
    matchesLoading = true;
    matchesError = null;
    notifyListeners();

    try {
      final allRes = await _matchesRepo.getAllMatches(
        page: 1,
        limit: 20,
        type: 'all',
      );
      final myRes = await _matchesRepo.getAllMatches(
        page: 1,
        limit: 20,
        type: 'my',
      );
      final merged = <String, AllMatches>{};
      for (final m in allRes.items) {
        merged[m.id] = m;
      }
      for (final m in myRes.items) {
        merged[m.id] = m;
      }
      final nowUtc = DateTime.now().toUtc();

      matches = merged.values.where((m) {
        final start = m.scheduledStartUtc;
        return start != null &&
            start.isAfter(nowUtc) &&
            !DeletedMatchesService().isDeleted(m.id);
      }).toList();
      hasMoreUpcoming = allRes.hasNext || myRes.hasNext;

      _resortMatches();
    } catch (e) {
      matchesError = e.toString();
      matches = [];
      hasMoreUpcoming = false;
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

  void removeMatchById(String matchId) {
    final trimmedId = matchId.trim();
    if (trimmedId.isEmpty) return;

    matches.removeWhere((m) => m.id == trimmedId);
    DeletedMatchesService().markDeleted(trimmedId);
    notifyListeners();
  }

  ProfileService get profileService => ProfileService();

  String get fullName => profileService.fullName;
  String get avatarUrl => profileService.avatarUrl;
  bool get isLoading => profileService.isLoading;
  String? get errorMessage => profileService.errorMessage;
}

String _assetForSport(String iconKey) {
  final key = iconKey.trim();
  switch (key.toLowerCase().replaceAll('-', '_').replaceAll(' ', '_')) {
    case 'football':
    case 'soccer':
      return AppAssets.footBallIcon;
    case 'basketball':
      return AppAssets.basketBallIcon;
    case 'tennis':
    case 'table_tennis':
    case 'badminton':
    case 'padel':
    case 'squash':
      return AppAssets.tableTennisIcon;
    case 'volleyball':
      return AppAssets.volleyBallIcon;
    case 'cricket':
      return AppAssets.batIcon;
    default:
      return AppAssets.footBallIcon;
  }
}
