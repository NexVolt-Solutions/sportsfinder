import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/Data/Repositories/UpdateProfileRepo/update_profile_repo.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/Providers/route_providers.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/feature/view/Auth/ForgotPassword/components/new_password_screen.dart';
import 'package:sport_finding/feature/view/Auth/ForgotPassword/components/verification_screen.dart';
import 'package:sport_finding/feature/view/Auth/ForgotPassword/forgot_password_screen.dart';
import 'package:sport_finding/feature/view/Auth/Login/login_screen.dart';
import 'package:sport_finding/feature/view/Auth/auth_callback_screen.dart';
import 'package:sport_finding/feature/view/Auth/SigUp/sign_up.dart';
import 'package:sport_finding/Data/model/chat_route_args.dart';
import 'package:sport_finding/feature/view/BottomBar/Components/AllMember/all_member_screen.dart';
import 'package:sport_finding/feature/view/BottomBar/Components/Chat/chat_screen.dart';
import 'package:sport_finding/feature/view/BottomBar/ViewModel/update_profile_provider.dart';
import 'package:sport_finding/feature/view/Home/components/all_upcoming_matches.dart';
import 'package:sport_finding/feature/view/Home/components/create_match_screen.dart';
import 'package:sport_finding/feature/view/Home/components/edit_match_screen.dart';
import 'package:sport_finding/feature/view/Home/components/host_details_screen.dart';
import 'package:sport_finding/feature/view/Home/components/user_match_details_screen.dart';
import 'package:sport_finding/feature/view/BottomBar/bottom_bar_screen.dart';
import 'package:sport_finding/feature/view/ChooseSport/choose_sport_screen.dart';
import 'package:sport_finding/feature/view/Home/components/match_created_done_screen.dart';
import 'package:sport_finding/feature/view/Home/components/location_search_screen.dart';
import 'package:sport_finding/feature/view/Home/components/see_all_invated_player_screen.dart';
import 'package:sport_finding/Data/model/edit_profile_route_args.dart';
import 'package:sport_finding/Data/model/follow_connections_args.dart';
import 'package:sport_finding/Data/model/public_profile_args.dart';
import 'package:sport_finding/feature/view/LocationAccess/location_access_screen.dart';
import 'package:sport_finding/feature/view/BottomBar/Components/Profile/followers_screen.dart';
import 'package:sport_finding/feature/view/BottomBar/Components/Profile/following_screen.dart';
import 'package:sport_finding/feature/view/BottomBar/Components/Profile/edit_profile_screen.dart';
import 'package:sport_finding/feature/view/BottomBar/Components/Profile/private_profile_screen.dart';
import 'package:sport_finding/feature/view/BottomBar/Components/Profile/public_profile_screen.dart';
import 'package:sport_finding/feature/view/Legal/privacy_policy_screen.dart';
import 'package:sport_finding/feature/view/Legal/terms_of_service_screen.dart';
import 'package:sport_finding/feature/view/Notifications/notifications_screen.dart';
import 'package:sport_finding/feature/view/Onboarding/on_boarding_screen.dart';
import 'package:sport_finding/feature/view/Auth/Otp/otp_verification_screen.dart';
import 'package:sport_finding/feature/view/AppStart/app_start_screen.dart';
import 'package:sport_finding/feature/view/SkillLevelScreen/skill_level_screen.dart';

class Routes {
  static T? _argAs<T>(Object? arg) => arg is T ? arg : null;
  static Route<dynamic> _route(
    RouteSettings settings,
    WidgetBuilder builder,
  ) {
    return MaterialPageRoute(settings: settings, builder: builder);
  }

  /// Web engines sometimes pass `"/auth-callback?next=..."` as [RouteSettings.name].
  /// Strip query/hash so switch cases match.
  static String _routeNameForMatch(RouteSettings settings) {
    var name = settings.name;
    if (kIsWeb && (name == null || name.isEmpty)) {
      final p = Uri.base.path;
      name = p.isEmpty ? '/' : p;
    }
    if (name == null || name.isEmpty) {
      return RoutesName.appStartScreen;
    }

    // Some web engines can pass the URL hash payload itself as route name,
    // e.g. "access_token=...&refresh_token=...". In that case, route by path.
    if (kIsWeb) {
      final lowered = name.toLowerCase();
      final looksLikeOAuthPayload =
          (lowered.contains('access_token=') &&
              lowered.contains('token_type=')) ||
          lowered.startsWith('refresh_token=');
      if (looksLikeOAuthPayload) {
        final p = Uri.base.path.trim();
        if (p.isNotEmpty) return p;
      }
    }

    var n = name;
    final q = n.indexOf('?');
    if (q != -1) n = n.substring(0, q);
    final h = n.indexOf('#');
    if (h != -1) n = n.substring(0, h);
    if (n.startsWith('http')) {
      try {
        n = Uri.parse(n).path;
      } catch (_) {}
    }
    if (n.length > 1 && n.endsWith('/')) {
      n = n.substring(0, n.length - 1);
    }
    // Browser root path should behave like app start route.
    if (n == '/') return RoutesName.appStartScreen;
    return n;
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final routeKey = _routeNameForMatch(settings);
    if (kIsWeb) {
      debugPrint(
        '[ROUTES][web] incoming="${settings.name}" matched="$routeKey" uri="${Uri.base}"',
      );
    }
    switch (routeKey) {
      case '/':
      case RoutesName.appStartScreen:
        return _route(settings, (_) => const AppStartScreen());
      case RoutesName.authCallbackScreen:
      case 'auth-callback':
        return _route(settings, (_) => const AuthCallbackScreen());
      case RoutesName.onboardingScreen:
        return _route(
          settings,
          (_) => RouteProviders.wrapIfNeeded(
                RoutesName.onboardingScreen,
                const OnBoardingScreen(),
              ),
        );
      case RoutesName.LoginScreen:
        return _route(
          settings,
          (_) => RouteProviders.wrapIfNeeded(
                RoutesName.LoginScreen,
                const LoginScreen(),
              ),
        );
      case RoutesName.SignUp:
        return _route(
          settings,
          (_) => RouteProviders.wrapIfNeeded(RoutesName.SignUp, const SignUp()),
        );
      case RoutesName.skillLevelScreen:
        return _route(
          settings,
          (_) => RouteProviders.wrapIfNeeded(
                RoutesName.skillLevelScreen,
                const SkillLevelScreen(),
              ),
        );
      case RoutesName.chooseSportScreen:
        return _route(
          settings,
          (_) => RouteProviders.wrapIfNeeded(
                RoutesName.chooseSportScreen,
                const ChooseSportScreen(),
              ),
        );
      case RoutesName.locationAccessScreen:
        return _route(
          settings,
          (_) => RouteProviders.wrapIfNeeded(
                RoutesName.locationAccessScreen,
                const LocationAccessScreen(),
              ),
        );
      case RoutesName.bottomBarScreen:
        return _route(
          settings,
          (_) => RouteProviders.wrapIfNeeded(
                RoutesName.bottomBarScreen,
                const BottomBarScreen(),
              ),
        );

      case RoutesName.otpVerificationScreen:
        return _route(
          settings,
          (_) => RouteProviders.wrapIfNeeded(
                RoutesName.otpVerificationScreen,
                OtpVerificationScreen(),
              ),
        );
      case RoutesName.allUpComingMatchesScreen:
        return _route(
          settings,
          (_) => RouteProviders.wrapIfNeeded(
                RoutesName.allUpComingMatchesScreen,
                AllUpcomingMatches(),
                routeArguments: settings.arguments,
              ),
        );
      case RoutesName.seeAllInvatedPlayerScreen:
        return _route(
          settings,
          (_) => RouteProviders.wrapIfNeeded(
                RoutesName.seeAllInvatedPlayerScreen,
                SeeAllInvatedPlayerScreen(),
                routeArguments: settings.arguments,
              ),
        );

      case RoutesName.userMatchDetailsScreen:
        return _route(
          settings,
          (_) => RouteProviders.wrapIfNeeded(
                RoutesName.userMatchDetailsScreen,
                const UserMatchDetailsScreen(),
              ),
        );
      case RoutesName.hostDetailsScreen:
        return _route(
          settings,
          (_) => RouteProviders.wrapIfNeeded(
                RoutesName.hostDetailsScreen,
                HostDetailsScreen(),
              ),
        );
      case RoutesName.createMatchScreen:
        return _route(
          settings,
          (_) => RouteProviders.wrapIfNeeded(
                RoutesName.createMatchScreen,
                CreateMatchScreen(),
              ),
        );
      case RoutesName.locationSearchScreen:
        return _route(
          settings,
          (_) => RouteProviders.wrapIfNeeded(
                RoutesName.locationSearchScreen,
                const LocationSearchScreen(),
              ),
        );
      case RoutesName.editMatchScreen:
        return _route(
          settings,
          (_) => RouteProviders.wrapIfNeeded(
                RoutesName.editMatchScreen,
                const EditMatchScreen(),
                routeArguments: settings.arguments,
              ),
        );
      case RoutesName.matchCreatedDoneScreen:
        return _route(
          settings,
          (_) => RouteProviders.wrapIfNeeded(
                RoutesName.matchCreatedDoneScreen,
                const MatchCreatedDoneScreen(),
              ),
        );

      case RoutesName.allMemberScreen:
        return _route(
          settings,
          (_) => RouteProviders.wrapIfNeeded(
                RoutesName.allMemberScreen,
                AllMemberScreen(),
              ),
        );
      case RoutesName.chatScreen:
        final args = _argAs<ChatRouteArgs>(settings.arguments);
        return _route(
          settings,
          (_) => RouteProviders.wrapIfNeeded(
                RoutesName.chatScreen,
                ChatScreen(
                  targetUserId: args?.targetUserId,
                ),
                routeArguments: settings.arguments,
              ),
        );
      case RoutesName.notificationsScreen:
        return _route(
          settings,
          (_) => RouteProviders.wrapIfNeeded(
                RoutesName.notificationsScreen,
                const NotificationsScreen(),
              ),
        );
      case RoutesName.editProfileRoute:
        final editArgs = settings.arguments;
        final a = _argAs<EditProfileRouteArgs>(editArgs) ??
            const EditProfileRouteArgs();
        return _route(
          settings,
          (_) => ChangeNotifierProvider(
                create: (_) => EditProfileScreenViewModel(UpdateProfileRepo()),
                child: EditProfileScreen(
                  initialName: a.initialName,
                  initialBio: a.initialBio,
                  initialAvatarUrl: a.initialAvatarUrl,
                  initialSport: a.initialSport,
                  initialSkill: a.initialSkill,
                ),
              ),
        );
      case RoutesName.forgotPasswordScreen:
        return _route(
          settings,
          (_) => RouteProviders.wrapIfNeeded(
                RoutesName.forgotPasswordScreen,
                const ForgotPasswordScreen(),
              ),
        );

      case RoutesName.verificationScreen:
        return _route(
          settings,
          (_) => RouteProviders.wrapIfNeeded(
                RoutesName.verificationScreen,
                const VerificationScreen(),
              ),
        );

      case RoutesName.newPasswordScreen:
        return _route(
          settings,
          (_) => RouteProviders.wrapIfNeeded(
                RoutesName.newPasswordScreen,
                const NewPasswordScreen(),
              ),
        );

      case RoutesName.followersScreen:
        return _route(
          settings,
          (_) => FollowersScreen(
                args: _argAs<FollowConnectionsArgs>(settings.arguments),
              ),
        );
      case RoutesName.followingScreen:
        return _route(
          settings,
          (_) => FollowingScreen(
                args: _argAs<FollowConnectionsArgs>(settings.arguments),
              ),
        );
      case RoutesName.privacyPolicyScreen:
        return _route(settings, (_) => const PrivacyPolicyScreen());
      case RoutesName.termsOfServiceScreen:
        return _route(settings, (_) => const TermsOfServiceScreen());
      case RoutesName.publicProfileScreen:
        return _route(
          settings,
          (_) => PublicProfileScreen(
                args: _argAs<PublicProfileArgs>(settings.arguments),
              ),
        );
      case RoutesName.privateProfileScreen:
        return _route(settings, (_) => const PrivateProfileScreen());

      default:
        debugPrint(
          '[ROUTES][fallback] incoming="${settings.name}" matched="$routeKey" uri="${Uri.base}"',
        );
        return _route(
          settings,
          (context) => Scaffold(
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
