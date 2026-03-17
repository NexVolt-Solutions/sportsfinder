import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/feature/model/match.dart';

class HomeScreenViewModel extends ChangeNotifier {
  final List<Match> matcheData = [
    Match(imagePath: AppAssets.addIcon, title: AppText.createMatchTitle),
    Match(imagePath: AppAssets.matchesIcon, title: AppText.findAMatch),
  ];
}
