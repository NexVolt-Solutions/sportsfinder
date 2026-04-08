class CreateMatchModel {
  String? title;
  String? description;
  String? sport;
  String? facilityAddress;
  String? scheduledAt;
  int? durationMinutes;
  int? maxPlayers;
  String? skillLevel;

  CreateMatchModel({
    this.title,
    this.description,
    this.sport,
    this.facilityAddress,
    this.scheduledAt,
    this.durationMinutes,
    this.maxPlayers,
    this.skillLevel,
  });

  CreateMatchModel.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    description = json['description'];
    sport = json['sport'];
    facilityAddress = json['facility_address'];
    scheduledAt = json['scheduled_at'];
    durationMinutes = json['duration_minutes'];
    maxPlayers = json['max_players'];
    skillLevel = json['skill_level'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['description'] = description;
    data['sport'] = sport;
    data['facility_address'] = facilityAddress;
    data['scheduled_at'] = scheduledAt;
    data['duration_minutes'] = durationMinutes;
    data['max_players'] = maxPlayers;
    data['skill_level'] = skillLevel;
    return data;
  }
}
