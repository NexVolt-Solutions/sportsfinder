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
import 'package:sport_finding/feature/widget/splash_background.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  @override
  void dispose() {
    context.read<OnboardingScreenViewModel>().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingScreenViewModel>(
      builder: (context, model, child) => Scaffold(
        backgroundColor: context.appColors.surface,
        bottomNavigationBar: Padding(
          padding: EdgeInsetsGeometry.only(
            top: context.h(3),
            left: context.w(20),
            right: context.w(20),
            bottom: context.text(20),
          ),
          child: CustomButton(
            text: model.isLastPage ? AppText.next : AppText.next,
            color: context.appColors.primary,
            onTap: () => model.onNextTapped(context),
          ),
        ),
        body: SafeArea(
          child: SplashBackground(
            child: Padding(
              padding: context.padSym(h: 20, v: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      model.isFirstPage
                          ? const SizedBox.shrink()
                          : GestureDetector(
                              onTap: model.onBackTapped,
                              child: SvgPicture.asset(
                                AppAssets.backIcon,
                                fit: BoxFit.contain,
                              ),
                            ),
                      model.isFirstPage || model.isLastPage
                          ? const SizedBox.shrink()
                          : GestureDetector(
                              onTap: () => model.onSkipTapped(context),
                              child: NormalText(
                                titleText: AppText.skip,
                                titleStyle: context.appText.text16W500,
                                titleColor: context.appColors.greyDark,
                              ),
                            ),
                    ],
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
                            SvgPicture.asset(data['Image']),
                            NormalText(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              titleText: data['title'],
                              titleStyle: context.appText.text18W600,
                              titleColor: context.appColors.onSurface,
                              subText: data['subTitle'],
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
