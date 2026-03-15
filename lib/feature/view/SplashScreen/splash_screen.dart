import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/feature/view_model/splash_screen_view_model.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<SplashScreenViewModel>().loginto(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainFrame(child: Center(child: Image.asset(AppAssets.mainLogo)));
  }
}
