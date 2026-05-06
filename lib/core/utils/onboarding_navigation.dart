import 'package:flutter/material.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/core/Storage/app_preferences.dart';
import 'package:sport_finding/core/utils/auth_route_resolver.dart';
import 'package:sport_finding/core/utils/onboarding_profile_sync.dart';
import 'package:sport_finding/feature/view/BottomBar/ViewModel/bottom_bar_screen_view_model.dart';

Future<void> finishOnboardingAndOpenHome(BuildContext context) async {
  await syncPendingOnboardingToServer();
  final isComplete = await AuthRouteResolver.isCurrentUserProfileComplete();
  await AppPreferences.setOnboardingCompleted(isComplete);
  if (!context.mounted) return;
  Navigator.pushReplacementNamed(
    context,
    RoutesName.bottomBarScreen,
    arguments: BottomBarScreenViewModel.homeIndex,
  );
}
