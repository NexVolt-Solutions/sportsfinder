import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_form_field_layout.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';

// class TextFormFieldWidget extends StatelessWidget {
//   final String? label;
//   final String? hintText;
//   final TextEditingController? controller;
//   final String? Function(String?)? validator;
//   final TextInputType? keyboardType;

//   const TextFormFieldWidget({
//     super.key,
//     this.label,
//     this.hintText,
//     this.controller,
//     this.validator,
//     this.keyboardType,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final c = context.appColors;
//     return TextFormField(
//       controller: controller,
//       validator: validator,
//       keyboardType: keyboardType ?? TextInputType.text,
//       style: context.appText.text14W400.copyWith(color: c.greyDark),
//       decoration: InputDecoration(
//         alignLabelWithHint: true,
//         label: label != null
//             ? Text(
//                 label!,
//                 style: context.appText.text16W400.copyWith(color: c.onSurface),
//               )
//             : null,
//         hintText: hintText,
//         hintStyle: context.appText.text14W400.copyWith(color: c.greylight),
//         filled: true,
//         fillColor: c.transparent,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(context.radius(12)),
//           borderSide: BorderSide(color: c.greylight, width: 1),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(context.radius(12)),
//           borderSide: BorderSide(color: c.greylight, width: 1),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(context.radius(12)),
//           borderSide: BorderSide(color: c.primary, width: 1),
//         ),
//       ),
//     );
//   }
// }
class TextFormFieldWidget extends StatelessWidget {
  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  final bool readOnly;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;  
  final TextInputAction? textInputAction;
  final IconData? suffixIcon;
  final Widget? customSuffix;
  final Color? fillColor;
  final int maxLines;

  const TextFormFieldWidget({
    super.key,
    this.label, 
    this.onChanged,
    this.hintText,
    this.controller,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.fillColor,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
    this.customSuffix,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;

    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType ?? TextInputType.text,
      textInputAction: textInputAction,
      readOnly: readOnly,
      onTap: onTap,
      onChanged: onChanged,
      maxLines: maxLines,
      style: context.appText.text14W400.copyWith(color: c.greyDark),
      decoration: InputDecoration(
        alignLabelWithHint: true,
          
        isDense: maxLines == 1,
        constraints: maxLines == 1
            ? AppFormFieldLayout.singleLineConstraints(context)
            : null,
        
        errorStyle: AppFormFieldLayout.errorStyle(context),
        errorMaxLines: 2,
        suffixIconConstraints: BoxConstraints(
          minWidth: context.w(40),
          minHeight: context.h(40),
        ),
        label: label != null
            ? Text(
                label!,
                style: context.appText.text16W400.copyWith(color: c.onSurface),
              )
            : null,
        hintText: hintText,
        hintStyle: context.appText.text14W400.copyWith(color: c.greylight),
        filled: true,
        fillColor: fillColor ?? c.transparent,
        suffixIcon:
            customSuffix ??
            (suffixIcon != null ? Icon(suffixIcon, color: c.greyDark) : null),
        border: OutlineInputBorder(
          borderRadius: AppFormFieldLayout.borderRadius(context),
          borderSide: BorderSide(color: c.greylight, width: 1),
        ),

        // ✅ ENABLED
        enabledBorder: OutlineInputBorder(
          borderRadius: AppFormFieldLayout.borderRadius(context),
          borderSide: BorderSide(color: c.greylight, width: 1),
        ),

        // ✅ FOCUSED (Primary Color)
        focusedBorder: OutlineInputBorder(
          borderRadius: AppFormFieldLayout.borderRadius(context),
          borderSide: BorderSide(color: c.primary, width: 1),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: AppFormFieldLayout.borderRadius(context),
          borderSide: BorderSide(color: c.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppFormFieldLayout.borderRadius(context),
          borderSide: BorderSide(color: c.error, width: 1),
        ),

        // (Optional) disable white hover issue
        disabledBorder: OutlineInputBorder(
          borderRadius: AppFormFieldLayout.borderRadius(context),
          borderSide: BorderSide(color: c.greylight, width: 1),
        ),
      ),
    );
  }
}
