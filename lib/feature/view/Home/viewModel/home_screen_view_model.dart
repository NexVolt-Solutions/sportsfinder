import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/feature/model/discovery_match.dart';
import 'package:sport_finding/feature/model/match.dart';
import 'package:sport_finding/feature/model/sport.dart';

class HomeScreenViewModel extends ChangeNotifier {
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

  final List<DiscoveryMatch> descoverMatchData = [
    DiscoveryMatch(
      id: '1',
      title: 'Rimsha Match',
      distanceKm: 2.5,
      sportType: AppText.basketball,
      location: 'Central Park Court',
      dateTime: '16/03/2026, 7:00 PM',
      participantsJoined: 10,
      participantsTotal: 10,
    ),
    DiscoveryMatch(
      id: '2',
      title: 'Shehzad Match',
      distanceKm: 2.5,
      sportType: AppText.tennis,
      location: 'Peshawar',
      dateTime: '15/06/2026, 7:35 PM',
      participantsJoined: 5,
      participantsTotal: 10,
    ),
    DiscoveryMatch(
      id: '3',
      title: 'Faiz Match',
      distanceKm: 2.5,
      sportType: AppText.football,
      location: 'Tatarak Park Court',
      dateTime: '16/07/2026, 9:00 PM',
      participantsJoined: 9,
      participantsTotal: 10,
    ),
    DiscoveryMatch(
      id: '4',
      title: 'Awais Match',
      distanceKm: 2.5,
      sportType: AppText.volleyball,
      location: 'Gul Bahr',
      dateTime: '16/08/2026, 9:30 PM',
      participantsJoined: 10,
      participantsTotal: 10,
    ),
  ];
}
