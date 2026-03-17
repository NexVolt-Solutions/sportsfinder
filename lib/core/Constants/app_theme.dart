import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_colors.dart';

/// App colors from theme. Use [context.appColors] instead of [AppColors] in UI.
class AppColorTheme extends ThemeExtension<AppColorTheme> {
  const AppColorTheme({
    required this.primary,
    required this.onPrimary,
    required this.surface,
    required this.onSurface,
    required this.error,
    required this.onError,
    required this.greyDark,
    required this.greylight,
    required this.blue10,
    required this.blue20,
    required this.transparent,
    required this.primaryGradient,
  });

  final Color primary;
  final Color onPrimary;
  final Color surface;
  final Color onSurface;
  final Color error;
  final Color onError;
  final Color greyDark;
  final Color greylight;
  final Color blue10;
  final Color blue20;
  final Color transparent;
  final LinearGradient primaryGradient;

  @override
  ThemeExtension<AppColorTheme> copyWith({
    Color? primary,
    Color? onPrimary,
    Color? surface,
    Color? onSurface,
    Color? error,
    Color? onError,
    Color? greyDark,
    Color? greylight,
    Color? blue10,
    Color? blue20,
    Color? transparent,
    LinearGradient? primaryGradient,
  }) => AppColorTheme(
    primary: primary ?? this.primary,
    onPrimary: onPrimary ?? this.onPrimary,
    surface: surface ?? this.surface,
    onSurface: onSurface ?? this.onSurface,
    error: error ?? this.error,
    onError: onError ?? this.onError,
    greyDark: greyDark ?? this.greyDark,
    greylight: greylight ?? this.greylight,
    blue10: blue10 ?? this.blue10,
    blue20: blue20 ?? this.blue20,
    transparent: transparent ?? this.transparent,
    primaryGradient: primaryGradient ?? this.primaryGradient,
  );

  @override
  ThemeExtension<AppColorTheme> lerp(
    ThemeExtension<AppColorTheme>? other,
    double t,
  ) => this;
}

extension AppColorThemeExtension on BuildContext {
  AppColorTheme get appColors =>
      Theme.of(this).extension<AppColorTheme>() ?? _defaultAppColorTheme;
}

AppColorTheme get _defaultAppColorTheme => AppColorTheme(
  primary: AppColors.bluecolor,
  onPrimary: AppColors.whitecolor,
  surface: AppColors.whitecolor,
  onSurface: AppColors.blackcolor,
  error: AppColors.redcolor,
  onError: AppColors.whitecolor,
  greyDark: AppColors.greydark,
  greylight: AppColors.greylight,
  blue10: AppColors.blue10,
  blue20: AppColors.blue20,
  transparent: AppColors.transparent,
  primaryGradient: AppColors.primaryGradient,
);

class AppTextTheme extends ThemeExtension<AppTextTheme> {
  AppTextTheme({this.color = AppColors.blackcolor});
  final Color color;

  static const String _fontFamily = 'Nunito';

  TextStyle _style(double size, FontWeight weight) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: size,
    fontWeight: weight,
    color: color,
  );

  // 18
  TextStyle get text18W600 => _style(18, FontWeight.w600);
  TextStyle get text18W500 => _style(18, FontWeight.w500);
  TextStyle get text18W400 => _style(18, FontWeight.w400);
  TextStyle get text18Bold => _style(18, FontWeight.bold);

  // 16
  TextStyle get text16W600 => _style(16, FontWeight.w600);
  TextStyle get text16W500 => _style(16, FontWeight.w500);
  TextStyle get text16W400 => _style(16, FontWeight.w400);
  TextStyle get text16Bold => _style(16, FontWeight.bold);

  // 14
  TextStyle get text14W600 => _style(14, FontWeight.w600);
  TextStyle get text14W500 => _style(14, FontWeight.w500);
  TextStyle get text14W400 => _style(14, FontWeight.w400);
  TextStyle get text14Bold => _style(14, FontWeight.bold);

  // 12
  TextStyle get text12W600 => _style(12, FontWeight.w600);
  TextStyle get text12W500 => _style(12, FontWeight.w500);
  TextStyle get text12W400 => _style(12, FontWeight.w400);
  TextStyle get text12Bold => _style(12, FontWeight.bold);

  @override
  ThemeExtension<AppTextTheme> copyWith({Color? color}) =>
      AppTextTheme(color: color ?? this.color);

  @override
  ThemeExtension<AppTextTheme> lerp(
    ThemeExtension<AppTextTheme>? other,
    double t,
  ) => this;
}

extension AppTextThemeExtension on BuildContext {
  AppTextTheme get appText =>
      Theme.of(this).extension<AppTextTheme>() ?? AppTextTheme();
}

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'Nunito',
    scaffoldBackgroundColor: AppColors.whitecolor,
    colorScheme: ColorScheme.light(
      primary: AppColors.bluecolor,
      onPrimary: AppColors.whitecolor,
      secondary: AppColors.bluecolor,
      onSecondary: AppColors.whitecolor,
      surface: AppColors.whitecolor,
      onSurface: AppColors.blackcolor,
      error: AppColors.redcolor,
      onError: AppColors.whitecolor,
    ),
    extensions: [
      AppTextTheme(),
      AppColorTheme(
        primary: AppColors.bluecolor,
        onPrimary: AppColors.whitecolor,
        surface: AppColors.whitecolor,
        onSurface: AppColors.blackcolor,
        error: AppColors.redcolor,
        onError: AppColors.whitecolor,
        greyDark: AppColors.greydark,
        greylight: AppColors.greylight,
        blue10: AppColors.blue10,
        blue20: AppColors.blue20,
        transparent: AppColors.transparent,
        primaryGradient: AppColors.primaryGradient,
      ),
    ],
  );
}
