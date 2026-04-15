class OptionsModel {
  final List<String> skills;
  final List<String> sports;

  OptionsModel({required this.skills, required this.sports});

  factory OptionsModel.fromJson(Map<String, dynamic> json) {
    return OptionsModel(
      skills: List<String>.from(json['skills'] ?? []),
      sports: List<String>.from(json['sports'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {'skills': skills, 'sports': sports};
  }
}
