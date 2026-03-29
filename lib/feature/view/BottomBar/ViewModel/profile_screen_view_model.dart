import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/feature/model/my_sport.dart';
import 'package:sport_finding/feature/view/BottomBar/Components/Profile/profile_screen.dart';

class ProfileScreenViewModel extends ChangeNotifier {
  int selectedSportIndex = -1;
  List<Map<String, dynamic>> profileData = [
    {
      'leading': AppAssets.eyeIcon,
      'title': AppText.publicProfile,
      'subtitle': AppText.seeWhatYourProfileLooksLikeToOthers,
      'trailingType': 'arrow',
      'switchValue': false,
    },
    {
      'leading': AppAssets.eyeIcon,
      'title': AppText.privateProfile,
      'subtitle': AppText.seeWhatYourProfileLooksLikeToOthers,
      'trailingType': 'arrow',
      'switchValue': false,
    },
    {
      'leading': AppAssets.notificationIcon,
      'title': AppText.notification,
      'subtitle': AppText.pushNotificationEnabled,
      'trailingType': 'switch',
      'switchValue': true,
    },
    {
      'leading': AppAssets.termIcon,
      'title': AppText.termsOfService,
      'subtitle': AppText.readOurTermsOfServices,
      'trailingType': 'arrow',
      'switchValue': false,
    },
    {
      'leading': AppAssets.privacyIcon,
      'title': AppText.privacyPolicy,
      'subtitle': AppText.readOurTermsOfServices,
      'trailingType': 'arrow',
      'switchValue': false,
    },
  ];
  List<MySport> sportsList = [
    MySport(name: AppText.football, skill: AppText.beginner),
    MySport(name: AppText.basketball, skill: AppText.intermediate),
    MySport(name: AppText.tennis, skill: AppText.advanced),
    MySport(name: AppText.volleyball, skill: AppText.beginner),
  ];

  void toggleSwitch(int index, bool value) {
    profileData[index]['switchValue'] = value;
    notifyListeners();
  }

  void onTapFun(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
        break;

      case 3:
        // Privacy
        break;

      default:
        break;
    }
  }
}
