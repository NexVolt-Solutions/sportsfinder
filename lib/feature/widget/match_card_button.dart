import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';

class MatchCardButton extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;
  final VoidCallback? ontap;
  final bool isLoading;

  const MatchCardButton({
    super.key,
    required this.text,
    required this.color,
    required this.textColor,
    this.ontap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // Keep chip width stable when swapping label ↔ spinner ("Invited" is widest).
    final minLabelWidth = context.w(40);

    final button = Container(
      padding: context.padSym(h: kIsWeb ? 12 : 10, v: kIsWeb ? 6 : 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(context.radius(kIsWeb ? 10 : 12)),
        border: kIsWeb && color == context.appColors.surface
            ? Border.all(color: const Color(0xFFD7E7F7))
            : null,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: minLabelWidth),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: kIsWeb ? 18 : 16,
                  height: kIsWeb ? 18 : 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(context.appColors.primary),
                  ),  
                )
              : NormalText(
                  titleText: text,
                  titleStyle: context.appText.text12W600.copyWith(
                    height: 1.5,
                    color: textColor,
                  ),
                ),
        ),
      ),
    );
    return GestureDetector(
      onTap: isLoading ? null : ontap,
      child: kIsWeb ? button : Card(margin: EdgeInsets.zero, child: button),
    );
  }
}
