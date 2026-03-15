import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';

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
    return Center(
      child: RichText(
        text: TextSpan(
          style: context.appText.text14W400.copyWith(
            color: context.appColors.onSurface,
          ),
          children: [
            if (normalText != null) TextSpan(text: normalText),
            if (actionText != null)
              TextSpan(
                text: actionText,
                style: context.appText.text16W400.copyWith(
                  color: context.appColors.primary,
                ),
                recognizer: onTap != null
                    ? (TapGestureRecognizer()..onTap = onTap)
                    : null,
              ),
          ],
        ),
      ),
    );
  }
}
