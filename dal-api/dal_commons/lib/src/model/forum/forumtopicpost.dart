import 'package:dal_commons/src/model/forum/forumuser.dart';

class ForumTopicPost {
  final int? id;
  final int? number;
  final DateTime? createdAt;
  final ForumUser? createdBy;
  final String? body;
  final String? signature;

  ForumTopicPost({
    this.body,
    this.signature,
    this.number,
    this.createdAt,
    this.createdBy,
    this.id,
  });

  factory ForumTopicPost.fromJson(Map<String, dynamic>? json) {
    return json != null
        ? ForumTopicPost(
            id: json["id"],
            createdAt: DateTime.tryParse(json["created_at"] ?? ""),
            createdBy: ForumUser.fromJson(json["created_by"]),
            number: json["number"],
            body: json["body"],
            signature: json["signature"],
          )
        : ForumTopicPost();
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "number": number,
      "created_at": createdAt,
      "created_by": createdBy
    };
  }

  @override
  String toString() {
    return """
    >> Post By: ${createdBy?.name} on ${createdAt?.toString()}
    Content: $body
    """;
  }
}
