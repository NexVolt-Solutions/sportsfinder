import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/feature/view/LocationAccess/LocationAccessViewModel/location_access_screen_view_model.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
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
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              top: context.h(5),
              bottom: context.h(20),
              right: context.w(20),
              left: context.w(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // IMPORTANT 🔥
              children: [
                CustomButton(
                  text: AppText.allowLocation,
                  color: context.appColors.primary,
                  onTap: () =>
                      Navigator.pushNamed(context, RoutesName.bottomBarScreen),
                ),
                SizedBox(height: context.h(12)),
                GestureDetector(
                  onTap: () {
                    // handle skip
                  },
                  child: NormalText(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    titleText: AppText.skipForNow,
                    titleStyle: context.appText.text16W500,
                    titleColor: context.appColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
        body: MainFrame(
          child: Column(
            children: [
              AppBarWidget(title: AppText.sportFinding),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    AppAssets.locationIcon,
                    fit: BoxFit.scaleDown,
                  ),
                  SizedBox(height: context.h(20)),
                  Center(
                    child: NormalText(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      titleText: AppText.allowLocationAccess,
                      titleStyle: context.appText.text18W600,
                      titleColor: context.appColors.onSurface,
                      subText: AppText
                          .allowLocationToDiscoverNearbySportsMatchesAndPlayersInYourArea,
                      subStyle: context.appText.text16W400,
                      subAlign: TextAlign.center,
                      maxLines: 2,
                      subColor: context.appColors.greyDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
