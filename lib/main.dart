import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/feature/view/Onboarding/on_boarding_screen.dart';
import 'package:sport_finding/feature/view_model/on_boarding_screen_view_model.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => OnBoardingScreenViewModel(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: OnBoardingScreen(),
        // initialRoute: RoutesName.StartUpScreen,
        // onGenerateRoute: Routes.generateRoute,
      ),
    ),
  );
}
