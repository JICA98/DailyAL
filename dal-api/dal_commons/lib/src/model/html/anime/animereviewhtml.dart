import 'package:dal_commons/dal_commons.dart';
import 'package:dal_commons/src/model/global/node.dart' as dal_node;

final reactionBoxes = [
  "Nice",
  "Love it",
  "Funny",
  "Confusing",
  "Informative",
  "Well-written",
  "Creative"
];

class AnimeReviewHtml with ToJson {
  final String ?userName;
  final String ?timeAdded;
  final String ?userPicture;
  final String ?overallRating;
  final String ?reviewText;
  final List<String> ?tags;
  final List<String> ?reactionBox;
  bool ?fromCache;
  final dal_node.Node ?relatedNode;

  AnimeReviewHtml({
    this.userName,
    this.reactionBox,
    this.tags,
    this.timeAdded,
    this.userPicture,
    this.overallRating,
    this.reviewText,
    this.relatedNode,
    this.fromCache,
  });

  factory AnimeReviewHtml.fromJson(Map<String, dynamic>? json) {
    return json != null
        ? AnimeReviewHtml(
            userPicture: json["userPicture"],
            userName: json["userName"],
            timeAdded: json["timeAdded"],
            reactionBox: ((json['reactionBox'] ?? []) as List)
                .map((e) => e as String)
                .toList(),
            relatedNode: dal_node.Node.fromJson(json['relatedNode']),
            tags:
                ((json['tags'] ?? []) as List).map((e) => e as String).toList(),
            overallRating: json["overallRating"],
            reviewText: json["reviewText"],
            fromCache: json['fromCache'])
        : AnimeReviewHtml();
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "userPicture": userPicture,
      "userName": userName,
      "timeAdded": timeAdded,
      "overallRating": overallRating,
      "reviewText": reviewText,
      'reactionBox': reactionBox,
      'tags': tags,
      'relatedNode': relatedNode,
      'fromCache': fromCache
    };
  }
}
