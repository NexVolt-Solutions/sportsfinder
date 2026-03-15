import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/feature/model/onboarding.dart';

class OnboardingScreenViewModel extends ChangeNotifier {
  final PageController pageController = PageController();
  int currentIndex = 0;
  bool _isNavigating = false;

  List<OnboardingModel> onBoardingImages = [
    OnboardingModel(
      image: AppAssets.firstImage,
      title: AppText.onboardingTitle1,
      subTitle: AppText.onboardingDesc1,
    ),
    OnboardingModel(
      image: AppAssets.secondImage,
      title: AppText.onboardingTitle2,
      subTitle: AppText.onboardingDesc2,
    ),
    OnboardingModel(
      image: AppAssets.thirdImage,
      title: AppText.onboardingTitle3,
      subTitle: AppText.onboardingDesc3,
    ),
  ];

  bool get isLastPage => currentIndex == onBoardingImages.length - 1;
  bool get isFirstPage => currentIndex == 0;

  void onPageChanged(int index) {
    currentIndex = index;
    notifyListeners();
  }

  void onNextTapped(BuildContext context) {
    if (!isLastPage) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      onGetStarted(context);
    }
  }

  void onBackTapped() {
    if (!isFirstPage) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void onSkipTapped(BuildContext context) {
    onGetStarted(context);
  }

  void onGetStarted(BuildContext context) {
    if (_isNavigating) return;
    _isNavigating = true;
    Navigator.pushReplacementNamed(context, RoutesName.LoginScreen)
        .whenComplete(() => _isNavigating = false);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
