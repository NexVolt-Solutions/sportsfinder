// splash_background.dart
import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';

class MainFrame extends StatelessWidget {
  const MainFrame({super.key, this.child, this.showDecorationLayer = true});

  final Widget? child;

  /// When false, only [child] is built — no glow layer or [SafeArea].
  /// Use inside [BottomBarScreen] tabs so one outer [MainFrame] owns the decoration.
  final bool showDecorationLayer;

  @override
  Widget build(BuildContext context) {
    final content = child ?? const SizedBox.shrink();
    if (!showDecorationLayer) {
      return content;
    }
    final canvas = Theme.of(context).scaffoldBackgroundColor;
    return SafeArea(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: DecoratedBox(decoration: BoxDecoration(color: canvas)),
          ),
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

          Positioned.fill(child: content),
        ],
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final BuildContext context;

  const _GlowCircle({required this.context});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Container(
      height: context.h(150),
      width: context.w(150),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: c.blue20,
            offset: const Offset(5, 5),
            blurRadius: 40,
          ),
        ],
      ),
    );
  }
}
