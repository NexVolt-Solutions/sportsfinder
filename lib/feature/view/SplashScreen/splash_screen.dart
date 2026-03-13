import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_colors.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/view_model/splash_screen_view_model.dart';
import 'package:sport_finding/feature/widget/splash_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  SplashScreenViewModel splashScreen = SplashScreenViewModel();
  @override
  void initState() {
    splashScreen.loginto(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whitecolor,
      body: SafeArea(
        child: SplashBackground(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Container(
                    padding: context.padSym(h: 2, v: 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.bluecolor.withOpacity(0.2),
                          offset: Offset(5, 5),
                          blurRadius: 80,
                        ),
                      ],
                    ),
                    child: Image.asset(AppAssets.mainLogo),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
