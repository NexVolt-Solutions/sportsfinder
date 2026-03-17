import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_colors.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/view_model/home_screen_view_model.dart';
import 'package:sport_finding/feature/widget/card_icon_widget.dart';
import 'package:sport_finding/feature/widget/card_widget.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';
import 'package:sport_finding/feature/widget/search_bar_widget.dart';
import 'package:sport_finding/feature/widget/section_header_widget.dart';
import 'package:sport_finding/feature/widget/splash_background.dart';

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
            child: SplashBackground(
              child: ListView(
                padding: context.padSym(h: 20),
                children: [
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      NormalText(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        titleText: AppText.appName,
                        titleSize: context.sp(20),
                        titleColor: AppColors.blackcolor,
                        titleWeight: FontWeight.w600,
                      ),
                      SvgPicture.asset(AppAssets.notificationIcon),
                    ],
                  ),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.greydark,
                        ),
                      ),
                      SizedBox(width: context.w(24)),
                      NormalText(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        titleText: AppText.goodEvening,
                        titleSize: context.sp(20),
                        titleColor: AppColors.blackcolor,
                        titleWeight: FontWeight.w600,
                        subText: 'Shehzad Khan',
                        subColor: AppColors.greylight60,
                        subSize: context.sp(16),
                        titleAlign: TextAlign.center,
                        subWeight: FontWeight.w500,
                        subAlign: TextAlign.start,
                      ),
                    ],
                  ),
                  SizedBox(height: context.h(20)),
                  SearchBarWidget(),
                  SizedBox(height: context.h(20)),
                  SizedBox(
                    height: context.h(140),
                    width: context.w(double.infinity),
                    child: ListView.separated(
                      separatorBuilder: (context, index) =>
                          SizedBox(width: context.sw(20)),
                      scrollDirection: Axis.horizontal,
                      itemCount: model.matcheData.length,
                      itemBuilder: (context, index) {
                        final match = model.matcheData[index];

                        return CardWidget(
                          padding: context.padSym(h: 50, v: 18),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CardIconWidget(imageAsset: match.imagePath),
                              SizedBox(height: context.h(8)),
                              NormalText(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                titleText: match.title,
                                titleSize: context.sp(14),
                                titleColor: AppColors.blackcolor,
                                titleWeight: FontWeight.w400,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: context.h(20)),
                  SectionHeaderWidget(
                    title: AppText.createMatchTitle,
                    actionText: AppText.viewAll,
                    icon: AppAssets.nextIcon,
                  ),
                  CardWidget(
                    padding: context.padSym(h: 50, v: 18),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        NormalText(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          titleText: 'Khan Match',
                          titleSize: context.sp(20),
                          titleColor: AppColors.blackcolor,
                          titleWeight: FontWeight.w600,
                          subText: AppText.basketball,
                          subColor: AppColors.greylight60,
                          subSize: context.sp(16),
                          titleAlign: TextAlign.center,
                          subWeight: FontWeight.w500,
                          subAlign: TextAlign.start,
                        ),
                        Row(children: [Row(children: [])]),
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
