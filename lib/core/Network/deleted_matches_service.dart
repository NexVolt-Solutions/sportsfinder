import 'package:flutter/material.dart';

class DeletedMatchesService extends ChangeNotifier {
  static final DeletedMatchesService _instance =
      DeletedMatchesService._internal();

  factory DeletedMatchesService() => _instance;

  DeletedMatchesService._internal();

  final Set<String> _deletedMatchIds = <String>{};

  bool isDeleted(String matchId) => _deletedMatchIds.contains(matchId.trim());

  void markDeleted(String matchId) {
    final trimmedId = matchId.trim();
    if (trimmedId.isEmpty) return;
    if (_deletedMatchIds.add(trimmedId)) {
      notifyListeners();
    }
  }

  void clear() {
    if (_deletedMatchIds.isEmpty) return;
    _deletedMatchIds.clear();
    notifyListeners();
  }
}
