import 'package:flutter/material.dart';

/// Figma design size (reference). Use sw() / sh() with Figma pixel values.
const double kFigmaDesignWidth = 375;
const double kFigmaDesignHeight = 844;

extension SizeExtension on BuildContext {
  // Screen dimensions
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Scale factor: current width / Figma width. Use for horizontal/width-related values.
  double get scaleWidth => screenWidth / kFigmaDesignWidth;
  /// Scale factor: current height / Figma height. Use for vertical/height-related values.
  double get scaleHeight => screenHeight / kFigmaDesignHeight;

  // ----- Responsive (Figma-based): use these for pixel-perfect scaling -----
  /// Figma width → scaled. Use for: width, horizontal padding, horizontal spacing, font size, radius.
  double sw(double figmaPx) => figmaPx * scaleWidth;
  /// Figma height → scaled. Use for: height, vertical padding, vertical spacing.
  double sh(double figmaPx) => figmaPx * scaleHeight;

  /// Responsive symmetric padding from Figma values (h,v in Figma px).
  EdgeInsets paddingSymmetricR({double horizontal = 0, double vertical = 0}) =>
      EdgeInsets.symmetric(horizontal: sw(horizontal), vertical: sh(vertical));
  /// Responsive all-side padding from Figma value.
  EdgeInsets paddingAllR(double figmaPx) => EdgeInsets.all(sw(figmaPx));
  /// Responsive padding only from Figma values.
  EdgeInsets paddingOnlyR({
    double left = 0,
    double right = 0,
    double top = 0,
    double bottom = 0,
  }) =>
      EdgeInsets.only(
        left: sw(left),
        right: sw(right),
        top: sh(top),
        bottom: sh(bottom),
      );
  /// Responsive border radius from Figma value.
  double radiusR(double figmaPx) => sw(figmaPx);
  /// Responsive font size from Figma value (scales with width so text stays readable).
  double sp(double figmaPx) => sw(figmaPx);

  // ----- Fixed (no scaling): raw logical pixels -----
  double w(double value) => value;
  double h(double value) => value;

  // Padding — fixed pixels (standard spelling)
  EdgeInsets paddingAll(double value) => EdgeInsets.all(value);
  EdgeInsets paddingOnly({
    double left = 0,
    double right = 0,
    double top = 0,
    double bottom = 0,
  }) =>
      EdgeInsets.only(left: left, right: right, top: top, bottom: bottom);
  EdgeInsets paddingSymmetric({double horizontal = 0, double vertical = 0}) =>
      EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);

  // Backward-compatible aliases
  EdgeInsets padAll(double value) => paddingAll(value);
  EdgeInsets padonly({
    double left = 0,
    double right = 0,
    double top = 0,
    double bottom = 0,
  }) =>
      paddingOnly(left: left, right: right, top: top, bottom: bottom);
  EdgeInsets padSym({double h = 0, double v = 0}) =>
      paddingSymmetric(horizontal: h, vertical: v);

  double padH(double value) => value;
  double padV(double value) => value;

  double radius(double value) => value;
  double text(double value) => value;

  // Spacing constants (fixed)
  double get s4 => 4;
  double get s8 => 8;
  double get s12 => 12;
  double get s16 => 16;
  double get s20 => 20;

  double get smallText => 12;
  double get mediumText => 16;
  double get largeText => 20;
}

// ─── Quick reference (Figma 375×844) ─────────────────────────────────────
// Use Figma pixel values directly; they scale to any device.
//
//   width: context.sw(200),        // Figma width 200 → scales with screen
//   height: context.sh(400),      // Figma height 400 → scales with screen
//   padding: context.paddingSymmetricR(horizontal: 20, vertical: 16),
//   fontSize: context.sp(16),    // Figma font 16
//   borderRadius: context.radiusR(12),
//
// Rule: horizontal/size/font/radius → sw(); vertical → sh().
