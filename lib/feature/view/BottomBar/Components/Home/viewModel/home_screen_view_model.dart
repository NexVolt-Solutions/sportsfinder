import 'package:flutter/material.dart';
import 'package:sport_finding/Data/Repositories/my_profile_Repository.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/discovery_match_data.dart';
import 'package:sport_finding/Data/model/discovery_match.dart';
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
  }

  void _onProfileServiceChanged() {
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

  /// Future matches only; **your hosted rows first** so the hosting badge is visible
  /// on the home carousel without scrolling past many other hosts’ games.
  late final List<DiscoveryMatch> matches = _loadUpcomingMatches();

  List<DiscoveryMatch> _loadUpcomingMatches() {
    final now = DateTime.now();
    final list =
        DiscoveryMatchData.allMatches
            .where((m) => m.isUpcomingRelativeTo(now))
            .toList()
          ..sort((a, b) {
            if (a.isHostedByCurrentUser == b.isHostedByCurrentUser) return 0;
            return a.isHostedByCurrentUser ? -1 : 1;
          });
    return list;
  }

  ProfileService get profileService => ProfileService();

  String get fullName => profileService.fullName;
  String get avatarUrl => profileService.avatarUrl;
  bool get isLoading => profileService.isLoading;
  String? get errorMessage => profileService.errorMessage;

  // // --- profile ---
  // MyProfileModel? profile;
  // bool isLoading = false;
  // String? errorMessage;

  // HomeScreenViewModel.withInit({required this.repository}) {
  //   _init();
  // }

  // void _init() {
  //   fetchMyProfile();
  // }

  // Future<void> fetchMyProfile() async {
  //   isLoading = true;
  //   errorMessage = null;
  //   notifyListeners();

  //   try {
  //           final  token = await SharedPreferences.getInstance().then((prefs) => prefs.getString('authToken'));
  //     final response = await repository.getMyProfile(token: token);
  //     log('Profile API Response: $response');

  //     if (response != null) {
  //       profile = MyProfileModel.fromJson(response);
  //       log('Profile loaded: ${profile?.fullName}');
  //     }
  //   } catch (e) {
  //     errorMessage = e.toString();
  //     log('Error fetching profile: $errorMessage');
  //   } finally {
  //     isLoading = false;
  //     notifyListeners();
  //   }
  // }
}
