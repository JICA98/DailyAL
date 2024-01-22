class ForumUser {
  final int? id;
  final String? name;
  final String? forumAvatar;

  ForumUser({this.id, this.name, this.forumAvatar});

  factory ForumUser.fromJson(Map<String, dynamic> ?json) {
    return json != null
        ? ForumUser(
            forumAvatar: json["forum_avator"],
            id: json["id"],
            name: json["name"])
        : ForumUser();
  }

  Map<String, dynamic> toJson() {
    return {"form_avatar": forumAvatar, "id": id, "name": name};
  }
}
