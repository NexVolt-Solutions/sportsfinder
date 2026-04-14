class ListOfAllMatchesModel {
  List<Items>? items;
  int? total;
  int? page;
  int? limit;
  bool? hasNext;
  bool? hasPrev;

  ListOfAllMatchesModel({
    this.items,
    this.total,
    this.page,
    this.limit,
    this.hasNext,
    this.hasPrev,
  });

  ListOfAllMatchesModel.fromJson(Map<String, dynamic> json) {
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items!.add(new Items.fromJson(v));
      });
    }
    total = json['total'];
    page = json['page'];
    limit = json['limit'];
    hasNext = json['has_next'];
    hasPrev = json['has_prev'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.items != null) {
      data['items'] = this.items!.map((v) => v.toJson()).toList();
    }
    data['total'] = this.total;
    data['page'] = this.page;
    data['limit'] = this.limit;
    data['has_next'] = this.hasNext;
    data['has_prev'] = this.hasPrev;
    return data;
  }
}

class Items {
  String? id;
  String? title;
  String? sport;
  String? skillLevel;
  String? status;
  String? scheduledAt;
  int? durationMinutes;
  String? scheduledDate;
  String? scheduledTime;
  String? locationName;
  String? location;
  String? facilityAddress;
  int? latitude;
  int? longitude;
  int? maxPlayers;
  int? currentPlayers;
  int? distanceKm;
  Host? host;

  Items({
    this.id,
    this.title,
    this.sport,
    this.skillLevel,
    this.status,
    this.scheduledAt,
    this.durationMinutes,
    this.scheduledDate,
    this.scheduledTime,
    this.locationName,
    this.location,
    this.facilityAddress,
    this.latitude,
    this.longitude,
    this.maxPlayers,
    this.currentPlayers,
    this.distanceKm,
    this.host,
  });

  Items.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    sport = json['sport'];
    skillLevel = json['skill_level'];
    status = json['status'];
    scheduledAt = json['scheduled_at'];
    durationMinutes = json['duration_minutes'];
    scheduledDate = json['scheduled_date'];
    scheduledTime = json['scheduled_time'];
    locationName = json['location_name'];
    location = json['location'];
    facilityAddress = json['facility_address'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    maxPlayers = json['max_players'];
    currentPlayers = json['current_players'];
    distanceKm = json['distance_km'];
    host = json['host'] != null ? new Host.fromJson(json['host']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['sport'] = this.sport;
    data['skill_level'] = this.skillLevel;
    data['status'] = this.status;
    data['scheduled_at'] = this.scheduledAt;
    data['duration_minutes'] = this.durationMinutes;
    data['scheduled_date'] = this.scheduledDate;
    data['scheduled_time'] = this.scheduledTime;
    data['location_name'] = this.locationName;
    data['location'] = this.location;
    data['facility_address'] = this.facilityAddress;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['max_players'] = this.maxPlayers;
    data['current_players'] = this.currentPlayers;
    data['distance_km'] = this.distanceKm;
    if (this.host != null) {
      data['host'] = this.host!.toJson();
    }
    return data;
  }
}

class Host {
  String? id;
  String? fullName;
  String? avatarUrl;
  int? avgRating;

  Host({this.id, this.fullName, this.avatarUrl, this.avgRating});

  Host.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fullName = json['full_name'];
    avatarUrl = json['avatar_url'];
    avgRating = json['avg_rating'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['full_name'] = this.fullName;
    data['avatar_url'] = this.avatarUrl;
    data['avg_rating'] = this.avgRating;
    return data;
  }
}
