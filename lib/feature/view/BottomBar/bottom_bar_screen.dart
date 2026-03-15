import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/view_model/bottom_bar_screen_view_model.dart';
import 'package:sport_finding/feature/widget/splash_background.dart';

class BottomBarScreen extends StatefulWidget {
  const BottomBarScreen({super.key});

  @override
  State<BottomBarScreen> createState() => _BottomBarScreenState();
}

class _BottomBarScreenState extends State<BottomBarScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BottomBarScreenViewModel(),
      child: Consumer<BottomBarScreenViewModel>(
        builder: (context, model, child) => Scaffold(
          backgroundColor: Colors.white,

          body: SafeArea(
            child: SplashBackground(
              child: ListView(
                padding: context.padSym(h: 20),
                children: [SizedBox(height: 200)],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
