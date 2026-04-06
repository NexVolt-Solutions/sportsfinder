import 'package:flutter/material.dart';

class AppColors {
  static const Color bluecolor = Color(0xFF3EA7FD);
  static Color blue20 = Color(0xFF3EA7FD).withValues(alpha: 0.2);
  static const Color whitecolor = Color(0xFFFFFFFF);
  static Color blue10 = Color(0xFF3EA7FD).withValues(alpha: 0.1);
  static const Color redcolor = Color(0xFFFF0000);
  static const Color greencolor = Color(0xFF00CC46);
  static const Color blackcolor = Color(0xFF000000);
  static const Color greydark = Color(0xFF565656);
  static Color greylight = Color(0xFF565656).withValues(alpha: 0.6);

  /// Light grey for app bar icons on dark background.
  static const Color transparent = Colors.transparent;

  static LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.bluecolor.withValues(alpha: 0.0), AppColors.whitecolor],
  );
}
