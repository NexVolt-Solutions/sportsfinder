import 'package:flutter/material.dart';
import 'package:sport_finding/Data/model/follow_connection_user.dart';

enum FollowConnectionsMode { followers, following }

class FollowConnectionsViewModel extends ChangeNotifier {
  FollowConnectionsViewModel(this.mode) {
    _allUsers = List<FollowConnectionUser>.from(kDefaultFollowConnectionUsers);
    if (mode == FollowConnectionsMode.following) {
      _activeFollowingIds
        ..clear()
        ..addAll(_allUsers.map((e) => e.id));
    }
    if (mode == FollowConnectionsMode.followers) {
      _followedBackIds.clear();
    }
    _rebuildVisible();
  }

  final FollowConnectionsMode mode;

  final TextEditingController searchController = TextEditingController();

  late List<FollowConnectionUser> _allUsers;

  /// Followers: ids where the user tapped "Follow Back".
  final Set<String> _followedBackIds = <String>{};

  /// Following: ids still followed (unfollow removes).
  final Set<String> _activeFollowingIds = <String>{};

  List<FollowConnectionUser> _visible = [];

  List<FollowConnectionUser> get visibleUsers => List.unmodifiable(_visible);

  bool didFollowBack(FollowConnectionUser user) =>
      _followedBackIds.contains(user.id);

  bool isStillFollowing(FollowConnectionUser user) =>
      _activeFollowingIds.contains(user.id);

  void onSearchChanged(String _) {
    _rebuildVisible();
    notifyListeners();
  }

  void followBack(FollowConnectionUser user) {
    if (mode != FollowConnectionsMode.followers) return;
    _followedBackIds.add(user.id);
    notifyListeners();
  }

  void unfollow(FollowConnectionUser user) {
    if (mode != FollowConnectionsMode.following) return;
    _activeFollowingIds.remove(user.id);
    _rebuildVisible();
    notifyListeners();
  }

  void _rebuildVisible() {
    final q = searchController.text.trim().toLowerCase();
    Iterable<FollowConnectionUser> rows = _allUsers;
    if (mode == FollowConnectionsMode.following) {
      rows = rows.where((u) => _activeFollowingIds.contains(u.id));
    }
    if (q.isNotEmpty) {
      rows = rows.where((u) => u.displayName.toLowerCase().contains(q));
    }
    _visible = rows.toList();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
