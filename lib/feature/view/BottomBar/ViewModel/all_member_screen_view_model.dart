import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/discovery_match_data.dart';
import 'package:sport_finding/feature/model/discovery_match.dart';
import 'package:sport_finding/feature/widget/filter_bottom_sheet_widget.dart';

class FilterOption {
  final String text;
  FilterOption({required this.text});
}

class AllMemberScreenViewModel extends ChangeNotifier {
  List<DiscoveryMatch> allMatches = DiscoveryMatchData.allMatches;
  List<DiscoveryMatch> matches = [];

  int selectedIndex = 0;
  FilterData? currentFilters;

  List<FilterOption> get upComingMatchesText => [
    FilterOption(text: 'All'),
    FilterOption(text: 'Football'),
    FilterOption(text: 'Volleyball'),
    FilterOption(text: 'Cricket'),
  ];

  void AllUpcommingMatchesViewModel() {
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
      matches = allMatches
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

  // List<DiscoveryMatch> allMatches = DiscoveryMatchData.allMatches;
}
