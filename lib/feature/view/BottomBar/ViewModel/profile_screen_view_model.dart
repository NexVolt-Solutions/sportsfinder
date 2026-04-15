import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Network/profile_service.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/Data/model/follow_connection_user.dart';
import 'package:sport_finding/Data/model/my_sport.dart'; // Added VoidCallback import

class ProfileScreenViewModel extends ChangeNotifier {
  late final VoidCallback _listener;

  ProfileScreenViewModel() {
    // ✅ Store listener reference so we can remove it properly
    _listener = () => notifyListeners();
    // ✅ Forward ProfileService rebuilds into this ViewModel
    ProfileService().addListener(_listener);
    // ✅ Fetch — skips if already loaded by HomeScreen
    ProfileService().fetchMyProfile();
  }

  @override
  void dispose() {
    ProfileService().removeListener(_listener);
    super.dispose();
  }

  // ✅ All profile data comes from ProfileService singleton
  ProfileService get _ps => ProfileService();

  String get fullName => _ps.fullName;
  String get avatarUrl => _ps.avatarUrl;
  String get email => _ps.email;
  String get bio => _ps.bio;
  String get location => _ps.location;
  bool get isLoading => _ps.isLoading;
  bool get showBioOnProfile => true;

  // --- stats (hardcoded until stats API exists) ---
  int get followersCount => kDefaultFollowConnectionUsers.length;
  int get followingCount => kDefaultFollowConnectionUsers.length;
  int get matchesPlayedCount => 12;

  String get followersCountLabel => '$followersCount';
  String get followingCountLabel => '$followingCount';
  String get matchesPlayedLabel => '$matchesPlayedCount';

  // --- unchanged below ---
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
      'subtitle': AppText.readOurTermsOfPrivacyPolicy,
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

  void openFollowers(BuildContext context) =>
      Navigator.pushNamed(context, RoutesName.followersScreen);

  void openFollowing(BuildContext context) =>
      Navigator.pushNamed(context, RoutesName.followingScreen);

  void openNotifications(BuildContext context) =>
      Navigator.pushNamed(context, RoutesName.notificationsScreen);

  void onTapFun(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, RoutesName.publicProfileScreen);
        break;
      case 1:
        Navigator.pushNamed(context, RoutesName.privateProfileScreen);
        break;
      case 3:
        Navigator.pushNamed(context, RoutesName.termsOfServiceScreen);
        break;
      case 4:
        Navigator.pushNamed(context, RoutesName.privacyPolicyScreen);
        break;
      default:
        break;
    }
  }
}
