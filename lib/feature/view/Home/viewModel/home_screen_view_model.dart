import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/discovery_match_data.dart';
import 'package:sport_finding/Data/model/discovery_match.dart';
import 'package:sport_finding/Data/model/match.dart';
import 'package:sport_finding/Data/model/sport.dart';

class HomeScreenViewModel extends ChangeNotifier {
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
}
