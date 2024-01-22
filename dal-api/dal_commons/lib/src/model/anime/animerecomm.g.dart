// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'animerecomm.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnimeRecommendation _$AnimeRecommendationFromJson(Map<String, dynamic> json) =>
    AnimeRecommendation(
      firstAnime: json['firstAnime'] == null
          ? null
          : Node.fromJson(json['firstAnime'] as Map<String, dynamic>?),
      secondAnime: json['secondAnime'] == null
          ? null
          : Node.fromJson(json['secondAnime'] as Map<String, dynamic>?),
      desc: json['desc'] as String?,
      username: json['username'] as String?,
      postedDate: json['postedDate'] as String?,
    );

Map<String, dynamic> _$AnimeRecommendationToJson(
        AnimeRecommendation instance) =>
    <String, dynamic>{
      'firstAnime': instance.firstAnime,
      'secondAnime': instance.secondAnime,
      'desc': instance.desc,
      'username': instance.username,
      'postedDate': instance.postedDate,
    };
