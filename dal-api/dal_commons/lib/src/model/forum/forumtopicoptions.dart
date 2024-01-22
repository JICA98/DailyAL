class ForumTopicOptions {
  final int? id;
  final String? text;
  final int? votes;

  ForumTopicOptions({this.id, this.text, this.votes});

  factory ForumTopicOptions.fromJson(Map<String, dynamic>? json) {
    return json != null
        ? ForumTopicOptions(
            votes: json["votes"], id: json["id"], text: json["text"])
        : ForumTopicOptions();
  }

  Map<String, dynamic> toJson() {
    return {"votes": votes, "id": id, "text": text};
  }
}
