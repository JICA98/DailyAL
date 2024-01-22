import 'package:dal_commons/src/model/forum/forumtopicpoll.dart';
import 'package:dal_commons/src/model/forum/forumtopicpost.dart';
import 'package:dal_commons/src/model/global/paging.dart';

class ForumTopicData {
  final List<ForumTopicPost>? posts;
  final String? title;
  final Paging? paging;
  final ForumTopicPoll? poll;
  String? url;
  bool? fromCache;
  DateTime? lastUpdated;

  ForumTopicData({
    this.posts,
    this.paging,
    this.poll,
    this.title,
    this.fromCache,
    this.lastUpdated,
    this.url,
  });

  factory ForumTopicData.fromJson(Map<String, dynamic>? json) {
    var data = (json ?? {})["data"] ?? {};
    return json != null
        ? (ForumTopicData(
            url: json["url"],
            fromCache: json["fromCache"] ?? false,
            title: data["title"],
            poll: ForumTopicPoll.fromJson(data["poll"]),
            lastUpdated:
                DateTime.tryParse(json["lastUpdated"]?.toString() ?? "") ??
                    DateTime.now(),
            paging: Paging.fromJson(json["paging"]),
            posts: List.from(data["posts"] ?? [])
                .map((e) => ForumTopicPost.fromJson(e))
                .toList()))
        : ForumTopicData();
  }

  Map<String, dynamic> toJson() {
    return {
      "posts": posts,
      "paging": paging,
      "url": url,
      "fromCache": fromCache ?? false,
      "lastUpdated": lastUpdated.toString(),
    };
  }
}
