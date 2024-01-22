import 'package:dal_commons/src/model/forum/forumtopics.dart';
import 'package:dal_commons/src/model/forum/html/forumhtml.dart';
import 'package:dal_commons/src/model/global/paging.dart';

class ForumTopicsHtml extends ForumTopics {
  @override
  final List<ForumHtml>? data;
  @override
  Paging? paging;
  @override
  String? url;
  @override
  bool? fromCache;
  @override
  DateTime? lastUpdated;

  ForumTopicsHtml(
      {this.paging, this.data, this.fromCache, this.lastUpdated, this.url});

  factory ForumTopicsHtml.fromJson(Map<String, dynamic>? json) {
    return json == null
        ? ForumTopicsHtml()
        : ForumTopicsHtml(
            fromCache: true,
            data: List.from(json["forum_topics"] ?? [])
                .map((e) => ForumHtml.fromJson(e))
                .toList());
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "forum_topics": data,
      "from_cache": fromCache,
    };
  }
}
