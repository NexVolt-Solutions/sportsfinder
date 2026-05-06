import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Network/api_service.dart';
import 'package:sport_finding/core/Network/fcm_service.dart';
import 'package:sport_finding/core/Constants/google_maps_config.dart';
import 'package:sport_finding/core/utils/google_maps_js_loader.dart';
import 'package:sport_finding/core/Network/notification_service.dart';
import 'package:sport_finding/core/Network/profile_service.dart';
import 'package:sport_finding/core/Routes/routes.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/core/Constants/responsive_text_scaler.dart';
import 'package:sport_finding/core/utils/app_snack_bar.dart';
import 'package:sport_finding/core/widgets/tap_outside_unfocus.dart';
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

/// Avoids Flutter splitting `"/auth-callback"` into nested routes `"/"` + `"auth-callback"`,
/// which made the first segment hit [Routes] `default` → "no route found" on web.
List<Route<dynamic>> _onGenerateInitialRoutes(String initialRoute) {
  if (!kIsWeb) {
    return <Route<dynamic>>[
      Routes.generateRoute(RouteSettings(name: initialRoute)),
    ];
  }

  var path = initialRoute;
  final q = path.indexOf('?');
  if (q != -1) path = path.substring(0, q);
  final h = path.indexOf('#');
  if (h != -1) path = path.substring(0, h);
  if (path.length > 1 && path.endsWith('/')) {
    path = path.substring(0, path.length - 1);
  }

  if (path == RoutesName.authCallbackScreen ||
      path == 'auth-callback' ||
      path.toLowerCase() == '/auth-callback') {
    return <Route<dynamic>>[
      Routes.generateRoute(
        const RouteSettings(name: RoutesName.authCallbackScreen),
      ),
    ];
  }

  if (path.isEmpty ||
      path == '/' ||
      path == RoutesName.appStartScreen) {
    return <Route<dynamic>>[
      Routes.generateRoute(
        RouteSettings(name: RoutesName.appStartScreen),
      ),
    ];
  }

  return <Route<dynamic>>[
    Routes.generateRoute(RouteSettings(name: initialRoute)),
  ];
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GoogleMapsConfig.loadEnv();
  await ensureGoogleMapsScriptLoaded();
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
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => notificationService)],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: DevicePreview.locale(context),
          theme: AppTheme.light,
          scaffoldMessengerKey: rootScaffoldMessengerKey,
          navigatorKey: rootNavigatorKey,
          initialRoute: _materialInitialRoute(),
          onGenerateInitialRoutes: _onGenerateInitialRoutes,
          onGenerateRoute: Routes.generateRoute,
          builder: (context, child) {
            final scaled = MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: appResponsiveTextScaler(context),
              ),
              child: TapOutsideUnfocus(child: child),
            );
            return DevicePreview.appBuilder(context, scaled);
          },
        ),
      ),
    ),
  );
}
