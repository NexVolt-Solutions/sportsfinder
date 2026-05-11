import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';

class AppFormFieldLayout {
  AppFormFieldLayout._();

  static double controlHeight(BuildContext context) => context.h(50);

  static BoxConstraints singleLineConstraints(BuildContext context) =>
      BoxConstraints(minHeight: controlHeight(context));

  static double controlRadius(BuildContext context) => context.radius(12);

  static BorderRadius borderRadius(BuildContext context) =>
      BorderRadius.circular(controlRadius(context));

  static EdgeInsets contentPadding(BuildContext context) {
    return EdgeInsets.fromLTRB(
      context.w(20),
      context.h(12),
      context.w(20),
      context.h(12),
    );
  }

  static EdgeInsets contentPaddingMultiline(BuildContext context) {
    return EdgeInsets.fromLTRB(
       context.w(20),
      context.h(12),
      context.w(20),
      context.h(12),
    );
  }

  static TextStyle errorStyle(BuildContext context) {
    return context.appText.text12W400.copyWith(
      color: context.appColors.error,
      height: 1.25,
    );
  }
}
