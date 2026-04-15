//       return;
//     }
//     final base = _baseListForChips();
//     final afterSheet = currentFilters != null
//         ? applyFilterDataToMatches(base, currentFilters!)
//         : List<DiscoveryMatch>.from(base);
//     final q = query.toLowerCase();
//     matches = afterSheet
//         .where(
//           (match) =>
//               match.title.toLowerCase().contains(q) ||
//               match.sportType.toLowerCase().contains(q) ||
//               match.location.toLowerCase().contains(q),
//         )
//         .toList();
//     notifyListeners();
//   }

//   void applyFilters(FilterData filterData) {
//     currentFilters = filterData.isEffectivelyEmpty ? null : filterData;
//     _rebuildMatches();
//     notifyListeners();
//   }
// }
import 'package:flutter/material.dart';
import 'package:sport_finding/Data/Repositories/matches_repo.dart';
import 'package:sport_finding/Data/model/all_matches_model.dart';
import 'package:sport_finding/Data/model/match_filters.dart';
import 'package:sport_finding/feature/view/Home/viewModel/upcoming_matches_scope.dart';

class AllUpcommingMatchesViewModel extends ChangeNotifier {
  final MatchesRepo _repo = MatchesRepo();

  // ================= DATA =================
  List<AllMatches> allMatches = [];
  List<AllMatches> matches = [];

  // ================= STATE =================
  bool isLoading = false;
  String? error;

  // ================= FILTERS =================
  int selectedIndex = 0;
  FilterData? currentFilters;

  final UpcomingMatchesScope scope;

  UpcomingMatchesScope get listScope => scope;

  // ================= PAGINATION =================
  int page = 1;
  bool hasNext = true;

  AllUpcommingMatchesViewModel({this.scope = UpcomingMatchesScope.allUpcoming});

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

      final res = await _repo.getAllMatches(page: page);

      allMatches.addAll(res.items);
      matches = List.from(allMatches);

      hasNext = res.hasNext;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ================= SEARCH =================
  void searchMatches(String query) {
    if (query.isEmpty) {
      matches = List.from(allMatches);
    } else {
      final q = query.toLowerCase();

      matches = allMatches.where((m) {
        return m.title.toLowerCase().contains(q) ||
            m.sport.toLowerCase().contains(q) ||
            m.locationName.toLowerCase().contains(q);
      }).toList();
    }

    notifyListeners();
  }

  // ================= FILTER (SPORT CHIPS) =================
  List<AllMatches> _baseListForChips() {
    if (selectedIndex == 0) return List.from(allMatches);

    final sports = ["Football", "Basketball", "Tennis", "Volleyball"];

    if (selectedIndex - 1 >= sports.length) return allMatches;

    final sport = sports[selectedIndex - 1];

    return allMatches.where((m) {
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
      page++;

      final res = await _repo.getAllMatches(page: page);

      allMatches.addAll(res.items);
      matches = List.from(allMatches);

      hasNext = res.hasNext;
    } catch (e) {
      error = e.toString();
    }

    notifyListeners();
  }
}
