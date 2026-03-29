import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/feature/model/discovery_match.dart';

class HostDetailScreenViewModel extends ChangeNotifier {
  int selectedIndex = 0;
  final List<String> buttonName = [
    AppText.overview,
    AppText.invitePlayers,
    AppText.location,
  ];

  String? _boundMatchId;
  List<String> _rosterNames = [];
  List<String> _rosterSkills = [];

  int get rosterCount => _rosterNames.length;

  String rosterNameAt(int index) =>
      index >= 0 && index < _rosterNames.length ? _rosterNames[index] : '';

  String rosterSkillAt(int index) =>
      index >= 0 && index < _rosterSkills.length ? _rosterSkills[index] : '';

  /// Call from [didChangeDependencies] with route [DiscoveryMatch] (idempotent).
  void bindMatch(DiscoveryMatch match) {
    if (_boundMatchId == match.id) return;
    _boundMatchId = match.id;
    _rosterNames = List<String>.from(match.players);
    _rosterSkills = List.generate(
      match.players.length,
      (i) => match.playerSkillAt(i),
    );
    notifyListeners();
  }

  void changeIndex(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  void removePlayerAt(int index) {
    if (index < 0 || index >= _rosterNames.length) return;
    _rosterNames.removeAt(index);
    _rosterSkills.removeAt(index);
    notifyListeners();
  }
}
