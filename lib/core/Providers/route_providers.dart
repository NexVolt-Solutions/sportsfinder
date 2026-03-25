import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/feature/view/Home/viewModel/player_match_detail_screen_view_model.dart';
import 'package:sport_finding/feature/view_model/all_upcomming_matches_view_model.dart';
import 'package:sport_finding/feature/view_model/bottom_bar_screen_view_model.dart';
import 'package:sport_finding/feature/view_model/choose_sport_screen_view_model.dart';
import 'package:sport_finding/feature/view_model/location_access_screen_view_model.dart';
import 'package:sport_finding/feature/view_model/login_screen_view_model.dart';
import 'package:sport_finding/feature/view_model/onboarding_screen_view_model.dart';
import 'package:sport_finding/feature/view_model/otp_verification_screen_view_model.dart';
import 'package:sport_finding/feature/view_model/see_all_invated_player_screen_view_model.dart';
import 'package:sport_finding/feature/view_model/sign_screen_view_model.dart';
import 'package:sport_finding/feature/view_model/skill_level_screen_view_model.dart';
import 'package:sport_finding/feature/view_model/splash_screen_view_model.dart';

/// Central place for all route-level ChangeNotifier wiring.
class RouteProviders {
  RouteProviders._();

  static Widget wrapIfNeeded(String routeName, Widget child) {
    switch (routeName) {
      case RoutesName.SplashScreen:
        return ChangeNotifierProvider(
          create: (_) => SplashScreenViewModel(),
          child: child,
        );
      case RoutesName.OnboardingScreen:
        return ChangeNotifierProvider(
          create: (_) => OnboardingScreenViewModel(),
          child: child,
        );
      case RoutesName.signUpScreen:
        return ChangeNotifierProvider(
          create: (_) => LoginScreenViewModel(),
          child: child,
        );
      case RoutesName.SignInScreen:
        return ChangeNotifierProvider(
          create: (_) => SignScreenViewModel(),
          child: child,
        );
      case RoutesName.SkillLevelScreen:
        return ChangeNotifierProvider(
          create: (_) => SkillLevelScreenViewModel(),
          child: child,
        );
      case RoutesName.ChooseSportScreen:
        return ChangeNotifierProvider(
          create: (_) => ChooseSportScreenViewModel(),
          child: child,
        );
      case RoutesName.LocationAccessScreen:
        return ChangeNotifierProvider(
          create: (_) => LocationAccessScreenViewModel(),
          child: child,
        );
      case RoutesName.BottomBarScreen:
        return ChangeNotifierProvider(
          create: (_) => BottomBarScreenViewModel(),
          child: child,
        );
      case RoutesName.OtpVerificationScreen:
        return ChangeNotifierProvider(
          create: (_) => OtpVerificationScreenViewModel(),
          child: child,
        );
      case RoutesName.AllUpComingMatchesScreen:
        return ChangeNotifierProvider(
          create: (_) => AllUpcommingMatchesViewModel(),
          child: child,
        );
      case RoutesName.SeeAllInvatedPlayerScreen:
        return ChangeNotifierProvider(
          create: (_) => SeeAllInvatedPlayerScreenViewModel(),
          child: child,
        );
      case RoutesName.PlayerMatchDetailsScreen:
        return ChangeNotifierProvider(
          create: (_) => PlayerMatchDetailScreenViewModel(),
          child: child,
        );

      default:
        return child;
    }
  }
}
