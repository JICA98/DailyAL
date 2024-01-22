import 'package:dal_commons/src/model/forum/forumtopicsdata.dart';
import 'package:dal_commons/src/model/forum/forumuser.dart';
import 'package:dal_commons/src/constants/constant.dart';

class ForumHtml extends ForumTopicsData {
  @override
  final String? title;
  final int? topicId;
  final String? createdByName;
  final String? createdTime;
  final String? lastPostBy;
  final String? lastPostTime;
  final String? replies;

  ForumHtml(
      {this.topicId,
      this.createdByName,
      this.createdTime,
      this.lastPostBy,
      this.lastPostTime,
      this.title,
      this.replies})
      : super(
            id: topicId,
            createdAt: DateTime.tryParse(createdTime ?? ''),
            createdBy: ForumUser(name: createdByName ?? ''),
            isLocked: false,
            lastPostCreatedAt: DateTime.tryParse(lastPostTime ?? ''),
            lastPostCreatedBy: ForumUser(name: lastPostBy),
            numberOfPosts: int.tryParse(replies?.getOnlyDigits() ?? ''),
            title: title);

  factory ForumHtml.fromJson(Map<String, dynamic>? json) {
    return json != null
        ? (ForumHtml(
            title: json["title"],
            createdByName: json["created_by"],
            createdTime: json["created_time"],
            lastPostBy: json["last_post_by"],
            lastPostTime: json["last_post_time"],
            replies: json["replies"],
            topicId: json["topic_id"]))
        : ForumHtml();
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "replies": replies,
      "title": title,
      "created_by": createdByName,
      "created_time": createdTime,
      "last_post_by": lastPostBy,
      "last_post_time": lastPostTime,
      "topic_id": topicId
    };
  }
}
