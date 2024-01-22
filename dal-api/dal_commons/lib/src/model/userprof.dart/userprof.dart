import 'package:dal_commons/src/model/userprof.dart/animestatistics.dart';

class UserProf {
  final int? id;
  final String? name;
  final String? location;
  final String? gender;
  final DateTime? birthday;
  final String? timezone;
  final bool? isSupporter;
  final String? joinedAt;
  final String? picture;
  final UserAnimeStatistics? animeStatistics;
  bool? fromCache;

  UserProf(
      {this.gender,
      this.birthday,
      this.timezone,
      this.isSupporter,
      this.picture,
      this.id,
      this.name,
      this.location,
      this.joinedAt,
      this.animeStatistics,
      this.fromCache});

  factory UserProf.fromJson(Map<String, dynamic>? json) {
    return json != null
        ? UserProf(
            fromCache: json["fromCache"] ?? false,
            id: json["id"],
            animeStatistics:
                UserAnimeStatistics.fromJson(json["anime_statistics"]),
            joinedAt: json["joined_at"],
            location: json["location"],
            picture: json["picture"],
            birthday: DateTime.tryParse(json["birthday"] ?? ""),
            gender: json["gender"],
            name: json["name"],
            isSupporter: json["is_supporter"] ?? false,
            timezone: json["time_zone"])
        : UserProf();
  }

  Map<String, dynamic> toJson() {
    return {
      "fromCache": fromCache ?? false,
      "id": id,
      "name": name,
      "location": location,
      "joined_at": joinedAt,
      "picture": picture,
      "anime_statistics": animeStatistics?.toJson(),
      "gender": gender,
      "birthday": birthday.toString(),
      "is_supporter": isSupporter ?? false,
      "time_zone": timezone
    };
  }
}
