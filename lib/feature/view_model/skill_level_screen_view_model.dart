import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/feature/model/skill_level.dart';

class SkillLevelScreenViewModel extends ChangeNotifier {
  int selectedIndex = -1;

  bool get hasSelection => selectedIndex >= 0;

  final List<SkillLevel> skillLevels = [
    SkillLevel(
      imagePath: AppAssets.beginnerIcon,
      title: AppText.beginner,
      subTitle: AppText.casualPlayer,
    ),
    SkillLevel(
      imagePath: AppAssets.intermidateIcon,
      title: AppText.intermediate,
      subTitle: AppText.regularPlayer,
    ),
    SkillLevel(
      imagePath: AppAssets.advanceIcon,
      title: AppText.advanced,
      subTitle: AppText.competitiveAthlete,
    ),
  ];

  void selectSkill(int index) {
    selectedIndex = index;
    notifyListeners();
  }
}
