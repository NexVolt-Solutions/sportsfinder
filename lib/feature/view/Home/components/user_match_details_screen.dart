import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/feature/model/discovery_match.dart';
import 'package:sport_finding/feature/view/Home/viewModel/user_match_detail_screen_view_model.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/card_widget.dart';
import 'package:sport_finding/feature/widget/custom_button.dart';
import 'package:sport_finding/feature/widget/info_item_widget.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';
import 'package:sport_finding/feature/widget/section_header_widget.dart';
import 'package:sport_finding/feature/widget/user_greeting_widget.dart';
import 'package:sport_finding/feature/widget/user_match_card_widget.dart';

class UserMatchDetailsScreen extends StatefulWidget {
  const UserMatchDetailsScreen({super.key});

  @override
  State<UserMatchDetailsScreen> createState() => _UserMatchDetailsScreenState();
}

class _UserMatchDetailsScreenState extends State<UserMatchDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final match = ModalRoute.of(context)!.settings.arguments as DiscoveryMatch;
    return Consumer<UserMatchDetailScreenViewModel>(
      builder: (context, model, child) => Scaffold(
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              top: context.h(5),
              bottom: context.h(20),
              right: context.w(20),
              left: context.w(20),
            ),
            child: CustomButton(
              text: AppText.startMatch,
              color: context.appColors.primary,
              onTap: () =>
                  Navigator.pushNamed(context, RoutesName.bottomBarScreen),
            ),
          ),
        ),
        body: MainFrame(
          child: ListView(
            padding: context.padSym(h: 20),
            children: [
              AppBarWidget(
                onLeadingTap: () {
                  Navigator.pop(context);
                },
                title: AppText.sportFinding,
              ),
              NormalText(titleText: match.title, subText: match.sportType),
              SizedBox(height: context.h(20)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InfoItem(
                    icon: AppAssets.calendarIcon,
                    title: "Date",
                    value: match.date,
                  ),
                  InfoItem(
                    icon: AppAssets.clockIcon,
                    title: "Time",
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
                    title: "Skill Level",
                    value: match.sportType,
                  ),
                  InfoItem(
                    icon: AppAssets.playerIcon,
                    title: "Players",
                    value: match.participantsJoined.toString(),
                  ),
                ],
              ),
              SizedBox(height: context.h(16)),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  InfoItem(
                    icon: AppAssets.locationIcon,
                    title: "Location",
                    value: match.location,
                  ),
                ],
              ),
              SizedBox(height: context.h(16)),

              UserGreetingWidget(
                title: 'khan',
                name: AppText.newYorkUsa,
                title2: AppText.passionateAboutSportsAndFitness,
                isShow: true,
              ),
              SizedBox(height: context.h(16)),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, RoutesName.hostDetailsScreen);
                },
                child: CardWidget(
                  padding: context.padSym(h: 82, v: 26),
                  child: NormalText(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    titleText: match.participantsJoined.toString(),
                    subText: AppText.matchesPlayed,
                  ),
                ),
              ),
              SizedBox(height: context.h(16)),

              NormalText(
                crossAxisAlignment: CrossAxisAlignment.start,
                titleText: AppText.aboutThisMatch,
                sizeBoxheight: context.h(8),
                maxLines: 5,
                subText: AppText.friendlyFinalTournamentDescription,
                subAlign: TextAlign.start,
              ),
              SizedBox(height: context.h(16)),
              SectionHeaderWidget(title: AppText.participatedPlayers),
              ListView.builder(
                itemCount: match.players.length,
                shrinkWrap: true, // ✅ important inside another ListView
                physics:
                    NeverScrollableScrollPhysics(), // ✅ prevent scroll conflict
                itemBuilder: (context, index) {
                  return UserMatchCard(
                    title: match.players[index],
                    subTitle: AppText.advanced,
                    // showActionIcon: index.isEven, // optional logic
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
