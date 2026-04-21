// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:sport_finding/Data/model/llst_of_all_user_model.dart';
// import 'package:sport_finding/core/Constants/app_text.dart';
// import 'package:sport_finding/core/Network/list_of_all_user_service.dart';
// import 'package:sport_finding/Data/model/discovery_match.dart';

// class HostDetailScreenViewModel extends ChangeNotifier {
//   int selectedIndex = 0;
//   final List<String> buttonName = [
//     AppText.overview,
//     AppText.players,
//     AppText.location,
//   ];

//   String? _boundMatchId;
//   List<String> _rosterNames = [];
//   List<String> _rosterSkills = [];

//   int get rosterCount => _rosterNames.length;
//   String rosterNameAt(int i) =>
//       i >= 0 && i < _rosterNames.length ? _rosterNames[i] : '';
//   String rosterSkillAt(int i) =>
//       i >= 0 && i < _rosterSkills.length ? _rosterSkills[i] : '';

//   // ✅ All users from the global service
//   List<Items> get allUsers => ListOfAllUserService().allUsers;
//   bool get isLoadingUsers => ListOfAllUserService().isLoading;
//   String? get usersFetchError => ListOfAllUserService().errorMessage;

//   HostDetailScreenViewModel() {
//     ListOfAllUserService().addListener(_onUsersChanged);
//   }

//   /// Loads [GET /api/v1/users] when the **Players** tab (index 1) is opened.
//   void ensureUsersLoadedForPlayersTab() {
//     unawaited(ListOfAllUserService().fetchAllUsers());
//   }

//   void _onUsersChanged() => notifyListeners();

//   /// ✅ Manual refresh to reload users from API
//   Future<void> refreshUsers() async {
//     await ListOfAllUserService().fetchAllUsers(forceRefresh: true);
//     notifyListeners();
//   }

//   @override
//   void dispose() {
//     ListOfAllUserService().removeListener(_onUsersChanged);
//     super.dispose();
//   }

//   void bindMatch(DiscoveryMatch match) {
//     if (_boundMatchId == match.id) return;
//     _boundMatchId = match.id;
//     _rosterNames = List<String>.from(match.players);
//     _rosterSkills = List.generate(
//       match.players.length,
//       (i) => match.playerSkillAt(i),
//     );
//   }

//   void changeIndex(int index) {
//     selectedIndex = index;
//     if (index == 1) {
//       ensureUsersLoadedForPlayersTab();
//     }
//     notifyListeners();
//   }

//   void removePlayerAt(int index) {
//     if (index < 0 || index >= _rosterNames.length) return;
//     _rosterNames.removeAt(index);
//     _rosterSkills.removeAt(index);
//     notifyListeners();
//   }
// }
import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:sport_finding/Data/Repositories/DeleteMatch/delete_match_repo.dart';
import 'package:sport_finding/Data/Repositories/RemovePlayer/remove_player_repo.dart';
import 'package:sport_finding/Data/model/DeleteMAtch/delete_match_Model.dart';
import 'package:sport_finding/Data/Repositories/MatchInvitation/match_invitation_repository.dart';
import 'package:sport_finding/Data/Repositories/JoinMatch/match_join_leave_repository.dart';
import 'package:sport_finding/Data/Repositories/UpdateMatchStatus/update_match_status_repo.dart';
import 'package:sport_finding/Data/model/JoinMatch/join_leave_match_response.dart';
import 'package:sport_finding/Data/model/RemovePlayer/remove_player_response_model.dart';
import 'package:sport_finding/Data/model/UpdateMatchStatus/update_match_status_model.dart';
import 'package:sport_finding/Data/model/llst_of_all_user_model.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Network/list_of_all_user_service.dart';
import 'package:sport_finding/Data/model/discovery_match.dart';
import 'package:sport_finding/Data/model/match_detail_model.dart';
import 'package:sport_finding/Data/Repositories/matches_repo.dart';
import 'package:sport_finding/core/Network/profile_service.dart';
import 'package:sport_finding/core/utils/logger.dart';

class HostDetailScreenViewModel extends ChangeNotifier {
  static final Map<String, bool> _sessionJoinStateByMatchId = <String, bool>{};
  int selectedIndex = 0;
  final List<String> buttonName = [
    AppText.overview,
    AppText.players,
    AppText.location,
  ];

  String? _boundMatchId;
  List<String> _rosterNames = [];
  List<String> _rosterSkills = [];
  List<String> _rosterUserIds = [];

  // ── Current match being displayed ──────────────────────────────────────────
  DiscoveryMatch? _currentMatch;
  DiscoveryMatch? get currentMatch => _currentMatch;

  int get rosterCount => _rosterNames.length;
  String rosterNameAt(int i) =>
      i >= 0 && i < _rosterNames.length ? _rosterNames[i] : '';
  String rosterSkillAt(int i) =>
      i >= 0 && i < _rosterSkills.length ? _rosterSkills[i] : '';

  // ── All users from the global service ─────────────────────────────────────
  List<Items> get allUsers => ListOfAllUserService().allUsers;
  bool get isLoadingUsers => ListOfAllUserService().isLoading;
  String? get usersFetchError => ListOfAllUserService().errorMessage;

  // ── Join / Leave state ─────────────────────────────────────────────────────
  final MatchJoinLeaveRepository _joinLeaveRepo = MatchJoinLeaveRepository();
  final MatchInvitationRepository _matchInvitationRepository =
      MatchInvitationRepository();
  final DeleteMatchRepo _deleteMatchRepo = DeleteMatchRepo();
  final RemovePlayerRepo _removePlayerRepo = RemovePlayerRepo();
  final MatchesRepo _matchesRepo = MatchesRepo();

  bool _hasJoined = false;
  bool get hasJoined => _hasJoined;

  bool _isJoinLeaveLoading = false;
  bool get isJoinLeaveLoading => _isJoinLeaveLoading;

  String? _joinLeaveError;
  String? get joinLeaveError => _joinLeaveError;

  Set<String>? _invitingUserIds = <String>{};
  Set<String>? _invitedUserIds = <String>{};
  String? _inviteErrorMessage;

  Set<String> get _safeInvitingUserIds => _invitingUserIds ??= <String>{};
  Set<String> get _safeInvitedUserIds => _invitedUserIds ??= <String>{};

  bool isInvitingUser(String userId) => _safeInvitingUserIds.contains(userId);
  bool isUserAlreadyInvited(String userId) =>
      _safeInvitedUserIds.contains(userId);
  String? get inviteErrorMessage => _inviteErrorMessage;

  bool _isDeletingMatch = false;
  bool get isDeletingMatch => _isDeletingMatch;

  String? _deleteMatchError;
  String? get deleteMatchError => _deleteMatchError;

  // ── Match Status state ─────────────────────────────────────────────────────
  final UpdateMatchStatusRepo _updateMatchStatusRepo = UpdateMatchStatusRepo();
  bool _isUpdatingMatchStatus = false;
  bool get isUpdatingMatchStatus => _isUpdatingMatchStatus;

  String _matchStatus = 'pending'; // pending, ongoing, completed
  String get matchStatus => _matchStatus;

  String? _matchStatusError;
  String? get matchStatusError => _matchStatusError;

  bool _isRefreshingRoster = false;
  bool get isRefreshingRoster => _isRefreshingRoster;

  // ── Constructor ────────────────────────────────────────────────────────────
  HostDetailScreenViewModel() {
    ListOfAllUserService().addListener(_onUsersChanged);
  }

  // ── Users tab logic ────────────────────────────────────────────────────────

  /// Loads [GET /api/v1/users] when the Players tab (index 1) is opened.
  void ensureUsersLoadedForPlayersTab() {
    unawaited(ListOfAllUserService().fetchAllUsers());
  }

  void _onUsersChanged() => notifyListeners();

  /// Manual refresh to reload users from API
  Future<void> refreshUsers() async {
    await ListOfAllUserService().fetchAllUsers(forceRefresh: true);
    notifyListeners();
  }

  /// Update match data when edited
  void updateMatchAfterEdit(DiscoveryMatch updatedMatch) {
    debugPrint('🔄 [ViewModel] updateMatchAfterEdit called');
    debugPrint('🔄 Title: ${updatedMatch.title}');
    debugPrint('🔄 Sport: ${updatedMatch.sportType}');
    debugPrint('🔄 Time: ${updatedMatch.time}');
    _currentMatch = updatedMatch;
    debugPrint('🔄 _currentMatch set to: ${_currentMatch?.sportType}');
    bindMatch(updatedMatch);
    debugPrint('🔄 bindMatch completed');
    notifyListeners();
    debugPrint(
      '🔄 notifyListeners() called - currentMatch sport now: ${_currentMatch?.sportType}',
    );
  }

  List<String> get rosterPlayers => List.unmodifiable(_rosterNames);

  Future<String?> inviteUserToMatch({
    required String matchId,
    required String userId,
  }) async {
    final trimmedMatchId = matchId.trim();
    final trimmedUserId = userId.trim();

    AppLogger.info('inviteUserToMatch called', tag: 'HostDetailVM');
    AppLogger.debug('matchId: $trimmedMatchId', tag: 'HostDetailVM');
    AppLogger.debug('userId: $trimmedUserId', tag: 'HostDetailVM');

    if (trimmedMatchId.isEmpty || trimmedUserId.isEmpty) {
      AppLogger.warning(
        'Invite aborted because matchId or userId is empty',
        tag: 'HostDetailVM',
      );
      return 'Missing match or user id';
    }

    final invitingIds = _safeInvitingUserIds;
    final invitedIds = _safeInvitedUserIds;

    AppLogger.debug(
      'Currently inviting ids: $invitingIds',
      tag: 'HostDetailVM',
    );
    AppLogger.debug('Already invited ids: $invitedIds', tag: 'HostDetailVM');

    if (invitingIds.contains(trimmedUserId)) {
      AppLogger.warning(
        'Invite skipped because this user is already in-flight',
        tag: 'HostDetailVM',
      );
      return null;
    }
    if (invitedIds.contains(trimmedUserId)) {
      AppLogger.warning(
        'Invite skipped because this user was already invited',
        tag: 'HostDetailVM',
      );
      return 'Invitation already sent';
    }

    invitingIds.add(trimmedUserId);
    _inviteErrorMessage = null;
    notifyListeners();

    try {
      AppLogger.info(
        'Calling MatchInvitationRepository.invitePlayer...',
        tag: 'HostDetailVM',
      );
      final response = await _matchInvitationRepository.invitePlayer(
        matchId: trimmedMatchId,
        userId: trimmedUserId,
      );
      AppLogger.success(
        'Invite API call completed successfully: ${response.message}',
        tag: 'HostDetailVM',
      );
      invitedIds.add(trimmedUserId);
      return response.message;
    } catch (e) {
      _inviteErrorMessage = e.toString();
      AppLogger.error('Invite API call failed', tag: 'HostDetailVM', error: e);
      return _inviteErrorMessage;
    } finally {
      invitingIds.remove(trimmedUserId);
      AppLogger.debug(
        'Invite flow finished for userId: $trimmedUserId',
        tag: 'HostDetailVM',
      );
      notifyListeners();
    }
  }

  Future<DeleteMatchModel?> deleteCurrentMatch() async {
    final matchId = _currentMatch?.id.trim() ?? '';
    if (matchId.isEmpty) {
      _deleteMatchError = 'Match ID is missing';
      AppLogger.warning(
        'Delete match aborted because no current match id was found',
        tag: 'HostDetailVM',
      );
      notifyListeners();
      return null;
    }

    AppLogger.info(
      'Delete current match requested for matchId: $matchId',
      tag: 'HostDetailVM',
    );
    _isDeletingMatch = true;
    _deleteMatchError = null;
    notifyListeners();

    try {
      final result = await _deleteMatchRepo.deleteMatch(matchId: matchId);
      AppLogger.success(
        'Delete match completed for matchId: ${result.matchId}',
        tag: 'HostDetailVM',
      );
      return result;
    } catch (e) {
      _deleteMatchError = e.toString();
      AppLogger.error(
        'Delete match failed for matchId: $matchId',
        tag: 'HostDetailVM',
        error: e,
      );
      return null;
    } finally {
      _isDeletingMatch = false;
      notifyListeners();
    }
  }

  // ── Join Match ─────────────────────────────────────────────────────────────

  /// Returns [true] on success, [false] on failure.
  /// Sets [hasJoined] = true so the button switches to "Leave Match".
  Future<bool> joinMatch(String matchId) async {
    log('🟡 [ViewModel] joinMatch called — matchId: $matchId');

    _isJoinLeaveLoading = true;
    _joinLeaveError = null;
    notifyListeners();

    try {
      final JoinLeaveMatchResponse result = await _joinLeaveRepo.joinMatch(
        matchId,
      );

      log('✅ [ViewModel] joinMatch success — message: ${result.message}');

      _hasJoined = true;
      _sessionJoinStateByMatchId[matchId] = true;
      _addCurrentUserToRoster();
      log('[ViewModel] joinMatch cached state -> joined for matchId: $matchId');
      return true;
    } catch (e, stack) {
      log('❌ [ViewModel] joinMatch failed — error: $e');
      log('📍 [ViewModel] joinMatch stacktrace: $stack');

      final errorStr = e.toString();
      _joinLeaveError = errorStr;

      // If user already joined, still show Leave button
      if (errorStr.contains('already joined')) {
        log('ℹ️ [ViewModel] User already joined - setting hasJoined = true');
        _hasJoined = true;
        _sessionJoinStateByMatchId[matchId] = true;
        _addCurrentUserToRoster();
        log(
          '[ViewModel] joinMatch cached state -> joined for matchId: $matchId',
        );
        return true; // Treat as success for UI purposes
      }

      return false;
    } finally {
      _isJoinLeaveLoading = false;
      notifyListeners();
    }
  }

  // ── Leave Match ────────────────────────────────────────────────────────────

  /// Returns [true] on success, [false] on failure.
  /// Sets [hasJoined] = false so the button switches back to "Join Match".
  Future<bool> leaveMatch(String matchId) async {
    log('🟡 [ViewModel] leaveMatch called — matchId: $matchId');

    _isJoinLeaveLoading = true;
    _joinLeaveError = null;
    notifyListeners();

    try {
      final JoinLeaveMatchResponse result = await _joinLeaveRepo.leaveMatch(
        matchId,
      );

      log('✅ [ViewModel] leaveMatch success — message: ${result.message}');

      _hasJoined = false;
      _sessionJoinStateByMatchId[matchId] = false;
      _removeCurrentUserFromRoster();
      log('[ViewModel] leaveMatch cached state -> left for matchId: $matchId');
      return true;
    } catch (e, stack) {
      log('❌ [ViewModel] leaveMatch failed — error: $e');
      log('📍 [ViewModel] leaveMatch stacktrace: $stack');

      final errorStr = e.toString();
      _joinLeaveError = errorStr;

      // If user is the host, they cannot leave
      if (errorStr.contains('host') || errorStr.contains('cannot leave')) {
        log('ℹ️ [ViewModel] User is host - cannot leave');
        _hasJoined = true; // Keep them "joined" (as host)
        _sessionJoinStateByMatchId[matchId] = true;
        _joinLeaveError =
            'As the host, you cannot leave this match. Delete it instead.';
        return false; // This is an error, show message
      }

      // If user not joined, still show Join button
      if (errorStr.contains('not joined') || errorStr.contains('not found')) {
        log('ℹ️ [ViewModel] User not joined - setting hasJoined = false');
        _hasJoined = false;
        _sessionJoinStateByMatchId[matchId] = false;
        _removeCurrentUserFromRoster();
        log(
          '[ViewModel] leaveMatch cached state -> left for matchId: $matchId',
        );
        return true; // Treat as success for UI purposes
      }

      return false;
    } finally {
      _isJoinLeaveLoading = false;
      notifyListeners();
    }
  }

  // ── Bind Match ─────────────────────────────────────────────────────────────
  void bindMatch(DiscoveryMatch match) {
    _boundMatchId = match.id;
    _currentMatch = match;
    _seedRosterFromMatch(match);

    // Reset join/leave state when a new match is bound
    log(
      '🔄 [ViewModel] bindMatch — resetting join state for matchId: ${match.id}',
    );
    final cachedJoinState = _sessionJoinStateByMatchId[match.id];
    final resolvedJoinState = cachedJoinState ?? match.isJoinedByCurrentUser;
    log('[ViewModel] bindMatch for matchId: ${match.id}');
    log(
      '[ViewModel] bindMatch resolved join state: $resolvedJoinState '
      '(cached: $cachedJoinState, joinedFromMatch: ${match.isJoinedByCurrentUser}, '
      'hosted: ${match.isHostedByCurrentUser})',
    );
    _hasJoined = resolvedJoinState;
    _joinLeaveError = null;
    _isJoinLeaveLoading = false;
    _safeInvitingUserIds.clear();
    _safeInvitedUserIds.clear();
    _inviteErrorMessage = null;
    if (match.id.trim().isNotEmpty) {
      unawaited(refreshRoster());
    }
  }

  // ── Tab navigation ────────────────────────────────────────────────────────
  void changeIndex(int index) {
    selectedIndex = index;
    if (index == 1) {
      ensureUsersLoadedForPlayersTab();
    }
    notifyListeners();
  }

  // ── Roster management ──────────────────────────────────────────────────────
  void removePlayerAt(int index) {
    if (index < 0 || index >= _rosterNames.length) return;
    _rosterNames.removeAt(index);
    _rosterSkills.removeAt(index);
    if (index < _rosterUserIds.length) {
      _rosterUserIds.removeAt(index);
    }
    _syncCurrentMatchRoster();
    notifyListeners();
  }

  Future<String?> removePlayerFromMatchAt(int index) async {
    final matchId = _currentMatch?.id.trim() ?? '';
    if (matchId.isEmpty) {
      _joinLeaveError = 'Match ID is missing';
      notifyListeners();
      return null;
    }
    if (index < 0 || index >= _rosterNames.length) {
      return null;
    }
    if (index >= _rosterUserIds.length) {
      _joinLeaveError = 'User ID is missing for selected player';
      notifyListeners();
      return null;
    }

    final userId = _rosterUserIds[index].trim();
    if (userId.isEmpty) {
      _joinLeaveError = 'User ID is missing for selected player';
      notifyListeners();
      return null;
    }

    _isJoinLeaveLoading = true;
    _joinLeaveError = null;
    notifyListeners();

    try {
      final RemovePlayerResponseModel response = await _removePlayerRepo
          .removePlayer(matchId: matchId, userId: userId);
      _rosterNames.removeAt(index);
      _rosterSkills.removeAt(index);
      _rosterUserIds.removeAt(index);
      _syncCurrentMatchRoster();
      return response.message;
    } catch (e) {
      _joinLeaveError = e.toString();
      return null;
    } finally {
      _isJoinLeaveLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshRoster() async {
    final matchId = _currentMatch?.id.trim() ?? '';
    if (matchId.isEmpty || _isRefreshingRoster) return;

    _isRefreshingRoster = true;
    notifyListeners();

    try {
      final detail = await _matchesRepo.getMatch(matchId);
      _applyRosterFromDetail(detail);
      AppLogger.success(
        'Roster refreshed for matchId: $matchId',
        tag: 'HostDetailVM',
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to refresh roster for matchId: $matchId',
        tag: 'HostDetailVM',
        error: e,
        stackTrace: stackTrace,
      );
    } finally {
      _isRefreshingRoster = false;
      notifyListeners();
    }
  }

  void _seedRosterFromMatch(DiscoveryMatch match) {
    final hostName = match.displayHostName.trim().toLowerCase();
    final names = <String>[];
    final skills = <String>[];
    final userIds = <String>[];

    for (var i = 0; i < match.players.length; i++) {
      final playerName = match.players[i].trim();
      if (playerName.isEmpty) continue;
      if (hostName.isNotEmpty && playerName.toLowerCase() == hostName) {
        continue;
      }
      names.add(playerName);
      skills.add(match.playerSkillAt(i));
      userIds.add('');
    }

    _rosterNames = names;
    _rosterSkills = skills;
    _rosterUserIds = userIds;
    AppLogger.debug(
      'Seeded participated roster from route for matchId=${match.id}: '
      'players=$_rosterNames',
      tag: 'HostDetailVM',
    );
    _syncCurrentMatchRoster();
  }

  void _applyRosterFromDetail(MatchDetailResponse detail) {
    final hostId = detail.host.id.trim();
    final hostName = detail.host.fullName.trim().toLowerCase();
    final names = <String>[];
    final skills = <String>[];
    final userIds = <String>[];

    for (final participant in detail.participants) {
      if (!participant.countsAsJoinedPlayer) continue;
      final userId = participant.user.id.trim();
      final fullName = participant.user.fullName.trim();
      if (fullName.isEmpty) continue;
      if (hostId.isNotEmpty && userId == hostId) continue;
      if (hostName.isNotEmpty && fullName.toLowerCase() == hostName) continue;

      names.add(fullName);
      skills.add(
        detail.skillLevel.trim().isNotEmpty ? detail.skillLevel : 'Intermediate',
      );
      userIds.add(userId);
    }

    _rosterNames = names;
    _rosterSkills = skills;
    _rosterUserIds = userIds;
    AppLogger.info(
      'Stored participated players from backend for matchId=${detail.id}: '
      'players=$_rosterNames',
      tag: 'HostDetailVM',
    );
    _syncCurrentMatchRoster();
  }

  void _syncCurrentMatchRoster() {
    final match = _currentMatch;
    if (match == null) return;
    _currentMatch = match.copyWith(
      players: List<String>.from(_rosterNames),
      playerSkills: List<String>.from(_rosterSkills),
      participantsJoined: _rosterNames.length,
    );
    AppLogger.debug(
      'Current match roster synced for matchId=${match.id}: '
      'count=${_rosterNames.length}, players=$_rosterNames',
      tag: 'HostDetailVM',
    );
  }

  void _addCurrentUserToRoster() {
    final rawName = ProfileService().profile?.fullName.trim() ?? '';
    if (rawName.isEmpty) return;
    final normalized = rawName.toLowerCase();
    if (_rosterNames.any((name) => name.trim().toLowerCase() == normalized)) {
      AppLogger.debug(
        'Accepted user already exists in participated list: $rawName',
        tag: 'HostDetailVM',
      );
      _syncCurrentMatchRoster();
      return;
    }
    _rosterNames.add(rawName);
    _rosterSkills.add(_currentMatch?.skillLevel ?? 'Intermediate');
    _rosterUserIds.add(ProfileService().profile?.id.trim() ?? '');
    AppLogger.success(
      'Accepted user stored in participated list: $rawName',
      tag: 'HostDetailVM',
    );
    _syncCurrentMatchRoster();
  }

  void _removeCurrentUserFromRoster() {
    final rawName = ProfileService().profile?.fullName.trim() ?? '';
    if (rawName.isEmpty) return;
    final normalized = rawName.toLowerCase();
    final index = _rosterNames.indexWhere(
      (name) => name.trim().toLowerCase() == normalized,
    );
    if (index == -1) {
      AppLogger.debug(
        'User not found in participated list while removing: $rawName',
        tag: 'HostDetailVM',
      );
      _syncCurrentMatchRoster();
      return;
    }
    _rosterNames.removeAt(index);
    if (index < _rosterSkills.length) {
      _rosterSkills.removeAt(index);
    }
    if (index < _rosterUserIds.length) {
      _rosterUserIds.removeAt(index);
    }
    AppLogger.info(
      'User removed from participated list: $rawName',
      tag: 'HostDetailVM',
    );
    _syncCurrentMatchRoster();
  }

  // ── Update Match Status ───────────────────────────────────────────────────
  /// Updates match status to "Ongoing" when the host starts the match.
  /// Returns [true] on success, [false] on failure.
  Future<bool> startMatch(String matchId) async {
    log('🟡 [ViewModel] startMatch called — matchId: $matchId');
    log('🟡 [ViewModel] Current match status: $_matchStatus');

    _isUpdatingMatchStatus = true;
    _matchStatusError = null;
    _matchStatus = 'ongoing';
    notifyListeners();

    try {
      log('🚀 [ViewModel] Calling UpdateMatchStatusRepo.updateMatchStatus...');
      log('🚀 [ViewModel] Endpoint: /api/v1/matches/$matchId/status');
      log('🚀 [ViewModel] New status: Ongoing (capitalized)');

      final UpdateMatchStatusRequestModel requestData =
          UpdateMatchStatusRequestModel(status: 'Ongoing');

      final UpdateMatchStatusModel result = await _updateMatchStatusRepo
          .updateMatchStatus(matchId: matchId, data: requestData);

      log('✅ [ViewModel] Match status updated successfully');
      log('✅ [ViewModel] Response status: ${result.status}');
      log('✅ [ViewModel] Match ID: ${result.id}');

      _matchStatus = result.status ?? 'ongoing';
      _isUpdatingMatchStatus = false;
      notifyListeners();

      return true;
    } catch (e, stack) {
      log('❌ [ViewModel] Failed to update match status — error: $e');
      log('📍 [ViewModel] Stacktrace: $stack');

      _matchStatusError = e.toString();
      _matchStatus = 'pending'; // Revert to pending on error
      _isUpdatingMatchStatus = false;
      notifyListeners();

      return false;
    }
  }

  // ── Dispose ────────────────────────────────────────────────────────────────
  @override
  void dispose() {
    log('🗑️ [ViewModel] dispose called');
    ListOfAllUserService().removeListener(_onUsersChanged);
    super.dispose();
  }
}
