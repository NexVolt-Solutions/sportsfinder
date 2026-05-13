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
          decoration: AppFormFieldLayout.standardOutlineInputDecoration(
            context,
            label: Text(
              label,
              style: context.appText.text16W400.copyWith(color: c.onSurface),
            ),
            hintText: hintText,
            constraints: AppFormFieldLayout.singleLineConstraints(context),
            isDense: true,
            errorText: state.errorText,
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
