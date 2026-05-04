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
import 'package:sport_finding/core/utils/api_error_message.dart';
import 'package:sport_finding/core/utils/logger.dart';

class HostDetailScreenViewModel extends ChangeNotifier {
  static final Map<String, bool> _sessionJoinStateByMatchId = <String, bool>{};
  static final Map<String, Set<String>> _sessionInvitedUserIdsByMatchId =
      <String, Set<String>>{};
  static final Map<String, String> _sessionStatusByMatchId = <String, String>{};
  int selectedIndex = 0;
  final List<String> buttonName = [
    AppText.overview,
    AppText.players,
    AppText.location,
  ];

  bool _isDisposed = false;
  List<String> _rosterNames = [];
  List<String> _rosterSkills = [];
  List<String> _rosterUserIds = [];
  List<String> _rosterAvatarUrls = [];

  // ── Current match being displayed ──────────────────────────────────────────
  DiscoveryMatch? _currentMatch;
  DiscoveryMatch? get currentMatch => _currentMatch;

  int get rosterCount => _rosterNames.length;
  String rosterNameAt(int i) =>
      i >= 0 && i < _rosterNames.length ? _rosterNames[i] : '';
  String rosterSkillAt(int i) =>
      i >= 0 && i < _rosterSkills.length ? _rosterSkills[i] : '';
  String rosterUserIdAt(int i) =>
      i >= 0 && i < _rosterUserIds.length ? _rosterUserIds[i] : '';
  String rosterAvatarUrlAt(int i) =>
      i >= 0 && i < _rosterAvatarUrls.length ? _rosterAvatarUrls[i] : '';

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
  String get matchStatusLabel =>
      _matchStatus.isNotEmpty
          ? _matchStatus[0].toUpperCase() + _matchStatus.substring(1)
          : 'Pending';

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
      _cacheInvitedUserIdsForMatch(trimmedMatchId);
      return response.message;
    } catch (e) {
      _inviteErrorMessage = messageFromApiException(e);
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
      _deleteMatchError = messageFromApiException(e);
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
      // Sync first so we do not send join while server still finalizing a recent leave.
      await refreshRoster();
      if (_hasJoined) {
        log('ℹ️ [ViewModel] joinMatch skipped - user already joined after sync');
        _sessionJoinStateByMatchId[matchId] = true;
        return true;
      }

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

      final errorStr = messageFromApiException(e);
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

      // Some backends need a moment after leave before re-join.
      if (errorStr.contains('unexpected error occurred')) {
        log(
          'ℹ️ [ViewModel] joinMatch transient backend error after leave; retrying once...',
        );
        await Future<void>.delayed(const Duration(milliseconds: 900));
        try {
          await refreshRoster();
          if (_hasJoined) {
            _sessionJoinStateByMatchId[matchId] = true;
            return true;
          }
          final retryResult = await _joinLeaveRepo.joinMatch(matchId);
          log(
            '✅ [ViewModel] joinMatch retry success — message: ${retryResult.message}',
          );
          _hasJoined = true;
          _sessionJoinStateByMatchId[matchId] = true;
          _addCurrentUserToRoster();
          _joinLeaveError = null;
          return true;
        } catch (retryError, retryStack) {
          log('❌ [ViewModel] joinMatch retry failed — error: $retryError');
          log('📍 [ViewModel] joinMatch retry stacktrace: $retryStack');
          _joinLeaveError = retryError.toString();
          return false;
        }
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
      await refreshRoster();
      log('[ViewModel] leaveMatch cached state -> left for matchId: $matchId');
      return true;
    } catch (e, stack) {
      log('❌ [ViewModel] leaveMatch failed — error: $e');
      log('📍 [ViewModel] leaveMatch stacktrace: $stack');

      final errorStr = messageFromApiException(e);
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
    _restoreInvitedUserIdsForMatch(match.id);
    final cachedStatus = _sessionStatusByMatchId[match.id.trim()];
    if (cachedStatus != null && cachedStatus.isNotEmpty) {
      _matchStatus = cachedStatus;
    } else {
      _matchStatus = _normalizeMatchStatus(match.status);
      _sessionStatusByMatchId[match.id.trim()] = _matchStatus;
    }
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
    if (index < _rosterAvatarUrls.length) {
      _rosterAvatarUrls.removeAt(index);
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
      if (index < _rosterAvatarUrls.length) {
        _rosterAvatarUrls.removeAt(index);
      }
      _syncCurrentMatchRoster();
      return response.message;
    } catch (e) {
      _joinLeaveError = messageFromApiException(e);
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
    final avatarUrls = <String>[];

    for (var i = 0; i < match.players.length; i++) {
      final playerName = match.players[i].trim();
      if (playerName.isEmpty) continue;
      if (hostName.isNotEmpty && playerName.toLowerCase() == hostName) {
        continue;
      }
      names.add(playerName);
      skills.add(match.playerSkillAt(i));
      userIds.add('');
      avatarUrls.add('');
    }

    _rosterNames = names;
    _rosterSkills = skills;
    _rosterUserIds = userIds;
    _rosterAvatarUrls = avatarUrls;
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
    final myId = (ProfileService().profile?.id ?? '').trim();
    final names = <String>[];
    final skills = <String>[];
    final userIds = <String>[];
    final avatarUrls = <String>[];
    final invitedUserIdsFromDetail = <String>{};

    for (final participant in detail.participants) {
      final userId = participant.user.id.trim();
      final role = participant.role.trim().toLowerCase();
      if (role.contains('invit') && role.contains('pend') && userId.isNotEmpty) {
        invitedUserIdsFromDetail.add(userId);
      }
      if (!participant.countsAsJoinedPlayer) continue;
      final fullName = participant.user.fullName.trim();
      if (myId.isNotEmpty && userId == myId) {
        // _isCurrentUserInParticipants = true;
      }
      if (fullName.isEmpty) continue;
      if (hostId.isNotEmpty && userId == hostId) continue;
      if (hostName.isNotEmpty && fullName.toLowerCase() == hostName) continue;

      names.add(fullName);
      skills.add(
        detail.skillLevel.trim().isNotEmpty ? detail.skillLevel : 'Intermediate',
      );
      userIds.add(userId);
      avatarUrls.add(participant.user.avatarUrl?.trim() ?? '');
    }

    _rosterNames = names;
    _rosterSkills = skills;
    _rosterUserIds = userIds;
    _rosterAvatarUrls = avatarUrls;
    if (invitedUserIdsFromDetail.isNotEmpty) {
      _safeInvitedUserIds
        ..clear()
        ..addAll(invitedUserIdsFromDetail);
      _cacheInvitedUserIdsForMatch(detail.id);
    }
    final resolvedStatus = _normalizeMatchStatus(detail.status);
    _matchStatus = resolvedStatus;
    if (detail.id.trim().isNotEmpty) {
      _sessionStatusByMatchId[detail.id.trim()] = resolvedStatus;
    }
    AppLogger.info(
      'Stored participated players from backend for matchId=${detail.id}: '
      'players=$_rosterNames',
      tag: 'HostDetailVM',
    );
    _mergeMatchMetadataFromDetail(detail);
    _syncCurrentMatchRoster();
  }

  /// Fills title, schedule, host, location, etc. from [GET /api/v1/matches/{id}]
  /// so push-opened stubs and partial route args match the API.
  void _mergeMatchMetadataFromDetail(MatchDetailResponse detail) {
    final m = _currentMatch;
    if (m == null) return;

    final loc = detail.location.trim().isNotEmpty
        ? detail.location.trim()
        : detail.facilityAddress.trim();
    final dateStr = detail.scheduledDate.trim().isNotEmpty
        ? detail.scheduledDate.trim()
        : m.date;
    final timeStr = detail.scheduledTime.trim().isNotEmpty
        ? detail.scheduledTime.trim()
        : m.time;
    final hostId = detail.host.id.trim();
    final hostName = detail.host.fullName.trim();

    _currentMatch = m.copyWith(
      title: detail.title.trim().isNotEmpty ? detail.title.trim() : m.title,
      sportType: detail.sport.trim().isNotEmpty ? detail.sport.trim() : m.sportType,
      location: loc.isNotEmpty ? loc : m.location,
      date: dateStr,
      time: timeStr,
      hostUserId: hostId.isNotEmpty ? hostId : m.hostUserId,
      hostDisplayName: hostName.isNotEmpty ? hostName : m.hostDisplayName,
      hostAvatarUrl: detail.host.avatarUrl ?? m.hostAvatarUrl,
      skillLevel: detail.skillLevel.trim().isNotEmpty
          ? detail.skillLevel.trim()
          : m.skillLevel,
      latitude: detail.latitude ?? m.latitude,
      longitude: detail.longitude ?? m.longitude,
      participantsTotal: detail.maxPlayers > 0 ? detail.maxPlayers : m.participantsTotal,
      status: _normalizeMatchStatus(detail.status),
    );
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

  void _cacheInvitedUserIdsForMatch(String matchId) {
    final key = matchId.trim();
    if (key.isEmpty) return;
    _sessionInvitedUserIdsByMatchId[key] = Set<String>.from(_safeInvitedUserIds);
  }

  void _restoreInvitedUserIdsForMatch(String matchId) {
    final key = matchId.trim();
    final cached = _sessionInvitedUserIdsByMatchId[key];
    _safeInvitedUserIds
      ..clear()
      ..addAll(cached ?? const <String>{});
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
    _rosterAvatarUrls.add(ProfileService().profile?.avatarUrl?.trim() ?? '');
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
    if (index < _rosterAvatarUrls.length) {
      _rosterAvatarUrls.removeAt(index);
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

    if (_matchStatus == 'ongoing') {
      log('ℹ️ [ViewModel] Match is already ongoing. Skipping status update call.');
      return true;
    }
    if (_matchStatus == 'completed') {
      _matchStatusError = 'Match is already completed';
      log('ℹ️ [ViewModel] Match is already completed. Start is not allowed.');
      return false;
    }

    return _updateMatchStatus(matchId: matchId, nextStatus: 'Ongoing');
  }

  Future<bool> completeMatch(String matchId) async {
    if (_matchStatus == 'completed') {
      return true;
    }
    if (_matchStatus == 'cancelled') {
      _matchStatusError = 'Cancelled match cannot be completed';
      return false;
    }
    return _updateMatchStatus(matchId: matchId, nextStatus: 'Completed');
  }

  Future<bool> cancelMatch(String matchId) async {
    if (_matchStatus == 'cancelled') {
      return true;
    }
    if (_matchStatus == 'ongoing') {
      _matchStatusError =
          'This match is already ongoing and can only be completed right now.';
      return false;
    }
    if (_matchStatus == 'completed') {
      _matchStatusError = 'Completed match cannot be cancelled';
      return false;
    }
    return _updateMatchStatus(matchId: matchId, nextStatus: 'Cancelled');
  }

  Future<bool> _updateMatchStatus({
    required String matchId,
    required String nextStatus,
  }) async {
    final previousStatus = _matchStatus;
    _isUpdatingMatchStatus = true;
    _matchStatusError = null;
    _matchStatus = _normalizeMatchStatus(nextStatus);
    notifyListeners();

    try {
      log('🚀 [ViewModel] Calling UpdateMatchStatusRepo.updateMatchStatus...');
      log('🚀 [ViewModel] Endpoint: /api/v1/matches/$matchId/status');
      log('🚀 [ViewModel] New status: $nextStatus');

      final UpdateMatchStatusRequestModel requestData =
          UpdateMatchStatusRequestModel(status: nextStatus);

      final UpdateMatchStatusModel result = await _updateMatchStatusRepo
          .updateMatchStatus(matchId: matchId, data: requestData);

      log('✅ [ViewModel] Match status updated successfully');
      log('✅ [ViewModel] Response status: ${result.status}');
      log('✅ [ViewModel] Match ID: ${result.id}');

      final resolvedStatus = _normalizeMatchStatus(result.status);
      _matchStatus = resolvedStatus;
      _sessionStatusByMatchId[matchId.trim()] = resolvedStatus;
      _isUpdatingMatchStatus = false;
      notifyListeners();
      return true;
    } catch (e, stack) {
      log('❌ [ViewModel] Failed to update match status — error: $e');
      log('📍 [ViewModel] Stacktrace: $stack');
      _matchStatusError = messageFromApiException(e);
      _matchStatus = previousStatus;
      _isUpdatingMatchStatus = false;
      notifyListeners();
      return false;
    }
  }

  String _normalizeMatchStatus(String? rawStatus) {
    final value = rawStatus?.trim().toLowerCase() ?? '';
    // Backend may send "Open" for not-started matches.
    // Keep a single internal pre-start status to avoid UI branching issues.
    if (value == 'open') {
      return 'pending';
    }
    if (value == 'ongoing' ||
        value == 'completed' ||
        value == 'pending' ||
        value == 'cancelled') {
      return value;
    }
    if (value.isEmpty) return 'pending';
    return value;
  }

  // ── Dispose ────────────────────────────────────────────────────────────────
  @override
  void dispose() {
    _isDisposed = true;
    log('🗑️ [ViewModel] dispose called');
    ListOfAllUserService().removeListener(_onUsersChanged);
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (_isDisposed) return;
    super.notifyListeners();
  }
}
