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
import 'package:sport_finding/Data/Repositories/MatchInvitation/match_invitation_repository.dart';
import 'package:sport_finding/Data/Repositories/JoinMatch/match_join_leave_repository.dart';
import 'package:sport_finding/Data/Repositories/UpdateMatchStatus/update_match_status_repo.dart';
import 'package:sport_finding/Data/model/JoinMatch/join_leave_match_response.dart';
import 'package:sport_finding/Data/model/UpdateMatchStatus/update_match_status_model.dart';
import 'package:sport_finding/Data/model/llst_of_all_user_model.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Network/list_of_all_user_service.dart';
import 'package:sport_finding/Data/model/discovery_match.dart';
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

  // ── Match Status state ─────────────────────────────────────────────────────
  final UpdateMatchStatusRepo _updateMatchStatusRepo = UpdateMatchStatusRepo();
  bool _isUpdatingMatchStatus = false;
  bool get isUpdatingMatchStatus => _isUpdatingMatchStatus;

  String _matchStatus = 'pending'; // pending, ongoing, completed
  String get matchStatus => _matchStatus;

  String? _matchStatusError;
  String? get matchStatusError => _matchStatusError;

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
    if (_boundMatchId == match.id) return;
    _boundMatchId = match.id;
    _currentMatch = match;
    _rosterNames = List<String>.from(match.players);
    _rosterSkills = List.generate(
      match.players.length,
      (i) => match.playerSkillAt(i),
    );

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
    notifyListeners();
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
