import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/Data/model/DeleteMAtch/delete_match_Model.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/Network/deleted_matches_service.dart';
import 'package:sport_finding/core/Network/list_of_all_user_service.dart';
import 'package:sport_finding/core/Network/notification_service.dart';
import 'package:sport_finding/core/Routes/discovery_match_navigation.dart';
import 'package:sport_finding/Data/model/discovery_match.dart';
import 'package:sport_finding/Data/model/UpdateMatch/update_match_model.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/core/utils/app_snack_bar.dart';
import 'package:sport_finding/feature/view/Home/viewModel/host_detail_screen_view_model.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/app_svg_icon.dart';
import 'package:sport_finding/feature/widget/card_widget.dart';
import 'package:sport_finding/feature/widget/custom_bottom_sheet_widget.dart';
import 'package:sport_finding/feature/widget/custom_button.dart';
import 'package:sport_finding/feature/widget/info_item_widget.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';
import 'package:sport_finding/feature/widget/person_invited_card.dart';
import 'package:sport_finding/feature/widget/section_header_widget.dart';
import 'package:sport_finding/feature/widget/shimmer_loading.dart';
import 'package:sport_finding/feature/widget/user_greeting_widget.dart';
import 'package:sport_finding/feature/widget/user_match_card_widget.dart';
import 'package:sport_finding/feature/widget/match_location_map_card.dart';
import 'package:sport_finding/core/utils/logger.dart';

class HostDetailsScreen extends StatefulWidget {
  const HostDetailsScreen({super.key});

  @override
  State<HostDetailsScreen> createState() => _HostDetailsScreenState();
}

class _HostDetailsScreenState extends State<HostDetailsScreen> {
  bool _scheduledInitialBind = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_scheduledInitialBind) return;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is DiscoveryMatch &&
        !DeletedMatchesService().isDeleted(args.id) &&
        context.read<HostDetailScreenViewModel>().currentMatch == null) {
      _scheduledInitialBind = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<HostDetailScreenViewModel>().bindMatch(args);
      });
    }
  }

  void _navigateToEditScreen() async {
    final model = context.read<HostDetailScreenViewModel>();
    final match = model.currentMatch;

    if (match == null) {
      debugPrint('❌ [HostDetailsScreen] No match to edit');
      return;
    }

    final result = await Navigator.pushNamed(
      context,
      RoutesName.editMatchScreen,
      arguments: match,
    );
    if (!mounted) return;

    debugPrint(
      '🔵 [HostDetailsScreen] Navigation returned with result: $result',
    );
    debugPrint('🔵 [HostDetailsScreen] Result type: ${result.runtimeType}');

    // Handle returned updated data
    if (result != null && result is UpdateMatchModel) {
      debugPrint('✅ [HostDetailsScreen] UpdateMatchModel received');
      debugPrint('📝 [HostDetailsScreen] Updated title: ${result.title}');
      debugPrint('📝 [HostDetailsScreen] Updated sport: ${result.sport}');
      debugPrint(
        '📝 [HostDetailsScreen] Current match sport BEFORE: ${match.sportType}',
      );

      String dateStr = match.date;
      String timeStr = match.time;
      if (result.scheduledAt != null && result.scheduledAt!.isNotEmpty) {
        try {
          final dt = DateTime.parse(result.scheduledAt!).toLocal();
          final dd = dt.day.toString().padLeft(2, '0');
          final mm = dt.month.toString().padLeft(2, '0');
          dateStr = '$dd/$mm/${dt.year}';
          final timeOfDay = TimeOfDay.fromDateTime(dt);
          timeStr = timeOfDay.format(context);
        } catch (e) {
          dateStr = match.date;
          timeStr = match.time;
        }
      }

      // Convert UpdateMatchModel to updated DiscoveryMatch
      final updatedMatch = DiscoveryMatch(
        id: result.id ?? match.id,
        title: result.title ?? match.title,
        distanceKm: match.distanceKm,
        sportType: result.sport ?? match.sportType,
        location: result.location ?? match.location,
        date: dateStr,
        time: timeStr,
        participantsJoined: match.participantsJoined,
        participantsTotal: result.maxPlayers ?? match.participantsTotal,
        players: match.players,
        hostUserId: match.hostUserId,
        hostDisplayName: match.hostDisplayName,
        skillLevel: result.skillLevel ?? match.skillLevel,
        matchDescription: result.description ?? match.matchDescription,
        hostBio: match.hostBio,
        playerSkills: match.playerSkills,
        hostMatchesPlayed: match.hostMatchesPlayed,
        latitude: result.latitude ?? match.latitude,
        longitude: result.longitude ?? match.longitude,
      );

      debugPrint(
        '📝 [HostDetailsScreen] New match title: ${updatedMatch.title}',
      );
      debugPrint(
        '📝 [HostDetailsScreen] New match sport: ${updatedMatch.sportType}',
      );
      debugPrint('📝 [HostDetailsScreen] New match time: ${updatedMatch.time}');

      if (mounted) {
        model.updateMatchAfterEdit(updatedMatch);
        debugPrint('✅ [HostDetailsScreen] updateMatchAfterEdit() called');
        debugPrint(
          '✅ [HostDetailsScreen] Model current match sport AFTER: ${model.currentMatch?.sportType}',
        );
      }
    } else if (result != null && result is DeleteMatchModel) {
      debugPrint(
        '[HostDetailsScreen] DeleteMatchModel received: ${result.matchId}',
      );
      if (!mounted) return;
      Navigator.pop(context, result);
    } else if (result != null && result is DiscoveryMatch) {
      debugPrint('✅ [HostDetailsScreen] DiscoveryMatch received');
      if (mounted) {
        model.updateMatchAfterEdit(result);
      }
    } else {
      debugPrint('⚠️ [HostDetailsScreen] Unexpected result type or null');
    }
  }

  Future<void> _deleteMatchFromAppBar() async {
    final model = context.read<HostDetailScreenViewModel>();
    final match = model.currentMatch;
    if (match == null) {
      AppLogger.warning(
        'Delete icon tapped but no match is currently bound',
        tag: 'HostDetailsScreen',
      );
      return;
    }

    AppLogger.info(
      'Delete icon tapped for matchId: ${match.id}',
      tag: 'HostDetailsScreen',
    );

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppText.deleteMatchConfirmationTitle),
        content: const Text(AppText.deleteMatchConfirmationMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(AppText.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(AppText.deleteMatch),
          ),
        ],
      ),
    );

    AppLogger.debug(
      'Delete confirmation result: $shouldDelete',
      tag: 'HostDetailsScreen',
    );
    if (shouldDelete != true || !mounted) {
      AppLogger.info(
        'Delete flow cancelled by user or widget was unmounted',
        tag: 'HostDetailsScreen',
      );
      return;
    }

    final result = await model.deleteCurrentMatch();
    if (!mounted) return;

    if (result == null) {
      AppLogger.warning(
        'Delete API returned null result. Error: ${model.deleteMatchError}',
        tag: 'HostDetailsScreen',
      );
      AppSnackBar.show(
        model.deleteMatchError ?? AppText.failedToDeleteMatch,
        backgroundColor: context.appColors.error,
      );
      return;
    }

    AppLogger.info(
      'Delete API succeeded. Refreshing notifications for current user.',
      tag: 'HostDetailsScreen',
    );
    await context.read<NotificationService>().fetchNotifications();
    if (!mounted) return;

    AppLogger.info(
      'Notification refresh completed after deleting matchId: ${result.matchId}',
      tag: 'HostDetailsScreen',
    );
    AppLogger.warning(
      'Participant notifications depend on backend support. The app can only show notifications already created by the server.',
      tag: 'HostDetailsScreen',
    );

    DeletedMatchesService().markDeleted(result.matchId);
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HostDetailScreenViewModel>(
      builder: (context, model, _) {
        final match = model.currentMatch;

        if (match == null) {
          AppLogger.warning(
            'No match found while building HostDetailsScreen',
            tag: 'HostDetailsScreen',
          );
          return Scaffold(
            body: Center(
              child: Text(
                AppText.noRouteFound,
                style: context.appText.text16W500,
              ),
            ),
          );
        }

        final showPlayedMatchesCard = match.hostMatchesPlayed > 0;
        return Scaffold(
          backgroundColor: context.appColors.surface,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: MainFrame(
                  child: ListView(
                    padding: context.padSym(h: 20),
                    children: [
                      AppBarWidget(
                        onLeadingTap: () => Navigator.pop(context),
                        title: AppText.hostMatchDetails,
                        trailingActions: [
                          GestureDetector(
                            onTap: model.isDeletingMatch
                                ? null
                                : _deleteMatchFromAppBar,
                            behavior: HitTestBehavior.opaque,
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: model.isDeletingMatch
                                  ? CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: context.appColors.error,
                                    )
                                  : Icon(
                                      Icons.delete,
                                      color: context.appColors.error,
                                      size: 20,
                                    ),
                            ),
                          ),

                          GestureDetector(
                            onTap: _navigateToEditScreen,
                            behavior: HitTestBehavior.opaque,
                            child: Icon(
                              Icons.edit,
                              color: context.appColors.greyDark,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      NormalText(
                        titleText: match.title,
                        subText: match.sportType,
                      ),
                      SizedBox(height: context.h(20)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: InfoItem(
                              icon: AppAssets.calendarIcon,
                              title: 'Date',
                              value: match.date,
                            ),
                          ),
                          SizedBox(width: context.w(12)),
                          Expanded(
                            child: InfoItem(
                              icon: AppAssets.clockIcon,
                              title: 'Time',
                              value: match.time,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: context.h(16)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: InfoItem(
                              icon: AppAssets.matchesIcon,
                              title: AppText.skillLevel,
                              value: match.skillLevel,
                            ),
                          ),
                          SizedBox(width: context.w(12)),
                          Expanded(
                            child: InfoItem(
                              icon: AppAssets.playerIcon,
                              title: AppText.players,
                              value:
                                  '${model.rosterCount}/${match.participantsTotal}',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: context.h(16)),
                      InfoItem(
                        icon: AppAssets.locationIcon,
                        title: AppText.location,
                        value: match.location,
                        maxLines: 3,
                      ),
                      SizedBox(height: context.h(16)),
                      Card(
                        child: Padding(
                          padding: context.padSym(h: 12),
                          child: Row(
                            children: List.generate(model.buttonName.length, (
                              index,
                            ) {
                              final isSelected = model.selectedIndex == index;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () => model.changeIndex(index),
                                  behavior: HitTestBehavior.opaque,
                                  child: Center(
                                    child: isSelected
                                        ? CardWidget(
                                            padding: context.padSym(h: 8, v: 8),
                                            child: NormalText(
                                              titleText:
                                                  model.buttonName[index],
                                              titleColor:
                                                  context.appColors.primary,
                                              titleFontSize: 14,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          )
                                        : Padding(
                                            padding: context.padSym(h: 8, v: 8),
                                            child: NormalText(
                                              subText: model.buttonName[index],
                                              subColor:
                                                  context.appColors.greylight,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                      SizedBox(height: context.h(16)),
                      if (model.selectedIndex == 0) ...[
                        UserGreetingWidget(
                          imageUrl: match.hostAvatarUrl,
                          title: match.displayHostName,
                          locName: match.location,
                          subTitle: match.resolvedHostBio,
                          isShow: true,
                        ),
                        if (showPlayedMatchesCard) ...[
                          SizedBox(height: context.h(16)),
                          CardWidget(
                            child: NormalText(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              titleText: '${match.hostMatchesPlayed}',
                              subText: AppText.matchesPlayed,
                            ),
                          ),
                        ],
                        SizedBox(height: context.h(16)),
                        NormalText(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          titleText: AppText.aboutThisMatch,
                          sizeBoxheight: context.h(8),
                          maxLines: 8,
                          subText: match.aboutText,

                          subAlign: TextAlign.start,
                        ),
                        SizedBox(height: context.h(16)),
                        SectionHeaderWidget(title: AppText.participatedPlayers),
                        if (model.rosterCount == 0)
                          Padding(
                            padding: context.padSym(v: 12),
                            child: Text(
                              AppText.noPlayersOnRoster,
                              style: context.appText.text14W400.copyWith(
                                color: context.appColors.greyDark,
                              ),
                            ),
                          )
                        else
                          ListView.builder(
                            itemCount: model.rosterCount,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return UserMatchCard(
                                avatarUrl: model.rosterAvatarUrlAt(index),
                                onActionTap: () async {
                                  final shouldRemove = await showDialog<bool>(
                                    context: context,
                                    builder: (dialogContext) => AlertDialog(
                                      title: const Text('Remove Player'),
                                      content: Text(
                                        'Are you sure you want to remove ${model.rosterNameAt(index)} from this match?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(
                                            dialogContext,
                                            false,
                                          ),
                                          child: const Text(AppText.cancel),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(
                                            dialogContext,
                                            true,
                                          ),
                                          child: const Text('Remove'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (shouldRemove != true ||
                                      !context.mounted) {
                                    return;
                                  }
                                  final message = await model
                                      .removePlayerFromMatchAt(index);
                                  if (!context.mounted) return;
                                  if (message != null && message.isNotEmpty) {
                                    AppSnackBar.show(message);
                                  } else if (model.joinLeaveError != null) {
                                    AppSnackBar.show(
                                      model.joinLeaveError!,
                                      backgroundColor: context.appColors.error,
                                    );
                                  }
                                },
                                onCardTap: () {
                                  final uid = model
                                      .rosterUserIdAt(index)
                                      .trim();
                                  final name = model.rosterNameAt(index);
                                  if (uid.isEmpty || name.trim().isEmpty) {
                                    return;
                                  }
                                  match.pushPublicProfileForUser(
                                    context,
                                    userId: uid,
                                    displayName: name,
                                  );
                                },
                                title: model.rosterNameAt(index),
                                subTitle: model.rosterSkillAt(index),
                                showActionIcon: true,
                              );
                            },
                          ),
                        SizedBox(height: context.h(16)),
                      ],
                      if (model.selectedIndex == 1) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppText.participatedPlayers,
                              style: context.appText.text16W500.copyWith(
                                color: context.appColors.onSurface,
                              ),
                            ),
                            // ✅ Refresh button
                            if (!model.isLoadingUsers)
                              GestureDetector(
                                onTap: () => model.refreshUsers(),
                                child: Icon(
                                  Icons.refresh,
                                  color: context.appColors.primary,
                                  size: 24,
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: context.h(8)),

                        // ── loading state ──────────────────────────────────────────
                        if (model.isLoadingUsers)
                          const _HostPlayersShimmer()
                        // ── error state ────────────────────────────────────────────
                        else if (model.usersFetchError != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding: context.padSym(v: 8),
                                child: Text(
                                  model.usersFetchError!,
                                  style: context.appText.text14W400.copyWith(
                                    color: context.appColors.greyDark,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => model.refreshUsers(),
                                child: Container(
                                  padding: context.padSym(h: 16, v: 8),
                                  decoration: BoxDecoration(
                                    color: context.appColors.primary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Retry',
                                    style: context.appText.text14Bold.copyWith(
                                      color: context.appColors.onPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        else if (model.allUsers.isEmpty)
                          Column(
                            children: [
                              SizedBox(height: context.h(12)),
                              Text(
                                AppText.noUsersFound,
                                style: context.appText.text14W400.copyWith(
                                  color: context.appColors.greyDark,
                                ),
                              ),
                              SizedBox(height: context.h(16)),
                              GestureDetector(
                                onTap: () => model.refreshUsers(),
                                child: Container(
                                  padding: context.padSym(h: 16, v: 8),
                                  decoration: BoxDecoration(
                                    color: context.appColors.primary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Refresh',
                                    style: context.appText.text14Bold.copyWith(
                                      color: context.appColors.onPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        // ── all users from API ─────────────────────────────────────
                        else ...[
                          SizedBox(height: context.h(4)),
                          ...List.generate(model.allUsers.length, (index) {
                            final user = model.allUsers[index];
                            final sport = user.sports?.isNotEmpty == true
                                ? user.sports!.first
                                : null;

                            return PersonInvitedCard(
                              avatarUrl: user.avatarUrl,
                              playerName: user.fullName,
                              matchName: sport?.sport ?? match.sportType,
                              matchLevel: sport?.skillLevel ?? match.skillLevel,
                              destance: user.location?.trim().isNotEmpty == true
                                  ? user.location
                                  : '${match.distanceKm.toStringAsFixed(1)} km',
                              isShow: true,
                              isInvited: model.isUserAlreadyInvited(
                                user.id?.trim() ?? '',
                              ),
                              isLoading: model.isInvitingUser(
                                user.id?.trim() ?? '',
                              ),
                              ontap: () async {
                                final userId = user.id?.trim() ?? '';
                                AppLogger.info(
                                  'Invite button tapped from HostDetailsScreen',
                                  tag: 'HostDetailsScreen',
                                );
                                AppLogger.debug(
                                  'Tapped matchId: ${match.id}',
                                  tag: 'HostDetailsScreen',
                                );
                                AppLogger.debug(
                                  'Tapped userId: $userId',
                                  tag: 'HostDetailsScreen',
                                );
                                if (userId.isEmpty) {
                                  if (!context.mounted) return;
                                  AppSnackBar.show('User id is missing');
                                  return;
                                }

                                final message = await model.inviteUserToMatch(
                                  matchId: match.id,
                                  userId: userId,
                                );

                                AppLogger.debug(
                                  'Invite result message: $message',
                                  tag: 'HostDetailsScreen',
                                );
                                if (!context.mounted || message == null) {
                                  return;
                                }
                                AppSnackBar.show(message);
                              },
                              cardOnTap: () {
                                ListOfAllUserService().recordProfileView(user);
                                final uid = user.id?.trim() ?? '';
                                if (uid.isEmpty) return;
                                match.pushPublicProfileForUser(
                                  context,
                                  userId: uid,
                                  displayName: user.fullName ?? '',
                                );
                              },
                            );
                          }),
                        ],

                        SizedBox(height: context.h(16)),
                      ],

                      if (model.selectedIndex == 2) ...[
                        MatchLocationMapCard(
                          location: match.location,
                          latitude: match.latitude,
                          longitude: match.longitude,
                        ),
                        SizedBox(height: context.h(16)),
                        SectionHeaderWidget(title: match.location),
                        SizedBox(height: context.h(8)),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppSvgIcon(
                              icon: AppAssets.locationIcon,
                              color: context.appColors.greylight,
                            ),
                            SizedBox(width: context.w(4)),
                            Expanded(
                              child: NormalText(
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                subText: match.location,
                                subColor: context.appColors.greylight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.only(
                    top: context.h(5),
                    bottom: context.h(20),
                    right: context.w(20),
                    left: context.w(20),
                  ),
                  child:
                      model.isJoinLeaveLoading ||
                          (model.isUpdatingMatchStatus &&
                              match.isHostedByCurrentUser)
                      // ── Loading state ─────────────────────────────────────────
                      ? const Center(child: CircularProgressIndicator())
                      // ── Join / Leave button ───────────────────────────────────
                      : CustomButton(
                          text: match.isHostedByCurrentUser
                              ? model.matchStatus == 'ongoing'
                                    ? 'Ongoing'
                                    : model.matchStatus == 'completed'
                                    ? 'Completed'
                                    : AppText.startMatching
                              : model.hasJoined
                              ? AppText.leaveMatch
                              : AppText.joinMatch,
                          color: match.isHostedByCurrentUser
                              ? model.matchStatus == 'completed'
                                    ? context.appColors.greyDark
                                    : context.appColors.primary
                              : model.hasJoined
                              ? context
                                    .appColors
                                    .error // red for Leave
                              : context.appColors.primary, // primary for Join
                          onTap:
                              model.matchStatus == 'completed' &&
                                  match.isHostedByCurrentUser
                              ? null
                              : () async {
                                  final matchId = match.id;
                                  if (matchId.isEmpty) {
                                    return;
                                  }

                                  // ── START MATCH flow (host) ────────────────────────
                                  if (match.isHostedByCurrentUser) {
                                    debugPrint(
                                      '🟡 [HostDetailsScreen] Start Match button tapped',
                                    );
                                    debugPrint(
                                      '🟡 [HostDetailsScreen] Match ID: $matchId',
                                    );
                                    debugPrint(
                                      '🟡 [HostDetailsScreen] Current match status: ${model.matchStatus}',
                                    );

                                    final success = await model.startMatch(
                                      matchId,
                                    );

                                    if (!context.mounted) return;

                                    if (success) {
                                      AppSnackBar.show(
                                        'Match started successfully!',
                                        backgroundColor:
                                            context.appColors.primary,
                                      );
                                      Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        RoutesName.bottomBarScreen,
                                        (route) => false,
                                        arguments: 2,
                                      );
                                    } else {
                                      debugPrint(
                                        '❌ [HostDetailsScreen] Failed to start match',
                                      );
                                      debugPrint(
                                        '❌ [HostDetailsScreen] Error: ${model.matchStatusError}',
                                      );
                                      AppSnackBar.show(
                                        model.matchStatusError ??
                                            'Failed to start match',
                                        backgroundColor:
                                            context.appColors.error,
                                      );
                                    }
                                    return;
                                  }
                                  if (model.hasJoined) {
                                    final result = await model.leaveMatch(
                                      matchId,
                                    );
                                    if (!context.mounted) return;
                                    if (!result &&
                                        model.joinLeaveError != null) {
                                      AppSnackBar.show(
                                        model.joinLeaveError!,
                                        backgroundColor:
                                            context.appColors.error,
                                      );
                                    } else if (result) {
                                      AppSnackBar.show(
                                        'Left match successfully',
                                        backgroundColor:
                                            context.appColors.primary,
                                      );
                                    }
                                    return;
                                  }

                                  // ── Check if match is full ─────────────────────────
                                  final int roster = model.rosterCount;
                                  final int total = match.participantsTotal;
                                  final bool isFull = roster >= total;

                                  if (isFull) {
                                    if (!context.mounted) return;
                                    showDialog(
                                      context: context,
                                      barrierDismissible: true,
                                      builder: (dialogContext) =>
                                          CustomBottomSheetWidget(
                                            isCenter: true,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                SvgPicture.asset(
                                                  AppAssets
                                                      .joiningMatchPeopelIcon,
                                                  fit: BoxFit.scaleDown,
                                                ),
                                                SizedBox(height: context.h(16)),
                                                NormalText(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  titleText:
                                                      AppText.matchIsFull,
                                                  maxLines: 5,
                                                  subAlign: TextAlign.center,
                                                  subText: AppText
                                                      .thisMatchHasReachedItsMaximumCapacity,
                                                ),
                                              ],
                                            ),
                                          ),
                                    );
                                    return;
                                  }
                                  // ── JOIN flow ──────────────────────────────────────
                                  final result = await model.joinMatch(matchId);
                                  if (!context.mounted) return;

                                  if (!result && model.joinLeaveError != null) {
                                    AppSnackBar.show(
                                      model.joinLeaveError!,
                                      backgroundColor: context.appColors.error,
                                    );
                                  } else if (result) {
                                    AppSnackBar.show(
                                      'Joined match successfully!',
                                      backgroundColor:
                                          context.appColors.primary,
                                    );
                                  }
                                },
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HostPlayersShimmer extends StatelessWidget {
  const _HostPlayersShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: List.generate(
          3,
          (_) => Padding(
            padding: EdgeInsets.only(bottom: context.h(12)),
            child: Row(
              children: const [
                ShimmerBox(width: 52, height: 52, shape: BoxShape.circle),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(width: 140, height: 14),
                      SizedBox(height: 8),
                      ShimmerBox(width: 100, height: 12),
                    ],
                  ),
                ),
                SizedBox(width: 12),
                ShimmerBox(width: 72, height: 34, radius: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
