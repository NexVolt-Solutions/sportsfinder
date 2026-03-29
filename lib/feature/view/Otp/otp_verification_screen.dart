import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:sport_finding/core/Constants/app_colors.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
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
  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      padding: EdgeInsets.zero,
      width: context.h(45),
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

    return Scaffold(
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
            Pinput(
              length: 6,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: focusedPinTheme,
              submittedPinTheme: submittedPinTheme,
              pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
              showCursor: true,
              validator: (s) {
                return s == '123456' ? null : 'Pin is incorrect';
              },
              onCompleted: (pin) {
                print(pin);
              },
            ),
            SizedBox(height: context.h(20)),
            NormalText(
              crossAxisAlignment: CrossAxisAlignment.center,
              titleText: "02:30s",
              titleColor: context.appColors.primary,
            ),
            SizedBox(height: context.h(20)),
            AuthFooterText(
              normalText: AppText.didntReceiveTheCodeResend,
              actionText: AppText.reSend,
              onTap: () {
                Navigator.pushNamed(context, RoutesName.skillLevelScreen);
              },
            ),
          ],
        ),
      ),
    );
  }
}
