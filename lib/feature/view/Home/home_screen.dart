import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_colors.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/view_model/home_screen_view_model.dart';
import 'package:sport_finding/feature/widget/card_icon_widget.dart';
import 'package:sport_finding/feature/widget/card_widget.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';
import 'package:sport_finding/feature/widget/search_bar_widget.dart';
import 'package:sport_finding/feature/widget/section_header_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HomeScreenViewModel(),
      child: Consumer<HomeScreenViewModel>(
        builder: (context, model, child) => Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: MainFrame(
              child: ListView(
                padding: context.padSym(h: 20),
                children: [
                  SizedBox(height: context.h(20)),

                  // Header with App Name and Notification Icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      NormalText(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        titleText: AppText.appName,
                        titleStyle: context.appText.text18W600,
                        titleColor: context.appColors.onSurface,
                      ),
                      SvgPicture.asset(AppAssets.notificationIcon),
                    ],
                  ),

                  SizedBox(height: context.h(24)),

                  // User Profile Section
                  Row(
                    children: [
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: context.appColors.greyDark,
                        ),
                      ),
                      SizedBox(width: context.w(16)),
                      Expanded(
                        child: NormalText(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          titleText: AppText.goodEvening,
                          titleStyle: context.appText.text18W600,
                          titleColor: context.appColors.onSurface,
                          subText: 'Shehzad Khan',
                          subStyle: context.appText.text16W400,
                          subColor: context.appColors.greylight,
                          titleAlign: TextAlign.start,
                          subAlign: TextAlign.start,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: context.h(20)),

                  // Search Bar
                  SearchBarWidget(),

                  SizedBox(height: context.h(20)),

                  // Horizontal Scrollable Matches List
                  // SizedBox(
                  //   height: context.h(140),
                  //   child: ListView.separated(
                  //     separatorBuilder: (context, index) =>
                  //         SizedBox(width: context.w(12)),
                  //     scrollDirection: Axis.horizontal,
                  //     itemCount: model.matcheData.length,
                  //     itemBuilder: (context, index) {
                  //       final match = model.matcheData[index];

                  //       return CardWidget(
                  //         padding: context.padSym(h: 30, v: 18),
                  //         child: Column(
                  //           mainAxisAlignment: MainAxisAlignment.center,
                  //           children: [
                  //             CardIconWidget(imageAsset: match.imagePath),
                  //             SizedBox(height: context.h(8)),
                  //             NormalText(
                  //               crossAxisAlignment: CrossAxisAlignment.center,
                  //               titleText: match.title,
                  //               titleColor: AppColors.blackcolor,
                  //             ),
                  //           ],
                  //         ),
                  //       );
                  //     },
                  //   ),
                  // ),
                  SizedBox(height: context.h(20)),

                  // Create Match Section Header
                  SectionHeaderWidget(
                    title: AppText.createMatchTitle,
                    actionText: AppText.viewAll,
                    icon: AppAssets.nextIcon,
                  ),

                  SizedBox(height: context.h(12)),

                  // Match Card
                  CardWidget(
                    padding: context.padSym(h: 16, v: 18),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        NormalText(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          titleText: 'Khan Match',
                          titleColor: AppColors.blackcolor,
                          subText: AppText.basketball,
                          titleAlign: TextAlign.start,
                          subAlign: TextAlign.start,
                        ),
                        SizedBox(height: context.h(12)),
                        // Add more content here if needed
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 16),
                            SizedBox(width: context.w(4)),
                            Text(
                              'Location Name',
                              style: TextStyle(fontSize: context.sp(14)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
