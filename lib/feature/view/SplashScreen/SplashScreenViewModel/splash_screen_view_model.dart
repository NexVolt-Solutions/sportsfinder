import 'package:flutter/material.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/core/Storage/app_preferences.dart';
import 'package:sport_finding/feature/view/BottomBar/ViewModel/bottom_bar_screen_view_model.dart';

class SplashScreenViewModel extends ChangeNotifier {
  Future<void> loginto(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 3));
    if (!context.mounted) return;

    try {
      final isLoggedIn = await AppPreferences.isLoggedIn();
      if (!context.mounted) return;

      if (isLoggedIn) {
        final isOnboardingCompleted = await AppPreferences.isOnboardingCompleted();
        if (!context.mounted) return;

        if (isOnboardingCompleted) {
          debugPrint(
            "User logged in and onboarding completed → Navigating to Home",
          );
          Navigator.pushReplacementNamed(
            context,
            RoutesName.bottomBarScreen,
            arguments: BottomBarScreenViewModel.homeIndex,
          );
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

}
