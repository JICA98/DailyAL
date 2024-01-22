import 'package:dal_commons/src/model/global/animenode.dart';

import 'forumuser.dart';

class ForumTopicsData extends BaseNode {
  final int? id;
  final String? title;
  final DateTime? createdAt;
  final ForumUser? createdBy;
  final int? numberOfPosts;
  final DateTime? lastPostCreatedAt;
  final ForumUser? lastPostCreatedBy;
  final bool ?isLocked;

  ForumTopicsData({
    this.numberOfPosts,
    this.lastPostCreatedAt,
    this.lastPostCreatedBy,
    this.isLocked,
    this.id,
    this.createdAt,
    this.createdBy,
    this.title,
  });

  factory ForumTopicsData.fromJson(Map<String, dynamic>? json) {
    return json != null
        ? (ForumTopicsData(
            id: json["id"],
            isLocked: json["is_locked"],
            lastPostCreatedAt:
                DateTime.tryParse(json["last_post_created_at"] ?? ""),
            lastPostCreatedBy: ForumUser.fromJson(json["last_post_created_by"]),
            numberOfPosts: json["number_of_posts"],
            createdAt: DateTime.tryParse(json["created_at"] ?? ""),
            createdBy: ForumUser.fromJson(json["created_by"]),
            title: json["title"],
          ))
        : ForumTopicsData();
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "created_at": createdAt.toString(),
      "created_by": createdBy,
      "number_of_posts": numberOfPosts,
      "last_post_created_at": lastPostCreatedAt.toString(),
      "last_post_created_by": lastPostCreatedBy,
      "is_locked": isLocked,
    };
  }
}
