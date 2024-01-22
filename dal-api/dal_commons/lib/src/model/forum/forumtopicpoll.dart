import 'package:dal_commons/src/model/forum/forumtopicoptions.dart';

class ForumTopicPoll {
  final int? id;
  final String? question;
  final bool? close;
  final List<ForumTopicOptions>? options;

  ForumTopicPoll({this.id, this.question, this.close, this.options});

  factory ForumTopicPoll.fromJson(Map<String, dynamic>? json) {
    return json != null
        ? ForumTopicPoll(
            close: json["close"],
            id: json["id"],
            question: json["question"],
            options: List.from(json["options"] ?? [])
                .map((e) => ForumTopicOptions.fromJson(e))
                .toList(),
          )
        : ForumTopicPoll();
  }

  Map<String, dynamic> toJson() {
    return {
      "close": close,
      "id": id,
      "question": question,
      "options": options,
    };
  }
}
