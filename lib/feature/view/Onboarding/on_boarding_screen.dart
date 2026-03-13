// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:sport_finding/core/Constants/app_assets.dart';
// import 'package:sport_finding/core/Constants/app_colors.dart';
// import 'package:sport_finding/core/Constants/app_text.dart';
// import 'package:sport_finding/core/Constants/size_extension.dart';
// import 'package:sport_finding/feature/widget/custom_button.dart';
// import 'package:sport_finding/feature/widget/normal_text.dart';
// import 'package:sport_finding/feature/widget/splash_background.dart';

// class OnBoardingScreen extends StatefulWidget {
//   const OnBoardingScreen({super.key});

//   @override
//   State<OnBoardingScreen> createState() => _OnBoardingScreenState();
// }

// class _OnBoardingScreenState extends State<OnBoardingScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.whitecolor,
//       bottomNavigationBar: Padding(
//         padding: EdgeInsetsGeometry.only(
//           top: context.h(3),
//           left: context.w(20),
//           right: context.w(20),
//           bottom: context.text(10),
//         ),
//         child: CustomButton(
//           isEnabled: true,
//           text: AppText.next,
//           color: AppColors.bluecolor,
//         ),
//       ),
//       body: SafeArea(
//         child: SplashBackground(
//           child: Padding(
//             padding: context.padSym(h: 20, v: 20),
//             child: Column(
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     SvgPicture.asset(AppAssets.backIcon, fit: BoxFit.contain),
//                     NormalText(
//                       titleText: 'Skip',
//                       titleSize: context.text(16),
//                       titleColor: AppColors.greydark,
//                       titleWeight: FontWeight.w500,
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: context.h(180)),
//                 Image.asset(AppAssets.firstImage),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_colors.dart';
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
  final OnboardingScreenViewModel model = OnboardingScreenViewModel();
  @override
  void initState() {
    super.initState();

    model.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whitecolor,
      bottomNavigationBar: Padding(
        padding: EdgeInsetsGeometry.only(
          top: context.h(3),
          left: context.w(20),
          right: context.w(20),
          bottom: context.text(10),
        ),
        child: CustomButton(
          isEnabled: true,
          text: model.isLastPage ? AppText.next : AppText.next,
          color: AppColors.bluecolor,
          onTap: () => model.onNextTapped(context),
        ),
      ),
      body: SafeArea(
        child: SplashBackground(
          child: Padding(
            padding: context.padSym(h: 20, v: 20),
            child: Column(
              children: [
                // Header Row
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
                    GestureDetector(
                      onTap: () => model.onSkipTapped(context),
                      child: NormalText(
                        titleText: AppText.skip,
                        titleSize: context.text(16),
                        titleColor: AppColors.greydark,
                        titleWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                // PageView
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(data['Image'], fit: BoxFit.contain),
                          NormalText(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            titleText: data['title'],
                            titleSize: context.text(20),
                            titleColor: AppColors.blackcolor,
                            titleWeight: FontWeight.w600,
                            subText: data['subTitle'],
                            subAlign: TextAlign.center,
                            subColor: AppColors.greydark,
                            subSize: context.text(16),
                            subWeight: FontWeight.w400,
                            sizeBoxheight: context.h(1),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // // Dot Indicators
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: List.generate(
                //     model.onBoardingImages.length,
                //     (index) => AnimatedContainer(
                //       duration: const Duration(milliseconds: 300),
                //       margin: EdgeInsets.symmetric(horizontal: context.w(4)),
                //       width: model.currentIndex == index
                //           ? context.w(20)
                //           : context.w(8),
                //       height: context.h(8),
                //       decoration: BoxDecoration(
                //         color: model.currentIndex == index
                //             ? AppColors.bluecolor
                //             : AppColors.greydark.withOpacity(0.4),
                //         borderRadius: BorderRadius.circular(4),
                //       ),
                //     ),
                //   ),
                // ),
                // SizedBox(height: context.h(16)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
