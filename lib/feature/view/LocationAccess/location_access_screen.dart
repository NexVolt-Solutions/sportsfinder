import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/feature/view_model/location_access_screen_view_model.dart';
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
      builder: (context, model, child) => MainFrame(
        appBar: AppBarWidget(title: AppText.appName),
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
                text: AppText.allowLocation,
                color: context.appColors.primary,
                onTap: () {
                  Navigator.pushNamed(context, RoutesName.BottomBarScreen);
                },
              ),
              SizedBox(height: context.h(12)),
              NormalText(
                crossAxisAlignment: CrossAxisAlignment.center,
                titleText: AppText.skipForNow,
                titleStyle: context.appText.text14W400,
                titleColor: context.appColors.greyDark,
              ),
              SizedBox(height: context.h(20)),
            ],
          ),
        ),
        child: ListView(
          padding: context.padSym(h: 20),
          children: [
            SizedBox(height: context.h(234)),
            SvgPicture.asset(AppAssets.locationIcon, fit: BoxFit.scaleDown),
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
      ),
    );
  }
}
