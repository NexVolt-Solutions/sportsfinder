// import 'package:flutter/material.dart';
// import 'package:sport_finding/core/Constants/app_assets.dart';
// import 'package:sport_finding/core/Constants/app_text.dart';
// import 'package:sport_finding/Data/model/sport.dart';

// class ChooseSportScreenViewModel extends ChangeNotifier {
//   int selectedIndex = -1;

//   bool get hasSelection => selectedIndex >= 0;

//   final List<Sport> sports = [
//     Sport(imagePath: AppAssets.footBallIcon, title: AppText.football),
//     Sport(imagePath: AppAssets.basketBallIcon, title: AppText.basketball),
//     Sport(imagePath: AppAssets.tableTennisIcon, title: AppText.tennis),
//     Sport(imagePath: AppAssets.volleyBallIcon, title: AppText.volleyball),
//     Sport(imagePath: AppAssets.batIcon, title: AppText.cricket),
//   ];

//   void selectSkill(int index) {
//     selectedIndex = index;
//     notifyListeners();
//   }
// }
import 'package:flutter/foundation.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/Data/model/sport.dart';
import 'package:sport_finding/core/Network/platform_options_store.dart';

class ChooseSportScreenViewModel extends ChangeNotifier {

  void _log(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }

  int selectedIndex = -1;
  bool isLoading = false;
  String? errorMessage;

  bool get hasSelection => selectedIndex >= 0;

  List<Sport> sports = [];

  ChooseSportScreenViewModel() {
    fetchSports();
  }

  /// Fetch sports from API
  Future<void> fetchSports() async {
    _log("========== FETCH SPORTS REQUEST ==========");
    isLoading = true;
    notifyListeners();

    try {
      final o = await PlatformOptionsStore.instance.load();
      final sportsList = o.sports;

      _log("Raw Sports Response: $sportsList");

      sports = sportsList.map((sport) {
        return Sport(
          imagePath: _getImageForSport(sport),
          title: _getTitleForSport(sport),
        );
      }).toList();

      _log("Mapped Sports: ${sports.map((e) => e.title).toList()}");
      _log("========== FETCH SPORTS SUCCESS ==========");
    } catch (e, stackTrace) {
      errorMessage = e.toString();

      _log("========== FETCH SPORTS ERROR ==========");
      _log("Error: $e");
      _log("StackTrace: $stackTrace");

      sports = _defaultSports();
      _log("Fallback to default sports list");
    }

    isLoading = false;
    notifyListeners();
    _log("Loading finished");
  }

  /// Handle selection
  void selectSkill(int index) {
    selectedIndex = index;
    _log("Selected Sport Index: $index");
    _log("Selected Sport: ${sports[index].title}");
    notifyListeners();
  }

  /// Map sport names to assets
  String _getImageForSport(String sport) {
    switch (sport.toLowerCase()) {
      case 'football':
        return AppAssets.footBallIcon;
      case 'basketball':
        return AppAssets.basketBallIcon;
      case 'tennis':
        return AppAssets.tableTennisIcon;
      case 'volleyball':
        return AppAssets.volleyBallIcon;
      case 'badminton':
        return AppAssets.tableTennisIcon;
      case 'cricket':
        return AppAssets.batIcon;
      default:
        return AppAssets.footBallIcon;
    }
  }

  /// Map sport names to titles
  String _getTitleForSport(String sport) {
    switch (sport.toLowerCase()) {
      case 'football':
        return AppText.football;
      case 'basketball':
        return AppText.basketball;
      case 'tennis':
        return AppText.tennis;
      case 'volleyball':
        return AppText.volleyball;
      case 'badminton':
        return AppText.badminton;
      case 'cricket':
        return AppText.cricket;
      default:
        return sport;
    }
  }

  List<Sport> _defaultSports() {
    return [
      Sport(imagePath: AppAssets.footBallIcon, title: AppText.football),
      Sport(imagePath: AppAssets.basketBallIcon, title: AppText.basketball),
      Sport(imagePath: AppAssets.tableTennisIcon, title: AppText.tennis),
      Sport(imagePath: AppAssets.volleyBallIcon, title: AppText.volleyball),
      Sport(imagePath: AppAssets.batIcon, title: AppText.cricket),
    ];
  }

  String? get selectedSport {
    if (hasSelection && selectedIndex < sports.length) {
      return sports[selectedIndex].title;
    }
    return null;
  }
}
