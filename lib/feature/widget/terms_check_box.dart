import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/app_text.dart';

class TermsCheckbox extends StatefulWidget {
  const TermsCheckbox({super.key});

  @override
  State<TermsCheckbox> createState() => _TermsCheckboxState();
}

class _TermsCheckboxState extends State<TermsCheckbox> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Row(
      children: [
        Checkbox(
          value: isChecked,
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return c.primary;
            }
            return c.surface;
          }),
          checkColor: c.onPrimary,
          side: BorderSide(color: c.greyDark, width: 1.5),
          onChanged: (value) {
            setState(() {
              isChecked = value ?? false;
            });
          },
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: context.appText.text12W400.copyWith(color: c.greylight),
              children: [
                TextSpan(text: AppText.iAgreeTo),
                TextSpan(
                  text: AppText.agreeToTerms,
                  style: context.appText.text12W500.copyWith(color: c.primary),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      // Navigate to Terms screen
                    },
                ),
                TextSpan(text: AppText.and),
                TextSpan(
                  text: AppText.privacy,
                  style: context.appText.text12W500.copyWith(color: c.primary),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      // Navigate to Privacy Policy screen
                    },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
