import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sport_finding/Data/model/llst_of_all_user_model.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Network/list_of_all_user_service.dart';
import 'package:sport_finding/Data/model/discovery_match.dart';

class HostDetailScreenViewModel extends ChangeNotifier {
  int selectedIndex = 0;
  final List<String> buttonName = [
    AppText.overview,
    AppText.players,
    AppText.location,
  ];

  String? _boundMatchId;
  List<String> _rosterNames = [];
  List<String> _rosterSkills = [];

  int get rosterCount => _rosterNames.length;
  String rosterNameAt(int i) =>
      i >= 0 && i < _rosterNames.length ? _rosterNames[i] : '';
  String rosterSkillAt(int i) =>
      i >= 0 && i < _rosterSkills.length ? _rosterSkills[i] : '';

  // ✅ All users from the global service
  List<Items> get allUsers => ListOfAllUserService().allUsers;
  bool get isLoadingUsers => ListOfAllUserService().isLoading;
  String? get usersFetchError => ListOfAllUserService().errorMessage;

  HostDetailScreenViewModel() {
    ListOfAllUserService().addListener(_onUsersChanged);
  }

  /// Loads [GET /api/v1/users] when the **Players** tab (index 1) is opened.
  void ensureUsersLoadedForPlayersTab() {
    unawaited(ListOfAllUserService().fetchAllUsers());
  }

  void _onUsersChanged() => notifyListeners();

  /// ✅ Manual refresh to reload users from API
  Future<void> refreshUsers() async {
    await ListOfAllUserService().fetchAllUsers(forceRefresh: true);
    notifyListeners();
  }

  @override
  void dispose() {
    ListOfAllUserService().removeListener(_onUsersChanged);
    super.dispose();
  }

  void bindMatch(DiscoveryMatch match) {
    if (_boundMatchId == match.id) return;
    _boundMatchId = match.id;
    _rosterNames = List<String>.from(match.players);
    _rosterSkills = List.generate(
      match.players.length,
      (i) => match.playerSkillAt(i),
    );
  }

  void changeIndex(int index) {
    selectedIndex = index;
    if (index == 1) {
      ensureUsersLoadedForPlayersTab();
    }
    notifyListeners();
  }

  void removePlayerAt(int index) {
    if (index < 0 || index >= _rosterNames.length) return;
    _rosterNames.removeAt(index);
    _rosterSkills.removeAt(index);
    notifyListeners();
  }
}
