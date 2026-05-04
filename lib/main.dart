import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Network/api_service.dart';
import 'package:sport_finding/core/Network/fcm_service.dart';
import 'package:sport_finding/core/Constants/google_maps_config.dart';
import 'package:sport_finding/core/Network/notification_service.dart';
import 'package:sport_finding/core/Network/profile_service.dart';
import 'package:sport_finding/core/Routes/routes.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/core/utils/app_snack_bar.dart';
import 'package:sport_finding/firebase_options.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// On web, honor the browser path (e.g. `/auth-callback`) instead of always
/// booting `app_start_screen`, which breaks OAuth redirects.
String _materialInitialRoute() {
  if (!kIsWeb) return RoutesName.appStartScreen;
  var path = Uri.base.path;
  if (path.isEmpty || path == '/') return RoutesName.appStartScreen;
  if (path.length > 1 && path.endsWith('/')) {
    path = path.substring(0, path.length - 1);
  }
  return path;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GoogleMapsConfig.loadEnv();
  final notificationService = NotificationService();
  await FcmService.instance.initialize(
    notificationService: notificationService,
    navigatorKey: rootNavigatorKey,
  );
  ApiService.onUnauthorized = () {
    ProfileService().clear();
    final nav = rootNavigatorKey.currentState;
    if (nav == null) return;
    nav.pushNamedAndRemoveUntil(RoutesName.LoginScreen, (route) => false);
  };
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => notificationService)],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        navigatorKey: rootNavigatorKey,
        initialRoute: _materialInitialRoute(),
        onGenerateRoute: Routes.generateRoute,
      ),
    ),
  );
}
