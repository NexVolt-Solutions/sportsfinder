import 'package:flutter/material.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';

class SplashScreenViewModel extends ChangeNotifier {
  Future<void> loginto(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 3));
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, RoutesName.onboardingScreen);
  }
}
