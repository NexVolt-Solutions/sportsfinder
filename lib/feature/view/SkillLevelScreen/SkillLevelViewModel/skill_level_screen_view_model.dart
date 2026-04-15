// import 'package:flutter/material.dart';
// import 'package:sport_finding/core/Constants/app_assets.dart';
// import 'package:sport_finding/core/Constants/app_text.dart';
// import 'package:sport_finding/Data/model/skill_level.dart';

// class SkillLevelScreenViewModel extends ChangeNotifier {
//   int selectedIndex = -1;

//   bool get hasSelection => selectedIndex >= 0;

//   final List<SkillLevel> skillLevels = [
//     SkillLevel(
//       imagePath: AppAssets.beginnerIcon,
//       title: AppText.beginner,
//       subTitle: AppText.casualPlayer,
//     ),
//     SkillLevel(
//       imagePath: AppAssets.intermidateIcon,
//       title: AppText.intermediate,
//       subTitle: AppText.regularPlayer,
//     ),
//     SkillLevel(
//       imagePath: AppAssets.advanceIcon,
//       title: AppText.advanced,
//       subTitle: AppText.competitiveAthlete,
//     ),
//   ];

//   void selectSkill(int index) {
//     selectedIndex = index;
//     notifyListeners();
//   }
// }
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sport_finding/Data/repositories/options_repository.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/Data/model/options_model.dart';

class SkillLevelScreenViewModel extends ChangeNotifier {
  final OptionsRepository _repository = OptionsRepository();

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
      final response = await _repository.getOptions();

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
