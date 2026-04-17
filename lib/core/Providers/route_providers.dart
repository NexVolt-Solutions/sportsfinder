import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/Data/Repositories/UpdateProfileRepo/update_profile_repo.dart';
import 'package:sport_finding/Data/Repositories/forgot_password_repository.dart';
import 'package:sport_finding/Data/Repositories/login_repository.dart';
import 'package:sport_finding/Data/Repositories/my_profile_repository.dart';
import 'package:sport_finding/Data/Repositories/otp_verification_repository.dart';
import 'package:sport_finding/Data/Repositories/sign_up_repository.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/core/Network/api_service.dart';
import 'package:sport_finding/feature/view/Auth/ForgotPassword/ViewModel/new_password_screen_view_model.dart';
import 'package:sport_finding/feature/view/Auth/ForgotPassword/ViewModel/verification_screen_view_model.dart';
import 'package:sport_finding/feature/view/Auth/ForgotPassword/forgot_password_screen_view_model.dart';
import 'package:sport_finding/feature/view/BottomBar/ViewModel/update_profile_provider.dart';
import 'package:sport_finding/Data/model/all_matches_model.dart';
import 'package:sport_finding/Data/model/discovery_match.dart';
import 'package:sport_finding/feature/view/Home/viewModel/all_upcomming_matches_view_model.dart';
import 'package:sport_finding/feature/view/Home/viewModel/upcoming_matches_scope.dart';
import 'package:sport_finding/feature/view/Home/viewModel/create_match_view_model.dart';
import 'package:sport_finding/feature/view/Home/viewModel/edit_match_view_model.dart';
import 'package:sport_finding/feature/view/Home/viewModel/host_detail_screen_view_model.dart';
import 'package:sport_finding/feature/view/Home/viewModel/match_created_done_screen_view_model.dart';
import 'package:sport_finding/feature/view/Home/viewModel/see_all_invated_player_screen_view_model.dart';
import 'package:sport_finding/feature/view/BottomBar/ViewModel/all_member_screen_view_model.dart';
import 'package:sport_finding/feature/view/BottomBar/ViewModel/chat_screen_view_model.dart';
import 'package:sport_finding/feature/view/BottomBar/ViewModel/bottom_bar_screen_view_model.dart';
import 'package:sport_finding/feature/view/ChooseSport/ChooseSportViewModel/choose_sport_screen_view_model.dart';
import 'package:sport_finding/feature/view/LocationAccess/LocationAccessViewModel/location_access_screen_view_model.dart';
import 'package:sport_finding/feature/view/Auth/Login/login_viewmodel.dart';
import 'package:sport_finding/feature/view/Onboarding/OnBoardingViewModel/onboarding_screen_view_model.dart';
import 'package:sport_finding/feature/view/Auth/Otp/OtpScreenViewModel/otp_verification_screen_view_model.dart';
import 'package:sport_finding/feature/view/Auth/SigUp/signup_viewmodel.dart';
import 'package:sport_finding/feature/view/SkillLevelScreen/SkillLevelViewModel/skill_level_screen_view_model.dart';
import 'package:sport_finding/feature/view/SplashScreen/SplashScreenViewModel/splash_screen_view_model.dart';

/// Central place for all route-level ChangeNotifier wiring.
class RouteProviders {
  RouteProviders._();

  static Widget wrapIfNeeded(
    String routeName,
    Widget child, {
    Object? routeArguments,
  }) {
    switch (routeName) {
      case RoutesName.splashScreen:
        return ChangeNotifierProvider(
          create: (_) => SplashScreenViewModel(),
          child: child,
        );
      case RoutesName.onboardingScreen:
        return ChangeNotifierProvider(
          create: (_) => OnboardingScreenViewModel(),
          child: child,
        );
      case RoutesName.LoginScreen:
        return ChangeNotifierProvider(
          create: (_) => LoginScreenViewModel(
            repository: LoginRepository(apiService: ApiService()),
          ),
          child: child,
        );
      case RoutesName.SignUp:
        return ChangeNotifierProvider(
          create: (_) => SignUpViewModel(
            repository: SignUpRepository(apiService: ApiService()),
          ),
          child: child,
        );
      case RoutesName.skillLevelScreen:
        return ChangeNotifierProvider(
          create: (_) => SkillLevelScreenViewModel(),
          child: child,
        );
      case RoutesName.chooseSportScreen:
        return ChangeNotifierProvider(
          create: (_) => ChooseSportScreenViewModel(),
          child: child,
        );
      case RoutesName.locationAccessScreen:
        return ChangeNotifierProvider(
          create: (_) => LocationAccessScreenViewModel(),
          child: child,
        );
      case RoutesName.bottomBarScreen:
        return ChangeNotifierProvider(
          create: (_) => BottomBarScreenViewModel(
            MyProfileRepository(apiService: ApiService()),
          ),
          child: child,
        );
      case RoutesName.otpVerificationScreen:
        return ChangeNotifierProvider(
          create: (_) => OtpVerificationScreenViewModel(
            repository: OtpVerificationRepository(apiService: ApiService()),
          ),
          child: child,
        );
      case RoutesName.allUpComingMatchesScreen:
        return ChangeNotifierProvider(
          create: (_) => _allUpcomingMatchesViewModelForRoute(routeArguments),
          child: child,
        );

      case RoutesName.seeAllInvatedPlayerScreen:
        return ChangeNotifierProvider(
          create: (_) => SeeAllInvatedPlayerScreenViewModel(
            matchId: _seeAllInvitedMatchId(routeArguments),
          ),
          child: child,
        );
      case RoutesName.userMatchDetailsScreen:
        return child;

      case RoutesName.hostDetailsScreen:
        return ChangeNotifierProvider(
          create: (_) => HostDetailScreenViewModel(),
          child: child,
        );
      case RoutesName.createMatchScreen:
        return ChangeNotifierProvider(
          create: (_) => CreateMatchViewModel(),

          child: child,
        );
      case RoutesName.editMatchScreen:
        return ChangeNotifierProvider(
          create: (_) => EditMatchViewModel(),
          child: child,
        );
      case RoutesName.matchCreatedDoneScreen:
        return ChangeNotifierProvider(
          create: (_) => MatchCreatedDoneScreenViewModel(),
          child: child,
        );
      case RoutesName.allMemberScreen:
        return ChangeNotifierProvider(
          create: (_) => AllMemberScreenViewModel(),
          child: child,
        );
      case RoutesName.chatScreen:
        return ChangeNotifierProvider(
          create: (_) => ChatScreenViewModel(),
          child: child,
        );
      case RoutesName.notificationsScreen:
        return child;
      case RoutesName.forgotPasswordScreen:
        return ChangeNotifierProvider(
          create: (_) => ForgotPasswordScreenViewModel(
            repository: ForgotPasswordRepository(apiService: ApiService()),
          ),
          child: child,
        );

      case RoutesName.editProfileRoute:
        return ChangeNotifierProvider(
          create: (_) => EditProfileScreenViewModel(UpdateProfileRepo()),
          child: child,
        );

      case RoutesName.verificationScreen:
        return ChangeNotifierProvider(
          create: (_) => VerificationScreenViewModel(
            repository: ForgotPasswordRepository(apiService: ApiService()),
          ),
          child: child,
        );

      case RoutesName.newPasswordScreen:
        return ChangeNotifierProvider(
          create: (_) => NewPasswordScreenViewModel(),
          child: child,
        );
      default:
        return child;
    }
  }

  static String _seeAllInvitedMatchId(Object? routeArguments) {
    if (routeArguments is AllMatches) return routeArguments.id;
    if (routeArguments is DiscoveryMatch) return routeArguments.id;
    return '';
  }

  static AllUpcommingMatchesViewModel _allUpcomingMatchesViewModelForRoute(
    Object? routeArguments,
  ) {
    var scope = UpcomingMatchesScope.allUpcoming;
    List<AllMatches>? prefetched;

    if (routeArguments is AllUpcomingMatchesRouteArgs) {
      scope = routeArguments.scope;
      prefetched = routeArguments.prefetchedMatches;
    } else if (routeArguments is UpcomingMatchesScope) {
      scope = routeArguments;
    }

    final vm = AllUpcommingMatchesViewModel(scope: scope);
    if (prefetched != null) {
      vm.applyPrefetchedMatches(prefetched);
    } else {
      Future.microtask(() => vm.fetchMatches());
    }
    return vm;
  }
}
