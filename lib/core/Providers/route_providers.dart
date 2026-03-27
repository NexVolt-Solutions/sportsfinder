import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/feature/view/Home/viewModel/create_match_screen_view_model.dart';
import 'package:sport_finding/feature/view/Home/viewModel/host_detail_screen_view_model.dart';
import 'package:sport_finding/feature/view/Home/viewModel/match_created_done_screen_view_model.dart';
import 'package:sport_finding/feature/view/Home/viewModel/user_match_detail_screen_view_model.dart';
import 'package:sport_finding/feature/view/Home/viewModel/all_upcomming_matches_view_model.dart';
import 'package:sport_finding/feature/view/BottomBar/BottomBarViewModel/bottom_bar_screen_view_model.dart';
import 'package:sport_finding/feature/view/ChooseSport/ChooseSportViewModel/choose_sport_screen_view_model.dart';
import 'package:sport_finding/feature/view/LocationAccess/LocationAccessViewModel/location_access_screen_view_model.dart';
import 'package:sport_finding/feature/view/Auth/Signup/SignUpViewModel/sign_up_screen_view_model.dart';
import 'package:sport_finding/feature/view/Onboarding/OnBoardingViewModel/onboarding_screen_view_model.dart';
import 'package:sport_finding/feature/view/Otp/OtpScreenViewModel/otp_verification_screen_view_model.dart';
import 'package:sport_finding/feature/view/Home/viewModel/see_all_invated_player_screen_view_model.dart';
import 'package:sport_finding/feature/view/Auth/SigIn/SignInViewModel/sign_in_screen_view_model.dart';
import 'package:sport_finding/feature/view/SkillLevelScreen/SkillLevelViewModel/skill_level_screen_view_model.dart';
import 'package:sport_finding/feature/view/SplashScreen/SplashScreenViewModel/splash_screen_view_model.dart';

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
          create: (_) => SignUpScreenViewModel(),
          child: child,
        );
      case RoutesName.SignInScreen:
        return ChangeNotifierProvider(
          create: (_) => SignInScreenViewModel(),
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
      case RoutesName.UserMatchDetailsScreen:
        return ChangeNotifierProvider(
          create: (_) => UserMatchDetailScreenViewModel(),
          child: child,
        );

      case RoutesName.HostDetailsScreen:
        return ChangeNotifierProvider(
          create: (_) => HostDetailScreenViewModel(),
          child: child,
        );
      case RoutesName.createMatchScreen:
        return ChangeNotifierProvider(
          create: (_) => CreateMatchScreenViewModel(),
          child: child,
        );
      case RoutesName.matchCreatedDoneScreen:
        return ChangeNotifierProvider(
          create: (_) => MatchCreatedDoneScreenViewModel(),
          child: child,
        );

      default:
        return child;
    }
  }
}
