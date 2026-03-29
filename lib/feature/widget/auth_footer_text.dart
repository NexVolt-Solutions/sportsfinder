import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';

class AuthFooterText extends StatelessWidget {
  final String? normalText;
  final String? actionText;
  final VoidCallback? onTap;

  const AuthFooterText({
    super.key,
    this.normalText,
    this.actionText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: context.appText.text16W500.copyWith(
          color: context.appColors.onSurface,
        ),
        children: [
          if (normalText != null) TextSpan(text: '${normalText!} '),
          if (actionText != null)
            TextSpan(
              text: actionText,
              style: context.appText.text16Bold.copyWith(
                color: context.appColors.primary,
              ),
              recognizer: onTap != null
                  ? (TapGestureRecognizer()..onTap = onTap)
                  : null,
            ),
        ],
      ),
    );
  }
}
