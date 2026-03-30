import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/discovery_match_data.dart';
import 'package:sport_finding/feature/model/discovery_match.dart';
import 'package:sport_finding/feature/model/match_filters.dart';
import 'package:sport_finding/feature/model/up_coming.dart';
import 'package:sport_finding/feature/view/Home/viewModel/upcoming_matches_scope.dart';

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

  List<DiscoveryMatch> _baseListForChips() {
    if (selectedIndex == 0) {
      return List<DiscoveryMatch>.from(allMatches);
    }
    final filterType = upComingMatchesText[selectedIndex].text;
    return allMatches
        .where(
          (match) => match.sportType.toLowerCase() == filterType.toLowerCase(),
        )
        .toList();
  }

  void _rebuildMatches() {
    final base = _baseListForChips();
    matches = currentFilters != null
        ? applyFilterDataToMatches(base, currentFilters!)
        : List<DiscoveryMatch>.from(base);
  }

  void filterMatches(int index) {
    selectedIndex = index;
    _rebuildMatches();
    notifyListeners();
  }

  void searchMatches(String query) {
    if (query.isEmpty) {
      filterMatches(selectedIndex);
      return;
    }
    final base = _baseListForChips();
    final afterSheet = currentFilters != null
        ? applyFilterDataToMatches(base, currentFilters!)
        : List<DiscoveryMatch>.from(base);
    final q = query.toLowerCase();
    matches = afterSheet
        .where(
          (match) =>
              match.title.toLowerCase().contains(q) ||
              match.sportType.toLowerCase().contains(q) ||
              match.location.toLowerCase().contains(q),
        )
        .toList();
    notifyListeners();
  }

  void applyFilters(FilterData filterData) {
    currentFilters = filterData.isEffectivelyEmpty ? null : filterData;
    _rebuildMatches();
    notifyListeners();
  }
}
