import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';

class MainFrame extends StatelessWidget {
  const MainFrame({super.key, this.child, this.showDecorationLayer = true});

  final Widget? child;

  final bool showDecorationLayer;

  @override
  Widget build(BuildContext context) {
    final content = child ?? const SizedBox.shrink();
    if (!showDecorationLayer) {
      return content;
    }
    return SafeArea(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: 80,
            right: -80,
            child: _GlowCircle(size: 220, color: context.appColors.blue20),
          ),

          Positioned(
            bottom: 40,
            left: -80,
            child: _GlowCircle(size: 180, color: context.appColors.blue20),
          ),
          Positioned.fill(child: content),
        ],
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0.0)],
          ),
        ),
      ),
    );
  }
}
