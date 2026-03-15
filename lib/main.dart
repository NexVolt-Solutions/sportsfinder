import 'package:flutter/material.dart';
import 'package:sport_finding/core/Routes/routes.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: RoutesName.SplashScreen,
      onGenerateRoute: Routes.generateRoute,
    ),
  );
}
