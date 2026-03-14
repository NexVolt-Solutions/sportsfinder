// splash_background.dart
import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_colors.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';

class SplashBackground extends StatelessWidget {
  final Widget? child;

  const SplashBackground({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top-left circle
        Positioned(
          top: 0,
          left: -context.w(55),
          child: _GlowCircle(context: context),
        ),
        // Mid-right circle
        Positioned(
          top: context.h(144),
          right: -context.w(55),
          child: _GlowCircle(context: context),
        ),
        // Mid-left circle
        Positioned(
          top: context.h(490),
          left: -context.w(55),
          child: _GlowCircle(context: context),
        ),
        // Bottom-right circle
        Positioned(
          bottom: context.h(0),
          right: -context.w(55),
          child: _GlowCircle(context: context),
        ),

        // Your custom child content goes here
        ?child,
      ],
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final BuildContext context;

  const _GlowCircle({required this.context});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.h(150),
      width: context.w(150),
      decoration: BoxDecoration(
        // color: AppColors.blue20,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.blue20,
            offset: const Offset(5, 5),
            blurRadius: 40,
          ),
        ],
      ),
    );
  }
}
