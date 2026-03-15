import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_colors.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';

class TextFormFieldWidget extends StatelessWidget {
  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const TextFormFieldWidget({
    super.key,
    this.label,
    this.hintText,
    this.controller,
    this.validator,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType ?? TextInputType.text,
      style: TextStyle(fontSize: context.sp(14), color: AppColors.greydark),
      decoration: InputDecoration(
        alignLabelWithHint: true,
        label: label != null
            ? Text(
                label!,
                style: TextStyle(
                  color: AppColors.blackcolor,
                  fontSize: context.sp(16),
                  fontWeight: FontWeight.w400,
                ),
              )
            : null,
        hintText: hintText,
        hintStyle: TextStyle(
          color: AppColors.greylight60,
          fontSize: context.sp(14),
        ),
        filled: true,
        fillColor: AppColors.transparent,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.radius(12)),
          borderSide: BorderSide(color: AppColors.greylight60, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.radius(12)),
          borderSide: BorderSide(color: AppColors.greylight60, width: 1),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.radius(12)),
          borderSide: const BorderSide(color: AppColors.bluecolor, width: 1),
        ),
      ),
    );
  }
}
