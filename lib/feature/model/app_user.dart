/// Signed-in user (replace with real auth/session later).
class AppUser {
  const AppUser({
    required this.id,
    required this.displayName,
  });

  final String id;
  final String displayName;

  /// Demo user until login/API provides a profile.
  static const AppUser current = AppUser(
    id: 'user_shehzad_khan',
    displayName: 'Shehzad Khan',
  );

  bool isSameUser(String? otherUserId) =>
      otherUserId != null && otherUserId == id;
}
