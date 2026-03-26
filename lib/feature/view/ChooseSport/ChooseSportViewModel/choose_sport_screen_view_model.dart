import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/feature/model/sport.dart';

class ChooseSportScreenViewModel extends ChangeNotifier {
  int selectedIndex = -1;

  bool get hasSelection => selectedIndex >= 0;

  final List<Sport> sports = [
    Sport(imagePath: AppAssets.footBallIcon, title: AppText.football),
    Sport(imagePath: AppAssets.basketBallIcon, title: AppText.basketball),
    Sport(imagePath: AppAssets.tableTennisIcon, title: AppText.tennis),
    Sport(imagePath: AppAssets.volleyBallIcon, title: AppText.volleyball),
    Sport(imagePath: AppAssets.batIcon, title: AppText.cricket),
  ];

  void selectSkill(int index) {
    selectedIndex = index;
    notifyListeners();
  }
}
