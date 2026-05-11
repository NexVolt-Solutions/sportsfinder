import 'package:flutter/foundation.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
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
      final sportsList = o.sportOptions;

      _log("Raw Sports Response: $sportsList");

      sports = sportsList.map((sport) {
        return Sport(
          id: sport.id,
          iconKey: sport.iconKey,
          category: sport.category,
          isPopular: sport.isPopular,
          imagePath: _getImageForSport(sport.iconKey),
          title: sport.name,
        );
      }).toList();

      _log("Mapped Sports: ${sports.map((e) => e.title).toList()}");
      _log("========== FETCH SPORTS SUCCESS ==========");
    } catch (e, stackTrace) {
      errorMessage = e.toString();

      _log("========== FETCH SPORTS ERROR ==========");
      _log("Error: $e");
      _log("StackTrace: $stackTrace");
      sports = [];
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
  String _getImageForSport(String iconKey) {
    final key = iconKey.trim();
    switch (key.toLowerCase().replaceAll('-', '_').replaceAll(' ', '_')) {
      case 'football':
      case 'soccer':
        return AppAssets.footBallIcon;
      case 'basketball':
        return AppAssets.basketBallIcon;
      case 'tennis':
      case 'table_tennis':
        return AppAssets.tableTennisIcon;
      case 'volleyball':
        return AppAssets.volleyBallIcon;
      case 'badminton':
      case 'padel':
      case 'squash':
        return AppAssets.tableTennisIcon;
      case 'cricket':
        return AppAssets.batIcon;
      default:
        return AppAssets.footBallIcon;
    }
  }

  String? get selectedSport {
    if (hasSelection && selectedIndex < sports.length) {
      return sports[selectedIndex].id;
    }
    return null;
  }
}
