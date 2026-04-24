import 'package:flutter/material.dart';
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

    final isLoggedIn = await AppPreferences.isLoggedIn();
    if (!mounted || _navigated) return;

    if (!isLoggedIn) {
      _navigated = true;
      Navigator.pushReplacementNamed(context, RoutesName.onboardingScreen);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.surface,
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}
