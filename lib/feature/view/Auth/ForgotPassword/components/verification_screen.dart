import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
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
import 'package:sport_finding/feature/widget/web_auth_shell.dart';

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
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is String) {
      _email = args;
    }
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

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
      builder: (context, vm, child) {
        final content = ListView(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          children: [
            if (!kIsWeb)
              AppBarWidget(
                onTapFirst: () => Navigator.pop(context),
                title: AppText.sportFinding,
              ),
            if (!kIsWeb) SizedBox(height: context.h(30)),
            NormalText(
              titleText: kIsWeb ? 'Verify Your Identity' : AppText.verifyYourAccount,
              subText: kIsWeb
                  ? 'We sent a 6-digit code to your email.\nEnter it below to continue.'
                  : AppText.enterThe6DigitCodeWeHaveSentTo(_email),
              maxLines: 3,
              crossAxisAlignment: CrossAxisAlignment.center,
              subAlign: TextAlign.center,
            ),
            SizedBox(height: context.h(30)),
            Pinput(
              length: 6,
              controller: _pinController,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: focusedPinTheme,
              submittedPinTheme: submittedPinTheme,
              showCursor: true,
              pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
              onCompleted: (pin) async {
                if (_email.isEmpty) {
                  AppSnackBar.show('Email not found. Please try again.');
                  return;
                }

                final error = await vm.verifyOtp(email: _email, otp: pin);

                if (!context.mounted) return;

                if (error == null) {
                  if (vm.resetToken.trim().isEmpty) {
                    _pinController.clear();
                    AppSnackBar.show(
                      'Reset token missing. Please try again.',
                    );
                    return;
                  }
                  AppSnackBar.show('OTP Verified Successfully!');
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
            if (vm.isLoading) const Center(child: CircularProgressIndicator()),
            SizedBox(height: context.h(10)),
            if (_timerVisible)
              NormalText(
                crossAxisAlignment: CrossAxisAlignment.center,
                titleText: _formattedTime,
                titleColor: context.appColors.primary,
              ),
            SizedBox(height: context.h(20)),
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
        );

        if (kIsWeb) {
          return WebAuthSplitShell(child: content);
        }

        return Scaffold(
          body: MainFrame(
            child: Padding(
              padding: context.padSym(h: 20),
              child: content,
            ),
          ),
        );
      },
    );
  }
}
