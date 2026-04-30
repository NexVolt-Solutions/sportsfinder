import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_form_field_layout.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';

class DropdownFormFieldWidget extends StatelessWidget {
  const DropdownFormFieldWidget({
    super.key,
    required this.label,
    required this.hintText,
    required this.items,
    required this.value,
    required this.onChanged,
    this.validator,
    this.includeHorizontalPadding = false,
  });

  final String label;
  final String hintText;
  final List<String> items;

  final String? value;
  final ValueChanged<String?>? onChanged;
  final String? Function(String?)? validator;

  final bool includeHorizontalPadding;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final effectiveValue = value != null && items.contains(value)
        ? value
        : null;

    final field = FormField<String>(
      key: ValueKey<String?>('$label-$effectiveValue'),
      initialValue: effectiveValue,
      validator: validator,
      builder: (state) {
        void handleChanged(String? v) {
          state.didChange(v);
          onChanged?.call(v);
        }

        return InputDecorator(
          decoration: InputDecoration(
            alignLabelWithHint: true,
            isDense: true,
            label: Text(
              label,
              style: context.appText.text16W400.copyWith(color: c.onSurface),
            ),
            hintText: hintText,
            hintStyle: context.appText.text14W400.copyWith(color: c.greylight),
            filled: true,
            fillColor: c.transparent,
            errorText: state.errorText,
            errorStyle: AppFormFieldLayout.errorStyle(context),
            errorMaxLines: 2,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.radius(12)),
              borderSide: BorderSide(color: c.greylight, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.radius(12)),
              borderSide: BorderSide(color: c.greylight, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.radius(12)),
              borderSide: BorderSide(color: c.primary, width: 1),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.radius(12)),
              borderSide: BorderSide(color: c.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.radius(12)),
              borderSide: BorderSide(color: c.error, width: 1),
            ),
            contentPadding: AppFormFieldLayout.contentPadding(context),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: state.value,
              hint: Text(
                hintText,
                style: context.appText.text14W400.copyWith(color: c.greylight),
              ),
              isExpanded: true,
              isDense: true,
              iconSize: context.w(22),
              padding: EdgeInsets.zero,
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: c.greyDark),
              style: context.appText.text14W400.copyWith(color: c.greyDark),
              dropdownColor: c.surface,
              items: items
                  .map(
                    (item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    ),
                  )
                  .toList(),
              onChanged: onChanged == null ? null : handleChanged,
            ),
          ),
        );
      },
    );

    if (includeHorizontalPadding) {
      return Padding(padding: context.padSym(h: 20), child: field);
    }
    return field;
  }
}
