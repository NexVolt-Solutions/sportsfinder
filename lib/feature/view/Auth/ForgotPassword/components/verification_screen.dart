// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:pinput/pinput.dart';
// import 'package:provider/provider.dart';
// import 'package:sport_finding/core/Constants/app_colors.dart';
// import 'package:sport_finding/core/Constants/app_text.dart';
// import 'package:sport_finding/core/Constants/app_theme.dart';
// import 'package:sport_finding/core/Constants/size_extension.dart';
// import 'package:sport_finding/core/Routes/routes_name.dart';
// import 'package:sport_finding/feature/view/Auth/ForgotPassword/forgot_password_screen_view_model.dart';
// import 'package:sport_finding/feature/widget/app_bar_widget.dart';
// import 'package:sport_finding/feature/widget/auth_footer_text.dart';
// import 'package:sport_finding/feature/widget/mainframe.dart';
// import 'package:sport_finding/feature/widget/normal_text.dart';

// class VerificationScreen extends StatefulWidget {
//   const VerificationScreen({super.key});

//   @override
//   State<VerificationScreen> createState() => _VerificationScreenState();
// }

// class _VerificationScreenState extends State<VerificationScreen> {
//   final TextEditingController _pinController = TextEditingController();

//   String _email = '';

//   Timer? _timer;
//   int _secondsRemaining = 120;
//   bool _timerVisible = true;

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     final args = ModalRoute.of(context)?.settings.arguments;
//     if (args != null && args is String) {
//       _email = args;
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     _startTimer(); // ✅ start timer when screen opens
//   }

//   // ✅ Start countdown timer
//   void _startTimer() {
//     _timer?.cancel();
//     setState(() {
//       _secondsRemaining = 120; // reset to 2:00
//       _timerVisible = true;
//     });

//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (_secondsRemaining == 0) {
//         timer.cancel();
//         setState(() {
//           _timerVisible = false; // hide timer when done
//         });
//       } else {
//         setState(() {
//           _secondsRemaining--;
//         });
//       }
//     });
//   }

//   // ✅ Format seconds to MM:SS
//   String get _formattedTime {
//     final minutes = _secondsRemaining ~/ 60;
//     final seconds = _secondsRemaining % 60;
//     return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}s';
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     _pinController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final defaultPinTheme = PinTheme(
//       width: context.w(45),
//       height: context.h(45),
//       textStyle: context.appText.text16W600.copyWith(
//         color: context.appColors.onSurface,
//       ),
//       decoration: BoxDecoration(
//         color: AppColors.transparent,
//         border: Border.all(color: context.appColors.greylight),
//         borderRadius: BorderRadius.circular(context.radiusR(8)),
//       ),
//     );

//     final focusedPinTheme = defaultPinTheme.copyDecorationWith(
//       border: Border.all(color: context.appColors.primary),
//       borderRadius: BorderRadius.circular(context.radiusR(8)),
//     );

//     final submittedPinTheme = defaultPinTheme.copyWith(
//       decoration: defaultPinTheme.decoration!.copyWith(
//         color: AppColors.transparent,
//       ),
//     );

//     return Consumer<ForgotPasswordScreenViewModel>(
//       builder: (context, vm, child) => Scaffold(
//         body: MainFrame(
//           child: ListView(
//             padding: context.padSym(h: 20),
//             children: [
//               AppBarWidget(
//                 onTapFirst: () => Navigator.pop(context),
//                 title: AppText.sportFinding,
//               ),
//               SizedBox(height: context.h(30)),
//               NormalText(
//                 titleText: AppText.verifyYourAccount,
//                 subText: AppText.enterThe6DigitCodeWeHaveSentToYourEmail,
//                 maxLines: 2,
//               ),
//               SizedBox(height: context.h(30)),

//               // ✅ OTP Input with auto-fill support
//               Pinput(
//                 length: 6,
//                 controller: _pinController,
//                 defaultPinTheme: defaultPinTheme,
//                 focusedPinTheme: focusedPinTheme,
//                 submittedPinTheme: submittedPinTheme,
//                 pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
//                 showCursor: true,
//                 // ✅ This enables SMS auto-fill on Android
//                 // smsRetrieverEnabled: true,
//                 onCompleted: (pin) async {
//                   final error = await vm.verifyOtp(email: _email, otp: pin);

//                   if (!context.mounted) return;

//                   if (error == null) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text("OTP Verified Successfully!"),
//                       ),
//                     );
//                     Navigator.pushNamed(
//                       context,
//                       RoutesName.newPasswordScreen,
//                       arguments: _email,
//                     );
//                   } else {
//                     // ❌ Wrong OTP - clear and restart timer
//                     _pinController.clear();
//                     ScaffoldMessenger.of(
//                       context,
//                     ).showSnackBar(SnackBar(content: Text(error)));
//                   }
//                 },
//               ),

//               SizedBox(height: context.h(20)),

//               // ✅ Loading indicator
//               if (vm.isLoading)
//                 const Center(child: CircularProgressIndicator()),

//               SizedBox(height: context.h(10)),

//               // ✅ Timer - always visible, counts down from 2:30
//               if (_timerVisible)
//                 NormalText(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   titleText: _formattedTime,
//                   titleColor: context.appColors.primary,
//                 ),

//               SizedBox(height: context.h(20)),

//               // ✅ Resend OTP - resets timer
//               AuthFooterText(
//                 normalText: AppText.didntReceiveTheCodeResend,
//                 actionText: AppText.reSend,
//                 onTap: () async {
//                   final error = await vm.resendOtp(email: _email);

//                   if (!context.mounted) return;

//                   if (error == null) {
//                     _pinController.clear(); // clear OTP field
//                     _startTimer(); // ✅ restart timer
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text("OTP Resent!")),
//                     );
//                   } else {
//                     ScaffoldMessenger.of(
//                       context,
//                     ).showSnackBar(SnackBar(content: Text(error)));
//                   }
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/core/Constants/app_colors.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/core/utils/app_snack_bar.dart';
import 'package:sport_finding/feature/view/Auth/ForgotPassword/ViewModel/verification_screen_view_model.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/auth_footer_text.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final TextEditingController _pinController = TextEditingController();

  String _email = '';

  Timer? _timer;
  int _secondsRemaining = 120;
  bool _timerVisible = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // ✅ Retrieve email from route arguments safely
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is String) {
      _email = args;
    }

    debugPrint("📧 Received Email: $_email");
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  /// ✅ Start countdown timer
  void _startTimer() {
    _timer?.cancel();
    _secondsRemaining = 120;
    _timerVisible = true;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      if (_secondsRemaining == 0) {
        timer.cancel();
        setState(() {
          _timerVisible = false;
        });
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  /// ✅ Format seconds to MM:SS
  String get _formattedTime {
    final minutes = _secondsRemaining ~/ 60;
    final seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}s';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: context.w(45),
      height: context.h(45),
      textStyle: context.appText.text16W600.copyWith(
        color: context.appColors.onSurface,
      ),
      decoration: BoxDecoration(
        color: AppColors.transparent,
        border: Border.all(color: context.appColors.greylight),
        borderRadius: BorderRadius.circular(context.radiusR(8)),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: context.appColors.primary),
      borderRadius: BorderRadius.circular(context.radiusR(8)),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: AppColors.transparent,
      ),
    );

    return Consumer<VerificationScreenViewModel>(
      builder: (context, vm, child) => Scaffold(
        body: MainFrame(
          child: ListView(
            padding: context.padSym(h: 20),
            children: [
              AppBarWidget(
                onTapFirst: () => Navigator.pop(context),
                title: AppText.sportFinding,
              ),
              SizedBox(height: context.h(30)),

              NormalText(
                titleText: AppText.verifyYourAccount,
                subText: AppText.enterThe6DigitCodeWeHaveSentTo(_email),
                maxLines: 2,
              ),
              SizedBox(height: context.h(30)),

              /// 🔹 OTP INPUT
              Pinput(
                length: 6,
                controller: _pinController,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: focusedPinTheme,
                submittedPinTheme: submittedPinTheme,
                showCursor: true,
                pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                onCompleted: (pin) async {
                  debugPrint("🔐 Entered OTP: $pin");

                  if (_email.isEmpty) {
                    AppSnackBar.show('Email not found. Please try again.');
                    return;
                  }

                  final error = await vm.verifyOtp(email: _email, otp: pin);

                  if (!context.mounted) return;

                  debugPrint("🔎 Verification Result: $error");

                  if (error == null) {
                    if (vm.resetToken.trim().isEmpty) {
                      _pinController.clear();
                      AppSnackBar.show(
                        'Reset token missing. Please try again.',
                      );
                      return;
                    }
                    AppSnackBar.show('OTP Verified Successfully!');

                    /// ✅ Navigate to New Password Screen
                    Navigator.pushReplacementNamed(
                      context,
                      RoutesName.newPasswordScreen,
                      arguments: vm.resetToken.trim(),
                    );
                  } else {
                    _pinController.clear();
                    AppSnackBar.show(error);
                  }
                },
              ),

              SizedBox(height: context.h(20)),

              /// 🔹 Loading Indicator
              if (vm.isLoading)
                const Center(child: CircularProgressIndicator()),

              SizedBox(height: context.h(10)),

              /// 🔹 Timer
              if (_timerVisible)
                NormalText(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  titleText: _formattedTime,
                  titleColor: context.appColors.primary,
                ),

              SizedBox(height: context.h(20)),

              /// 🔹 Resend OTP
              AuthFooterText(
                normalText: AppText.didntReceiveTheCodeResend,
                actionText: AppText.reSend,
                onTap: () async {
                  final error = await vm.resendOtp(email: _email);

                  if (!context.mounted) return;

                  if (error == null) {
                    _pinController.clear();
                    _startTimer();
                    AppSnackBar.show('OTP Resent!');
                  } else {
                    AppSnackBar.show(error);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
