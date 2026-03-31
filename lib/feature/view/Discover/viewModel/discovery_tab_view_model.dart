import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/discovery_match_data.dart';
import 'package:sport_finding/Data/model/discovery_match.dart';
import 'package:sport_finding/Data/model/match_filters.dart';

class SportFilterChip {
  const SportFilterChip({required this.label, this.sportKey});

  final String label;

  /// If null, means "All" (no sport filter).
  final String? sportKey;
}

class DiscoveryTabViewModel extends ChangeNotifier {
  DiscoveryTabViewModel();

  final TextEditingController searchController = TextEditingController();
  final List<SportFilterChip> filterChips = const [
    SportFilterChip(label: AppText.football),
    SportFilterChip(label: AppText.football, sportKey: AppText.football),
    SportFilterChip(label: AppText.basketball, sportKey: AppText.basketball),
    SportFilterChip(label: AppText.tennis, sportKey: AppText.tennis),
    SportFilterChip(label: AppText.volleyball, sportKey: AppText.volleyball),
  ];

  final List<DiscoveryMatch> _allMatches =
      List<DiscoveryMatch>.from(DiscoveryMatchData.allMatches)
          .where(
            (m) =>
                !m.involvesCurrentUser &&
                m.isUpcomingRelativeTo(DateTime.now()),
          )
          .toList();
  int _selectedFilterIndex = 0;
  FilterData? currentFilters;

  List<DiscoveryMatch> get filteredMatches {
    final query = searchController.text.trim().toLowerCase();
    final chip = filterChips[_selectedFilterIndex];
    var list = _allMatches;

    if (chip.sportKey != null) {
      list = list
          .where(
            (m) => m.sportType.toLowerCase() == chip.sportKey!.toLowerCase(),
          )
          .toList();
    }
    if (query.isNotEmpty) {
      list = list.where((m) {
        return m.title.toLowerCase().contains(query) ||
            m.sportType.toLowerCase().contains(query) ||
            m.location.toLowerCase().contains(query);
      }).toList();
    }
    if (currentFilters != null) {
      list = applyFilterDataToMatches(list, currentFilters!);
    }
    return list;
  }

  int get selectedFilterIndex => _selectedFilterIndex;

  void setSelectedFilterIndex(int index) {
    if (_selectedFilterIndex == index) return;
    _selectedFilterIndex = index;
    notifyListeners();
  }

  void onSearchChanged() {
    notifyListeners();
  }

  void applyFilters(FilterData filterData) {
    currentFilters = filterData.isEffectivelyEmpty ? null : filterData;
    notifyListeners();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
