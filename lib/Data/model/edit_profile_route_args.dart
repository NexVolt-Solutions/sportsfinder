/// Arguments for [RoutesName.editProfileRoute].
class EditProfileRouteArgs {
  const EditProfileRouteArgs({
    this.initialName,
    this.initialBio,
    this.initialAvatarUrl,
    this.initialSport,
    this.initialSkill,
  });

  final String? initialName;
  final String? initialBio;
  final String? initialAvatarUrl;
  final String? initialSport;
  final String? initialSkill;
}
