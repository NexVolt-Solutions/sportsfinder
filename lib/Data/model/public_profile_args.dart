/// Route arguments for [PublicProfileScreen].
class PublicProfileArgs {
  const PublicProfileArgs({
    required this.userId,
    required this.displayName,
    this.forceRefreshProfile = false,
  });

  final String userId;
  final String displayName;

  /// When true and the screen shows **your** profile, [ProfileService] runs
  /// `GET /api/v1/users/me` again so Settings → preview matches the API.
  final bool forceRefreshProfile;

  /// Settings → Private profile: same user as `/users/me`, always refresh.
  factory PublicProfileArgs.privateProfilePreview() => const PublicProfileArgs(
        userId: '',
        displayName: '',
        forceRefreshProfile: true,
      );
}
