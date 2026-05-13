import 'package:flutter/material.dart';
import 'package:sport_finding/Data/Repositories/DeleteMatch/delete_match_repo.dart';
import 'package:sport_finding/Data/Repositories/matches_repo.dart';
import 'package:sport_finding/Data/model/all_matches_model.dart';
import 'package:sport_finding/Data/model/match_filters.dart';
import 'package:sport_finding/core/Network/deleted_matches_service.dart';
import 'package:sport_finding/core/Network/profile_service.dart';
import 'package:sport_finding/core/Storage/app_preferences.dart';
import 'package:sport_finding/core/utils/api_error_message.dart';
import 'package:sport_finding/core/utils/geo_distance.dart';
import 'package:sport_finding/core/utils/match_list_refresh_coordinator.dart';
import 'package:sport_finding/feature/view/Home/viewModel/upcoming_matches_scope.dart';

class AllUpcommingMatchesViewModel extends ChangeNotifier {
  final MatchesRepo _repo = MatchesRepo();
  final DeleteMatchRepo _deleteRepo = DeleteMatchRepo();

  List<AllMatches> allMatches = [];
  List<AllMatches> matches = [];

  bool isLoading = false;
  String? error;
  bool hasFetchedOnce = false;

  int selectedIndex = 0;
  FilterData? currentFilters;

  String _searchQuery = '';

  String get lastSearchQuery => _searchQuery;

  bool get hasAnyMatchesInCurrentScope => _scopedBaseMatches().isNotEmpty;

  bool get showSearchOrFilterEmptyState {
    if (matches.isNotEmpty) return false;
    if (_searchQuery.isNotEmpty) return true;
    if (hasAnyMatchesInCurrentScope &&
        currentFilters != null &&
        !currentFilters!.isEffectivelyEmpty) {
      return true;
    }
    return false;
  }

  final UpcomingMatchesScope scope;

  UpcomingMatchesScope get listScope => scope;

  int page = 1;
  bool hasNext = true;
  bool _isDisposed = false;

  double? _viewerLat;
  double? _viewerLng;

  Future<void> _refreshViewerLocation() async {
    final loc = await AppPreferences.getCurrentLocation();
    if (_isDisposed) return;
    _viewerLat = loc?.$1;
    _viewerLng = loc?.$2;
  }

  AllUpcommingMatchesViewModel({
    this.scope = UpcomingMatchesScope.allUpcoming,
  }) {
    DeletedMatchesService().addListener(_onDeletedMatchesChanged);
    ProfileService().addListener(_onProfileChanged);
    MatchListRefreshCoordinator.register(_onExternalListRefresh);
  }

  void _onExternalListRefresh() {
    if (_isDisposed) return;
    fetchMatches(reset: true);
  }

  void _onDeletedMatchesChanged() {
    _rebuildVisibleMatches();
    notifyListeners();
  }

  void _onProfileChanged() {
    if (scope != UpcomingMatchesScope.myMatches) return;
    Future<void>.microtask(() {
      if (_isDisposed) return;
      _rebuildVisibleMatches();
      notifyListeners();
    });
  }

  void applyPrefetchedMatches(List<AllMatches> items, {bool? hasNext}) {
    allMatches = List<AllMatches>.from(items);
    page = 1;
    this.hasNext = hasNext ?? items.length >= 20;
    isLoading = false;
    hasFetchedOnce = true;
    error = null;
    _rebuildVisibleMatches();
    notifyListeners();
    _prefetchViewerLocationAndRebuild();
  }

  Future<void> _prefetchViewerLocationAndRebuild() async {
    await _refreshViewerLocation();
    if (_isDisposed) return;
    _rebuildVisibleMatches();
    notifyListeners();
  }

  Future<void> fetchMatches({bool reset = false}) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      await _refreshViewerLocation();

      if (reset) {
        page = 1;
        allMatches.clear();
        matches.clear();
        hasNext = true;
      }

      if (scope == UpcomingMatchesScope.allUpcoming) {
        final allRes = await _repo.getAllMatches(page: page, type: 'all');
        final myRes = await _repo.getAllMatches(page: page, type: 'my');
        final merged = <String, AllMatches>{};
        for (final m in allRes.items) {
          if (!DeletedMatchesService().isDeleted(m.id)) {
            merged[m.id] = m;
          }
        }
        for (final m in myRes.items) {
          if (!DeletedMatchesService().isDeleted(m.id)) {
            merged[m.id] = m;
          }
        }
        allMatches.addAll(merged.values);
        hasNext = allRes.hasNext || myRes.hasNext;
      } else {
        final myRes = await _repo.getAllMatches(page: page, type: 'my');
        final allRes = await _repo.getAllMatches(page: page, type: 'all');
        final merged = <String, AllMatches>{};
        for (final m in myRes.items) {
          if (!DeletedMatchesService().isDeleted(m.id)) {
            merged[m.id] = m;
          }
        }
        for (final m in allRes.items) {
          if (!DeletedMatchesService().isDeleted(m.id)) {
            merged[m.id] = m;
          }
        }
        allMatches.addAll(merged.values);
        hasNext = myRes.hasNext || allRes.hasNext;
      }
      _dedupeAllMatchesById();
      _rebuildVisibleMatches();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      hasFetchedOnce = true;
      notifyListeners();
    }
  }

  void searchMatches(String query) {
    _searchQuery = query.trim();
    _rebuildVisibleMatches();
    notifyListeners();
  }

  List<AllMatches> _baseListForChips() {
    final scoped = _scopedBaseMatches();
    if (selectedIndex == 0) return List.from(scoped);

    final sports = ["Football", "Basketball", "Tennis", "Volleyball"];

    if (selectedIndex - 1 >= sports.length) return scoped;

    final sport = sports[selectedIndex - 1];

    return scoped.where((m) {
      return m.sport.toLowerCase() == sport.toLowerCase();
    }).toList();
  }

  void filterMatches(int index) {
    selectedIndex = index;
    _rebuildVisibleMatches();
    notifyListeners();
  }

  // ================= APPLY FILTER SHEET =================
  void applyFilters(FilterData filterData) {
    final before = matches.length;
    final scoped = _scopedBaseMatches().length;
    debugPrint(
      '🎛️ [AllUpcomingVM] applyFilters called (scoped=$scoped, visibleBefore=$before) '
      'filters={sport:${filterData.sportName}, skill:${filterData.skillLevel}, '
      'date:${filterData.date}, time:${filterData.time}, distance:${filterData.distance}} '
      'viewer=(${_viewerLat?.toStringAsFixed(5)},${_viewerLng?.toStringAsFixed(5)})',
    );

    currentFilters = filterData.isEffectivelyEmpty ? null : filterData;
    _rebuildVisibleMatches();
    debugPrint(
      '🎛️ [AllUpcomingVM] applyFilters done (visibleAfter=${matches.length}, currentFiltersNull=${currentFilters == null})',
    );
    notifyListeners();
  }

  List<AllMatches> _applySearchTo(List<AllMatches> input) {
    if (_searchQuery.isEmpty) return List<AllMatches>.from(input);
    final q = _searchQuery.toLowerCase();
    return input.where((m) {
      return m.title.toLowerCase().contains(q) ||
          m.sport.toLowerCase().contains(q) ||
          m.locationName.toLowerCase().contains(q) ||
          m.location.toLowerCase().contains(q);
    }).toList();
  }

  /// Same criteria as [applyFilterDataToMatches] for [DiscoveryMatch], but for [AllMatches].
  List<AllMatches> _applyFilters(List<AllMatches> input) {
    final f = currentFilters;
    if (f == null || f.isEffectivelyEmpty) {
      return List<AllMatches>.from(input);
    }

    return input.where((m) {
      final sport = f.sportName?.trim();
      if (sport != null && sport.isNotEmpty) {
        if (m.sport.trim().toLowerCase() != sport.toLowerCase()) return false;
      }

      final skill = f.skillLevel?.trim();
      if (skill != null && skill.isNotEmpty) {
        if (m.skillLevel.trim().toLowerCase() != skill.toLowerCase()) {
          return false;
        }
      }

      if (f.distance < kMaxFilterDistanceKm - 0.5) {
        final dk = m.distanceKm;
        double? effectiveKm = dk;
        if (effectiveKm == null &&
            _viewerLat != null &&
            _viewerLng != null &&
            m.latitude != null &&
            m.longitude != null) {
          effectiveKm = haversineDistanceKm(
            _viewerLat!,
            _viewerLng!,
            m.latitude!,
            m.longitude!,
          );
        }
        if (effectiveKm != null && effectiveKm > f.distance) return false;
      }

      if (f.date != null) {
        final d = f.date!;
        final start = m.scheduledStartUtc?.toLocal();
        if (start != null) {
          if (start.year != d.year ||
              start.month != d.month ||
              start.day != d.day) {
            return false;
          }
        }
      }

      if (f.time != null) {
        final t = f.time!;
        final start = m.scheduledStartUtc?.toLocal();
        if (start != null) {
          if (start.hour != t.hour || start.minute != t.minute) return false;
        }
      }

      return true;
    }).toList();
  }

  Future<void> loadMore() async {
    if (!hasNext || isLoading) return;

    try {
      isLoading = true;
      notifyListeners();
      await _refreshViewerLocation();
      page++;

      if (scope == UpcomingMatchesScope.allUpcoming) {
        final allRes = await _repo.getAllMatches(page: page, type: 'all');
        final myRes = await _repo.getAllMatches(page: page, type: 'my');
        final merged = <String, AllMatches>{};
        for (final m in allRes.items) {
          if (!DeletedMatchesService().isDeleted(m.id)) {
            merged[m.id] = m;
          }
        }
        for (final m in myRes.items) {
          if (!DeletedMatchesService().isDeleted(m.id)) {
            merged[m.id] = m;
          }
        }
        allMatches.addAll(merged.values);
        hasNext = allRes.hasNext || myRes.hasNext;
      } else {
        // Keep behavior consistent with initial fetch for My Matches.
        final myRes = await _repo.getAllMatches(page: page, type: 'my');
        final allRes = await _repo.getAllMatches(page: page, type: 'all');
        final merged = <String, AllMatches>{};
        for (final m in myRes.items) {
          if (!DeletedMatchesService().isDeleted(m.id)) {
            merged[m.id] = m;
          }
        }
        for (final m in allRes.items) {
          if (!DeletedMatchesService().isDeleted(m.id)) {
            merged[m.id] = m;
          }
        }
        allMatches.addAll(merged.values);
        hasNext = myRes.hasNext || allRes.hasNext;
      }
      _dedupeAllMatchesById();
      _rebuildVisibleMatches();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
    }

    notifyListeners();
  }

  void removeMatchById(String matchId) {
    final trimmedId = matchId.trim();
    if (trimmedId.isEmpty) return;

    allMatches.removeWhere((m) => m.id == trimmedId);
    matches.removeWhere((m) => m.id == trimmedId);
    DeletedMatchesService().markDeleted(trimmedId);
    notifyListeners();
  }

  /// Deletes on the server, then removes locally. Returns `null` on success,
  /// or an error message string on failure.
  Future<String?> deleteMatchById(String matchId) async {
    if (_isDisposed) return 'Not available';
    final trimmedId = matchId.trim();
    if (trimmedId.isEmpty) return 'Match ID is missing';

    try {
      await _deleteRepo.deleteMatch(matchId: trimmedId);
      if (_isDisposed) return null;
      removeMatchById(trimmedId);
      return null;
    } catch (e) {
      return messageFromApiException(e);
    }
  }

  List<AllMatches> _scopedBaseMatches() {
    final nowUtc = DateTime.now().toUtc();
    final visible = allMatches.where((m) {
      if (DeletedMatchesService().isDeleted(m.id)) return false;
      // Upcoming list should only show matches scheduled in the future.
      if (scope == UpcomingMatchesScope.allUpcoming) {
        final start = m.scheduledStartUtc;
        if (start == null) return false;
        return start.isAfter(nowUtc);
      }
      return true;
    });

    if (scope != UpcomingMatchesScope.myMatches) {
      return visible.toList();
    }

    final myId = ProfileService().profile?.id.trim();
    if (myId == null || myId.isEmpty) {
      return visible.toList();
    }

    return visible.where((m) => m.host.id.trim() == myId).toList();
  }

  void _rebuildVisibleMatches() {
    final base = _baseListForChips();
    matches = _applySearchTo(_applyFilters(base));
  }

  void _dedupeAllMatchesById() {
    if (allMatches.isEmpty) return;
    final deduped = <String, AllMatches>{};
    for (final match in allMatches) {
      deduped[match.id] = match;
    }
    allMatches = deduped.values.toList();
  }

  @override
  void dispose() {
    _isDisposed = true;
    MatchListRefreshCoordinator.unregister(_onExternalListRefresh);
    DeletedMatchesService().removeListener(_onDeletedMatchesChanged);
    ProfileService().removeListener(_onProfileChanged);
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (_isDisposed) return;
    super.notifyListeners();
  }
}
