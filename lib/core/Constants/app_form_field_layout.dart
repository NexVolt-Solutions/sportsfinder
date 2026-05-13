import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';

class AppFormFieldLayout {
  AppFormFieldLayout._();

  static double controlHeight(BuildContext context) => context.h(48);

  static BoxConstraints singleLineConstraints(BuildContext context) =>
      BoxConstraints(minHeight: controlHeight(context));

  static double controlRadius(BuildContext context) => context.radius(12);

  static BorderRadius borderRadius(BuildContext context) =>
      BorderRadius.circular(controlRadius(context));

  static EdgeInsets contentPadding(BuildContext context) {
    return EdgeInsets.fromLTRB(
      context.w(20),
      context.h(8),
      context.w(20),
      context.h(8),
    );
  }

  static EdgeInsets contentPaddingMultiline(BuildContext context) {
    return EdgeInsets.fromLTRB(
       context.w(20),
          context.h(8),
      context.w(20),
      context.h(8),
    );
  }

  static TextStyle errorStyle(BuildContext context) {
    return context.appText.text12W400.copyWith(
      color: context.appColors.error,
      height: 1.35,
    );
  }

  /// Single-line inner padding aligned with [TextFormFieldWidget].
  static EdgeInsetsGeometry singleLineFieldPadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: context.w(20),
      vertical: context.h(14),
    );
  }

  /// Outlined shell shared by text fields, dropdowns, and pickers.
  /// Validation: [errorText] / [errorStyle] only — error borders match the normal
  /// outline so stacked forms stay readable (no heavy red frame).
  static InputDecoration standardOutlineInputDecoration(
    BuildContext context, {
    Widget? label,
    String? labelText,
    TextStyle? labelStyle,
    TextStyle? floatingLabelStyle,
    FloatingLabelBehavior floatingLabelBehavior = FloatingLabelBehavior.auto,
    String? hintText,
    TextStyle? hintStyle,
    Color? fillColor,
    EdgeInsetsGeometry? contentPadding,
    bool alignLabelWithHint = true,
    bool isDense = false,
    BoxConstraints? constraints,
    String? errorText,
    int errorMaxLines = 2,
    Widget? prefixIcon,
    BoxConstraints? prefixIconConstraints,
  }) {
    final c = context.appColors;
    final t = context.appText;
    final radius = borderRadius(context);
    final normalSide = BorderSide(color: c.greylight, width: 1.5);
    final primarySide = BorderSide(color: c.primary, width: 1.5);
    final enabledShape = OutlineInputBorder(
      borderRadius: radius,
      borderSide: normalSide,
    );
    final focusedShape = OutlineInputBorder(
      borderRadius: radius,
      borderSide: primarySide,
    );

    return InputDecoration(
      alignLabelWithHint: alignLabelWithHint,
      isDense: isDense,
      constraints: constraints,
      label: label,
      labelText: label == null ? labelText : null,
      labelStyle: labelStyle ?? t.text16W400.copyWith(color: c.onSurface),
      floatingLabelStyle:
          floatingLabelStyle ?? t.text12W400.copyWith(color: c.greylight),
      floatingLabelBehavior: floatingLabelBehavior,
      hintText: hintText,
      hintStyle: hintStyle ?? t.text14W400.copyWith(color: c.greylight),
      filled: true,
      fillColor: fillColor ?? c.blue10,
      contentPadding:
          contentPadding ?? singleLineFieldPadding(context),
      border: enabledShape,
      enabledBorder: enabledShape,
      focusedBorder: focusedShape,
      errorBorder: enabledShape,
      focusedErrorBorder: focusedShape,
      disabledBorder: enabledShape,
      errorText: errorText,
      errorStyle: errorStyle(context),
      errorMaxLines: errorMaxLines,
      prefixIcon: prefixIcon,
      prefixIconConstraints: prefixIconConstraints,
    );
  }
}
