import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';

class CustomBottomSheetWidget extends StatelessWidget {
  final Widget child;
  final bool isCenter; // 🔥 control mode

  const CustomBottomSheetWidget({
    super.key,
    required this.child,
    this.isCenter = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: context.padAll(20),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(isCenter ? 20 : 0).copyWith(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// 🔘 Drag Handle (only for bottom sheet)
          if (!isCenter)
            Container(
              height: 4,
              width: 40,
              margin: EdgeInsets.only(bottom: context.h(16)),
              decoration: BoxDecoration(
                color: context.appColors.greylight,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

          child,
        ],
      ),
    );

    /// 🔽 Bottom Sheet Layout
    if (!isCenter) {
      return content;
    }

    /// 🟡 Center Dialog Layout
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: content,
        ),
      ),
    );
  }
}
