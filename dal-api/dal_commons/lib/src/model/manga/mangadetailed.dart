import 'package:dal_commons/src/model/global/alternatetitles.dart';
import 'package:dal_commons/src/model/global/node.dart';
import 'package:dal_commons/src/model/global/genre.dart';
import 'package:dal_commons/src/model/global/picture.dart';
import 'package:dal_commons/src/model/global/relatednode.dart';
import 'package:dal_commons/src/model/manga/mangaauthors.dart';
import 'package:dal_commons/src/model/manga/mymangaliststatus.dart';
import 'package:dal_commons/src/model/manga/serializationmanga.dart';

import '../global/recommendation.dart';

class MangaDetailed extends Node {
  final AlternateTitles? alternateTitles;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? synopsis;
  final double? mean;
  final int? rank;
  final int? popularity;
  final int? numListUsers;
  final int? numScoringUsers;
  final String? nsfw;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? mediaType;
  @override
  final String? status;
  final List<MalGenre>? genres;
  final int? numVolumes;
  final int? numChapters;
  final List<MangaAuthors>? authors;
  final List<Picture>? pictures;
  final String? background;
  final List<RelatedContent>? relatedAnime;
  final List<RelatedContent>? relatedManga;
  final List<Recommendation>? recommendations;
  @override
  MyMangaListStatus? myListStatus;
  final List<SerializationMangaNode>? serialization;

  DateTime? lastUpdated;

  MangaDetailed(
      {int? id,
      Picture? mainPicture,
      String? title,
      bool? fromCache,
      String? url,
      this.mediaType,
      this.authors,
      this.alternateTitles,
      this.background,
      this.lastUpdated,
      this.createdAt,
      this.endDate,
      this.genres,
      this.mean,
      this.myListStatus,
      this.nsfw,
      this.numVolumes,
      this.numListUsers,
      this.numScoringUsers,
      this.serialization,
      this.pictures,
      this.popularity,
      this.rank,
      this.recommendations,
      this.relatedAnime,
      this.relatedManga,
      this.startDate,
      this.status,
      this.synopsis,
      this.numChapters,
      this.updatedAt})
      : super(
            url: url,
            id: id,
            mainPicture: mainPicture,
            title: title,
            fromCache: fromCache);

  factory MangaDetailed.fromJson(Map<String, dynamic>? json) {
    return json != null
        ? MangaDetailed(
            url: json["url"],
            lastUpdated:
                DateTime.tryParse(json["lastUpdated"]?.toString() ?? "") ??
                    DateTime.now(),
            fromCache: json["fromCache"] ?? false,
            id: json["id"],
            title: json["title"],
            authors: List.from(json["authors"] ?? [])
                .map((e) => MangaAuthors.fromJson(e))
                .toList(),
            numChapters: json["num_chapters"],
            mainPicture: Picture.fromJson(json["main_picture"]),
            alternateTitles:
                AlternateTitles.fromJson(json["alternative_titles"]),
            startDate: DateTime.tryParse(json["start_date"].toString()),
            endDate: DateTime.tryParse(json["end_date"].toString()),
            synopsis: json["synopsis"],
            mean: double.tryParse(json["mean"].toString()),
            rank: json["rank"],
            popularity: json["popularity"],
            numListUsers: json["num_list_users"],
            numScoringUsers: json["num_scoring_users"],
            nsfw: json["nsfw"],
            createdAt: DateTime.tryParse(json["created_at"].toString()),
            updatedAt: DateTime.tryParse(json["updated_at"].toString()),
            mediaType: json["media_type"],
            status: json["status"],
            genres: List.from(json["genres"] ?? [])
                .map((e) => MalGenre.fromJson(e))
                .toList(),
            myListStatus: MyMangaListStatus.fromJson(json["my_list_status"]),
            numVolumes: json["num_volumes"],
            pictures: List.from(json["pictures"] ?? [])
                .map((e) => Picture.fromJson(e))
                .toList(),
            background: json["background"],
            relatedAnime: List.from(json["related_anime"] ?? [])
                .map((e) => RelatedContent.fromJson(e))
                .toList(),
            relatedManga: List.from(json["related_manga"] ?? [])
                .map((e) => RelatedContent.fromJson(e, 'manga'))
                .toList(),
            recommendations: List.from(json["recommendations"] ?? [])
                .map((e) => Recommendation.fromJson(e))
                .toList(),
            serialization: List.from(json["serialization"] ?? [])
                .map((e) => SerializationMangaNode.fromJson(e))
                .toList(),
          )
        : MangaDetailed();
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "url": url,
      "lastUpdated": lastUpdated.toString(),
      "fromCache": fromCache ?? false,
      "id": id,
      "title": title,
      "num_chapters": numChapters,
      "main_picture": mainPicture?.toJson(),
      "alternative_titles": alternateTitles?.toJson(),
      "start_date": startDate.toString(),
      "end_date": endDate.toString(),
      "synopsis": synopsis,
      "mean": mean,
      "rank": rank,
      "popularity": popularity,
      "num_list_users": numListUsers,
      "num_scoring_users": numScoringUsers,
      "nsfw": nsfw,
      "created_at": createdAt.toString(),
      "updated_at": updatedAt.toString(),
      "media_type": mediaType,
      "status": status,
      "genres": genres ?? [],
      "my_list_status": myListStatus?.toJson(),
      "num_volumes": numVolumes,
      "pictures": pictures ?? [],
      "background": background,
      "serialization": serialization ?? [],
      "related_anime": relatedAnime ?? [],
      "related_manga": relatedManga ?? [],
      "recommendations": recommendations ?? [],
    };
  }
}
