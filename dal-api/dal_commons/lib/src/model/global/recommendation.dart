import 'package:dal_commons/dal_commons.dart';

class Recommendation {
  final Node? recommNode;
  final int? numRecommendations;

  Recommendation({this.recommNode, this.numRecommendations});

  factory Recommendation.fromJson(Map<String, dynamic>? json) {
    Node? recommNode;
    if (json != null) {
      if (json["node"] != null && json["node"]['mean'] != null) {
        recommNode = AnimeDetailed.fromJson(json['node']);
      } else {
        recommNode = Node.fromJson(json["node"]);
      }
    }
    return json != null
        ? Recommendation(
            recommNode: recommNode,
            numRecommendations: json["num_recommendations"])
        : Recommendation();
  }

  Map<String, dynamic> toJson() {
    return {
      "node": recommNode?.toJson(),
      "num_recommendations": numRecommendations
    };
  }
}
