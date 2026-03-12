import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/view_model/splash_screen_view_model.dart';

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
      body: Stack(
        children: [
          Image.asset(
            AppAssets.splashScreenBackImage,
            height: context.h(double.infinity),
            width: context.w(double.infinity),
            fit: BoxFit.fill,
          ),
          Center(child: Image.asset(AppAssets.mainLogo)),
        ],
      ),
    );
  }
}
