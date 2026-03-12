import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_colors.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/widget/custom_widget.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pimaryColor,

      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 20),
          children: [
            Center(
              child: Image.asset(AppAssets.mainLogo, fit: BoxFit.scaleDown),
            ),
            Padding(
              padding: context.paddingSymmetricR(horizontal: 20, vertical: 30),
              child: CustomButton(
                text: 'Get Started',
                backgroundColor: AppColors.whiteColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
