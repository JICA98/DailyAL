import 'package:dal_commons/dal_commons.dart';

class RelatedContent {
  final String? relationType;
  final String? relationTypeFormatted;
  final Node? relatedNode;

  RelatedContent(
      {this.relatedNode, this.relationType, this.relationTypeFormatted});

  factory RelatedContent.fromJson(Map<String, dynamic>? json,
      [String category = 'anime']) {
    Node? relatedNode;
    if (json != null) {
      if (json["node"] != null && json["node"]['mean'] != null) {
        if (category == 'anime') {
          relatedNode = AnimeDetailed.fromJson(json['node']);
        } else {
          relatedNode = MangaDetailed.fromJson(json['node']);
        }
      } else {
        relatedNode = Node.fromJson(json["node"]);
      }
    }
    return json != null
        ? RelatedContent(
            relationType: json["relation_type"],
            relationTypeFormatted: json["relation_type_formatted"],
            relatedNode: relatedNode,
          )
        : RelatedContent();
  }

  Map<String, dynamic> toJson() {
    return {
      "relation_type": relationType,
      "relation_type_formatted": relationTypeFormatted,
      "node": relatedNode?.toJson()
    };
  }
}
