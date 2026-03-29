import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/Routes/discovery_match_navigation.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/feature/model/discovery_match.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/card_widget.dart';
import 'package:sport_finding/feature/widget/custom_button.dart';
import 'package:sport_finding/feature/widget/info_item_widget.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';
import 'package:sport_finding/feature/widget/section_header_widget.dart';
import 'package:sport_finding/feature/widget/user_greeting_widget.dart';
import 'package:sport_finding/feature/widget/user_match_card_widget.dart';

/// Match detail UI. Reads [DiscoveryMatch] from [ModalRoute.settings.arguments]
/// only in [build] so we never call [notifyListeners] during dependency changes.
class UserMatchDetailsScreen extends StatelessWidget {
  const UserMatchDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final match = args is DiscoveryMatch ? args : null;

    if (match == null) {
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
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Back',
                    style: context.appText.text16W500.copyWith(
                      color: context.appColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
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
            UserGreetingWidget(
              title: match.displayHostName,
              name: match.location,
              title2: match.resolvedHostBio,
              isShow: true,
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
              CardWidget(
                padding: context.padSym(h: 82, v: 26),
                child: NormalText(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  titleText: '${match.resolvedHostMatchesPlayed}',
                  subText: AppText.matchesPlayed,
                ),
              ),
            ],
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
            ListView.builder(
              itemCount: match.players.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return UserMatchCard(
                  title: match.players[index],
                  subTitle: match.playerSkillAt(index),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
