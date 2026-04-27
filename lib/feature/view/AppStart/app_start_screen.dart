import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/core/Storage/app_preferences.dart';
import 'package:sport_finding/core/utils/auth_route_resolver.dart';
import 'package:sport_finding/feature/view/BottomBar/ViewModel/bottom_bar_screen_view_model.dart';

class AppStartScreen extends StatefulWidget {
  const AppStartScreen({super.key});

  @override
  State<AppStartScreen> createState() => _AppStartScreenState();
}

class _AppStartScreenState extends State<AppStartScreen> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resolveAndNavigate();
    });
  }

  Future<void> _resolveAndNavigate() async {
    if (!mounted || _navigated) return;

    await _bootstrapAuthFromWebQueryIfPresent();
    if (!mounted || _navigated) return;

    final isLoggedIn = await AppPreferences.isLoggedIn();
    if (!mounted || _navigated) return;

    if (!isLoggedIn) {
      _navigated = true;
      Navigator.pushReplacementNamed(context, RoutesName.onboardingScreen);
      return;
    }

    if (kIsWeb) {
      _navigated = true;
      Navigator.pushReplacementNamed(
        context,
        RoutesName.bottomBarScreen,
        arguments: BottomBarScreenViewModel.homeIndex,
      );
      return;
    }

    final routeName = await AuthRouteResolver.resolvePostAuthRouteName();
    if (!mounted || _navigated) return;

    _navigated = true;
    Navigator.pushReplacementNamed(
      context,
      routeName,
      arguments: routeName == RoutesName.bottomBarScreen
          ? BottomBarScreenViewModel.homeIndex
          : null,
    );
  }

  Future<void> _bootstrapAuthFromWebQueryIfPresent() async {
    if (!kIsWeb) return;
    final query = Uri.base.queryParameters;
    final accessToken = (query['access_token'] ?? query['token'] ?? '').trim();
    if (accessToken.isEmpty) return;

    final refreshToken =
        (query['refresh_token'] ?? query['refreshToken'] ?? '').trim();
    final tokenType = (query['token_type'] ?? query['tokenType'] ?? 'Bearer')
        .trim();

    await AppPreferences.saveAuthTokens(
      accessToken: accessToken,
      refreshToken: refreshToken.isNotEmpty ? refreshToken : null,
      tokenType: tokenType.isNotEmpty ? tokenType : 'Bearer',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.surface,
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}
