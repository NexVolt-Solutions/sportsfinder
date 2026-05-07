import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';

class AppDialogAction {
  const AppDialogAction({
    required this.label,
    required this.onPressed,
    this.isDestructive = false,
    this.isDefault = false,
  });

  final String label;
  final void Function(BuildContext dialogContext) onPressed;
  final bool isDestructive;
  final bool isDefault;
}

Future<T?> showAppDialog<T>(
  BuildContext context, {
  String? title,
  String? message,
  Widget? content,
  bool barrierDismissible = true,
  required List<AppDialogAction> actions,
}) {
  assert(
    content != null || message != null,
    'Either content or message must be provided.',
  );

  final c = context.appColors;
  final t = context.appText;

  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: c.onPrimary,
        surfaceTintColor: c.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.radius(14)),
        ),
        title: title == null
            ? null
            : Text(
                title,
                style: t.text16W600.copyWith(color: c.onSurface),
              ),
        content: content ??
            Text(
              message!,
              style: t.text14W400.copyWith(color: c.greyDark),
            ),
        actionsPadding: EdgeInsets.only(
          left: context.w(12),
          right: context.w(12),
          bottom: context.h(10),
        ),
        actions: actions.map((a) {
          final color = a.isDestructive
              ? c.error
              : (a.isDefault ? c.primary : c.greyDark);
          final style = t.text14W600.copyWith(color: color);
          return TextButton(
            onPressed: () => a.onPressed(dialogContext),
            child: Text(a.label, style: style),
          );
        }).toList(),
      );
    },
  );
}

