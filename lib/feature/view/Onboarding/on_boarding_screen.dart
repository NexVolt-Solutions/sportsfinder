import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/view_model/onboarding_screen_view_model.dart';
import 'package:sport_finding/feature/widget/custom_button.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingScreenViewModel>(
      builder: (context, model, child) => Scaffold(
        body: MainFrame(
          child: Padding(
            padding: context.padSym(h: 20, v: 20),
            child: Column(
              children: [
                RepaintBoundary(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: model.isFirstPage
                            ? const SizedBox.shrink()
                            : Semantics(
                                label: 'Go back',
                                button: true,
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: model.onBackTapped,
                                    borderRadius: BorderRadius.circular(24),
                                    child: Center(
                                      child: SvgPicture.asset(
                                        AppAssets.backIcon,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                      ),
                      SizedBox(
                        width: 56,
                        height: 48,
                        child: model.isFirstPage || model.isLastPage
                            ? const SizedBox.shrink()
                            : Semantics(
                                label: AppText.skip,
                                button: true,
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => model.onSkipTapped(context),
                                    borderRadius: BorderRadius.circular(8),
                                    child: Center(
                                      child: NormalText(
                                        titleText: AppText.skip,
                                        titleStyle: context.appText.text16W500,
                                        titleColor: context.appColors.greyDark,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: model.pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: model.onPageChanged,
                    itemCount: model.onBoardingImages.length,
                    itemBuilder: (context, index) {
                      final data = model.onBoardingImages[index];
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(data.image),
                          NormalText(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            titleText: data.title,
                            titleStyle: context.appText.text18W600,
                            titleColor: context.appColors.onSurface,
                            subText: data.subTitle,
                            subStyle: context.appText.text16W400,
                            subAlign: TextAlign.center,
                            subColor: context.appColors.greyDark,
                            sizeBoxheight: context.h(1),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                SizedBox(height: context.h(20)),
                CustomButton(
                  text: model.isLastPage ? AppText.getStarted : AppText.next,
                  color: context.appColors.primary,
                  onTap: () => model.onNextTapped(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
