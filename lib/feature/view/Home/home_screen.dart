import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_colors.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/feature/view/Home/viewModel/home_screen_view_model.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/detail_match_card.dart';
import 'package:sport_finding/feature/widget/card_icon_widget.dart';
import 'package:sport_finding/feature/widget/card_widget.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';
import 'package:sport_finding/feature/widget/search_bar_widget.dart';
import 'package:sport_finding/feature/widget/section_header_widget.dart';
import 'package:sport_finding/feature/widget/user_greeting_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isSelected = false;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HomeScreenViewModel(),
      child: Consumer<HomeScreenViewModel>(
        builder: (context, model, child) => ListView(
          padding: context.padSym(h: 20),
          children: [
            AppBarWidget(
              leading: NormalText(
                titleText: AppText.sportFinding,
                titleFontSize: 18,
              ),
              onTapLast: () {},
            ),
            UserGreetingWidget(
              title: "Hey, Good Evening",
              name: "Shehzad Khan",

              isShow: false,
            ),
            SizedBox(height: context.h(24)),
            SearchBarWidget(isShow: false),
            SizedBox(height: context.h(16)),
            Row(
              children: [
                Expanded(
                  child: CardWidget(
                    borderColor: isSelected
                        ? context.appColors.primary
                        : context.appColors.blue10,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        RoutesName.createMatchScreen,
                      );
                    },
                    padding: context.padSym(h: 26, v: 18),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CardIconWidget(imageAsset: AppAssets.addIcon),
                        SizedBox(height: context.h(8)),
                        NormalText(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          titleText: AppText.createMatch,
                          titleColor: AppColors.blackcolor,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: context.w(12)),
                Expanded(
                  child: CardWidget(
                    padding: context.padSym(h: 26, v: 18),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CardIconWidget(imageAsset: AppAssets.matchesIcon),
                        SizedBox(height: context.h(8)),
                        NormalText(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          titleText: AppText.findMatch,
                          titleColor: AppColors.blackcolor,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: context.h(16)),
            SectionHeaderWidget(
              title: AppText.allUpcomingMatches,
              actionText: AppText.viewMatch,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  RoutesName.allUpComingMatchesScreen,
                );
              },
            ),
            SizedBox(height: context.h(8)),
            SizedBox(
              height: context.h(190),
              child: ListView.separated(
                scrollDirection: Axis.horizontal, // ✅ horizontal scroll
                itemCount: model.matches.length, // 4 items
                padding: context.padSym(h: 0),
                itemBuilder: (context, index) {
                  final match = model.matches[index];

                  return SizedBox(
                    width: context.w(300),
                    child:                     DetailsMatchesCard(
                      cardOnTap: () {
                        Navigator.pushNamed(
                          context,
                          RoutesName.userMatchDetailsScreen,
                          arguments: match,
                        );
                      },
                      hostName: match.title,
                      matchName: match.sportType,
                      loc: match.location,
                      time: match.date,
                      takenPlayer: match.participantsJoined,
                      totalPlayer: match.participantsTotal,
                    ),
                  );
                },
                separatorBuilder: (context, index) =>
                    SizedBox(width: context.w(12)),
              ),
            ),
            SectionHeaderWidget(title: AppText.popularSports),
            SizedBox(height: context.h(8)),

            SizedBox(
              height: context.h(140),
              width: double.infinity,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: model.sports.length,

                padding: context.padSym(h: 0),
                itemBuilder: (context, index) {
                  final sport = model.sports[index];

                  return CardWidget(
                    padding: context.padSym(h: 32, v: 18),
                    child: Column(
                      children: [
                        CardIconWidget(imageAsset: sport.imagePath),
                        NormalText(
                          titleText: sport.title,
                          titleStyle: context.appText.text16W500,
                        ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return SizedBox(width: context.w(12));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
