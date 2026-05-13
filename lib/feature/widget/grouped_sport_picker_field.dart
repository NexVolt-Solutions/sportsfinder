import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:sport_finding/Data/model/Option/options_model.dart';
import 'package:sport_finding/core/Constants/app_form_field_layout.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';

String humanizeSportCategoryKey(String raw) {
  final t = raw.trim();
  if (t.isEmpty) return 'Sports';
  return t
      .split('_')
      .where((p) => p.isNotEmpty)
      .map((p) => '${p[0].toUpperCase()}${p.substring(1)}')
      .join(' ');
}

List<MapEntry<String, List<SportOptionModel>>> _groupSportOptions(
  List<SportOptionModel> input,
) {
  final active = input
      .where((s) => s.isActive && s.name.trim().isNotEmpty)
      .toList();
  final order = <String>[];
  final byCategory = <String, List<SportOptionModel>>{};
  for (final s in active) {
    final key = s.category.trim().isEmpty ? 'other' : s.category;
    byCategory.putIfAbsent(key, () => <SportOptionModel>[]);
    if (byCategory[key]!.isEmpty) order.add(key);
    byCategory[key]!.add(s);
  }
  for (final list in byCategory.values) {
    list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }
  return [for (final k in order) MapEntry(k, byCategory[k]!)];
}

Future<String?> _showGroupedSportPicker({
  required BuildContext context,
  required String title,
  required List<SportOptionModel> sportOptions,
  String? current,
}) async {
  final grouped = _groupSportOptions(sportOptions);
  if (grouped.isEmpty) return null;

  if (kIsWeb) {
    return showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: 400,
            height: 480,
            child: _GroupedSportOptionList(
              grouped: grouped,
              current: current,
              onPick: (name) => Navigator.of(ctx).pop(name),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) {
      final h = MediaQuery.sizeOf(ctx).height * 0.72;
      return SizedBox(
        height: h,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                ctx.w(20),
                ctx.h(16),
                ctx.w(12),
                ctx.h(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: ctx.appText.text18W600
                          .copyWith(color: ctx.appColors.onSurface),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _GroupedSportOptionList(
                grouped: grouped,
                current: current,
                onPick: (name) => Navigator.of(ctx).pop(name),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _GroupedSportOptionList extends StatelessWidget {
  const _GroupedSportOptionList({
    required this.grouped,
    required this.onPick,
    this.current,
  });

  final List<MapEntry<String, List<SportOptionModel>>> grouped;
  final String? current;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return ListView(
      padding: EdgeInsets.only(bottom: context.h(16)),
      children: [
        for (final e in grouped) ...[
          Padding(
            padding: EdgeInsets.fromLTRB(
              context.w(16),
              context.h(12),
              context.w(16),
              context.h(6),
            ),
            child: Text(
              humanizeSportCategoryKey(e.key),
              style: context.appText.text14W600.copyWith(color: c.primary),
            ),
          ),
          for (final s in e.value)
            ListTile(
              title: Text(
                s.name,
                style: context.appText.text16W400.copyWith(color: c.greyDark),
              ),
              selected: s.name == current,
              onTap: () => onPick(s.name),
            ),
        ],
      ],
    );
  }
}

/// Sport field styled like [DropdownFormFieldWidget], with options grouped by API category.
class GroupedSportPickerField extends StatelessWidget {
  const GroupedSportPickerField({
    super.key,
    required this.label,
    required this.hintText,
    required this.sportOptions,
    required this.optionsLoading,
    required this.value,
    required this.onChanged,
    this.validator,
    this.includeHorizontalPadding = false,
    this.pickerTitle,
  });

  final String label;
  final String hintText;
  final List<SportOptionModel> sportOptions;
  final bool optionsLoading;
  final String? value;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;
  final bool includeHorizontalPadding;
  final String? pickerTitle;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final names = sportOptions.map((e) => e.name).toSet();
    final effectiveValue =
        value != null && names.contains(value) ? value : null;

    final field = FormField<String>(
      key: ValueKey<String?>('$label-$effectiveValue'),
      initialValue: effectiveValue,
      validator: validator,
      builder: (state) {
        void handleChanged(String? v) {
          state.didChange(v);
          onChanged(v);
        }

        final display = state.value;
        final canOpen = !optionsLoading && sportOptions.isNotEmpty;

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
          child: InkWell(
            onTap: !canOpen
                ? null
                : () async {
                    final title = pickerTitle ?? label;
                    final picked = await _showGroupedSportPicker(
                      context: context,
                      title: title,
                      sportOptions: sportOptions,
                      current: state.value,
                    );
                    if (picked != null) handleChanged(picked);
                  },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: context.h(4)),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      display != null && display.isNotEmpty
                          ? display
                          : hintText,
                      style: context.appText.text14W400.copyWith(
                        color: display != null && display.isNotEmpty
                            ? c.greyDark
                            : c.greylight,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: c.greyDark,
                    size: context.w(22),
                  ),
                ],
              ),
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
