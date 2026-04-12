// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:pinput/pinput.dart';
// import 'package:provider/provider.dart';
// import 'package:sport_finding/core/Constants/app_colors.dart';
// import 'package:sport_finding/core/Constants/app_text.dart';
// import 'package:sport_finding/core/Constants/app_theme.dart';
// import 'package:sport_finding/core/Constants/size_extension.dart';
// import 'package:sport_finding/core/Routes/routes_name.dart';
// import 'package:sport_finding/feature/view/Auth/ForgotPassword/ViewModel/verification_screen_view_model.dart';
// import 'package:sport_finding/feature/view/Auth/ForgotPassword/forgot_password_screen_view_model.dart';
// import 'package:sport_finding/feature/widget/app_bar_widget.dart';
// import 'package:sport_finding/feature/widget/auth_footer_text.dart';
// import 'package:sport_finding/feature/widget/custom_button.dart';
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

//   // ✅ Timer variables
//   Timer? _timer;
//   int _secondsRemaining = 150; // 2:30 minutes
//   bool _timerVisible = true; // ✅ show timer from start

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
//       _secondsRemaining = 150; // reset to 2:30
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
//     final email = ModalRoute.of(context)!.settings.arguments as String;
//     print('email: $_email');
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
//       builder: (context, vm, child) {
//         return Scaffold(
//           body: MainFrame(
//             child: ListView(
//               padding: context.padSym(h: 20),
//               children: [
//                 AppBarWidget(
//                   onTapFirst: () => Navigator.pop(context),
//                   title: AppText.sportFinding,
//                 ),
//                 SizedBox(height: context.h(30)),
//                 NormalText(
//                   titleText: AppText.verifyYourAccount,
//                   subText: AppText.enterThe6DigitCodeWeHaveSentToYourEmail,
//                   maxLines: 2,
//                 ),
//                 SizedBox(height: context.h(30)),

//                 // ✅ OTP Input with auto-fill support
//                 Pinput(
//                   length: 6,
//                   controller: _pinController,
//                   defaultPinTheme: defaultPinTheme,
//                   focusedPinTheme: focusedPinTheme,
//                   submittedPinTheme: submittedPinTheme,
//                   pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
//                   showCursor: true,
//                   // ✅ This enables SMS auto-fill on Android
//                   // smsRetrieverEnabled: true,
//                   onCompleted: (pin) async {
//                     final error = await vm.forgotPassword();

//                     if (!context.mounted) return;

//                     if (error == null) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text("OTP Verified Successfully!"),
//                         ),
//                       );
//                       Navigator.pushNamed(context, RoutesName.LoginScreen);
//                     } else {
//                       // ❌ Wrong OTP - clear and restart timer
//                       _pinController.clear();
//                       ScaffoldMessenger.of(
//                         context,
//                       ).showSnackBar(SnackBar(content: Text(error)));
//                     }
//                   },
//                 ),

//                 SizedBox(height: context.h(20)),

//                 // ✅ Loading indicator
//                 if (vm.isLoading)
//                   const Center(child: CircularProgressIndicator()),

//                 SizedBox(height: context.h(10)),

//                 // ✅ Timer - always visible, counts down from 2:30
//                 if (_timerVisible)
//                   NormalText(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     titleText: _formattedTime,
//                     titleColor: context.appColors.primary,
//                   ),

//                 SizedBox(height: context.h(20)),

//                 // ✅ Resend OTP - resets timer
//                 AuthFooterText(
//                   normalText: AppText.didntReceiveTheCodeResend,
//                   actionText: AppText.reSend,
//                   onTap: () async {
//                     final error = await vm.resendOtp(email: _email);

//                     if (!context.mounted) return;

//                     if (error == null) {
//                       _pinController.clear(); // clear OTP field
//                       _startTimer(); // ✅ restart timer
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text("OTP Resent!")),
//                       );
//                     } else {
//                       ScaffoldMessenger.of(
//                         context,
//                       ).showSnackBar(SnackBar(content: Text(error)));
//                     }
//                   },
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
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
import 'package:sport_finding/feature/view/Auth/ForgotPassword/forgot_password_screen_view_model.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/auth_footer_text.dart';
import 'package:sport_finding/feature/widget/custom_button.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  // final TextEditingController _pinController = TextEditingController();

  // String _email = '';

  // // Timer variables
  // Timer? _timer;
  // int _secondsRemaining = 150;
  // bool _timerVisible = true;

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   // ✅ Safely get email from arguments
  //   final args = ModalRoute.of(context)?.settings.arguments;
  //   if (args != null && args is String) {
  //     _email = args;
  //     print('📧 Email received: $_email');
  //   }
  // }

  // @override
  // void initState() {
  //   super.initState();
  //   _startTimer();
  // }

  // void _startTimer() {
  //   _timer?.cancel();
  //   setState(() {
  //     _secondsRemaining = 120; // ✅ Changed from 150 to 120 (2 minutes)
  //     _timerVisible = true;
  //   });

  //   _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
  //     if (_secondsRemaining == 0) {
  //       timer.cancel();
  //       setState(() {
  //         _timerVisible = false;
  //       });
  //     } else {
  //       setState(() {
  //         _secondsRemaining--;
  //       });
  //     }
  //   });
  // }

  // String get _formattedTime {
  //   final minutes = _secondsRemaining ~/ 60;
  //   final seconds = _secondsRemaining % 60;
  //   return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}s';
  // }

  // @override
  // void dispose() {
  //   _timer?.cancel();
  //   _pinController.dispose();
  //   super.dispose();
  // }

  // @override
  // Widget build(BuildContext context) {
  //   // ✅ Use _email directly — NO more casting arguments here
  //   print('📧 Email in build: $_email');

  //   final defaultPinTheme = PinTheme(
  //     width: context.w(45),
  //     height: context.h(45),
  //     textStyle: context.appText.text16W600.copyWith(
  //       color: context.appColors.onSurface,
  //     ),
  //     decoration: BoxDecoration(
  //       color: AppColors.transparent,
  //       border: Border.all(color: context.appColors.greylight),
  //       borderRadius: BorderRadius.circular(context.radiusR(8)),
  //     ),
  //   );

  //   final focusedPinTheme = defaultPinTheme.copyDecorationWith(
  //     border: Border.all(color: context.appColors.primary),
  //     borderRadius: BorderRadius.circular(context.radiusR(8)),
  //   );

  //   final submittedPinTheme = defaultPinTheme.copyWith(
  //     decoration: defaultPinTheme.decoration!.copyWith(
  //       color: AppColors.transparent,
  //     ),
  //   );

  //   return Consumer<ForgotPasswordScreenViewModel>(
  //     builder: (context, vm, child) {
  //       return Scaffold(
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

  //               // ✅ OTP Input
  //               Pinput(
  //                 length: 6,
  //                 controller: _pinController,
  //                 defaultPinTheme: defaultPinTheme,
  //                 focusedPinTheme: focusedPinTheme,
  //                 submittedPinTheme: submittedPinTheme,
  //                 pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
  //                 showCursor: true,
  //                 autofocus: true,
  //                 onCompleted: (pin) async {
  //                   print('🔢 PIN entered: $pin');
  //                   print('📧 Email used: $_email');

  //                   final error = await vm.forgotPassword();

  //                   if (!context.mounted) return;

  //                   if (error == null) {
  //                     ScaffoldMessenger.of(context).showSnackBar(
  //                       const SnackBar(
  //                         content: Text("OTP Verified Successfully!"),
  //                         backgroundColor: Colors.green,
  //                       ),
  //                     );
  //                     Navigator.pushNamed(
  //                       context,
  //                       RoutesName.newPasswordScreen,
  //                       arguments: _email,
  //                     );
  //                   } else {
  //                     // ❌ Wrong OTP - clear field
  //                     _pinController.clear();
  //                     ScaffoldMessenger.of(context).showSnackBar(
  //                       SnackBar(
  //                         content: Text(error),
  //                         backgroundColor: Colors.red,
  //                       ),
  //                     );
  //                   }
  //                 },
  //               ),

  //               SizedBox(height: context.h(20)),

  //               // ✅ Loading indicator
  //               if (vm.isLoading)
  //                 const Center(child: CircularProgressIndicator()),

  //               SizedBox(height: context.h(10)),

  //               // ✅ Timer countdown
  //               if (_timerVisible)
  //                 NormalText(
  //                   crossAxisAlignment: CrossAxisAlignment.center,
  //                   titleText: _formattedTime,
  //                   titleColor: context.appColors.primary,
  //                 ),

  //               SizedBox(height: context.h(20)),

  //               // ✅ Resend OTP
  //               if (!vm.isLoading)
  //                 AuthFooterText(
  //                   normalText: AppText.didntReceiveTheCodeResend,
  //                   actionText: AppText.reSend,
  //                   onTap: () async {
  //                     if (_timerVisible) {
  //                       // ⏳ Timer still running - block resend
  //                       ScaffoldMessenger.of(context).showSnackBar(
  //                         SnackBar(
  //                           content: Text(
  //                             'Please wait $_formattedTime before resending',
  //                           ),
  //                           backgroundColor: Colors.orange,
  //                         ),
  //                       );
  //                       return;
  //                     }

  //                     // ✅ Timer expired - allow resend
  //                     final error = await vm.resendOtp(email: _email);

  //                     if (!context.mounted) return;

  //                     if (error == null) {
  //                       _pinController.clear();
  //                       _startTimer(); // ✅ Restart timer
  //                       ScaffoldMessenger.of(context).showSnackBar(
  //                         const SnackBar(
  //                           content: Text("OTP Resent Successfully!"),
  //                           backgroundColor: Colors.green,
  //                         ),
  //                       );
  //                     } else {
  //                       ScaffoldMessenger.of(context).showSnackBar(
  //                         SnackBar(
  //                           content: Text(error),
  //                           backgroundColor: Colors.red,
  //                         ),
  //                       );
  //                     }
  //                   },
  //                 ),

  //               SizedBox(height: context.h(20)),

  //               // ✅ Verify Button
  //               CustomButton(
  //                 onTap: vm.isLoading
  //                     ? null
  //                     : () async {
  //                         if (_pinController.text.length != 6) {
  //                           ScaffoldMessenger.of(context).showSnackBar(
  //                             const SnackBar(
  //                               content: Text('Please enter 6-digit code'),
  //                               backgroundColor: Colors.orange,
  //                             ),
  //                           );
  //                           return;
  //                         }

  //                         print('🔢 Manual verify PIN: ${_pinController.text}');
  //                         print('📧 Email used: $_email');

  //                         final error = await vm.forgotPassword();

  //                         if (!context.mounted) return;

  //                         if (error == null) {
  //                           ScaffoldMessenger.of(context).showSnackBar(
  //                             const SnackBar(
  //                               content: Text("OTP Verified Successfully!"),
  //                               backgroundColor: Colors.green,
  //                             ),
  //                           );
  //                           Navigator.pushNamed(
  //                             context,
  //                             RoutesName.newPasswordScreen,
  //                             arguments: _email,
  //                           );
  //                         } else {
  //                           _pinController.clear();
  //                           ScaffoldMessenger.of(context).showSnackBar(
  //                             SnackBar(
  //                               content: Text(error),
  //                               backgroundColor: Colors.red,
  //                             ),
  //                           );
  //                         }
  //                       },
  //                 text: vm.isLoading
  //                     ? 'Verifying...'
  //                     : AppText.verifyYourAccount,
  //                 color: context.appColors.primary,
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }
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

    return Consumer<ForgotPasswordScreenViewModel>(
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
                subText: AppText.enterThe6DigitCodeWeHaveSentToYourEmail,
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
                  final error = await vm.verifyOtp(email: _email, otp: pin);

                  if (!context.mounted) return;

                  if (error == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("OTP Verified Successfully!"),
                      ),
                    );
                    Navigator.pushNamed(
                      context,
                      RoutesName.newPasswordScreen,
                      arguments: _email,
                    );
                  } else {
                    // ❌ Wrong OTP - clear and restart timer
                    _pinController.clear();
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(error)));
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("OTP Resent!")),
                    );
                  } else {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(error)));
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
