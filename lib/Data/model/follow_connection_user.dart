/// Minimal user model for Followers / Following lists.
class FollowConnectionUser {
  const FollowConnectionUser({
    required this.id,
    required this.displayName,
    this.isFollowing = false,
  });

  final String id;
  final String displayName;
  final bool isFollowing;

  String get initial {
    final t = displayName.trim();
    if (t.isEmpty) return '?';
    return t[0].toUpperCase();
  }
}

/// Display names shared by profile counts and follow list screens (design reference).
const List<String> kFollowConnectionSeedNames = [
  'Alex John',
  'Maira Garcia',
  'James Wilson',
  'Sarah John',
  'David Gam',
];

/// Immutable seed list for mock / demo data.
final List<FollowConnectionUser> kDefaultFollowConnectionUsers =
    List<FollowConnectionUser>.generate(
      kFollowConnectionSeedNames.length,
      (i) => FollowConnectionUser(
        id: 'u$i',
        displayName: kFollowConnectionSeedNames[i],
        isFollowing: false,
      ),
    );
