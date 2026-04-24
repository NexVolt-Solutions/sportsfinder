import 'package:sport_finding/Data/model/my_profile_model.dart';
import 'package:sport_finding/core/Network/profile_service.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/core/Storage/app_preferences.dart';

class AuthRouteResolver {
  AuthRouteResolver._();

  static const String homeTag = 'HOME';
  static const String skillLevelTag = 'SKILL_LEVEL';

  static Future<String> resolvePostAuthTag() async {
    final routeName = await resolvePostAuthRouteName();
    return routeName == RoutesName.bottomBarScreen ? homeTag : skillLevelTag;
  }

  static Future<String> resolvePostAuthRouteName() async {
    try {
      await ProfileService().fetchMyProfile(forceRefresh: true);
      final isComplete = await isCurrentUserProfileComplete();
      await AppPreferences.setOnboardingCompleted(isComplete);
      return isComplete
          ? RoutesName.bottomBarScreen
          : RoutesName.skillLevelScreen;
    } catch (_) {
      final isOnboardingCompleted =
          await AppPreferences.isOnboardingCompleted();
      return isOnboardingCompleted
          ? RoutesName.bottomBarScreen
          : RoutesName.skillLevelScreen;
    }
  }

  static Future<bool> isCurrentUserProfileComplete() async {
    final profile = ProfileService().profile;
    if (profile == null) return false;
    return _hasCompletedSports(profile) && await _hasCompletedLocation(profile);
  }

  static bool _hasCompletedSports(UserProfileModel profile) {
    for (final item in profile.sports) {
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);
      final sport = '${map['sport'] ?? map['name'] ?? ''}'.trim();
      final skill = '${map['skill_level'] ?? map['skillLevel'] ?? ''}'.trim();
      if (sport.isNotEmpty && skill.isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  static Future<bool> _hasCompletedLocation(UserProfileModel profile) async {
    final apiLocation = profile.location?.trim() ?? '';
    if (apiLocation.isNotEmpty) return true;
    final savedLocation = await AppPreferences.getCurrentLocationText();
    return savedLocation != null && savedLocation.trim().isNotEmpty;
  }
}
