import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_colors.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';

class TermsCheckbox extends StatefulWidget {
  const TermsCheckbox({super.key});

  @override
  State<TermsCheckbox> createState() => _TermsCheckboxState();
}

class _TermsCheckboxState extends State<TermsCheckbox> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: isChecked,
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.bluecolor;
            }
            return AppColors.whitecolor;
          }),
          checkColor: AppColors.whitecolor,
          side: const BorderSide(color: AppColors.greydark, width: 1.5),
          onChanged: (value) {
            setState(() {
              isChecked = value ?? false;
            });
          },
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                color: AppColors.greylight60,
                fontSize: context.sp(12),
              ),
              children: [
                TextSpan(text: AppText.iAgreeTo),
                TextSpan(
                  text: AppText.agreeToTerms,
                  style: TextStyle(
                    color: AppColors.bluecolor,
                    fontWeight: FontWeight.w500,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      // Navigate to Terms screen
                    },
                ),
                TextSpan(text: AppText.and),
                TextSpan(
                  text: AppText.privacy,
                  style: const TextStyle(
                    color: AppColors.bluecolor,
                    fontWeight: FontWeight.w500,
                  ),
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
