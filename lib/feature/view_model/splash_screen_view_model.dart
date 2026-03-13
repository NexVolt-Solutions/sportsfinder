import 'package:flutter/material.dart';
import 'package:sport_finding/feature/view/Onboarding/on_boarding_screen.dart';

class SplashScreenViewModel extends ChangeNotifier {
  Future<dynamic> loginto(BuildContext context) async {
    await Future.delayed(Duration(seconds: 3));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => OnBoardingScreen()),
    );
  }
}
