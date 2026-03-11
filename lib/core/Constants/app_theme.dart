// import 'package:flutter/material.dart';
// import 'package:looklabs/Core/Constants/app_colors.dart';

// class AppTheme {
//   // Color Palette from Figma
//   static const Color primaryTeal = Color(0xFF008080);
//   static const Color lightGray = Color(0xFFE0E0E0);
//   static const Color deepTeal = Color(0xFF004D4D);
//   static const Color slateGray = Color(0xFF708090);
//   static const Color pureWhite = Color(0xFFFFFFFF);
//   static const Color darkGray = Color(0xFF363636);
//   static const Color tealAccent = Color(0xFF2D8B9C);

//   // Background gradient colors
//   static const Color backgroundLight = Color(0xFFF5F7FA);
//   static const Color textDark = Color(0xFF333333);
//   static const Color textLight = Color(0xFF666666);
//   static const Color borderLight = Color(0xFFE5E5E5);

//   // Helper extension for easy theme access
//   static ThemeData theme(BuildContext context) => Theme.of(context);
//   static ColorScheme colors(BuildContext context) =>
//       Theme.of(context).colorScheme;
//   static TextTheme texts(BuildContext context) => Theme.of(context).textTheme;

//   static ThemeData get lightTheme {
//     return ThemeData(
//       useMaterial3: true,
//       brightness: Brightness.light,

//       colorScheme: ColorScheme.light(
//         primary: AppColors.pimaryColor,
//         onPrimary: AppColors.white,

//         secondary: AppColors.seconderyColor,
//         onSecondary: AppColors.white,

//         tertiary: AppColors.subHeadingColor,

//         surface: AppColors.backGroundColor,
//         onSurface: AppColors.headingColor,

//         background: AppColors.backGroundColor,

//         error: Colors.red,
//         onError: AppColors.white,

//         // onBackground: textDark,
//       ),

//       scaffoldBackgroundColor: backgroundLight,

//       appBarTheme: const AppBarTheme(
//         elevation: 0,
//         centerTitle: true,
//         backgroundColor: pureWhite,
//         foregroundColor: textDark,
//         titleTextStyle: TextStyle(
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//           color: textDark,
//           fontFamily: 'Roboto',
//         ),
//       ),

//       textTheme: TextTheme(
//         // displayLarge: TextStyle.heading1,
//         displayMedium: TextStyle(
//           fontSize: 24,
//           fontWeight: FontWeight.w500,
//           color: textDark,
//           fontFamily: 'Roboto',
//         ),

//         titleLarge: TextStyle(
//           fontSize: 20,
//           fontWeight: FontWeight.w600,
//           color: textDark,
//           fontFamily: 'Roboto',
//         ),
//         titleMedium: TextStyle(
//           fontSize: 18,
//           fontWeight: FontWeight.w600,
//           color: textDark,
//           fontFamily: 'Roboto',
//         ),
//         bodyLarge: TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.normal,
//           color: textDark,
//           fontFamily: 'Roboto',
//         ),
//         bodyMedium: TextStyle(
//           fontSize: 14,
//           fontWeight: FontWeight.normal,
//           color: textLight,
//           fontFamily: 'Roboto',
//         ),
//       ),

//       elevatedButtonTheme: ElevatedButtonThemeData(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: tealAccent,
//           foregroundColor: pureWhite,
//           elevation: 0,
//           padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           textStyle: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             fontFamily: 'Roboto',
//           ),
//         ),
//       ),

//       // iconButtonTheme: IconButtonThemeData(
//       //   style: IconButton.styleFrom(
//       //     backgroundColor: tealAccent,
//       //     foregroundColor: pureWhite,
//       //     elevation: 0,
//       //     padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
//       //     shape: RoundedRectangleBorder(
//       //       borderRadius: BorderRadius.circular(12),
//       //     ),

//       //   ),
//       // ),
//       outlinedButtonTheme: OutlinedButtonThemeData(
//         style: OutlinedButton.styleFrom(
//           foregroundColor: textDark,
//           side: const BorderSide(color: borderLight, width: 1),
//           padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           textStyle: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.normal,
//             fontFamily: 'Roboto',
//           ),
//         ),
//       ),

//       inputDecorationTheme: InputDecorationTheme(
//         filled: true,
//         fillColor: pureWhite,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: tealAccent, width: 1),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: tealAccent, width: 1),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: tealAccent, width: 2),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: Colors.red, width: 1),
//         ),
//         focusedErrorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: Colors.red, width: 2),
//         ),
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: 16,
//           vertical: 16,
//         ),
//         hintStyle: const TextStyle(
//           color: textLight,
//           fontSize: 14,
//           fontFamily: 'Roboto',
//         ),
//       ),
//     );
//   }
// }
