import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';

class WebAuthSplitShell extends StatelessWidget {
  const WebAuthSplitShell({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
  });

  final Widget child;
  final String? title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FC),
      body: MainFrame(
        child: Center(
          child: Container(
            decoration: BoxDecoration(color: c.onPrimary),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Container(
                    decoration: BoxDecoration(color: c.primary),
                    padding: context.padSym(h: 28, v: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              AppAssets.mainLogo,
                              width: context.w(56),
                              height: context.w(69),
                              errorBuilder: (_, _, _) => Icon(
                                Icons.sports_soccer_rounded,
                                color: c.onPrimary,
                                size: context.w(24),
                              ),
                            ),
                            SizedBox(width: context.w(18)),
                            Expanded(
                              child: Text(
                                AppText.sportFinding,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.appText.text28W500.copyWith(
                                  color: c.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Center(
                          child: SvgPicture.asset(
                            AppAssets.firstImage,
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(height: context.h(98)),
                        Center(
                          child: NormalText(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            titleText: title ?? 'Welcome to SportFinding',
                            titleStyle: context.appText.text28W700.copyWith(
                              color: c.onPrimary,
                            ),
                            subText:
                                subtitle ?? 'Your Ultimate Sports Gaming Hub',
                            subStyle: context.appText.text28W700.copyWith(
                              color: c.onPrimary,
                            ),
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(context.w(24)),
                      child: child,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WebAuthCenteredShell extends StatelessWidget {
  const WebAuthCenteredShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FC),
      body: MainFrame(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              padding: EdgeInsets.symmetric(
                horizontal: context.w(34),
                vertical: context.h(34),
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(context.radius(24)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x110E4A84),
                    blurRadius: 30,
                    offset: Offset(0, 16),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
