import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_text.dart';

class SkillLevelScreenViewModel extends ChangeNotifier {
  int selectedIndex = -1;

  List<Map<String, dynamic>> skillLevelData = [
    {
      'Image': AppAssets.beginnerIcon,
      'title': AppText.beginner,
      'subTitle': AppText.casualPlayer,
    },
    {
      'Image': AppAssets.intermidateIcon,
      'title': AppText.intermediate,
      'subTitle': AppText.regularPlayer,
    },
    {
      'Image': AppAssets.advanceIcon,
      'title': AppText.advanced,
      'subTitle': AppText.advanced,
    },
  ];

  void selectSkill(int index) {
    selectedIndex = index;
    notifyListeners();
  }
}
