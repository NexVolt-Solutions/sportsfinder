 
import 'package:flutter/material.dart';
import 'package:sport_finding/Data/Repositories/matches_repo.dart';
import 'package:sport_finding/Data/model/all_matches_model.dart';
import 'package:sport_finding/Data/model/match_filters.dart';
import 'package:sport_finding/core/Network/deleted_matches_service.dart';
import 'package:sport_finding/core/Network/profile_service.dart';
import 'package:sport_finding/feature/view/Home/viewModel/upcoming_matches_scope.dart';

class AllUpcommingMatchesViewModel extends ChangeNotifier {
  final MatchesRepo _repo = MatchesRepo();

  // ================= DATA =================
  List<AllMatches> allMatches = [];
  List<AllMatches> matches = [];

  // ================= STATE =================
  bool isLoading = false;
  String? error;
  bool hasFetchedOnce = false;

  // ================= FILTERS =================
  int selectedIndex = 0;
  FilterData? currentFilters;

  final UpcomingMatchesScope scope;

  UpcomingMatchesScope get listScope => scope;

  // ================= PAGINATION =================
  int page = 1;
  bool hasNext = true;
  bool _isDisposed = false;

  AllUpcommingMatchesViewModel({this.scope = UpcomingMatchesScope.allUpcoming}) {
    DeletedMatchesService().addListener(_onDeletedMatchesChanged);
    ProfileService().addListener(_onProfileChanged);
  }

  void _onDeletedMatchesChanged() {
    _rebuildVisibleMatches();
    notifyListeners();
  }

  void _onProfileChanged() {
    if (scope != UpcomingMatchesScope.myMatches) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isDisposed) return;
      _rebuildVisibleMatches();
      notifyListeners();
    });
  }

  /// Seeds lists from Home (or another screen) so the initial GET is skipped.
  void applyPrefetchedMatches(List<AllMatches> items, {bool? hasNext}) {
    allMatches = List<AllMatches>.from(items);
    _rebuildVisibleMatches();
    page = 1;
    this.hasNext = hasNext ?? items.length >= 20;
    isLoading = false;
    hasFetchedOnce = true;
    error = null;
    notifyListeners();
  }

  // ================= FETCH =================
  Future<void> fetchMatches({bool reset = false}) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      if (reset) {
        page = 1;
        allMatches.clear();
        matches.clear();
        hasNext = true;
      }

      if (scope == UpcomingMatchesScope.allUpcoming) {
        final allRes = await _repo.getAllMatches(
          page: page,
          type: 'all',
        );
        final myRes = await _repo.getAllMatches(
          page: page,
          type: 'my',
        );
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
        // Fallback for backends that omit completed/cancelled hosted matches
        // from `type=my`. We merge current page of `type=my` + `type=all`,
        // then host-filter in `_scopedBaseMatches()`.
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

  // ================= SEARCH =================
  void searchMatches(String query) {
    if (query.isEmpty) {
      _rebuildVisibleMatches();
    } else {
      final q = query.toLowerCase();

      matches = _scopedBaseMatches().where((m) {
        return m.title.toLowerCase().contains(q) ||
            m.sport.toLowerCase().contains(q) ||
            m.locationName.toLowerCase().contains(q);
      }).toList();
    }

    notifyListeners();
  }

  // ================= FILTER (SPORT CHIPS) =================
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

    final base = _baseListForChips();

    matches = currentFilters != null ? _applyFilters(base) : List.from(base);

    notifyListeners();
  }

  // ================= APPLY FILTER SHEET =================
  void applyFilters(FilterData filterData) {
    currentFilters = filterData;

    final base = _baseListForChips();

    matches = _applyFilters(base);

    notifyListeners();
  }

  List<AllMatches> _applyFilters(List<AllMatches> input) {
    return input.where((m) {
      final matchSkill = m.skillLevel.toLowerCase();
      final filterSkill = currentFilters?.skillLevel?.toLowerCase();

      final skillOk = filterSkill == null || matchSkill == filterSkill;

      return skillOk;
    }).toList();
  }

  // ================= LOAD MORE =================
  Future<void> loadMore() async {
    if (!hasNext || isLoading) return;

    try {
      isLoading = true;
      notifyListeners();
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
    matches = currentFilters != null ? _applyFilters(base) : List.from(base);
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
