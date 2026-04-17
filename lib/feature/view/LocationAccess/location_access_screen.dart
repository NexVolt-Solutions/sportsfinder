import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/core/Storage/app_preferences.dart';
import 'package:sport_finding/feature/view/BottomBar/ViewModel/bottom_bar_screen_view_model.dart';
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
  Future<void> _finishOnboardingAndOpenHome(BuildContext context) async {
    await AppPreferences.setOnboardingCompleted(true);
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(
      context,
      RoutesName.bottomBarScreen,
      arguments: BottomBarScreenViewModel.homeIndex,
    );
  }

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
                  onTap: () => _finishOnboardingAndOpenHome(context),
                ),
                SizedBox(height: context.h(12)),
                GestureDetector(
                  onTap: () => _finishOnboardingAndOpenHome(context),
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: context.padSym(h: 20),
                child: AppBarWidget(title: AppText.sportFinding),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: context.padSym(h: 20),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                          maxHeight: constraints.maxHeight,
                          minWidth: constraints.maxWidth,
                          maxWidth: constraints.maxWidth,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              AppAssets.locationIcon,
                              fit: BoxFit.scaleDown,
                            ),
                            SizedBox(height: context.h(20)),
                            NormalText(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              titleText: AppText.allowLocationAccess,
                              titleStyle: context.appText.text18W600,
                              titleColor: context.appColors.onSurface,
                              titleAlign: TextAlign.center,
                              subText: AppText
                                  .allowLocationToDiscoverNearbySportsMatchesAndPlayersInYourArea,
                              subStyle: context.appText.text16W400,
                              subAlign: TextAlign.center,
                              maxLines: 4,
                              subColor: context.appColors.greyDark,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
