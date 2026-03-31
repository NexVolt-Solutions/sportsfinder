import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/discovery_match_data.dart';
import 'package:sport_finding/Data/model/discovery_match.dart';
import 'package:sport_finding/Data/model/match_filters.dart';

class FilterOption {
  final String text;
  FilterOption({required this.text});
}

class AllMemberScreenViewModel extends ChangeNotifier {
  List<DiscoveryMatch> allMatches = DiscoveryMatchData.allMatches;
  late List<DiscoveryMatch> matches = List<DiscoveryMatch>.from(allMatches);

  int selectedIndex = 0;
  FilterData? currentFilters;

  List<FilterOption> get upComingMatchesText => [
    FilterOption(text: 'All'),
    FilterOption(text: 'Football'),
    FilterOption(text: 'Volleyball'),
    FilterOption(text: 'Tennis'),
  ];

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
