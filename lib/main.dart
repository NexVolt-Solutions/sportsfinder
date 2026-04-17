import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Network/notification_service.dart';
import 'package:sport_finding/core/Routes/routes.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';

void main() {
  runApp(
    /// App-wide [ChangeNotifier]s used from multiple routes (e.g. notifications
    /// opened from the bottom bar) must live **above** [MaterialApp] so every
    /// pushed screen inherits the same instance.
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NotificationService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: RoutesName.splashScreen,
        onGenerateRoute: Routes.generateRoute,
      ),
    ),
  );
}
