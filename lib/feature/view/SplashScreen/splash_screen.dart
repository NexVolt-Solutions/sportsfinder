import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
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
    return MainFrame(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Container(
                padding: context.padSym(h: 2, v: 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: context.appColors.primary.withOpacity(0.2),
                      offset: const Offset(5, 5),
                      blurRadius: 80,
                    ),
                  ],
                ),
                child: Image.asset(AppAssets.mainLogo),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
