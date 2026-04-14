import 'package:flutter/material.dart';
import 'package:sport_finding/Data/Repositories/matches_repo.dart';
import 'package:sport_finding/Data/model/list_of_all_matches_model.dart';
import 'upcoming_matches_scope.dart';

class AllUpcommingMatchesViewModel extends ChangeNotifier {
  final MatchesRepo _repository = MatchesRepo();

  List<MatchModel> _matches = [];
  List<MatchModel> _allMatches = [];

  List<MatchModel> get matches => _matches;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  UpcomingMatchesScope listScope = UpcomingMatchesScope.allUpcoming;

  int _page = 1;
  bool _hasNext = true;

  /// Fetch Matches
  Future<void> fetchMatches({
    String type = "all",
    double? lat,
    double? lng,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _repository.getMatches(
        type: type,
        page: _page,
        lat: lat,
        lng: lng,
      );

      _matches = response.items;
      _allMatches = response.items;
      _hasNext = response.hasNext;

      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint("❌ Error fetching matches: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Search Matches
  void searchMatches(String query) {
    if (query.isEmpty) {
      _matches = _allMatches;
    } else {
      _matches = _allMatches
          .where(
            (match) =>
                match.title.toLowerCase().contains(query.toLowerCase()) ||
                match.sport.toLowerCase().contains(query.toLowerCase()) ||
                match.locationName.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }
    notifyListeners();
  }

  /// Apply Filters
  Future<void> applyFilters(Map<String, dynamic> filters) async {
    await fetchMatches(type: filters['type'] ?? "all");
  }

  /// Pagination (Optional)
  Future<void> loadMore() async {
    if (!_hasNext || _isLoading) return;

    _page++;
    notifyListeners();

    try {
      final response = await _repository.getMatches(page: _page);
      _matches.addAll(response.items);
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Pagination Error: $e");
    }
  }
}
