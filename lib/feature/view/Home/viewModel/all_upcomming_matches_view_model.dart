import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/discovery_match_data.dart';
import 'package:sport_finding/feature/model/discovery_match.dart';
import 'package:sport_finding/feature/model/up_coming.dart';
import 'package:sport_finding/feature/view/Home/viewModel/upcoming_matches_scope.dart';
import 'package:sport_finding/feature/widget/filter_bottom_sheet_widget.dart';

class AllUpcommingMatchesViewModel extends ChangeNotifier {
  final List<UpComing> upComingMatchesText = [
    UpComing(text: AppText.all),
    UpComing(text: AppText.football),
    UpComing(text: AppText.basketball),
    UpComing(text: AppText.tennis),
    UpComing(text: AppText.volleyball),
  ];

  final UpcomingMatchesScope scope;

  UpcomingMatchesScope get listScope => scope;

  List<DiscoveryMatch> allMatches = [];
  List<DiscoveryMatch> matches = [];

  int selectedIndex = 0;
  FilterData? currentFilters;

  AllUpcommingMatchesViewModel({
    this.scope = UpcomingMatchesScope.allUpcoming,
  }) {
    final raw = DiscoveryMatchData.allMatches;
    final now = DateTime.now();
    allMatches = switch (scope) {
      UpcomingMatchesScope.myMatches =>
        raw.where((m) => m.isHostedByCurrentUser).toList(),
      // Future starts only; includes your hosted matches and everyone else's.
      UpcomingMatchesScope.allUpcoming =>
        raw.where((m) => m.isUpcomingRelativeTo(now)).toList(),
    };
    if (scope == UpcomingMatchesScope.allUpcoming) {
      allMatches.sort((a, b) {
        if (a.isHostedByCurrentUser == b.isHostedByCurrentUser) return 0;
        return a.isHostedByCurrentUser ? -1 : 1;
      });
    }
    matches = List.from(allMatches);
  }

  void filterMatches(int index) {
    selectedIndex = index;
    if (index == 0) {
      matches = List.from(allMatches);
    } else {
      final filterType = upComingMatchesText[index].text;
      matches = allMatches
          .where(
            (match) =>
                match.sportType.toLowerCase() == filterType.toLowerCase(),
          )
          .toList();
    }

    // Apply additional filters if they exist
    if (currentFilters != null) {
      _applyAdditionalFilters();
    }

    notifyListeners();
  }

  void searchMatches(String query) {
    if (query.isEmpty) {
      filterMatches(selectedIndex);
    } else {
      final base = _baseListForFilters();
      matches = base
          .where(
            (match) =>
                match.title.toLowerCase().contains(query.toLowerCase()) ||
                match.sportType.toLowerCase().contains(query.toLowerCase()) ||
                match.location.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
      notifyListeners();
    }
  }

  List<DiscoveryMatch> _baseListForFilters() {
    if (selectedIndex == 0) {
      return List.from(allMatches);
    }
    final filterType = upComingMatchesText[selectedIndex].text;
    return allMatches
        .where(
          (match) => match.sportType.toLowerCase() == filterType.toLowerCase(),
        )
        .toList();
  }

  void applyFilters(FilterData filterData) {
    currentFilters = filterData;
    matches = List.from(allMatches);

    // Filter by sport type
    if (filterData.sportIndex != null) {
      final sports = ['Football', 'Volleyball', 'Cricket'];
      final selectedSport = sports[filterData.sportIndex!];
      matches = matches
          .where((match) => match.sportType == selectedSport)
          .toList();
    }

    // Filter by skill level
    if (filterData.skillLevel != null) {
      matches = matches
          .where((match) => AppText.skillLevel == filterData.skillLevel)
          .toList();
    }

    // Filter by distance (if you have location data)
    // matches = matches
    //     .where((match) => match.distance <= filterData.distance)
    //     .toList();

    // Filter by date
    if (filterData.date != null) {
      matches = matches
          .where(
            (match) =>
                match.date == filterData.date!.year &&
                match.date == filterData.date!.month &&
                match.date == filterData.date!.day,
          )
          .toList();
    }

    notifyListeners();
  }

  void _applyAdditionalFilters() {
    if (currentFilters != null) {
      applyFilters(currentFilters!);
    }
  }
}
