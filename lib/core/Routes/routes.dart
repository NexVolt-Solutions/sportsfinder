import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/Providers/route_providers.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/feature/view/Auth/Login/login_screen.dart';
import 'package:sport_finding/feature/view/Auth/SigIn/sign_in_screen.dart';
import 'package:sport_finding/feature/view/BottomBar/bottom_bar_screen.dart';
import 'package:sport_finding/feature/view/ChooseSport/choose_sport_screen.dart';
import 'package:sport_finding/feature/view/Home/home_screen.dart';
import 'package:sport_finding/feature/view/LocationAccess/location_access_screen.dart';
import 'package:sport_finding/feature/view/Onboarding/on_boarding_screen.dart';
import 'package:sport_finding/feature/view/Otp/otp_verification_screen.dart';
import 'package:sport_finding/feature/view/SkillLevelScreen/skill_level_screen.dart';
import 'package:sport_finding/feature/view/SplashScreen/splash_screen.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutesName.SplashScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => RouteProviders.wrapIfNeeded(
            RoutesName.SplashScreen,
            const SplashScreen(),
          ),
        );
      case RoutesName.OnboardingScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => RouteProviders.wrapIfNeeded(
            RoutesName.OnboardingScreen,
            const OnBoardingScreen(),
          ),
        );
      case RoutesName.LoginScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => RouteProviders.wrapIfNeeded(
            RoutesName.LoginScreen,
            const LoginScreen(),
          ),
        );
      case RoutesName.SignInScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => RouteProviders.wrapIfNeeded(
            RoutesName.SignInScreen,
            const SignInScreen(),
          ),
        );
      case RoutesName.SkillLevelScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => RouteProviders.wrapIfNeeded(
            RoutesName.SkillLevelScreen,
            const SkillLevelScreen(),
          ),
        );
      case RoutesName.ChooseSportScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => RouteProviders.wrapIfNeeded(
            RoutesName.ChooseSportScreen,
            const ChooseSportScreen(),
          ),
        );
      case RoutesName.LocationAccessScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => RouteProviders.wrapIfNeeded(
            RoutesName.LocationAccessScreen,
            const LocationAccessScreen(),
          ),
        );
      case RoutesName.BottomBarScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => RouteProviders.wrapIfNeeded(
            RoutesName.BottomBarScreen,
            const BottomBarScreen(),
          ),
        );
      case RoutesName.HomeScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => HomeScreen(),
        );
      case RoutesName.OtpVerificationScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => OtpVerificationScreen(),
        );

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
                    style: context.appText.text18Bold.copyWith(
                      color: context.appColors.onSurface,
                    ),
                  ),
                ),
                Positioned(
                  top: context.sh(50),
                  left: context.sw(20),
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: context.appColors.onSurface,
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
