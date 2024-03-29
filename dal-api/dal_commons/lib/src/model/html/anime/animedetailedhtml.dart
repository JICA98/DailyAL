import 'package:dal_commons/src/model/featured/featured.dart';
import 'package:dal_commons/src/model/forum/html/forumtopicshtml.dart';
import 'package:dal_commons/src/model/html/anime/additional_title.dart';
import 'package:dal_commons/src/model/html/anime/animecharacterhtml.dart';
import 'package:dal_commons/src/model/html/anime/animelinks.dart';
import 'package:dal_commons/src/model/html/anime/animereviewhtml.dart';
import 'package:dal_commons/src/model/html/anime/intereststack.dart';
import 'package:dal_commons/src/model/html/anime/mangacharahtml.dart';

import '../../global/node.dart';

class AnimeDetailedHtml {
  final List<InterestStack>? interestStacks;
  final List<AnimeCharacterHtml>? characterHtmlList;
  final List<MangaCharacterHtml>? mangaCharaList;
  final List<AnimeReviewHtml>? animeReviewList;
  final ForumTopicsHtml? forumTopicsHtml;
  final String? videoUrl;
  final List<AnimeLink>? links;
  final List<AdditionalTitle>? additionalTitles;
  final Featured? news;
  final Featured? featured;
  final List<Node>? adaptedNodes;
  String? url;
  bool? fromCache;
  DateTime? lastUpdated;

  AnimeDetailedHtml({
    this.animeReviewList,
    this.url,
    this.characterHtmlList,
    this.fromCache,
    this.videoUrl,
    this.lastUpdated,
    this.forumTopicsHtml,
    this.featured,
    this.mangaCharaList,
    this.interestStacks,
    this.news,
    this.adaptedNodes,
    this.links,
    this.additionalTitles,
  });

  factory AnimeDetailedHtml.fromJson(Map<String, dynamic>? json) {
    return json != null
        ? AnimeDetailedHtml(
            url: json["url"],
            news: Featured.fromJson(json['news']),
            featured: Featured.fromJson(json['featured']),
            lastUpdated:
                DateTime.tryParse(json["lastUpdated"]?.toString() ?? "") ??
                    DateTime.now(),
            fromCache: true,
            links: ((json['links'] ?? []) as List)
                .map((e) => AnimeLink.fromJson(e))
                .where((e) => e != null)
                .map((e) => e!)
                .toList(),
            videoUrl: json["videoUrl"],
            additionalTitles: List.from(json["additionalTitles"] ?? [])
                .map((e) => AdditionalTitle.fromJson(e))
                .toList(),
            animeReviewList: List.from(json["animeReviewList"] ?? [])
                .map((e) => AnimeReviewHtml.fromJson(e))
                .toList(),
            forumTopicsHtml: ForumTopicsHtml.fromJson(json["forumTopicsHtml"]),
            characterHtmlList: List.from(json["characterHtml"] ?? [])
                .map((e) => AnimeCharacterHtml.fromJson(e))
                .toList(),
            mangaCharaList: List.from(json["mangaCharacterList"] ?? [])
                .map((e) => MangaCharacterHtml.fromJson(e))
                .toList(),
            interestStacks: List.from(json["interestStacks"] ?? [])
                .map((e) => InterestStack.fromJson(e))
                .toList(),
            adaptedNodes: List.from(json["adaptedNodes"] ?? [])
                .map((e) => Node.fromJson(e))
                .toList())
        : AnimeDetailedHtml();
  }

  Map<String, dynamic> toJson() {
    return {
      "url": url,
      "lastUpdated": lastUpdated.toString(),
      "fromCache": fromCache,
      "videoUrl": videoUrl,
      "characterHtml": characterHtmlList,
      "forumTopicsHtml": forumTopicsHtml,
      'animeReviewList': animeReviewList,
      'featured': featured,
      'news': news,
      'mangaCharacterList': mangaCharaList,
      'interestStacks': interestStacks,
      'adaptedNodes': adaptedNodes,
      'links': links,
      'additionalTitles': additionalTitles,
    };
  }
}
