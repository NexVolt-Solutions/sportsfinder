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
import 'package:sport_finding/feature/view/BottomBar/Components/Home/viewModel/host_detail_screen_view_model.dart';
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
    if (args is DiscoveryMatch) {
      context.read<HostDetailScreenViewModel>().bindMatch(args);
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final match = args is DiscoveryMatch ? args : null;

    if (match == null) {
      return Scaffold(
        body: Center(
          child: Text(AppText.noRouteFound, style: context.appText.text16W500),
        ),
      );
    }

    return Consumer<HostDetailScreenViewModel>(
      builder: (context, model, _) => Scaffold(
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
                                            titleText: model.buttonName[index],
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
                              onCardTap: () => match.pushPublicProfileForPlayer(
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
                          children: [
                            Padding(
                              padding: context.padSym(v: 8),
                              child: Text(
                                '❌ Error loading users:\n${model.usersFetchError}',
                                style: context.appText.text14W400.copyWith(
                                  color: context.appColors.onError,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: context.h(8)),
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
                      // ── empty state ────────────────────────────────────────────
                      else if (model.allUsers.isEmpty)
                        Column(
                          children: [
                            Padding(
                              padding: context.padSym(v: 8),
                              child: Text(
                                '📭 No users available yet\n(users are filtered to avoid showing yourself)',
                                style: context.appText.text14W400.copyWith(
                                  color: context.appColors.greyDark,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: context.h(8)),
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
                                  sport?.skillLevel ??
                                  model.rosterSkillAt(index),
                              destance:
                                  user.location ?? '${match.distanceKm} km',
                              isShow: true,
                              ontap: () {
                                // TODO: send invite to user.id
                              },
                              cardOnTap: () {
                                // ✅ record profile view for Recent Players
                                ListOfAllUserService().recordProfileView(user);
                                match.pushPublicProfileForPlayer(
                                  context,
                                  displayName: user.fullName ?? '',
                                  userIdSuffix: user.id ?? 'user_$index',
                                );
                              },
                            );
                          },
                        ),

                      SizedBox(height: context.h(16)),
                    ],
                    // if (model.selectedIndex == 1) ...[
                    //   SectionHeaderWidget(title: AppText.participatedPlayers),
                    //   SizedBox(height: context.h(8)),
                    //   if (model.rosterCount == 0)
                    //     Padding(
                    //       padding: context.padSym(v: 8),
                    //       child: Text(
                    //         AppText.noPlayersOnRoster,
                    //         style: context.appText.text14W400.copyWith(
                    //           color: context.appColors.greyDark,
                    //         ),
                    //       ),
                    //     )
                    //   else ...[
                    //     // PersonInvitedCard is similar to UserMatchCard but with a different layout and no action button, used here to show invited players in the host details screen.
                    //     ListView.builder(
                    //       itemCount: model.rosterCount,
                    //       shrinkWrap: true,
                    //       physics: const NeverScrollableScrollPhysics(),
                    //       itemBuilder: (context, index) {
                    //         return PersonInvitedCard(
                    //           playerName: model.rosterNameAt(index),
                    //           matchName: match.sportType,
                    //           matchLevel: model.rosterSkillAt(index),
                    //           destance: '${match.distanceKm} km',
                    //           isShow: true,
                    //           ontap: () {},
                    //           cardOnTap: () => match.pushPublicProfileForPlayer(
                    //             context,
                    //             displayName: model.rosterNameAt(index),
                    //             userIdSuffix: 'invited_participated_$index',
                    //           ),
                    //         );
                    //       },
                    //     ),
                    //   ],
                    //   SizedBox(height: context.h(16)),
                    // ],
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
                                    color: Colors.white.withValues(alpha: 0.8),
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
                child: CustomButton(
                  text: AppText.joinMatch,
                  color: context.appColors.primary,
                  onTap: () {
                    showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (context) => CustomBottomSheetWidget(
                        isCenter: true,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              AppAssets.joiningMatchPeopelIcon,
                              fit: BoxFit.scaleDown,
                            ),
                            SizedBox(height: context.h(16)),
                            NormalText(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              titleText: AppText.matchIsFull,
                              maxLines: 5,
                              subAlign: TextAlign.center,
                              subText:
                                  AppText.thisMatchHasReachedItsMaximumCapacity,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
