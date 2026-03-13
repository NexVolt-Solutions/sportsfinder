import 'package:flutter/material.dart';
import 'package:sport_finding/feature/view/Auth/Login/login_screen.dart';

class SplashScreenViewModel extends ChangeNotifier {
  Future<dynamic> loginto(BuildContext context) async {
    await Future.delayed(Duration(seconds: 3));
    // Navigator.pushReplacement(
    //   context,
    //   // MaterialPageRoute(builder: (context) => const LoginScreen()),
    // );
  }
}
