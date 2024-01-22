import 'package:dal_commons/src/model/global/myliststatus.dart';

class MyAnimeListStatus implements MyListStatus {
  String? status;
  int? score;
  int? numEpisodesWatched;
  bool? isRewatching;
  DateTime? updatedAt;
  DateTime? startDate;
  DateTime? finishDate;
  int? priority;
  int? numTimesRewatched;
  int? rewatchValue;
  List<String>? tags;
  String? comments;

  MyAnimeListStatus(
      {this.priority,
      this.numTimesRewatched,
      this.rewatchValue,
      this.tags,
      this.comments,
      this.status,
      this.score,
      this.finishDate,
      this.startDate,
      this.numEpisodesWatched,
      this.isRewatching,
      this.updatedAt});

  factory MyAnimeListStatus.fromJson(Map<String, dynamic>? json) {
    return json != null
        ? MyAnimeListStatus(
            status: json["status"],
            score: json["score"],
            isRewatching: json["is_rewatching"],
            numEpisodesWatched: json["num_episodes_watched"],
            updatedAt: DateTime.tryParse(json["updated_at"].toString()),
            comments: json["comments"],
            numTimesRewatched: json["num_times_rewatched"],
            priority: json["priority"],
            rewatchValue: json["rewatch_value"],
            startDate: DateTime.tryParse(json['start_date'] ?? ''),
            finishDate: DateTime.tryParse(json['finish_date'] ?? ''),
            tags:
                List.from(json["tags"] ?? []).map((e) => e.toString()).toList())
        : MyAnimeListStatus();
  }

  Map<String, dynamic> toJson() {
    return {
      "status": status,
      "score": score,
      "is_rewatching": isRewatching,
      "num_episodes_watched": numEpisodesWatched,
      "priority": priority,
      "num_times_rewatched": numTimesRewatched,
      "rewatch_value": rewatchValue,
      "tags": tags,
      "finish_date": finishDate?.toString(),
      "start_date": startDate?.toString(),
      "comments": comments,
      "updated_at": updatedAt.toString(),
    };
  }
}
