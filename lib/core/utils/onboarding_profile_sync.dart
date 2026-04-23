import 'package:sport_finding/Data/Repositories/UpdateProfileRepo/update_profile_repo.dart';
import 'package:sport_finding/core/Network/profile_service.dart';
import 'package:sport_finding/core/Storage/app_preferences.dart';
import 'package:sport_finding/core/utils/logger.dart';

/// Pushes sport, skill, and (when available) location from the onboarding flow
/// to [PUT /api/v1/users/me] so [GET /users/me] and profile UI stay in sync.
Future<void> syncPendingOnboardingToServer() async {
  final sport = await AppPreferences.getPendingOnboardingSport();
  final skill = await AppPreferences.getPendingOnboardingSkill();
  if (sport == null || sport.isEmpty || skill == null || skill.isEmpty) {
    return;
  }

  final name = await AppPreferences.getCurrentLocationName();
  final locationLine = (name != null && name.trim().isNotEmpty)
      ? name.trim()
      : await AppPreferences.getCurrentLocationText();

  try {
    if (ProfileService().profile == null) {
      await ProfileService().fetchMyProfile(forceRefresh: true);
    }
  } catch (e) {
    AppLogger.warning('Could not pre-fetch profile before onboarding sync: $e',
        tag: 'OnboardingProfileSync');
  }

  final p = ProfileService().profile;
  final fullName = p?.fullName.trim() ?? '';
  final bio = p?.bio?.trim() ?? '';

  final repo = UpdateProfileRepo();
  try {
    final result = await repo.updateMyProfile(
      fullName: fullName.isNotEmpty ? fullName : 'User',
      bio: bio,
      sportUi: sport,
      skillUi: skill,
      location: locationLine,
    );
    ProfileService().applySuccessfulProfileUpdate(result);
    try {
      await ProfileService().fetchMyProfile(forceRefresh: true);
    } catch (e) {
      AppLogger.warning('GET /users/me after onboarding sync: $e',
          tag: 'OnboardingProfileSync');
    }
  } catch (e, st) {
    AppLogger.error(
      'Onboarding profile sync failed.',
      tag: 'OnboardingProfileSync',
      error: e,
      stackTrace: st,
    );
  } finally {
    await AppPreferences.clearPendingOnboardingSportSkill();
  }
}
