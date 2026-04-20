import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/Network/list_of_all_user_service.dart';
import 'package:sport_finding/core/Routes/discovery_match_navigation.dart';
import 'package:sport_finding/Data/model/discovery_match.dart';
import 'package:sport_finding/Data/model/UpdateMatch/update_match_model.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
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
import 'package:sport_finding/feature/widget/user_greeting_widget.dart';
import 'package:sport_finding/feature/widget/user_match_card_widget.dart';
import 'package:sport_finding/core/utils/logger.dart';

class HostDetailsScreen extends StatefulWidget {
  const HostDetailsScreen({super.key});

  @override
  State<HostDetailsScreen> createState() => _HostDetailsScreenState();
}

class _HostDetailsScreenState extends State<HostDetailsScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is DiscoveryMatch &&
        context.read<HostDetailScreenViewModel>().currentMatch == null) {
      context.read<HostDetailScreenViewModel>().bindMatch(args);
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

      // Extract time from scheduledAt with AM/PM format
      String timeStr = match.time;
      if (result.scheduledAt != null && result.scheduledAt!.isNotEmpty) {
        try {
          final dt = DateTime.parse(result.scheduledAt!).toLocal();
          final timeOfDay = TimeOfDay.fromDateTime(dt);
          timeStr = timeOfDay.format(context);
        } catch (e) {
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
        date: result.scheduledAt != null
            ? DateTime.parse(
                result.scheduledAt!,
              ).toLocal().toString().split(' ')[0]
            : match.date,
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
    } else if (result != null && result is DiscoveryMatch) {
      debugPrint('✅ [HostDetailsScreen] DiscoveryMatch received');
      if (mounted) {
        model.updateMatchAfterEdit(result);
      }
    } else {
      debugPrint('⚠️ [HostDetailsScreen] Unexpected result type or null');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HostDetailScreenViewModel>(
      builder: (context, model, _) {
        final match = model.currentMatch;

        if (match == null) {
          return Scaffold(
            body: Center(
              child: Text(
                AppText.noRouteFound,
                style: context.appText.text16W500,
              ),
            ),
          );
        }

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
                        trailing: Icon(
                          Icons.edit,
                          color: context.appColors.greyDark,
                          size: 20,
                        ),
                        onTrailingTap: _navigateToEditScreen,
                      ),
                      NormalText(
                        titleText: match.title,
                        subText: match.sportType,
                      ),
                      SizedBox(height: context.h(20)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InfoItem(
                            icon: AppAssets.calendarIcon,
                            title: 'Date',
                            value: match.date,
                          ),
                          InfoItem(
                            icon: AppAssets.clockIcon,
                            title: 'Time',
                            value: match.time,
                          ),
                        ],
                      ),
                      SizedBox(height: context.h(16)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InfoItem(
                            icon: AppAssets.matchesIcon,
                            title: AppText.skillLevel,
                            value: match.skillLevel,
                          ),
                          InfoItem(
                            icon: AppAssets.playerIcon,
                            title: AppText.players,
                            value:
                                '${model.rosterCount}/${match.participantsTotal}',
                          ),
                        ],
                      ),
                      SizedBox(height: context.h(16)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InfoItem(
                            icon: AppAssets.locationIcon,
                            title: AppText.location,
                            value: match.location,
                          ),
                        ],
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
                          title: match.displayHostName,
                          locName: match.location,
                          subTitle: match.resolvedHostBio,
                          isShow: true,
                        ),
                        SizedBox(height: context.h(16)),
                        CardWidget(
                          child: NormalText(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            titleText: '${match.resolvedHostMatchesPlayed}',
                            subText: AppText.matchesPlayed,
                          ),
                        ),
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
                                onActionTap: () => model.removePlayerAt(index),
                                onCardTap: () =>
                                    match.pushPublicProfileForPlayer(
                                      context,
                                      displayName: model.rosterNameAt(index),
                                      userIdSuffix: 'roster_$index',
                                    ),
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
                            SectionHeaderWidget(
                              title: AppText.participatedPlayers,
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
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
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
                        else
                          ListView.builder(
                            itemCount: model.allUsers.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final user = model.allUsers[index];
                              final sport = user.sports?.isNotEmpty == true
                                  ? user.sports!.first
                                  : null;

                              return PersonInvitedCard(
                                playerName: user.fullName,
                                matchName: sport?.sport ?? match.sportType,
                                matchLevel:
                                    sport?.skillLevel ?? match.skillLevel,
                                destance:
                                    user.location?.trim().isNotEmpty == true
                                    ? user.location
                                    : '${match.distanceKm.toStringAsFixed(1)} km',
                                isShow: true,
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
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('User id is missing'),
                                      ),
                                    );
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
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(message)),
                                  );
                                },
                                cardOnTap: () {
                                  ListOfAllUserService().recordProfileView(
                                    user,
                                  );
                                  final uid = user.id?.trim() ?? '';
                                  if (uid.isEmpty) return;
                                  match.pushPublicProfileForUser(
                                    context,
                                    userId: uid,
                                    displayName: user.fullName ?? '',
                                  );
                                },
                              );
                            },
                          ),

                        SizedBox(height: context.h(16)),
                      ],

                      if (model.selectedIndex == 2) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            children: [
                              Container(
                                height: context.h(174),
                                width: context.w(380),
                                decoration: BoxDecoration(
                                  color: context.appColors.blue10,
                                  borderRadius: BorderRadius.circular(
                                    context.radiusR(12),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.topRight,
                                child: Padding(
                                  padding: context.padAll(12),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.fullscreen,
                                        size: 20,
                                      ),
                                      onPressed: () {},
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
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
                                      debugPrint(
                                        '✅ [HostDetailsScreen] Match status updated to ongoing',
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: const Text(
                                            'Match started successfully!',
                                          ),
                                          backgroundColor:
                                              context.appColors.primary,
                                        ),
                                      );
                                    } else {
                                      debugPrint(
                                        '❌ [HostDetailsScreen] Failed to start match',
                                      );
                                      debugPrint(
                                        '❌ [HostDetailsScreen] Error: ${model.matchStatusError}',
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            model.matchStatusError ??
                                                'Failed to start match',
                                          ),
                                          backgroundColor:
                                              context.appColors.error,
                                        ),
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
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(model.joinLeaveError!),
                                          backgroundColor:
                                              context.appColors.error,
                                        ),
                                      );
                                    } else if (result) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: const Text(
                                            'Left match successfully',
                                          ),
                                          backgroundColor:
                                              context.appColors.primary,
                                        ),
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
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(model.joinLeaveError!),
                                        backgroundColor:
                                            context.appColors.error,
                                      ),
                                    );
                                  } else if (result) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                          'Joined match successfully!',
                                        ),
                                        backgroundColor:
                                            context.appColors.primary,
                                      ),
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
