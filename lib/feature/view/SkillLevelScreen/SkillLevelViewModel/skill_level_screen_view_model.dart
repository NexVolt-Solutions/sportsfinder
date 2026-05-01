import 'package:flutter/foundation.dart';
import 'package:sport_finding/Data/model/Option/options_model.dart';
import 'package:sport_finding/core/Network/platform_options_store.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_text.dart';

class SkillLevelScreenViewModel extends ChangeNotifier {

  void _log(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }

  int selectedIndex = -1;
  bool isLoading = false;

  bool get hasSelection => selectedIndex >= 0;

  OptionsModel? _optionsModel;

  /// ONLY API TEXT
  List<String> skills = [];

  SkillLevelScreenViewModel() {
    fetchSkills();
  }

  /// Fetch API
  Future<void> fetchSkills() async {
    _log("========== FETCH SKILLS API ==========");
    isLoading = true;
    notifyListeners();

    try {
      final response = await PlatformOptionsStore.instance.load();

      _optionsModel = response;
      skills = response.skills;

      _log("Skills from API: $skills");
      _log("========== FETCH SUCCESS ==========");
    } catch (e, stackTrace) {
      _log("========== FETCH ERROR ==========");
      _log("Error: $e");
      _log("StackTrace: $stackTrace");

      skills = [];
    }

    isLoading = false;
    notifyListeners();
  }

  void selectSkill(int index) {
    selectedIndex = index;

    _log("========== SKILL SELECTED ==========");
    _log("Index: $index");
    _log("Skill: ${skills[index]}");

    notifyListeners();
  }

  /// STATIC IMAGE (NO API)
  String getImage(String skill) {
    switch (skill.toLowerCase()) {
      case 'beginner':
        return AppAssets.beginnerIcon;
      case 'intermediate':
        return AppAssets.intermidateIcon;
      case 'advanced':
        return AppAssets.advanceIcon;
      default:
        return AppAssets.beginnerIcon;
    }
  }

  /// STATIC SUBTITLE (NO API)
  String getSubtitle(String skill) {
    switch (skill.toLowerCase()) {
      case 'beginner':
        return AppText.casualPlayer;
      case 'intermediate':
        return AppText.regularPlayer;
      case 'advanced':
        return AppText.competitiveAthlete;
      default:
        return '';
    }
  }

  String? get selectedSkill {
    if (hasSelection) {
      return skills[selectedIndex];
    }
    return null;
  }

  OptionsModel? get optionsModel => _optionsModel;
}
