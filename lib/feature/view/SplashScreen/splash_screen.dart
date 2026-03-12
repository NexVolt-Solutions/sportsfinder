import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

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
