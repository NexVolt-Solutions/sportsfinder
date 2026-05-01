import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sport_finding/Data/model/all_matches_model.dart';
import 'package:sport_finding/Data/model/discovery_match.dart';
import 'package:sport_finding/Data/model/match_filters.dart';
import 'package:sport_finding/Data/Repositories/matches_repo.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Network/profile_service.dart';

class SportFilterChip {
  const SportFilterChip({required this.label, this.sportKey});

  final String label;

  final String? sportKey;
}

class DiscoveryTabViewModel extends ChangeNotifier {
  DiscoveryTabViewModel() {
    _profileListener = () {
      scheduleMicrotask(() {
        if (_disposed) return;
        notifyListeners();
      });
    };
    ProfileService().addListener(_profileListener);
    Future.microtask(_loadMatches);
  }

  bool _disposed = false;

  final MatchesRepo _repo = MatchesRepo();
  final TextEditingController searchController = TextEditingController();

  late final VoidCallback _profileListener;

  /// Raw API rows (all statuses / times); host filter uses [ProfileService].
  List<AllMatches> _apiItems = [];

  bool isLoading = false;
  String? error;

  final List<SportFilterChip> filterChips = const [
    SportFilterChip(label: AppText.football),
    SportFilterChip(label: AppText.football, sportKey: AppText.football),
    SportFilterChip(label: AppText.basketball, sportKey: AppText.basketball),
    SportFilterChip(label: AppText.tennis, sportKey: AppText.tennis),
    SportFilterChip(label: AppText.volleyball, sportKey: AppText.volleyball),
  ];

  int _selectedFilterIndex = 0;
  FilterData? currentFilters;

  Future<void> _loadMatches() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final ps = ProfileService();
      if (ps.profile == null && !ps.isLoading) {
        try {
          await ps.fetchMyProfile();
        } catch (_) {}
      }

      final List<AllMatches> acc = [];
      var page = 1;
      const limit = 50;
      const maxPages = 40;

      while (page <= maxPages) {
        final res = await _repo.getAllMatches(page: page, limit: limit);
        acc.addAll(res.items);
        if (!res.hasNext || res.items.isEmpty) break;
        page++;
      }

      _apiItems = acc;
      error = null;
    } catch (e) {
      error = e.toString();
      _apiItems = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Maps API rows to [DiscoveryMatch], excluding games **hosted** by the current user.
  List<DiscoveryMatch> get _baseDiscoverMatches {
    final myId = ProfileService().profile?.id.trim();
    return _apiItems
        .where(
          (m) =>
              myId == null ||
              myId.isEmpty ||
              m.host.id.trim().isEmpty ||
              m.host.id.trim() != myId,
        )
        .map(DiscoveryMatch.fromAllMatches)
        .where((m) => !m.isHostedByCurrentUser)
        .toList();
  }

  List<DiscoveryMatch> get filteredMatches {
    final query = searchController.text.trim().toLowerCase();
    final chip = filterChips[_selectedFilterIndex];
    var list = _baseDiscoverMatches;

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

  Future<void> refresh() => _loadMatches();

  @override
  void dispose() {
    _disposed = true;
    ProfileService().removeListener(_profileListener);
    searchController.dispose();
    super.dispose();
  }
}
