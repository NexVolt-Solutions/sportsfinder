import 'package:flutter/foundation.dart';
import 'package:sport_finding/Data/Repositories/MatchInvitation/invite_action_repository.dart';
import 'package:sport_finding/Data/model/Notification/notification_model.dart';
import 'package:sport_finding/core/Network/notification_service.dart';
import 'package:sport_finding/core/utils/logger.dart';

enum InviteLoadingPhase { accepting, declining }

enum ResolvedInviteAction { accepted, declined }

/// Result of accept/decline so the UI can show snackbars and navigate.
class InviteActionUiOutcome {
  const InviteActionUiOutcome._({
    required this.isSuccess,
    this.message,
    this.navigateToMatchOnAccept = false,
    this.item,
    this.rawError,
  });

  final bool isSuccess;
  final String? message;
  final bool navigateToMatchOnAccept;
  final NotificationModel? item;
  final Object? rawError;

  factory InviteActionUiOutcome.missingMatchId() {
    return const InviteActionUiOutcome._(
      isSuccess: false,
      message: 'Match id is missing',
    );
  }

  factory InviteActionUiOutcome.success({
    required String message,
    required bool navigateToMatchOnAccept,
    required NotificationModel item,
  }) {
    return InviteActionUiOutcome._(
      isSuccess: true,
      message: message,
      navigateToMatchOnAccept: navigateToMatchOnAccept,
      item: item,
    );
  }

  factory InviteActionUiOutcome.failure(Object error) {
    return InviteActionUiOutcome._(isSuccess: false, rawError: error);
  }
}

class NotificationsScreenViewModel extends ChangeNotifier {
  NotificationsScreenViewModel({
    InviteActionRepository? inviteRepository,
  }) : _inviteRepository = inviteRepository ?? InviteActionRepository();

  final InviteActionRepository _inviteRepository;

  final Map<String, InviteLoadingPhase> _inviteLoadingPhase =
      <String, InviteLoadingPhase>{};
  final Map<String, ResolvedInviteAction> _resolvedInviteActions =
      <String, ResolvedInviteAction>{};

  InviteLoadingPhase? invitePhaseFor(String notificationId) =>
      _inviteLoadingPhase[notificationId];

  ResolvedInviteAction? resolvedInviteFor(String notificationId) =>
      _resolvedInviteActions[notificationId];

  void clearInviteState() {
    _inviteLoadingPhase.clear();
    _resolvedInviteActions.clear();
    notifyListeners();
  }

  Future<InviteActionUiOutcome> submitInviteResponse({
    required NotificationModel item,
    required bool accept,
    required NotificationService notificationService,
    required String currentUserId,
  }) async {
    final matchId = item.matchId.trim();
    final actionLabel = accept ? 'accept' : 'decline';

    if (matchId.isEmpty) {
      return InviteActionUiOutcome.missingMatchId();
    }

    if (!accept && currentUserId.trim().isEmpty) {
      return InviteActionUiOutcome.failure(
        Exception('Your profile is still loading. Try again in a moment.'),
      );
    }

    AppLogger.info(
      'Notification action tapped: $actionLabel '
      'for notificationId=${item.id}, matchId=$matchId',
      tag: 'NotificationsScreenVM',
    );

    _inviteLoadingPhase[item.id] = accept
        ? InviteLoadingPhase.accepting
        : InviteLoadingPhase.declining;
    notifyListeners();

    try {
      AppLogger.debug(
        'Hitting $actionLabel invite API for matchId=$matchId',
        tag: 'NotificationsScreenVM',
      );

      final response = accept
          ? await _inviteRepository.acceptInvite(matchId: matchId)
          : await _inviteRepository.declineInvite(
              matchId: matchId,
              inviteeUserId: currentUserId,
            );

      AppLogger.success(
        '${accept ? 'Accept' : 'Decline'} invite API succeeded for '
        'notificationId=${item.id}, matchId=$matchId',
        tag: 'NotificationsScreenVM',
      );

      if (accept) {
        AppLogger.info(
          'Accepted invitation will appear in participated players after '
          'the roster is refreshed for matchId=$matchId',
          tag: 'NotificationsScreenVM',
        );
      } else {
        AppLogger.info(
          'Declined invitation completed for matchId=$matchId',
          tag: 'NotificationsScreenVM',
        );
      }

      await notificationService.markAsRead(item.id);

      _resolvedInviteActions[item.id] = accept
          ? ResolvedInviteAction.accepted
          : ResolvedInviteAction.declined;
      notifyListeners();

      AppLogger.info(
        'Notification invite actions resolved: notificationId=${item.id}',
        tag: 'NotificationsScreenVM',
      );

      final msg = response.message.isNotEmpty
          ? response.message
          : (accept ? 'Invitation accepted' : 'Invitation declined');

      return InviteActionUiOutcome.success(
        message: msg,
        navigateToMatchOnAccept: accept,
        item: item,
      );
    } catch (e) {
      AppLogger.error(
        '$actionLabel invite API failed for notificationId=${item.id}, '
        'matchId=$matchId',
        tag: 'NotificationsScreenVM',
        error: e,
      );
      return InviteActionUiOutcome.failure(e);
    } finally {
      _inviteLoadingPhase.remove(item.id);
      notifyListeners();
    }
  }
}
