import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/Providers/route_providers.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/feature/view/Auth/ForgotPassword/components/new_password_screen.dart';
import 'package:sport_finding/feature/view/Auth/ForgotPassword/components/verification_screen.dart';
import 'package:sport_finding/feature/view/Auth/ForgotPassword/forgot_password_screen.dart';
import 'package:sport_finding/feature/view/Auth/Login/login_screen.dart';
import 'package:sport_finding/feature/view/Auth/SigUp/sign_up.dart';
import 'package:sport_finding/feature/view/BottomBar/Components/AllMember/all_member_screen.dart';
import 'package:sport_finding/feature/view/BottomBar/Components/Chat/chat_screen.dart';
import 'package:sport_finding/feature/view/BottomBar/Components/Home/components/all_upcoming_matches.dart';
import 'package:sport_finding/feature/view/BottomBar/Components/Home/components/create_match_screen.dart';
import 'package:sport_finding/feature/view/BottomBar/Components/Home/components/host_details_screen.dart';
import 'package:sport_finding/feature/view/BottomBar/Components/Home/components/user_match_details_screen.dart';
import 'package:sport_finding/feature/view/BottomBar/bottom_bar_screen.dart';
import 'package:sport_finding/feature/view/ChooseSport/choose_sport_screen.dart';
import 'package:sport_finding/feature/view/BottomBar/Components/Home/components/match_created_done_screen.dart';
import 'package:sport_finding/feature/view/BottomBar/Components/Home/components/see_all_invated_player_screen.dart';
import 'package:sport_finding/feature/view/LocationAccess/location_access_screen.dart';
import 'package:sport_finding/feature/view/BottomBar/Components/Profile/followers_screen.dart';
import 'package:sport_finding/feature/view/BottomBar/Components/Profile/following_screen.dart';
import 'package:sport_finding/feature/view/BottomBar/Components/Profile/edit_profile_screen.dart';
import 'package:sport_finding/Data/model/public_profile_args.dart';
import 'package:sport_finding/feature/view/BottomBar/Components/Profile/private_profile_screen.dart';
import 'package:sport_finding/feature/view/BottomBar/Components/Profile/public_profile_screen.dart';
import 'package:sport_finding/feature/view/Legal/privacy_policy_screen.dart';
import 'package:sport_finding/feature/view/Legal/terms_of_service_screen.dart';
import 'package:sport_finding/feature/view/Notifications/notifications_screen.dart';
import 'package:sport_finding/feature/view/Onboarding/on_boarding_screen.dart';
import 'package:sport_finding/feature/view/Auth/Otp/otp_verification_screen.dart';
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

      ////////////
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
      case RoutesName.notificationsScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => RouteProviders.wrapIfNeeded(
            RoutesName.notificationsScreen,
            const NotificationsScreen(),
          ),
        );
      case RoutesName.forgotPasswordScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => RouteProviders.wrapIfNeeded(
            RoutesName.forgotPasswordScreen,
            const ForgotPasswordScreen(),
          ),
        );
      case RoutesName.verificationScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => RouteProviders.wrapIfNeeded(
            RoutesName.verificationScreen,
            const VerificationScreen(),
          ),
        );
      case RoutesName.newPasswordScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => RouteProviders.wrapIfNeeded(
            RoutesName.newPasswordScreen,
            const NewPasswordScreen(),
          ),
        );
      case RoutesName.followersScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const FollowersScreen(),
        );
      case RoutesName.followingScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const FollowingScreen(),
        );
      case RoutesName.privacyPolicyScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const PrivacyPolicyScreen(),
        );
      case RoutesName.termsOfServiceScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const TermsOfServiceScreen(),
        );
      case RoutesName.publicProfileScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => PublicProfileScreen(
            args: settings.arguments is PublicProfileArgs
                ? settings.arguments as PublicProfileArgs
                : null,
          ),
        );
      case RoutesName.privateProfileScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const PrivateProfileScreen(),
        );
      case RoutesName.editProfileRoute:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const EditProfileScreen(),
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
