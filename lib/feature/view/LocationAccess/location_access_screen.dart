import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/feature/view_model/location_access_screen_view_model.dart';
import 'package:sport_finding/feature/widget/custom_button.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';

class LocationAccessScreen extends StatefulWidget {
  const LocationAccessScreen({super.key});

  @override
  State<LocationAccessScreen> createState() => _LocationAccessScreenState();
}

class _LocationAccessScreenState extends State<LocationAccessScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<LocationAccessScreenViewModel>(
      builder: (context, model, child) => Scaffold(
        body: MainFrame(
          child: Column(
            children: [
              AppBarWidget(title: AppText.appName),

              Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          AppAssets.locationIcon,
                          fit: BoxFit.scaleDown,
                        ),
                        SizedBox(height: context.h(20)),
                        Padding(
                          padding: context.padSym(h: 30),
                          child: NormalText(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            titleText: AppText.allowLocationAccess,
                            titleStyle: context.appText.text18W600,
                            titleColor: context.appColors.onSurface,
                            subText: AppText.allowLocationDesc,
                            subStyle: context.appText.text16W400,
                            subAlign: TextAlign.center,
                            subColor: context.appColors.greyDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: SplashBackground(
            child: ListView(
              padding: context.padSym(h: 20),
              children: [
                SizedBox(height: context.h(234)),
                SvgPicture.asset(AppAssets.locationIcon, fit: BoxFit.scaleDown),
                SizedBox(height: context.h(20)),
                NormalText(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  titleText: AppText.allowLocationAccess,
                  titleSize: context.sp(20),
                  titleColor: AppColors.blackcolor,
                  titleWeight: FontWeight.w600,
                  subText: AppText.allowLocationDesc,
                  subColor: AppColors.greylight60,
                  subSize: context.sp(16),
                  titleAlign: TextAlign.center,
                  subWeight: FontWeight.w500,
                  subAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
