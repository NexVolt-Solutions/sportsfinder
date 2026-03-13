import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_text.dart';

class OnboardingScreenViewModel extends ChangeNotifier {
  final PageController pageController = PageController();
  int currentIndex = 0;

  List<Map<String, dynamic>> onBoardingImages = [
    {
      'Image': AppAssets.firstImage,
      'title': AppText.findSportsNearYou,
      'subTitle': AppText.discoverPlayerAndSportsMatchesHeppeningInYourArea,
    },
    {
      'Image': AppAssets.secondImage,
      'title': AppText.connectWithPlayers,
      'subTitle': AppText.joinGanesOrInvitePlayersToMatches,
    },
    {
      'Image': AppAssets.thirdImage,
      'title': AppText.playAndImprove,
      'subTitle': AppText.complatedWithPlayesOfYourSkillLevelAndEnjoeySports,
    },
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
    // TODO: Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  void dispose() {
    pageController.dispose();
  }
}
