import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/feature/model/discovery_match.dart';
import 'package:sport_finding/feature/model/up_coming.dart';

class AllUpcommingMatchesViewModel extends ChangeNotifier {
  final List<UpComing> upComingMatchesText = [
    UpComing(text: AppText.all),
    UpComing(text: AppText.football),
    UpComing(text: AppText.basketball),
    UpComing(text: AppText.tennis),
    UpComing(text: AppText.volleyball),
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
