import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';

/// Shared layout for [TextFormFieldWidget], [DropdownFormFieldWidget], and
/// read-only / picker fields. Do **not** wrap in a fixed-height [SizedBox] —
/// validation [errorText] must sit below the field without clipping.
class AppFormFieldLayout {
  AppFormFieldLayout._();

  /// Single-line outline fields (text, dropdown, date/time/duration pickers).
  /// Same padding as the compact dropdown row so heights stay aligned.
  static EdgeInsets contentPadding(BuildContext context) {
    return EdgeInsets.fromLTRB(
      context.w(12),
      context.h(10),
      context.w(12),
      context.h(10),
    );
  }

  /// Multiline body fields — slightly more vertical room than single-line.
  static EdgeInsets contentPaddingMultiline(BuildContext context) {
    return EdgeInsets.fromLTRB(
      context.w(12),
      context.h(14),
      context.w(12),
      context.h(14),
    );
  }

  static TextStyle errorStyle(BuildContext context) {
    return context.appText.text12W400.copyWith(
      color: context.appColors.error,
      height: 1.25,
    );
  }
}
