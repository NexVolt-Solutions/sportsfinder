import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_colors.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: -context.w(55),
            child: Container(
              height: context.h(132),
              width: context.w(144),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.pimaryColor.withOpacity(0.2),
                    offset: const Offset(5, 5),
                    blurRadius: 30,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: context.h(144),
            right: -context.w(55),
            child: Container(
              height: context.h(132),
              width: context.w(144),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.pimaryColor.withOpacity(0.2),
                    offset: const Offset(5, 5),
                    blurRadius: 30,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: context.h(394),
            left: -context.w(55),
            child: Container(
              height: context.h(132),
              width: context.w(144),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.pimaryColor.withOpacity(0.2),
                    offset: const Offset(5, 5),
                    blurRadius: 30,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: context.h(0),
            right: -context.w(55),
            child: Container(
              height: context.h(132),
              width: context.w(144),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.pimaryColor.withOpacity(0.2),
                    offset: const Offset(5, 5),
                    blurRadius: 30,
                  ),
                ],
              ),
            ),
          ),
          // Image.asset(
          //   AppAssets.splashScreenBackImage,
          //   height: context.h(double.infinity),
          //   width: context.w(double.infinity),
          //   fit: BoxFit.fill,
          // ),
          // Center(child: Image.asset(AppAssets.mainLogo)),
        ],
      ),
    );
  }
}
