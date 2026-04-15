import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';

class SplashScreenViewModel extends ChangeNotifier {
  Future<void> loginto(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 3));
    if (!context.mounted) return;

    try {
      // Check if user is already logged in
      final isLoggedIn = await _checkLoginStatus();

      if (isLoggedIn) {
        // Check if onboarding is completed
        final prefs = await SharedPreferences.getInstance();
        final isOnboardingCompleted =
            prefs.getBool('is_onboarding_completed') ?? false;

        if (isOnboardingCompleted) {
          debugPrint(
            "User logged in and onboarding completed → Navigating to Home",
          );
          Navigator.pushReplacementNamed(context, RoutesName.bottomBarScreen);
        } else {
          debugPrint(
            "User logged in but onboarding not completed → Navigating to Skill Level",
          );
          Navigator.pushReplacementNamed(context, RoutesName.skillLevelScreen);
        }
      } else {
        debugPrint("User not logged in → Navigating to Onboarding");
        Navigator.pushReplacementNamed(context, RoutesName.onboardingScreen);
      }
    } catch (e) {
      debugPrint("Error checking login status: $e");
      // If any error, go to onboarding
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, RoutesName.onboardingScreen);
      }
    }
  }

  /// Check if user has a valid access token
  Future<bool> _checkLoginStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      final isValid = accessToken != null && accessToken.isNotEmpty;

      debugPrint(
        "Access token found: ${isValid ? 'YES (${accessToken?.substring(0, 10)}...)' : 'NO'}",
      );
      return isValid;
    } catch (e) {
      debugPrint("Error reading token: $e");
      return false;
    }
  }
}
