import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/Providers/route_providers.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/feature/view/Auth/Login/login_screen.dart';
import 'package:sport_finding/feature/view/Auth/SigUp/sign_up.dart';
import 'package:sport_finding/feature/view/BottomBar/Components/AllMember/all_member_screen.dart';
import 'package:sport_finding/feature/view/BottomBar/Components/Chat/chat_screen.dart';
import 'package:sport_finding/feature/view/BottomBar/bottom_bar_screen.dart';
import 'package:sport_finding/feature/view/ChooseSport/choose_sport_screen.dart';
import 'package:sport_finding/feature/view/Home/components/all_upcoming_matches.dart';
import 'package:sport_finding/feature/view/Home/components/create_match_screen.dart';
import 'package:sport_finding/feature/view/Home/components/match_created_done_screen.dart';
import 'package:sport_finding/feature/view/Home/components/host_details_screen.dart';
import 'package:sport_finding/feature/view/Home/components/user_match_details_screen.dart';
import 'package:sport_finding/feature/view/Home/components/see_all_invated_player_screen.dart';
import 'package:sport_finding/feature/view/Home/home_screen.dart';
import 'package:sport_finding/feature/view/LocationAccess/location_access_screen.dart';
import 'package:sport_finding/feature/view/Onboarding/on_boarding_screen.dart';
import 'package:sport_finding/feature/view/Otp/otp_verification_screen.dart';
import 'package:sport_finding/feature/view/SkillLevelScreen/skill_level_screen.dart';
import 'package:sport_finding/feature/view/SplashScreen/splash_screen.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutesName.splashScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => RouteProviders.wrapIfNeeded(
            RoutesName.splashScreen,
            const SplashScreen(),
          ),
        );
      case RoutesName.onboardingScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => RouteProviders.wrapIfNeeded(
            RoutesName.onboardingScreen,
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
      case RoutesName.SignUp:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) =>
              RouteProviders.wrapIfNeeded(RoutesName.SignUp, const SignUp()),
        );
      case RoutesName.skillLevelScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => RouteProviders.wrapIfNeeded(
            RoutesName.skillLevelScreen,
            const SkillLevelScreen(),
          ),
        );
      case RoutesName.chooseSportScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => RouteProviders.wrapIfNeeded(
            RoutesName.chooseSportScreen,
            const ChooseSportScreen(),
          ),
        );
      case RoutesName.locationAccessScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => RouteProviders.wrapIfNeeded(
            RoutesName.locationAccessScreen,
            const LocationAccessScreen(),
          ),
        );
      case RoutesName.bottomBarScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => RouteProviders.wrapIfNeeded(
            RoutesName.bottomBarScreen,
            const BottomBarScreen(),
          ),
        );
      case RoutesName.homeScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) =>
              RouteProviders.wrapIfNeeded(RoutesName.homeScreen, HomeScreen()),
        );
      case RoutesName.otpVerificationScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => RouteProviders.wrapIfNeeded(
            RoutesName.otpVerificationScreen,
            OtpVerificationScreen(),
          ),
        );
      case RoutesName.allUpComingMatchesScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => RouteProviders.wrapIfNeeded(
            RoutesName.allUpComingMatchesScreen,
            AllUpcomingMatches(),
          ),
        );
      case RoutesName.seeAllInvatedPlayerScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => RouteProviders.wrapIfNeeded(
            RoutesName.seeAllInvatedPlayerScreen,
            SeeAllInvatedPlayerScreen(),
          ),
        );
      case RoutesName.userMatchDetailsScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => RouteProviders.wrapIfNeeded(
            RoutesName.userMatchDetailsScreen,
            const UserMatchDetailsScreen(),
          ),
        );
      case RoutesName.hostDetailsScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => RouteProviders.wrapIfNeeded(
            RoutesName.hostDetailsScreen,
            HostDetailsScreen(),
          ),
        );
      case RoutesName.createMatchScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => RouteProviders.wrapIfNeeded(
            RoutesName.createMatchScreen,
            CreateMatchScreen(),
          ),
        );
      case RoutesName.matchCreatedDoneScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => RouteProviders.wrapIfNeeded(
            RoutesName.matchCreatedDoneScreen,
            const MatchCreatedDoneScreen(),
          ),
        );
      case RoutesName.allMemeberScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => RouteProviders.wrapIfNeeded(
            RoutesName.allMemeberScreen,
            AllMemberScreen(),
          ),
        );
      case RoutesName.chatScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) =>
              RouteProviders.wrapIfNeeded(RoutesName.chatScreen, ChatScreen()),
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
