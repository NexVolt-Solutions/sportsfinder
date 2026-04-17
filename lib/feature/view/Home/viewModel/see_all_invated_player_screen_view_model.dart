import 'package:flutter/material.dart';
import 'package:sport_finding/Data/model/match_detail_model.dart';
import 'package:sport_finding/Data/Repositories/matches_repo.dart';

/// Loads GET /api/v1/matches/{id} and exposes joined [participants] (roster).
class SeeAllInvatedPlayerScreenViewModel extends ChangeNotifier {
  SeeAllInvatedPlayerScreenViewModel({required this.matchId}) {
    if (matchId.isEmpty) {
      error = 'Missing match';
      notifyListeners();
      return;
    }
    Future.microtask(_load);
  }

  final String matchId;
  final MatchesRepo _repo = MatchesRepo();

  bool isLoading = false;
  String? error;
  List<MatchPlayerResponse> joinedPlayers = [];

  Future<void> _load() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final detail = await _repo.getMatch(matchId);
      joinedPlayers = detail.participants
          .where((p) => p.countsAsJoinedPlayer)
          .toList();
    } catch (e) {
      error = e.toString();
      joinedPlayers = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => _load();
}
