class UserProfileModel {
  final String id;
  final String fullName;
  final String email;
  final String? bio;
  final String? location;
  final String? avatarUrl;
  final bool isAdmin;
  final String status;
  final List<dynamic> sports;
  final int totalReviews;
  final List<dynamic> reviews;
  final Stats stats;
  final Actions actions;
  final Settings settings;
  final Navigation navigation;
  final Cta cta;
  final DateTime createdAt;

  UserProfileModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.bio,
    this.location,
    this.avatarUrl,
    required this.isAdmin,
    required this.status,
    required this.sports,
    required this.totalReviews,
    required this.reviews,
    required this.stats,
    required this.actions,
    required this.settings,
    required this.navigation,
    required this.cta,
    required this.createdAt,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      bio: json['bio'],
      location: json['location'],
      avatarUrl: json['avatar_url'],
      isAdmin: json['is_admin'] ?? false,
      status: json['status'] ?? '',
      sports: json['sports'] ?? [],
      totalReviews: json['total_reviews'] ?? 0,
      reviews: json['reviews'] ?? [],
      stats: Stats.fromJson(json['stats'] ?? {}),
      actions: Actions.fromJson(json['actions'] ?? {}),
      settings: Settings.fromJson(json['settings'] ?? {}),
      navigation: Navigation.fromJson(json['navigation'] ?? {}),
      cta: Cta.fromJson(json['cta'] ?? {}),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'bio': bio,
      'location': location,
      'avatar_url': avatarUrl,
      'is_admin': isAdmin,
      'status': status,
      'sports': sports,
      'total_reviews': totalReviews,
      'reviews': reviews,
      'stats': stats.toJson(),
      'actions': actions.toJson(),
      'settings': settings.toJson(),
      'navigation': navigation.toJson(),
      'cta': cta.toJson(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class Stats {
  final int followers;
  final int following;
  final int matches;
  final double? rating;

  Stats({
    required this.followers,
    required this.following,
    required this.matches,
    this.rating,
  });

  factory Stats.fromJson(Map<String, dynamic> json) {
    return Stats(
      followers: json['followers'] ?? 0,
      following: json['following'] ?? 0,
      matches: json['matches'] ?? 0,
      rating: (json['rating'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'followers': followers,
      'following': following,
      'matches': matches,
      'rating': rating,
    };
  }
}

class Actions {
  final bool canFollow;
  final bool canMessage;
  final bool canRate;
  final bool? isFollowing;
  final bool isOwnProfile;

  Actions({
    required this.canFollow,
    required this.canMessage,
    required this.canRate,
    this.isFollowing,
    required this.isOwnProfile,
  });

  factory Actions.fromJson(Map<String, dynamic> json) {
    return Actions(
      canFollow: json['can_follow'] ?? false,
      canMessage: json['can_message'] ?? false,
      canRate: json['can_rate'] ?? false,
      isFollowing: json['is_following'],
      isOwnProfile: json['is_own_profile'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'can_follow': canFollow,
      'can_message': canMessage,
      'can_rate': canRate,
      'is_following': isFollowing,
      'is_own_profile': isOwnProfile,
    };
  }
}

class Settings {
  final bool notificationsEnabled;

  Settings({required this.notificationsEnabled});

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      notificationsEnabled: json['notifications_enabled'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'notifications_enabled': notificationsEnabled};
  }
}

class Navigation {
  final bool publicProfileEnabled;
  final bool privateProfileEnabled;
  final String termsUrl;
  final String privacyUrl;

  Navigation({
    required this.publicProfileEnabled,
    required this.privateProfileEnabled,
    required this.termsUrl,
    required this.privacyUrl,
  });

  factory Navigation.fromJson(Map<String, dynamic> json) {
    return Navigation(
      publicProfileEnabled: json['public_profile_enabled'] ?? false,
      privateProfileEnabled: json['private_profile_enabled'] ?? false,
      termsUrl: json['terms_url'] ?? '',
      privacyUrl: json['privacy_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'public_profile_enabled': publicProfileEnabled,
      'private_profile_enabled': privateProfileEnabled,
      'terms_url': termsUrl,
      'privacy_url': privacyUrl,
    };
  }
}

class Cta {
  final bool editProfile;
  final bool shareProfile;

  Cta({required this.editProfile, required this.shareProfile});

  factory Cta.fromJson(Map<String, dynamic> json) {
    return Cta(
      editProfile: json['edit_profile'] ?? false,
      shareProfile: json['share_profile'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'edit_profile': editProfile, 'share_profile': shareProfile};
  }
}
