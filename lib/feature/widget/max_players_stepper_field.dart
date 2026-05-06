import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/match_form_limits.dart';
import 'package:sport_finding/core/Constants/app_form_field_layout.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';

  class MaxPlayersStepperField extends StatelessWidget {
  const MaxPlayersStepperField({
    super.key,
    required this.value,
    required this.onChanged,
    this.label = 'Max players',
  });

  final int value;
  final ValueChanged<int> onChanged;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final t = context.appText;
    final v = MatchFormLimits.clampMaxPlayers(value);
    final canDec = v > MatchFormLimits.maxPlayersMin;
    final canInc = v < MatchFormLimits.maxPlayersMax;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(bottom: context.h(8)),
            child: Text(
              label,
              style: t.text16W600.copyWith(color: c.onSurface),
            ),
          ),
        SizedBox(
          height:context.h(46),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: c.transparent,
              border: Border.all(color: c.greylight, width: 1),
              borderRadius: AppFormFieldLayout.borderRadius(context),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _sideButton(
                  context: context,
                  icon: Icons.remove_rounded,
                  isLeft: true,
                  enabled: canDec,
                  onTap: () => onChanged(v - 1),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '$v',
                      style: t.text18W600.copyWith(color: c.onSurface),
                    ),
                  ),
                ),
                _sideButton(
                  context: context,
                  icon: Icons.add_rounded,
                  isLeft: false,
                  enabled: canInc,
                  onTap: () => onChanged(v + 1),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _sideButton({
    required BuildContext context,
    required IconData icon,
    required bool isLeft,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    final c = context.appColors;
    final r = AppFormFieldLayout.controlRadius(context);
    return Material(
      color: c.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: isLeft
            ? BorderRadius.only(topLeft: Radius.circular(r), bottomLeft: Radius.circular(r))
            : BorderRadius.only(
                topRight: Radius.circular(r),
                bottomRight: Radius.circular(r),
              ),
        child: SizedBox(
          width: context.w(48),
          height: AppFormFieldLayout.controlHeight(context),
          child: Icon(
            icon,
            size: context.w(22),
            color: enabled ? c.primary : c.greylight,
          ),
        ),
      ),
    );
  }
}
