import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/feature/view/user_screen.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: UserScreen(),
      // initialRoute: RoutesName.splashScreen,
      // onGenerateRoute: Routes.generateRoute,
    ),
  );
}
