import 'package:dal_commons/src/model/forum/forumtopicsdata.dart';
import 'package:dal_commons/src/model/global/paging.dart';
import 'package:dal_commons/src/model/global/searchresult.dart';

class ForumTopics extends SearchResult {
  @override
  final List<ForumTopicsData>? data;
  @override
  final Paging? paging;
  @override
  String? url;
  @override
  bool? fromCache;
  @override
  DateTime? lastUpdated;

  ForumTopics({
    this.paging,
    this.data,
    this.fromCache,
    this.lastUpdated,
    this.url,
  });

  factory ForumTopics.fromJson(Map<String, dynamic> ?json) {
    var data = (json ?? {})["data"] ?? [];
    return json != null
        ? (ForumTopics(
            url: json["url"],
            fromCache: json["fromCache"] ?? false,
            data: List.from(data)
                .map((e) => ForumTopicsData.fromJson(e))
                .toList(),
            lastUpdated:
                DateTime.tryParse(json["lastUpdated"]?.toString() ?? "") ??
                    DateTime.now(),
            paging: Paging.fromJson(json["paging"]),
          ))
        : ForumTopics();
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "data": data,
      "paging": paging,
      "url": url,
      "fromCache": fromCache ?? false,
      "lastUpdated": lastUpdated.toString(),
    };
  }
}
