// splash_background.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_colors.dart';

class MainFrame extends StatelessWidget {
  const MainFrame({super.key, this.child, this.showDecorationLayer = true});

  final Widget? child;

  /// When false, only [child] is built — no [SafeArea] or full-screen fill.
  /// Use inside [BottomBarScreen] tabs so one outer [MainFrame] owns the layout.
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
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: kIsWeb ? AppColors.whitecolor : canvas,
                // gradient: kIsWeb
                //     ? const LinearGradient(
                //         begin: Alignment.topLeft,
                //         end: Alignment.bottomRight,
                //         colors: [
                //           Color(0xFFF8FBFF),
                //           Color(0xFFEFF7FF),
                //           Color(0xFFF7FBFF),
                //         ],
                //       )
                //     : null,
              ),
            ),
          ),
          if (kIsWeb)
            Positioned(
              top: 80,
              right: -80,
              child: _GlowCircle(size: 220, color: const Color(0x223DA5FF)),
            ),
          if (kIsWeb)
            Positioned(
              bottom: 40,
              left: -80,
              child: _GlowCircle(size: 180, color: const Color(0x1A8FD3FF)),
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
