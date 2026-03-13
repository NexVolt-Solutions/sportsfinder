import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_colors.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/feature/view/Onboarding/on_boarding_screen.dart';
import 'package:sport_finding/feature/view/SplashScreen/splash_screen.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutesName.SplashScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => SplashScreen(),
        );
      case RoutesName.OnboardingScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => OnBoardingScreen(),
        );
      // case RoutesName.LoginScreen:
      //   return MaterialPageRoute(
      //     settings: settings,
      //     builder: (_) => LoginScreen(),
      //   );
      // case RoutesName.SignInScreen:
      //   return MaterialPageRoute(
      //     settings: settings,
      //     builder: (_) => SignInScreen(),
      //   );

      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => Scaffold(
            body: Stack(
              children: [
                Center(
                  child: Text(
                    AppText.noRouteFound,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.blackcolor,
                      fontSize: context.sp(18),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Positioned(
                  top: context.sh(50),
                  left: context.sw(20),
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.blackcolor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }
}
