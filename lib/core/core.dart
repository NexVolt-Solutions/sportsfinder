/// Single import for app-wide constants, theme, and style extensions.
///
/// Add to any file:
///   import 'package:sport_finding/core/core.dart';
///
/// Then use anywhere in that file:
///   - context.appColors.primary, context.appColors.onSurface, ...
///   - context.appStyles.heading2, context.appStyles.bodyMedium, ...
///   - context.sp(16), context.sw(20), context.sh(20), ...
///   - Theme.of(context).textTheme (theme is set in main.dart for whole project)
library;

export 'package:sport_finding/core/Constants/app_colors.dart';
export 'package:sport_finding/core/Constants/app_styles.dart';
export 'package:sport_finding/core/Constants/size_extension.dart';
export 'package:sport_finding/core/Constants/app_theme.dart';
