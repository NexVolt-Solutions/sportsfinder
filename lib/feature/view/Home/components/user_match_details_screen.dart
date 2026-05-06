import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/Routes/discovery_match_navigation.dart';
import 'package:sport_finding/core/utils/app_snack_bar.dart';
import 'package:sport_finding/Data/model/discovery_match.dart';
import 'package:sport_finding/feature/view/Home/viewModel/host_detail_screen_view_model.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/card_widget.dart';
import 'package:sport_finding/feature/widget/custom_bottom_sheet_widget.dart';
import 'package:sport_finding/feature/widget/custom_button.dart';
import 'package:sport_finding/feature/widget/info_item_widget.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';
import 'package:sport_finding/feature/widget/section_header_widget.dart';
import 'package:sport_finding/feature/widget/user_greeting_widget.dart';
import 'package:sport_finding/feature/widget/user_match_card_widget.dart';
import 'package:sport_finding/feature/widget/match_location_map_card.dart';

/// Match detail UI. Reads [DiscoveryMatch] from [ModalRoute.settings.arguments]
/// only in [build] so we never call [notifyListeners] during dependency changes.
class UserMatchDetailsScreen extends StatefulWidget {
  const UserMatchDetailsScreen({super.key});

  @override
  State<UserMatchDetailsScreen> createState() => _UserMatchDetailsScreenState();
}

class _UserMatchDetailsScreenState extends State<UserMatchDetailsScreen> {
  bool _scheduledInitialBind = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_scheduledInitialBind) return;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is DiscoveryMatch) {
      _scheduledInitialBind = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<HostDetailScreenViewModel>().bindMatch(args);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final routeMatch = args is DiscoveryMatch ? args : null;

    if (routeMatch == null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: context.padSym(h: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppText.noRouteFound,
                  textAlign: TextAlign.center,
                  style: context.appText.text16W500,
                ),
                SizedBox(height: context.h(16)),
                // TextButton(
                //   onPressed: () => Navigator.pop(context),
                //   child: Text(
                //     'Back',
                //     style: context.appText.text16W500.copyWith(
                //       color: context.appColors.primary,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      );
    }

    return Consumer<HostDetailScreenViewModel>(
      builder: (context, model, _) {
        final match = model.currentMatch ?? routeMatch;
        final showPlayedMatchesCard = match.hostMatchesPlayed > 0;
        final isHostedByCurrentUser = match.isHostedByCurrentUser;
        final status = model.matchStatus;
        final isPending = status == 'pending';
        final isOngoing = status == 'ongoing';
        final isCompleted = status == 'completed';
        final isCancelled = status == 'cancelled';
        final joinDisabledByStatus =
            !isHostedByCurrentUser &&
            !model.hasJoined &&
            (!isOngoing || isCancelled || isCompleted);
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
                        title: AppText.matchDetails,
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
                      GestureDetector(
                        onTap: () {
                          final uid = match.hostUserId.trim();
                          final name = match.displayHostName.trim();
                          if (uid.isEmpty || name.isEmpty) return;
                          match.pushPublicProfileForUser(
                            context,
                            userId: uid,
                            displayName: name,
                          );
                        },
                        behavior: HitTestBehavior.opaque,
                        child: UserGreetingWidget(
                          imageUrl: match.hostAvatarUrl,
                          title: match.displayHostName,
                          locName: match.location,
                          subTitle: match.resolvedHostBio,
                          isShow: true,
                        ),
                      ),
                      SizedBox(height: context.h(16)),
                      if (match.isHostedByCurrentUser) ...[
                        NormalText(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          titleText: AppText.youAreHosting,
                          titleColor: context.appColors.primary,
                          titleStyle: context.appText.text14W600,
                        ),
                      ] else ...[
                        if (showPlayedMatchesCard)
                          CardWidget(
                            padding: context.padSym(h: 82, v: 26),
                            child: NormalText(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              titleText: '${match.hostMatchesPlayed}',
                              subText: AppText.matchesPlayed,
                            ),
                          ),
                      ],
                      SizedBox(height: context.h(16)),
                      MatchLocationMapCard(
                        location: match.location,
                        latitude: match.latitude,
                        longitude: match.longitude,
                      ),
                      SizedBox(height: context.h(16)),
                      NormalText(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        titleText: AppText.aboutThisMatch,
                        maxLines: 8,
                        subText: match.aboutText,
                        subAlign: TextAlign.start,
                      ),
                      SizedBox(height: context.h(16)),
                      SectionHeaderWidget(title: AppText.participatedPlayers),
                      if (model.rosterCount == 0) ...[
                        Padding(
                          padding: context.padSym(v: 32),
                          child: Center(  
                            child: NormalText (titleText: AppText.noPlayersOnRoster, titleStyle: context.appText.text14W400.copyWith(
                                color: context.appColors.greyDark,
                              )),
                          ),
                        ),
                      ] else ...[
                        ...List.generate(
                          model.rosterCount,
                          (index) => UserMatchCard(
                            avatarUrl: model.rosterAvatarUrlAt(index),
                            onCardTap: () {
                              final uid = model.rosterUserIdAt(index).trim();
                              final name = model.rosterNameAt(index);
                              if (uid.isEmpty || name.trim().isEmpty) return;
                              match.pushPublicProfileForUser(
                                context,
                                userId: uid,
                                displayName: name,
                              );
                            },
                              title: model.rosterNameAt(index),
                            subTitle: model.rosterSkillAt(index),
                          ),
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
                     right: context.w(20),
                    left: context.w(20),
                  ),
                  child: CustomButton(
                    isLoading: model.isJoinLeaveLoading,
                    text: isHostedByCurrentUser
                        ? AppText.startMatch
                        : isCancelled
                        ? 'Match Cancelled'
                        : isCompleted
                        ? 'Match Completed'
                        : isPending && !model.hasJoined
                        ? 'Match Not Started'
                        : model.hasJoined
                        ? AppText.leaveMatch
                        : AppText.joinMatch,
                    color: isHostedByCurrentUser
                        ? context.appColors.primary
                        : joinDisabledByStatus
                        ? context.appColors.greylight
                        : model.hasJoined
                        ? context.appColors.error
                        : context.appColors.primary,
                    onTap: joinDisabledByStatus
                        ? null
                        : () async {
                                  final matchId = match.id;
                                  if (matchId.isEmpty) {
                                    return;
                                  }

                                  if (isHostedByCurrentUser) {
                                    if (!context.mounted) return;
                                    AppSnackBar.show(
                                      'You are hosting this match.',
                                    );
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
