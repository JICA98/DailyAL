import 'package:dal_commons/src/model/anime/animestatus.dart';

class AnimeStatistics {
  final AnimeStatus? status;
  final int? numListUsers;

  AnimeStatistics({this.numListUsers, this.status});

  factory AnimeStatistics.fromJson(Map<String, dynamic>? json) {
    return json != null
        ? AnimeStatistics(
            numListUsers: json["num_list_users"],
            status: AnimeStatus.fromJson(json["status"]))
        : AnimeStatistics();
  }

  Map<String, dynamic> toJson() {
    return {
      "status": status?.toJson(),
      "num_list_users": numListUsers,
    };
  }
}
