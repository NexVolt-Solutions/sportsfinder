import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';

extension AppStylesExtension on BuildContext {
  AppStyles get appStyles => AppStyles(this);
}

class AppStyles {
  AppStyles(this._context);
  final BuildContext _context;

  static const String _fontFamily = 'Nunito';

  TextStyle get heading1 => TextStyle(
    fontFamily: _fontFamily,
    fontSize: _context.sp(24),
    fontWeight: FontWeight.w700,
  );

  TextStyle get heading2 => TextStyle(
    fontFamily: _fontFamily,
    fontSize: _context.sp(20),
    fontWeight: FontWeight.w600,
  );

  TextStyle get titleLarge => TextStyle(
    fontFamily: _fontFamily,
    fontSize: _context.sp(18),
    fontWeight: FontWeight.w600,
  );

  TextStyle get titleMedium => TextStyle(
    fontFamily: _fontFamily,
    fontSize: _context.sp(16),
    fontWeight: FontWeight.w500,
  );

  TextStyle get bodyLarge => TextStyle(
    fontFamily: _fontFamily,
    fontSize: _context.sp(16),
    fontWeight: FontWeight.w400,
  );

  TextStyle get bodyMedium => TextStyle(
    fontFamily: _fontFamily,
    fontSize: _context.sp(14),
    fontWeight: FontWeight.w400,
  );

  TextStyle get bodySmall => TextStyle(
    fontFamily: _fontFamily,
    fontSize: _context.sp(12),
    fontWeight: FontWeight.w400,
  );

  TextStyle get caption => TextStyle(
    fontFamily: _fontFamily,
    fontSize: _context.sp(12),
    fontWeight: FontWeight.w400,
  );

  TextStyle get button => TextStyle(
    fontFamily: _fontFamily,
    fontSize: _context.sp(16),
    fontWeight: FontWeight.w600,
  );

  TextStyle get appBarTitle => TextStyle(
    fontFamily: _fontFamily,
    fontSize: _context.sp(20),
    fontWeight: FontWeight.w600,
  );

  // ─── 16 / 14 font size + weight combinations ─────────────────────────────

  /// 16px, w600
  TextStyle get s16w600 => TextStyle(
    fontFamily: _fontFamily,
    fontSize: _context.sp(16),
    fontWeight: FontWeight.w600,
  );

  /// 16px, w500
  TextStyle get s16w500 => TextStyle(
    fontFamily: _fontFamily,
    fontSize: _context.sp(16),
    fontWeight: FontWeight.w500,
  );

  /// 16px, w400
  TextStyle get s16w400 => TextStyle(
    fontFamily: _fontFamily,
    fontSize: _context.sp(16),
    fontWeight: FontWeight.w400,
  );

  /// 16px, bold (w700)
  TextStyle get s16Bold => TextStyle(
    fontFamily: _fontFamily,
    fontSize: _context.sp(16),
    fontWeight: FontWeight.bold,
  );

  /// 14px, w500
  TextStyle get s14w500 => TextStyle(
    fontFamily: _fontFamily,
    fontSize: _context.sp(14),
    fontWeight: FontWeight.w500,
  );

  /// 14px, w400
  TextStyle get s14w400 => TextStyle(
    fontFamily: _fontFamily,
    fontSize: _context.sp(14),
    fontWeight: FontWeight.w400,
  );

  /// 14px, bold (w700)
  TextStyle get s14Bold => TextStyle(
    fontFamily: _fontFamily,
    fontSize: _context.sp(14),
    fontWeight: FontWeight.bold,
  );

  TextStyle get bodyLargeGrey => bodyLarge;
  TextStyle get bodyMediumGrey => bodyMedium;
  TextStyle get titleMediumGrey => titleMedium;

  // ─── Layout (Figma-based) ─────────────────────────────────────────────────

  /// Card / container radius (Figma 12).
  double get radiusCard => _context.radiusR(12);

  /// Button radius (Figma 12).
  double get radiusButton => _context.radiusR(12);

  /// Small radius (Figma 8).
  double get radiusSmall => _context.radiusR(8);

  /// Standard horizontal padding (Figma 20).
  double get paddingHorizontal => _context.sw(20);

  /// Standard vertical spacing between sections (Figma 20).
  double get spacingSection => _context.sh(20);

  /// Small spacing (Figma 12).
  double get spacingSmall => _context.sh(12);

  /// Extra small spacing (Figma 8).
  double get spacingXSmall => _context.sh(8);
}
