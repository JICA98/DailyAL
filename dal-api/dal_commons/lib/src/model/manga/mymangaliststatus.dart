import 'package:dal_commons/src/model/global/myliststatus.dart';

class MyMangaListStatus implements MyListStatus {
  String? status;
  int? score;
  int? numVolumesRead;
  bool? isRereading;
  DateTime? updatedAt;
  int? numChaptersRead;
  int? numTimesReread;
  int? rereadValue;
  int? priority;
  DateTime? startDate;
  DateTime? finishDate;
  List<String>? tags;
  String? comments;

  MyMangaListStatus(
      {this.numChaptersRead,
      this.status,
      this.score,
      this.rereadValue,
      this.numVolumesRead,
      this.numTimesReread,
      this.isRereading,
      this.priority,
      this.updatedAt,
      this.comments,
      this.finishDate,
      this.startDate,
      this.tags});

  factory MyMangaListStatus.fromJson(Map<String, dynamic>? json) {
    return json != null
        ? MyMangaListStatus(
            comments: json["comments"],
            startDate: DateTime.tryParse(json['start_date'] ?? ''),
            finishDate: DateTime.tryParse(json['finish_date'] ?? ''),
            tags:
                List.from(json["tags"] ?? []).map((e) => e.toString()).toList(),
            priority: json["priority"],
            rereadValue: json["reread_value"],
            numTimesReread: json["num_times_reread"],
            status: json["status"],
            score: json["score"],
            isRereading: json["is_rereading"],
            numVolumesRead: json["num_volumes_read"],
            updatedAt: DateTime.tryParse(json["updated_at"].toString()),
            numChaptersRead: json["num_chapters_read"],
          )
        : MyMangaListStatus();
  }

  Map<String, dynamic> toJson() {
    return {
      "status": status,
      "score": score,
      "reread_value": rereadValue,
      "priority": priority,
      "num_times_reread": numTimesReread,
      "is_rereading": isRereading,
      "num_volumes_read": numVolumesRead,
      "num_chapters_read": numChaptersRead,
      "updated_at": updatedAt.toString(),
      "tags": tags,
      "finish_date": finishDate?.toString(),
      "start_date": startDate?.toString(),
      "comments": comments,
    };
  }
}
