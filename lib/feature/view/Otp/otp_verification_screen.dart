import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
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
      width: context.w(45),
      height: context.h(45),
      textStyle: context.appText.text16W600.copyWith(
        color: context.appColors.onSurface,
      ),
      decoration: BoxDecoration(
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
        color: context.appColors.greylight,
      ),
    );

    return Scaffold(
      body: MainFrame(
        child: ListView(
          padding: context.padSym(h: 20),
          children: [
            SizedBox(height: context.h(20)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                NormalText(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  titleText: AppText.sportFinding,
                  titleStyle: context.appText.text18W600,
                  titleColor: context.appColors.onSurface,
                ),
              ],
            ),

            SizedBox(height: context.h(30)),

            NormalText(
              crossAxisAlignment: CrossAxisAlignment.start,
              titleText: AppText.verifyYourAccount,
              titleStyle: context.appText.text16W600,
              titleColor: context.appColors.onSurface,
              subText: AppText.enterThe6DigitCodeWeHaveSentToYourEmail,
              subStyle: context.appText.text12W500,
              subColor: context.appColors.greylight,
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
              titleText: AppText.reSend,
              titleStyle: context.appText.text12W500,
              titleColor: context.appColors.greyDark,
            ),
            SizedBox(height: context.h(20)),
            AuthFooterText(
              normalText: AppText.didntReceiveTheCodeResend,
              actionText: AppText.reSend,
              onTap: () {
                Navigator.pushNamed(context, RoutesName.BottomBarScreen);
              },
            ),
          ],
        ),
      ),
    );
  }
}
