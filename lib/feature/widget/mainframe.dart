// splash_background.dart
import 'package:flutter/material.dart';

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
            child: DecoratedBox(decoration: BoxDecoration(color: canvas)),
          ),
          Positioned.fill(child: content),
        ],
      ),
    );
  }
}
