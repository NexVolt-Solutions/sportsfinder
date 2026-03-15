import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_text.dart';

class ChooseSportScreenViewModel extends ChangeNotifier {
  int selectedIndex = -1;

  List<Map<String, dynamic>> skillLevelData = [
    {'Image': AppAssets.footBallIcon, 'title': AppText.football},
    {'Image': AppAssets.basketBallIcon, 'title': AppText.basketball},
    {'Image': AppAssets.tableTennisIcon, 'title': AppText.tennis},
    {'Image': AppAssets.volleyBallIcon, 'title': AppText.volleyball},
    {'Image': AppAssets.batIcon, 'title': AppText.cricket},
  ];

  void selectSkill(int index) {
    selectedIndex = index;
    notifyListeners();
  }
}
