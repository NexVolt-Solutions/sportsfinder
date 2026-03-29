import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/Routes/discovery_match_navigation.dart';
import 'package:sport_finding/feature/model/discovery_match.dart';
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

class HostDetailsScreen extends StatefulWidget {
  const HostDetailsScreen({super.key});

  @override
  State<HostDetailsScreen> createState() => _HostDetailsScreenState();
}

class _HostDetailsScreenState extends State<HostDetailsScreen> {
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
        bottomNavigationBar: SafeArea(
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
        body: MainFrame(
          child: ListView(
            padding: context.padSym(h: 20),
            children: [
              AppBarWidget(
                onLeadingTap: () => Navigator.pop(context),
                title: AppText.sportFinding,
              ),
              NormalText(titleText: match.title, subText: match.sportType),
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
                    value: match.participantsLabel,
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
                    children: List.generate(model.buttonName.length, (index) {
                      final isSelected = model.selectedIndex == index;
                      return GestureDetector(
                        onTap: () => model.changeIndex(index),
                        child: isSelected
                            ? CardWidget(
                                padding: context.padSym(h: 16, v: 8),
                                child: NormalText(
                                  titleText: model.buttonName[index],
                                  titleColor: context.appColors.primary,
                                  titleFontSize: 16,
                                ),
                              )
                            : Padding(
                                padding: context.padSym(h: 16, v: 8),
                                child: NormalText(
                                  subText: model.buttonName[index],
                                  subColor: context.appColors.greylight,
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
                  name: match.location,
                  title2: match.resolvedHostBio,
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
                ListView.builder(
                  itemCount: match.players.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return UserMatchCard(
                      onActionTap: () {},
                      onCardTap: () =>
                          match.pushUserMatchDetailsScreen(context),
                      title: match.players[index],
                      subTitle: match.playerSkillAt(index),
                      showActionIcon: true,
                    );
                  },
                ),
                SizedBox(height: context.h(16)),
              ],
              if (model.selectedIndex == 1) ...[
                SectionHeaderWidget(title: AppText.participatedPlayers),
                SizedBox(height: context.h(8)),
                ListView.builder(
                  itemCount: match.players.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return PersonInvitedCard(
                      playerName: match.players[index],
                      matchName: match.sportType,
                      matchLevel: match.playerSkillAt(index),
                      destance: '${match.distanceKm} km',
                      isShow: true,
                      ontap: () {},
                      cardOnTap: () =>
                          match.pushUserMatchDetailsScreen(context),
                    );
                  },
                ),
                SizedBox(height: context.h(16)),
                SectionHeaderWidget(title: AppText.nearbyPlayers),
                SizedBox(height: context.h(8)),
                ListView.builder(
                  itemCount: match.players.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final i = (index + 1) % match.players.length;
                    return PersonInvitedCard(
                      playerName: match.players[i],
                      matchName: match.sportType,
                      matchLevel: match.playerSkillAt(i),
                      destance:
                          '${(match.distanceKm + index * 0.3).toStringAsFixed(1)} km',
                      isShow: true,
                      ontap: () {},
                      cardOnTap: () =>
                          match.pushUserMatchDetailsScreen(context),
                    );
                  },
                ),
                SizedBox(height: context.h(16)),
                SectionHeaderWidget(title: AppText.recommendedPlayers),
                SizedBox(height: context.h(8)),
                ListView.builder(
                  itemCount: match.players.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final i =
                        (match.players.length - 1 - index) %
                        match.players.length;
                    return PersonInvitedCard(
                      playerName: match.players[i],
                      matchName: match.sportType,
                      matchLevel: match.playerSkillAt(i),
                      destance:
                          '${(match.distanceKm + 0.5 + index * 0.2).toStringAsFixed(1)} km',
                      isShow: true,
                      ontap: () {},
                      cardOnTap: () =>
                          match.pushUserMatchDetailsScreen(context),
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
                              color: Colors.white.withValues(alpha: 0.8),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.fullscreen, size: 20),
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
    );
  }
}
