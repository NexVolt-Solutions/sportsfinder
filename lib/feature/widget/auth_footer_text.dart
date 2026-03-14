import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_colors.dart';
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
          style: const TextStyle(fontSize: 14, color: Colors.black),
          children: [
            if (normalText != null) TextSpan(text: normalText),
            if (actionText != null)
              TextSpan(
                text: actionText,
                style: TextStyle(
                  color: AppColors.bluecolor,
                  fontSize: context.sp(16),
                  fontWeight: FontWeight.w500,
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
