// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:dal_commons/dal_commons.dart';

class DalRenderContent {
  dynamic api;
  AnimeDetailedHtml? html;
  FeaturedResult? news;
  FeaturedResult? featured;
  DateTime? lastUpdated;

  DalRenderContent({
    this.api,
    this.html,
    this.news,
    this.featured,
    this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'api': api?.toJson(),
      'html': html?.toJson(),
      'news': news?.toJson(),
      'featured': featured?.toJson(),
      'lastUpdated': (lastUpdated ?? DateTime.now()).toString()
    };
  }

  factory DalRenderContent.fromMap(Map<String, dynamic>? map, String category) {
    if (map == null) return DalRenderContent();
    return DalRenderContent(
      api: category.equals('anime')
          ? AnimeDetailed.fromJson(map['api'])
          : MangaDetailed.fromJson(map['api']),
      html: AnimeDetailedHtml.fromJson(map['html']),
      news: FeaturedResult.fromMap(map['news']),
      featured: FeaturedResult.fromMap(map['featured']),
      lastUpdated: DateTime.tryParse(map['lastUpdated']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory DalRenderContent.fromJson(String source, String category) =>
      DalRenderContent.fromMap(
        json.decode(source) as Map<String, dynamic>,
        category,
      );

  @override
  String toString() {
    return 'DalRenderContent(api: $api, html: $html, news: $news, featured: $featured)';
  }
}
