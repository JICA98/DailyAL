import 'package:dal_commons/src/model/global/animenode.dart';
import 'package:dal_commons/src/model/global/node.dart';
import 'package:dal_commons/src/model/global/picture.dart';
import 'package:json_annotation/json_annotation.dart';

part 'featured.g.dart';

class FeaturedBaseNode extends BaseNode {
  final Featured? featured;
  FeaturedBaseNode([this.featured]) : super(content: featured);
  factory FeaturedBaseNode.fromJson(Map<String, dynamic>? json) {
    return json == null
        ? FeaturedBaseNode()
        : FeaturedBaseNode(Featured.fromJson(json["featured"]));
  }
  @override
  Map<String, dynamic> toJson() => {"featured": featured?.toJson()};
}

@JsonSerializable()
class Featured extends Node {
  factory Featured.fromJson(Map<String, dynamic> json) =>
      _$FeaturedFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$FeaturedToJson(this);

  final String? summary;
  final String? body;
  final List<FeaturedBaseNode> ?relatedArticles;
  final List<String>? tags;
  final Map<String, List<BaseNode>>? relatedDatabaseEntries;
  final Map<String, List<BaseNode>>? relatedNews;
  final String? postedBy;
  final String? postedDate;
  final String ?views;
  final int? topidId;

  Featured({
    this.postedBy,
    this.postedDate,
    this.views,
    this.body,
    this.relatedArticles,
    this.relatedDatabaseEntries,
    this.summary,
    this.tags,
    int? id,
    this.relatedNews,
    this.topidId,
    String? title,
    Picture? mainPicture,
  }) : super(id: id, mainPicture: mainPicture, title: title);
}
