import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_form_field_layout.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';

class TextFormFieldWidget extends StatelessWidget {
  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  final bool readOnly;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;  
  final ValueChanged<String>? onFieldSubmitted;
  final TextInputAction? textInputAction;
  final IconData? preffixIcon;
  final Widget? customSuffix;
  final Color? fillColor;
  final int maxLines;
  final double? controlHeight;

  const TextFormFieldWidget({
    super.key,
    this.label, 
    this.onChanged,
    this.onFieldSubmitted,
    this.hintText,
    this.controller,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.fillColor,
    this.readOnly = false,
    this.onTap,
    this.preffixIcon,
    this.customSuffix,
    this.maxLines = 1,
    this.controlHeight,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final resolvedControlHeight = controlHeight ?? 48.0;
    final isSingleLine = maxLines == 1;

    final field = TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType ?? TextInputType.text,
      textInputAction: textInputAction,
      readOnly: readOnly,
      onTap: onTap,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      maxLines: maxLines,
      textAlignVertical: isSingleLine ? TextAlignVertical.center : null,
      style: context.appText.text14W400.copyWith(color: c.greyDark),
      decoration: AppFormFieldLayout.standardOutlineInputDecoration(
        context,
        label: label != null
            ? Text(
                label!,
                style: context.appText.text16W400.copyWith(color: c.onSurface),
              )
            : null,
        hintText: hintText,
        fillColor: fillColor ?? c.blue10,
        contentPadding: isSingleLine
            ? AppFormFieldLayout.singleLineFieldPadding(context)
            : AppFormFieldLayout.contentPaddingMultiline(context),
        isDense: false,
        constraints: isSingleLine
            ? (controlHeight != null
                ? BoxConstraints(minHeight: resolvedControlHeight)
                : AppFormFieldLayout.singleLineConstraints(context))
            : null,
        prefixIcon: customSuffix ??
            (preffixIcon != null ? Icon(preffixIcon, color: c.greyDark) : null),
        prefixIconConstraints: BoxConstraints(
          minWidth: resolvedControlHeight,
          minHeight: resolvedControlHeight,
        ),
      ),
    );

    // Do not wrap single-line fields in a fixed-height [SizedBox]: validation
    // error text lives below the input and needs vertical space; capping height
    // clips or crushes errors against the next field (e.g. Create Match date/time).
    return field;
  }
}
