class OptionsModel {
  final List<String> skills;
  final List<String> sports;
  final List<SportOptionModel> sportOptions;

  OptionsModel({required this.skills, required this.sportOptions})
    : sports = sportOptions.map((sport) => sport.name).toList();

  OptionsModel.empty()
    : skills = const [],
      sports = const [],
      sportOptions = const [];

  OptionsModel copyWith({
    List<String>? skills,
    List<SportOptionModel>? sportOptions,
  }) {
    return OptionsModel(
      skills: skills ?? this.skills,
      sportOptions: sportOptions ?? this.sportOptions,
    );
  }

  factory OptionsModel.fromJson(Map<String, dynamic> json) {
    final rawSportOptions = json['sports'];
    final sportOptions = rawSportOptions is List
        ? rawSportOptions
              .whereType<Map>()
              .map(
                (item) =>
                    SportOptionModel.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList()
        : <SportOptionModel>[];

    return OptionsModel(
      skills: List<String>.from(json['skills'] ?? []),
      sportOptions: sportOptions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'skills': skills,
      'sports': sportOptions.map((sport) => sport.toJson()).toList(),
    };
  }
}

class SportOptionModel {
  const SportOptionModel({
    required this.id,
    required this.name,
    required this.category,
    required this.isActive,
    required this.isPopular,
    required this.sortOrder,
    required this.iconKey,
    required this.allowsCustomName,
  });

  final String id;
  final String name;
  final String category;
  final bool isActive;
  final bool isPopular;
  final int sortOrder;
  final String iconKey;
  final bool allowsCustomName;

  factory SportOptionModel.fromJson(Map<String, dynamic> json) {
    return SportOptionModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      isActive: json['is_active'] == true,
      isPopular: json['is_popular'] == true,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      iconKey: json['icon_key']?.toString() ?? '',
      allowsCustomName: json['allows_custom_name'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'is_active': isActive,
      'is_popular': isPopular,
      'sort_order': sortOrder,
      'icon_key': iconKey,
      'allows_custom_name': allowsCustomName,
    };
  }
}
