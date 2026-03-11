import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/core/Routes/routes.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        // ChangeNotifierProvider(create: (context) => SplashViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,

        initialRoute: RoutesName.StartUpScreen,
        onGenerateRoute: Routes.generateRoute,
      ),
    ),
  );
}
