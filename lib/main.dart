import 'dart:async' show unawaited;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Network/api_service.dart';
import 'package:sport_finding/core/Network/fcm_service.dart';
import 'package:sport_finding/core/Constants/google_maps_config.dart';
import 'package:sport_finding/core/utils/google_maps_js_loader.dart';
import 'package:sport_finding/core/Network/chat_connectivity_gate.dart';
import 'package:sport_finding/core/Network/chat_presence_lifecycle.dart';
import 'package:sport_finding/core/Network/notification_service.dart';
import 'package:sport_finding/core/Network/profile_service.dart';
import 'package:sport_finding/core/Routes/routes.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/core/Constants/responsive_text_scaler.dart';
import 'package:sport_finding/core/utils/app_snack_bar.dart';
import 'package:sport_finding/core/utils/logger.dart';
import 'package:sport_finding/core/widgets/tap_outside_unfocus.dart';
import 'package:sport_finding/firebase_options.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// On web, honor the browser path (e.g. `/auth-callback`) instead of always
/// booting `app_start_screen`, which breaks OAuth redirects.
String _materialInitialRoute() {
  if (!kIsWeb) return RoutesName.appStartScreen;
  final uri = Uri.base;

  // If we are using hash-based routes (e.g. `/#create_match_screen`),
  // the "route" lives in the fragment, while `path` stays `/`.
  final frag = uri.fragment.trim();
  if (frag.isNotEmpty) {
    // Keep this conservative: if a fragment is an OAuth payload, ignore it.
    final lowered = frag.toLowerCase();
    final looksLikeOAuthPayload =
        (lowered.contains('access_token=') && lowered.contains('token_type=')) ||
        lowered.startsWith('refresh_token=');
    if (!looksLikeOAuthPayload) {
      return frag;
    }
  }

  var path = uri.path;
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

  // When Flutter gives us `/` but the browser URL is `/#some_route`,
  // use the fragment so refresh/deep-link stays on the same screen.
  if (initialRoute.isEmpty ||
      initialRoute == '/' ||
      initialRoute == RoutesName.appStartScreen) {
    final frag = Uri.base.fragment.trim();
    if (frag.isNotEmpty) {
      return <Route<dynamic>>[
        Routes.generateRoute(RouteSettings(name: frag)),
      ];
    }
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

Future<void> _bootstrapMapsAndFcmAfterFirstFrame({
  required NotificationService notificationService,
}) async {
  try {
    await ensureGoogleMapsScriptLoaded();
  } catch (e, st) {
    AppLogger.warning(
      'Google Maps script load failed ($e). Maps may not work until fixed.',
      tag: 'main',
    );
    AppLogger.debug('$st', tag: 'main');
  }
  try {
    await FcmService.instance.initialize(
      notificationService: notificationService,
      navigatorKey: rootNavigatorKey,
    );
  } catch (e, st) {
    AppLogger.warning(
      'FCM init failed ($e). Push may be unavailable until reload.',
      tag: 'main',
    );
    AppLogger.debug('$st', tag: 'main');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ChatConnectivityGate.instance.ensureStarted();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GoogleMapsConfig.loadEnv();
  final notificationService = NotificationService();
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
        onGenerateInitialRoutes: _onGenerateInitialRoutes,
        onGenerateRoute: Routes.generateRoute,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: appResponsiveTextScaler(context),
            ),
            child: TapOutsideUnfocus(child: child),
          );
        },
      ),
    ),
  );

  // Maps + FCM must not block [runApp]: slow/blocked Google Maps JS or FCM
  // would otherwise leave a permanent white screen on web.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ChatPresenceLifecycle.register();
    unawaited(
      _bootstrapMapsAndFcmAfterFirstFrame(
        notificationService: notificationService,
      ),
    );
  });
}
