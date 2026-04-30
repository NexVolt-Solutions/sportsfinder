import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:sport_finding/Data/model/follow_connections_args.dart';
import 'package:sport_finding/Data/model/follow_connection_user.dart';
import 'package:sport_finding/Data/Repositories/GetFollower/followers_repo.dart';
import 'package:sport_finding/Data/Repositories/GetFollowing/following_repo.dart';
import 'package:sport_finding/Data/Repositories/FollowUser/follow_user_repo.dart';
import 'package:sport_finding/Data/Repositories/UnFollowUser/unfollow_user_repo.dart';
import 'package:sport_finding/core/Network/profile_service.dart';

enum FollowConnectionsMode { followers, following }

class FollowConnectionsViewModel extends ChangeNotifier {
  FollowConnectionsViewModel(this.mode, {FollowConnectionsArgs? args})
    : _args = args {
    _allUsers = List<FollowConnectionUser>.from(kDefaultFollowConnectionUsers);
    if (mode == FollowConnectionsMode.followers) {
      _followedBackIds.clear();
      _fetchFollowers(); // Fetch followers data when initialized
    } else {
      _fetchFollowing();
    }
    _rebuildVisible();
  }

  final FollowConnectionsMode mode;
  final FollowConnectionsArgs? _args;
  final TextEditingController searchController = TextEditingController();

  late List<FollowConnectionUser> _allUsers;

  /// Followers: ids where the user tapped "Follow Back".
  final Set<String> _followedBackIds = <String>{};

  /// Following: ids still followed (unfollow removes).
  final Set<String> _activeFollowingIds = <String>{};

  /// Users currently being followed (loading state).
  final Set<String> _followingUserIds = <String>{};

  /// Error messages per user for failed follow attempts.
  final Map<String, String> _userFollowErrors = <String, String>{};

  /// Users currently being unfollowed (loading state).
  final Set<String> _unfollowingUserIds = <String>{};

  /// Error messages per user for failed unfollow attempts.
  final Map<String, String> _userUnfollowErrors = <String, String>{};

  List<FollowConnectionUser> _visible = [];

  // ── Loading and Error states ───────────────────────────────────────────────
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  String get emptyStateMessage => mode == FollowConnectionsMode.followers
      ? 'No followers yet'
      : 'No following yet';

  String get _targetUserId {
    final routeId = _args?.userId?.trim() ?? '';
    if (routeId.isNotEmpty) return routeId;
    return ProfileService().profile?.id ?? '';
  }

  String get _currentUserId => ProfileService().profile?.id ?? '';

  bool get canManageFollowingActions =>
      mode == FollowConnectionsMode.following &&
      _targetUserId.isNotEmpty &&
      _targetUserId == _currentUserId;

  // ── Getters ────────────────────────────────────────────────────────────────
  List<FollowConnectionUser> get visibleUsers => List.unmodifiable(_visible);

  bool didFollowBack(FollowConnectionUser user) =>
      _activeFollowingIds.contains(user.id);

  bool isStillFollowing(FollowConnectionUser user) =>
      _activeFollowingIds.contains(user.id);

  bool isFollowingUser(String userId) => _followingUserIds.contains(userId);

  String? getFollowUserError(String userId) => _userFollowErrors[userId];

  bool isUnfollowingUser(String userId) => _unfollowingUserIds.contains(userId);

  String? getUnfollowUserError(String userId) => _userUnfollowErrors[userId];

  // ── API Integration: Fetch Followers ───────────────────────────────────────
  Future<void> _fetchFollowers() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final userId = _targetUserId;
      if (userId.isEmpty) {
        _errorMessage = 'User ID not found';
        _isLoading = false;
        notifyListeners();
        return;
      }

      log('🚀 [FollowConnectionsVM] Fetching followers for userId: $userId');

      final repo = FollowersRepo();
      final followersModel = await repo.getFollowers(
        userId: userId,
        page: 1,
        limit: 50,
      );

      log(
        '✅ [FollowConnectionsVM] Fetched ${followersModel.items.length} followers',
      );
      if (followersModel.items.isEmpty) {
        log('ℹ️ [FollowConnectionsVM] No followers found for userId: $userId');
      }

      // Convert FollowerItem to FollowConnectionUser
      _allUsers = followersModel.items
          .map(
            (follower) => FollowConnectionUser(
              id: follower.id,
              displayName: follower.fullName,
              isFollowing: follower.isFollowing,
            ),
          )
          .toList();

      // Use current user's real following graph as source of truth
      // for "Follow Back" / "Following" button state.
      await _hydrateCurrentUserFollowingIds();

      _rebuildVisible();
      _isLoading = false;
      notifyListeners();
    } catch (e, stack) {
      log('❌ [FollowConnectionsVM] Error fetching followers: $e');
      log('📍 [FollowConnectionsVM] Stacktrace: $stack');
      final errorText = e.toString();
      if (errorText.contains('Invalid or expired token')) {
        _errorMessage = 'Your session has expired. Please log in again.';
      } else {
        _errorMessage = 'Failed to load followers';
      }
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _hydrateCurrentUserFollowingIds() async {
    final me = _currentUserId;
    if (me.isEmpty) {
      _activeFollowingIds.clear();
      return;
    }
    try {
      final followingModel = await FollowingRepo().getFollowing(
        userId: me,
        page: 1,
        limit: 200,
      );
      _activeFollowingIds
        ..clear()
        ..addAll(followingModel.items.map((e) => e.id));
    } catch (_) {
      // Keep previous state if this side-call fails; do not block followers UI.
    }
  }

  Future<void> _fetchFollowing() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final userId = _targetUserId;
      if (userId.isEmpty) {
        _errorMessage = 'User ID not found';
        _isLoading = false;
        notifyListeners();
        return;
      }

      log('🚀 [FollowConnectionsVM] Fetching following for userId: $userId');

      final repo = FollowingRepo();
      final followingModel = await repo.getFollowing(
        userId: userId,
        page: 1,
        limit: 50,
      );

      log(
        '✅ [FollowConnectionsVM] Fetched ${followingModel.items.length} following users',
      );
      if (followingModel.items.isEmpty) {
        log('ℹ️ [FollowConnectionsVM] No following found for userId: $userId');
      }

      _allUsers = followingModel.items
          .map(
            (user) => FollowConnectionUser(
              id: user.id,
              displayName: user.fullName,
            ),
          )
          .toList();

      _activeFollowingIds
        ..clear()
        ..addAll(_allUsers.map((e) => e.id));

      _rebuildVisible();
      _isLoading = false;
      notifyListeners();
    } catch (e, stack) {
      log('❌ [FollowConnectionsVM] Error fetching following: $e');
      log('📍 [FollowConnectionsVM] Stacktrace: $stack');
      final errorText = e.toString();
      if (errorText.contains('Invalid or expired token')) {
        _errorMessage = 'Your session has expired. Please log in again.';
      } else {
        _errorMessage = 'Failed to load following';
      }
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── API Integration: Follow Back User ───────────────────────────────────────
  Future<bool> followBackUser(FollowConnectionUser user) async {
    if (mode != FollowConnectionsMode.followers) return false;

    final userId = user.id;

    // Don't follow again if already followed
    if (_followedBackIds.contains(userId)) {
      log('ℹ️ [FollowConnectionsVM] User $userId already followed back');
      return true;
    }

    try {
      _followingUserIds.add(userId);
      _userFollowErrors.remove(userId);
      notifyListeners();

      log(
        '🟡 [FollowConnectionsVM] Follow-back API hit for follower: '
        '${user.displayName} ($userId)',
      );

      final repo = FollowUserRepo();
      final result = await repo.followUser(userId: userId);

      log(
        '✅ [FollowConnectionsVM] You followed back ${user.displayName} '
        '($userId)',
      );
      log('📝 [FollowConnectionsVM] Follow-back response: ${result.message}');

      _followedBackIds.add(userId);
      _activeFollowingIds.add(userId);
      _followingUserIds.remove(userId);
      notifyListeners();

      return true;
    } catch (e, stack) {
      log('❌ [FollowConnectionsVM] Error following user $userId: $e');
      log('📍 [FollowConnectionsVM] Stacktrace: $stack');

      _userFollowErrors[userId] = 'Failed to follow user';
      _followingUserIds.remove(userId);
      notifyListeners();

      return false;
    }
  }

  // ── API Integration: Unfollow User ─────────────────────────────────────────
  Future<bool> unfollowUserApi(FollowConnectionUser user) async {
    if (mode != FollowConnectionsMode.following) return false;

    final userId = user.id;

    // Don't unfollow again if already unfollowing
    if (_unfollowingUserIds.contains(userId)) {
      log('ℹ️ [FollowConnectionsVM] User $userId already unfollowing');
      return false;
    }

    try {
      _unfollowingUserIds.add(userId);
      _userUnfollowErrors.remove(userId);
      notifyListeners();

      log('🟡 [FollowConnectionsVM] Unfollowing user: $userId');

      final repo = UnfollowUserRepo();
      final result = await repo.unfollowUser(userId: userId);

      log('✅ [FollowConnectionsVM] Successfully unfollowed user: $userId');
      log('📝 [FollowConnectionsVM] Message: ${result.message}');

      // Remove from active following and update visible list
      _activeFollowingIds.remove(userId);
      _unfollowingUserIds.remove(userId);
      _rebuildVisible();
      notifyListeners();

      return true;
    } catch (e, stack) {
      log('❌ [FollowConnectionsVM] Error unfollowing user $userId: $e');
      log('📍 [FollowConnectionsVM] Stacktrace: $stack');

      _userUnfollowErrors[userId] = 'Failed to unfollow user';
      _unfollowingUserIds.remove(userId);
      notifyListeners();

      return false;
    }
  }

  // ── Search and filtering ───────────────────────────────────────────────────
  void onSearchChanged(String _) {
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
