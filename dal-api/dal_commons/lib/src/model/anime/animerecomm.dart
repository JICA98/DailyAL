import 'package:dal_commons/src/model/global/node.dart';

import 'package:json_annotation/json_annotation.dart';

part 'animerecomm.g.dart';

@JsonSerializable()
class AnimeRecommendation {
  factory AnimeRecommendation.fromJson(Map<String, dynamic> json) =>
      _$AnimeRecommendationFromJson(json);
  Map<String, dynamic> toJson() => _$AnimeRecommendationToJson(this);

  final Node? firstAnime;
  final Node? secondAnime;
  final String? desc;
  final String? username;
  final String? postedDate;

  AnimeRecommendation(
      {this.firstAnime,
      this.secondAnime,
      this.desc,
      this.username,
      this.postedDate});
}
