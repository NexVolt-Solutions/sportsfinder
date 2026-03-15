import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_colors.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/view_model/location_access_screen_view_model.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/custom_button.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';
import 'package:sport_finding/feature/widget/splash_background.dart';

class LocationAccessScreen extends StatefulWidget {
  const LocationAccessScreen({super.key});

  @override
  State<LocationAccessScreen> createState() => _LocationAccessScreenState();
}

class _LocationAccessScreenState extends State<LocationAccessScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LocationAccessScreenViewModel(),
      child: Consumer<LocationAccessScreenViewModel>(
        builder: (context, model, child) => Scaffold(
          backgroundColor: Colors.white,
          bottomNavigationBar: Padding(
            padding: EdgeInsetsGeometry.only(
              top: context.h(3),
              left: context.w(20),
              right: context.w(20),
              bottom: context.text(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomButton(
                  padding: context.padSym(h: 125),
                  isEnabled: true,
                  text: AppText.allowLocation,
                  color: AppColors.bluecolor,
                  onTap: () {
                    // Navigator.pushNamed(context, RoutesName.LocationAccessScreen);
                  },
                ),
                SizedBox(height: context.h(12)),
                NormalText(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  titleText: AppText.skipForNow,
                  titleSize: context.sp(15),
                  titleColor: AppColors.greydark,
                  titleWeight: FontWeight.w500,
                ),
              ],
            ),
          ),
          body: SafeArea(
            child: SplashBackground(
              child: ListView(
                padding: context.padSym(h: 20),
                children: [
                  SizedBox(height: context.h(22)),
                  AppBarWidget(
                    onTap: () => Navigator.pop(context),
                    title: AppText.appName,
                  ),
                  SizedBox(height: context.h(234)),
                  SvgPicture.asset(
                    AppAssets.locationIcon,
                    fit: BoxFit.scaleDown,
                  ),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
