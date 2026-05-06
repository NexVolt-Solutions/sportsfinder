import 'package:flutter/material.dart';

/// Wraps the navigator subtree so a tap dismisses the keyboard when it
/// doesn’t land on a control that keeps focus (e.g. [TextField] still
/// receives the tap and keeps focus via normal hit testing).
class TapOutsideUnfocus extends StatelessWidget {
  const TapOutsideUnfocus({super.key, required this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      behavior: HitTestBehavior.translucent,
      child: child ?? const SizedBox.shrink(),
    );
  }
}
