import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
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
    // final match = ModalRoute.of(context)!.settings.arguments as DiscoveryMatch;
    return Consumer<HostDetailScreenViewModel>(
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
                onLeadingTap: () {
                  Navigator.pop(context);
                },
                title: AppText.sportFinding,
              ),
              NormalText(
                titleText: 'Host Data',
                // match.title,
                subText: 'Host Title',
                // match.sportType
              ),
              SizedBox(height: context.h(20)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InfoItem(
                    icon: AppAssets.calendarIcon,
                    title: "Date",
                    value: "Oct 26, 2024",
                  ),
                  InfoItem(
                    icon: AppAssets.clockIcon,
                    title: "Time",
                    value: "7:00 PM",
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
                    value: "Intermediate",
                  ),
                  InfoItem(
                    icon: AppAssets.playerIcon,
                    title: "Players",
                    value: "10/10",
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
                    value: "Central Park",
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
                  title: "Shehzad (Host)",
                  name: AppText.newYorkUsa,
                  title2: AppText.passionateAboutSportsAndFitness,
                  isShow: true,
                ),
                SizedBox(height: context.h(16)),
                CardWidget(
                  padding: context.padSym(h: 82, v: 26),
                  child: NormalText(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    titleText: '42',
                    subText: AppText.matchesPlayed,
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
                  itemCount: 5, // 👈 show 5 items
                  shrinkWrap: true, // if inside another scroll
                  physics: const NeverScrollableScrollPhysics(), // optional
                  itemBuilder: (context, index) {
                    return UserMatchCard(
                      onActionTap: () {},
                      onCardTap: () {},
                      title: AppText.shareMatch,
                      subTitle: AppText.advanced,
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
                  itemCount: 3, // 👈 show 5 items
                  shrinkWrap: true, // if inside another scroll
                  physics: const NeverScrollableScrollPhysics(), // optional
                  itemBuilder: (context, index) {
                    return PersonInvitedCard(
                      playerName: "Ali Khan",
                      matchName: "Football",
                      matchLevel: "Advanced",
                      destance: "3 km",
                      isShow: true, // show the invite button
                      ontap: () {
                        print("Invite button tapped for Ali Khan");
                      },
                      cardOnTap: () {
                        print("Card tapped for Ali Khan");
                      },
                    );
                  },
                ),
                SizedBox(height: context.h(16)),

                SectionHeaderWidget(title: AppText.nearbyPlayers),
                SizedBox(height: context.h(8)),

                ListView.builder(
                  itemCount: 3, // 👈 show 5 items
                  shrinkWrap: true, // if inside another scroll
                  physics: const NeverScrollableScrollPhysics(), // optional
                  itemBuilder: (context, index) {
                    return PersonInvitedCard(
                      playerName: "Ali Khan",
                      matchName: "Football",
                      matchLevel: "Advanced",
                      destance: "3 km",
                      isShow: true, // show the invite button
                      ontap: () {
                        print("Invite button tapped for Ali Khan");
                      },
                      cardOnTap: () {
                        print("Card tapped for Ali Khan");
                      },
                    );
                  },
                ),
                SizedBox(height: context.h(16)),

                SectionHeaderWidget(title: AppText.recommendedPlayers),
                SizedBox(height: context.h(8)),

                ListView.builder(
                  itemCount: 3, // 👈 show 5 items
                  shrinkWrap: true, // if inside another scroll
                  physics: const NeverScrollableScrollPhysics(), // optional
                  itemBuilder: (context, index) {
                    return PersonInvitedCard(
                      playerName: "Ali Khan",
                      matchName: "Football",
                      matchLevel: "Advanced",
                      destance: "3 km",
                      isShow: true, // show the invite button
                      ontap: () {
                        print("Invite button tapped for Ali Khan");
                      },
                      cardOnTap: () {
                        print("Card tapped for Ali Khan");
                      },
                    );
                  },
                ),
                SizedBox(height: context.h(16)),
              ],

              if (model.selectedIndex == 2) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12), // rounded corners
                  child: Stack(
                    children: [
                      // 1️⃣ Map Image
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
                              color: Colors.white.withOpacity(0.8),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(Icons.fullscreen, size: 20),
                              onPressed: () {
                                print('Fullscreen tapped');
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: context.h(16)),
                SectionHeaderWidget(title: AppText.centralPark),
                SizedBox(height: context.h(8)),
                Row(
                  children: [
                    AppSvgIcon(
                      icon: AppAssets.locationIcon,
                      color: context.appColors.greylight,
                    ),
                    SizedBox(width: context.w(4)),

                    NormalText(
                      subText: AppText.basketballCourtAddress,
                      subColor: context.appColors.greylight,
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
