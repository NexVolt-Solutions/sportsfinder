// import 'package:flutter/material.dart';
// import 'package:pinput/pinput.dart';
// import 'package:provider/provider.dart';
// import 'package:sport_finding/core/Constants/app_colors.dart';
// import 'package:sport_finding/core/Constants/app_text.dart';
// import 'package:sport_finding/core/Constants/app_theme.dart';
// import 'package:sport_finding/core/Constants/size_extension.dart';
// import 'package:sport_finding/core/Routes/routes_name.dart';
// import 'package:sport_finding/feature/view/Otp/OtpScreenViewModel/otp_verification_screen_view_model.dart';
// import 'package:sport_finding/feature/widget/app_bar_widget.dart';
// import 'package:sport_finding/feature/widget/auth_footer_text.dart';
// import 'package:sport_finding/feature/widget/mainframe.dart';
// import 'package:sport_finding/feature/widget/normal_text.dart';

// class OtpVerificationScreen extends StatefulWidget {
//   const OtpVerificationScreen({super.key});

//   @override
//   State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
// }

// class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
//   final TextEditingController _pinController = TextEditingController();

//   String? _email = '';

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     // Get email argument passed from signup screen
//     final args = ModalRoute.of(context)?.settings.arguments;
//     if (args != null && args is String) {
//       _email = args;
//     }
//   }

//   @override
//   void dispose() {
//     _pinController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final defaultPinTheme = PinTheme(
//       // padding: context.padSym(h: 12, v: 16),
//       width: context.w(45),
//       height: context.h(45),
//       textStyle: context.appText.text16W600.copyWith(
//         color: context.appColors.onSurface,
//       ),
//       decoration: BoxDecoration(
//         color: AppColors.transparent,
//         border: Border.all(color: context.appColors.greylight),
//         borderRadius: BorderRadius.circular(context.radius(8)),
//       ),
//     );

//     final focusedPinTheme = defaultPinTheme.copyDecorationWith(
//       border: Border.all(color: context.appColors.primary),
//       borderRadius: BorderRadius.circular(context.radius(8)),
//     );

//     final submittedPinTheme = defaultPinTheme.copyWith(
//       decoration: defaultPinTheme.decoration!.copyWith(
//         color: AppColors.transparent,
//       ),
//     );

//     return Consumer<OtpVerificationScreenViewModel>(
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
//               // ✅ Step 3: OTP input
//               Pinput(
//                 length: 6,
//                 controller: _pinController,
//                 defaultPinTheme: defaultPinTheme,
//                 focusedPinTheme: focusedPinTheme,
//                 submittedPinTheme: submittedPinTheme,
//                 pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
//                 validator: (s) {
//                   return s == '123456' ? null : 'Pin is incorrect';
//                 },
//                 showCursor: true,
//                 // ✅ Step 4: Called when all 6 digits entered
//                 onCompleted: (pin) async {
//                   final error = await vm.verfyOtp(email: _email!, otp: pin);

//                   if (!context.mounted) return;

//                   if (error == null) {
//                     // ✅ Success - go to next screen
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text("OTP Verified Successfully!"),
//                       ),
//                     );
//                     Navigator.pushNamed(context, RoutesName.skillLevelScreen);
//                   } else {
//                     // ❌ Show error
//                     ScaffoldMessenger.of(
//                       context,
//                     ).showSnackBar(SnackBar(content: Text(error)));
//                   }
//                 },
//               ),
//               // Pinput(
//               //   length: 6,
//               //   defaultPinTheme: defaultPinTheme,
//               //   focusedPinTheme: focusedPinTheme,
//               //   submittedPinTheme: submittedPinTheme,
//               //   pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
//               //   showCursor: true,
//               //   validator: (s) {
//               //     return s == '123456' ? null : 'Pin is incorrect';
//               //   },
//               //   onCompleted: (pin) async {
//               //     final error = await vm.verfyOtp(email: _email!, otp: pin);

//               //     if (!context.mounted) return;

//               //     if (error == null) {
//               //       // ✅ Success - go to next screen
//               //       ScaffoldMessenger.of(context).showSnackBar(
//               //         const SnackBar(
//               //           content: Text("OTP Verified Successfully!"),
//               //         ),
//               //       );
//               //       Navigator.pushNamed(context, RoutesName.skillLevelScreen);
//               //     } else {
//               //       // ❌ Show error
//               //       ScaffoldMessenger.of(
//               //         context,
//               //       ).showSnackBar(SnackBar(content: Text(error)));
//               //     }
//               //   },
//               // ),
//               SizedBox(height: context.h(20)),
//               NormalText(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 titleText: "02:30s",
//                 titleColor: context.appColors.primary,
//               ),
//               SizedBox(height: context.h(20)),
//               AuthFooterText(
//                 normalText: AppText.didntReceiveTheCodeResend,
//                 actionText: AppText.reSend,
//                 onTap: () async {
//                   final error = await vm.resendOtp(email: _email!);

//                   if (!context.mounted) return;

//                   if (error == null) {
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
import 'package:sport_finding/feature/view/Auth/Otp/OtpScreenViewModel/otp_verification_screen_view_model.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/auth_footer_text.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _pinController = TextEditingController();

  String _email = '';

  // ✅ Timer variables
  Timer? _timer;
  int _secondsRemaining = 150; // 2:30 minutes
  bool _timerVisible = true; // ✅ show timer from start

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is String) {
      _email = args;
    }
  }

  @override
  void initState() {
    super.initState();
    _startTimer(); // ✅ start timer when screen opens
  }

  // ✅ Start countdown timer
  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _secondsRemaining = 120; // reset to 2:30
      _timerVisible = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
        setState(() {
          _timerVisible = false; // hide timer when done
        });
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  // ✅ Format seconds to MM:SS
  String get _formattedTime {
    final minutes = _secondsRemaining ~/ 60;
    final seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}s';
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
        borderRadius: BorderRadius.circular(context.radius(8)),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: context.appColors.primary),
      borderRadius: BorderRadius.circular(context.radius(8)),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: AppColors.transparent,
      ),
    );

    return Consumer<OtpVerificationScreenViewModel>(
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

              // ✅ OTP Input with auto-fill support
              Pinput(
                length: 6,
                controller: _pinController,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: focusedPinTheme,
                submittedPinTheme: submittedPinTheme,
                pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                showCursor: true,
                // ✅ This enables SMS auto-fill on Android
                // smsRetrieverEnabled: true,
                onCompleted: (pin) async {
                  final error = await vm.verfyOtp(email: _email, otp: pin);

                  if (!context.mounted) return;

                  if (error == null) {
                    AppSnackBar.show('OTP Verified Successfully!');
                    Navigator.pushNamed(context, RoutesName.LoginScreen);
                  } else {
                    // ❌ Wrong OTP - clear and restart timer
                    _pinController.clear();
                    AppSnackBar.show(error);
                  }
                },
              ),

              SizedBox(height: context.h(20)),

              // ✅ Loading indicator
              if (vm.isLoading)
                const Center(child: CircularProgressIndicator()),

              SizedBox(height: context.h(10)),

              // ✅ Timer - always visible, counts down from 2:30
              if (_timerVisible)
                NormalText(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  titleText: _formattedTime,
                  titleColor: context.appColors.primary,
                ),

              SizedBox(height: context.h(20)),

              // ✅ Resend OTP - resets timer
              AuthFooterText(
                normalText: AppText.didntReceiveTheCodeResend,
                actionText: AppText.reSend,
                onTap: () async {
                  final error = await vm.resendOtp(email: _email);

                  if (!context.mounted) return;

                  if (error == null) {
                    _pinController.clear(); // clear OTP field
                    _startTimer(); // ✅ restart timer
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
