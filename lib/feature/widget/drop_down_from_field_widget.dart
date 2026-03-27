import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';

class DropdownFormFieldWidget extends StatelessWidget {
  final String label;
  final String hintText;
  final List<String> items;
  final String? value;
  final Function(String?) onChanged;

  const DropdownFormFieldWidget({
    super.key,
    required this.label,
    required this.hintText,
    required this.items,
    required this.onChanged,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.padSym(h: 20),
      child: Container(
        padding: context.padSym(h: 12, v: 4),
        decoration: BoxDecoration(
          color: context.appColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: context.appColors.greylight),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            hint: Text(
              hintText,
              style: TextStyle(color: context.appColors.greylight),
            ),
            isExpanded: true,
            items: items.map((item) {
              return DropdownMenuItem(value: item, child: Text(item));
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}
