import 'package:flutter/material.dart';
import 'package:sport_finding/Data/Repositories/MatchInvitation/match_invitation_repository.dart';
import 'package:sport_finding/core/utils/logger.dart';

class MatchInvitationViewModel extends ChangeNotifier {
  MatchInvitationViewModel({
    required MatchInvitationRepository repository,
  }) : _repository = repository;

  final MatchInvitationRepository _repository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  final List<String> _selectedUserIds = [];
  List<String> get selectedUserIds => List.unmodifiable(_selectedUserIds);

  Future<String?> invitePlayer({
    required String matchId,
    required String userId,
  }) async {
    try {
      AppLogger.info('Inviting player...', tag: 'InvitationVM');

      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _repository.invitePlayer(
        matchId: matchId,
        userId: userId,
      );

      AppLogger.success(
        'Player invited: ${response.message}',
        tag: 'InvitationVM',
      );
      return null;
    } catch (e) {
      _errorMessage = _parseError(e);
      AppLogger.error(
        'Failed to invite player',
        tag: 'InvitationVM',
        error: e,
      );
      return _errorMessage;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> inviteSelectedPlayers({required String matchId}) async {
    if (_selectedUserIds.isEmpty) {
      return 'Please select at least one player to invite';
    }

    try {
      AppLogger.info(
        'Inviting ${_selectedUserIds.length} players...',
        tag: 'InvitationVM',
      );

      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final results = await _repository.inviteMultiplePlayers(
        matchId: matchId,
        userIds: _selectedUserIds,
      );

      AppLogger.success(
        '${results.length} players invited successfully',
        tag: 'InvitationVM',
      );

      _selectedUserIds.clear();
      return null;
    } catch (e) {
      _errorMessage = _parseError(e);
      AppLogger.error(
        'Failed to invite multiple players',
        tag: 'InvitationVM',
        error: e,
      );
      return _errorMessage;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void togglePlayerSelection(String userId) {
    if (_selectedUserIds.contains(userId)) {
      _selectedUserIds.remove(userId);
    } else {
      _selectedUserIds.add(userId);
    }
    notifyListeners();
  }

  bool isPlayerSelected(String userId) {
    return _selectedUserIds.contains(userId);
  }

  void clearSelections() {
    _selectedUserIds.clear();
    notifyListeners();
  }

  String _parseError(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('422')) {
      return 'Invalid match or user information';
    }
    if (errorString.contains('401')) {
      return 'You are not authorized to invite players';
    }
    if (errorString.contains('403')) {
      return 'Only the match host can invite players';
    }
    if (errorString.contains('404')) {
      return 'Match or user not found';
    }
    if (errorString.contains('network')) {
      return 'Network error. Please check your connection';
    }

    return 'Failed to send invitation. Please try again';
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
