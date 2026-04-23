import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/utils/match_duration_format.dart';

const int _kMaxHours = 12;

/// Scroll wheels: hours 0–12, minutes 0–59, seconds 0–59. Total is capped at 12h.
Future<void> showMatchDurationPickerSheet(
  BuildContext context, {
  required int initialTotalMinutes,
  required void Function(int hours, int minutes, int seconds) onConfirm,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => _MatchDurationPickerBody(
      initialTotalMinutes: initialTotalMinutes,
      onConfirm: onConfirm,
    ),
  );
}

class _MatchDurationPickerBody extends StatefulWidget {
  const _MatchDurationPickerBody({
    required this.initialTotalMinutes,
    required this.onConfirm,
  });

  final int initialTotalMinutes;
  final void Function(int hours, int minutes, int seconds) onConfirm;

  @override
  State<_MatchDurationPickerBody> createState() =>
      _MatchDurationPickerBodyState();
}

class _MatchDurationPickerBodyState extends State<_MatchDurationPickerBody> {
  late FixedExtentScrollController _hCtrl;
  late FixedExtentScrollController _mCtrl;
  late FixedExtentScrollController _sCtrl;

  late int _h;
  late int _m;
  late int _s;

  @override
  void initState() {
    super.initState();
    final parts = matchDurationHmsFromApiMinutes(widget.initialTotalMinutes);
    _h = parts.h.clamp(0, _kMaxHours);
    _m = parts.m.clamp(0, 59);
    _s = parts.s.clamp(0, 59);
    _hCtrl = FixedExtentScrollController(initialItem: _h);
    _mCtrl = FixedExtentScrollController(initialItem: _m);
    _sCtrl = FixedExtentScrollController(initialItem: _s);
  }

  @override
  void dispose() {
    _hCtrl.dispose();
    _mCtrl.dispose();
    _sCtrl.dispose();
    super.dispose();
  }

  double get _itemExtent => context.h(34);

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final t = context.appText;
    final bottomPad = MediaQuery.paddingOf(context).bottom;
    final screenW = MediaQuery.sizeOf(context).width;
    final cardW = math.min(320.0, screenW - context.w(40));

    return Container(
      decoration: BoxDecoration(
        color: c.onPrimary,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.radiusR(16)),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        context.w(12),
        context.h(12),
        context.w(12),
        bottomPad + context.h(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Match duration',
            style: t.text16W600.copyWith(color: c.onSurface),
          ),
          SizedBox(height: context.h(4)),
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: cardW),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(context.radiusR(14)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        top: context.h(8),
                        left: context.w(8),
                        right: context.w(8),
                      ),
                      child: Row(
                        children: [
                          _headerCell('Hours', t, c),
                          _headerCell('Min', t, c),
                          _headerCell('Sec', t, c),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: context.h(150),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: CupertinoPicker(
                              backgroundColor: Colors.transparent,
                              scrollController: _hCtrl,
                              itemExtent: _itemExtent,
                              onSelectedItemChanged: (i) =>
                                  setState(() => _h = i),
                              children: List.generate(
                                _kMaxHours + 1,
                                (i) => Center(
                                  child: Text(
                                    '$i',
                                    style: t.text16W600.copyWith(
                                      color: c.onSurface,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: CupertinoPicker(
                              backgroundColor: Colors.transparent,
                              scrollController: _mCtrl,
                              itemExtent: _itemExtent,
                              onSelectedItemChanged: (i) =>
                                  setState(() => _m = i),
                              children: List.generate(
                                60,
                                (i) => Center(
                                  child: Text(
                                    i.toString().padLeft(2, '0'),
                                    style: t.text16W600.copyWith(
                                      color: c.onSurface,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: CupertinoPicker(
                              backgroundColor: Colors.transparent,
                              scrollController: _sCtrl,
                              itemExtent: _itemExtent,
                              onSelectedItemChanged: (i) =>
                                  setState(() => _s = i),
                              children: List.generate(
                                60,
                                (i) => Center(
                                  child: Text(
                                    i.toString().padLeft(2, '0'),
                                    style: t.text16W600.copyWith(
                                      color: c.onSurface,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.symmetric(vertical: context.h(8)),
            minimumSize: Size.zero,
            child: Text(AppText.done, style: t.text16W600),
            onPressed: () {
              widget.onConfirm(_h, _m, _s);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  static Widget _headerCell(
    String text,
    AppTextTheme t,
    AppColorTheme c,
  ) {
    return Expanded(
      child: Center(
        child: Text(
          text,
          style: t.text12W600.copyWith(
            color: c.greyDark,
            letterSpacing: 0.25,
          ),
        ),
      ),
    );
  }
}
