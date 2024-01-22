// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'featured.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Featured _$FeaturedFromJson(Map<String, dynamic> json) => Featured(
      postedBy: json['postedBy'] as String?,
      postedDate: json['postedDate'] as String?,
      views: json['views'] as String?,
      body: json['body'] as String?,
      relatedArticles: (json['relatedArticles'] as List<dynamic>?)
          ?.map((e) => FeaturedBaseNode.fromJson(e as Map<String, dynamic>?))
          .toList(),
      relatedDatabaseEntries:
          (json['relatedDatabaseEntries'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
            k,
            (e as List<dynamic>)
                .map((e) => BaseNode.fromJson(e as Map<String, dynamic>?))
                .toList()),
      ),
      summary: json['summary'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      id: json['id'] as int?,
      relatedNews: (json['relatedNews'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
            k,
            (e as List<dynamic>)
                .map((e) => BaseNode.fromJson(e as Map<String, dynamic>?))
                .toList()),
      ),
      topidId: json['topidId'] as int?,
      title: json['title'] as String?,
      mainPicture: json['mainPicture'] == null
          ? null
          : Picture.fromJson(json['mainPicture'] as Map<String, dynamic>?),
    )
      ..numEpisodes = json['numEpisodes'] as int?
      ..fromCache = json['fromCache'] as bool?
      ..url = json['url'] as String?;

Map<String, dynamic> _$FeaturedToJson(Featured instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'mainPicture': instance.mainPicture,
      'numEpisodes': instance.numEpisodes,
      'fromCache': instance.fromCache,
      'url': instance.url,
      'summary': instance.summary,
      'body': instance.body,
      'relatedArticles': instance.relatedArticles,
      'tags': instance.tags,
      'relatedDatabaseEntries': instance.relatedDatabaseEntries,
      'relatedNews': instance.relatedNews,
      'postedBy': instance.postedBy,
      'postedDate': instance.postedDate,
      'views': instance.views,
      'topidId': instance.topidId,
    };
