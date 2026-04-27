import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Network/api_service.dart';
import 'package:sport_finding/core/Constants/google_maps_config.dart';
import 'package:sport_finding/core/Network/notification_service.dart';
import 'package:sport_finding/core/Network/profile_service.dart';
import 'package:sport_finding/core/Routes/routes.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/core/utils/app_snack_bar.dart';
import 'package:sport_finding/firebase_options.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GoogleMapsConfig.loadEnv();
  ApiService.onUnauthorized = () {
    ProfileService().clear();
    final nav = rootNavigatorKey.currentState;
    if (nav == null) return;
    nav.pushNamedAndRemoveUntil(RoutesName.LoginScreen, (route) => false);
  };
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => NotificationService())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        navigatorKey: rootNavigatorKey,
        initialRoute: RoutesName.appStartScreen,
        onGenerateRoute: Routes.generateRoute,
      ),
    ),
  );
}
