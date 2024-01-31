import 'package:dal_commons/src/model/global/alternatetitles.dart';
import 'package:dal_commons/src/model/global/node.dart';
import 'package:dal_commons/src/model/anime/broadcast.dart';
import 'package:dal_commons/src/model/global/genre.dart';
import 'package:dal_commons/src/model/anime/myanimeliststatus.dart';
import 'package:dal_commons/src/model/global/picture.dart';
import 'package:dal_commons/src/model/global/relatednode.dart';
import 'package:dal_commons/src/model/anime/season.dart';
import 'package:dal_commons/src/model/anime/animestudio.dart';

import '../global/recommendation.dart';
import '../jikan/jikan_anime.dart';
import 'animestatistics.dart';
import 'detailedmixin.dart';
import 'themesong.dart';

class AnimeDetailed extends Node with AnimeDetailedMixin {
  final AlternateTitles? alternateTitles;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? synopsis;
  final double? mean;
  final int? rank;
  final int? popularity;
  final int? numListUsers;
  final String? numListUsersFormatted; // not an api field
  final int? numScoringUsers;
  final String? nsfw;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? mediaType;
  @override
  final String? status;
  final List<MalGenre>? genres;
  @override
  final int? numEpisodes;
  final Season? startSeason;
  @override
  final Broadcast? broadcast;
  final String? source;
  final int? averageEpisodeDuration;
  final String? rating;
  final List<Picture>? pictures;
  final String? background;
  final List<RelatedContent>? relatedAnime;
  final List<String>? relatedManga;
  final List<Recommendation>? recommendations;
  final List<AnimeStudio>? studios;
  final AnimeStatistics? statistics;
  final List<ThemeSong>? openingSongs;
  final List<ThemeSong>? endingSongs;
  final String? additonalInfo; // not an api field

  DateTime? lastUpdated;

  @override
  MyAnimeListStatus? myListStatus;

  AnimeDetailed({
    this.openingSongs,
    this.endingSongs,
    int? id,
    Picture? mainPicture,
    String? title,
    bool? fromCache,
    String? url,
    this.mediaType,
    this.alternateTitles,
    this.averageEpisodeDuration,
    this.background,
    this.lastUpdated,
    this.numListUsersFormatted,
    this.broadcast,
    this.createdAt,
    this.endDate,
    this.genres,
    this.mean,
    this.myListStatus,
    this.nsfw,
    this.numEpisodes,
    this.numListUsers,
    this.numScoringUsers,
    this.pictures,
    this.popularity,
    this.rank,
    this.rating,
    this.recommendations,
    this.relatedAnime,
    this.relatedManga,
    this.source,
    this.startDate,
    this.startSeason,
    this.statistics,
    this.status,
    this.studios,
    this.synopsis,
    this.additonalInfo,
    this.updatedAt,
  }) : super(
            url: url,
            id: id,
            myListStatus: myListStatus,
            mainPicture: mainPicture,
            title: title,
            fromCache: fromCache);

  factory AnimeDetailed.fromJson(Map<String, dynamic>? json) {
    return json != null
        ? AnimeDetailed(
            url: json["url"],
            additonalInfo: json['additonalInfo'],
            lastUpdated:
                DateTime.tryParse(json["lastUpdated"]?.toString() ?? "") ??
                    DateTime.now(),
            fromCache: json["fromCache"] ?? false,
            id: json["id"],
            title: json["title"],
            numListUsersFormatted: json['numListUsersFormatted'],
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
            myListStatus: MyAnimeListStatus.fromJson(json["my_list_status"]),
            numEpisodes: json["num_episodes"],
            startSeason: Season.fromJson(json["start_season"]),
            broadcast: Broadcast.fromJson(json["broadcast"]),
            source: json["source"],
            averageEpisodeDuration: json["average_episode_duration"],
            rating: json["rating"],
            openingSongs: List.from(json["opening_themes"] ?? [])
                .map((e) => ThemeSong.fromJson(e))
                .toList(),
            endingSongs: List.from(json["ending_themes"] ?? [])
                .map((e) => ThemeSong.fromJson(e))
                .toList(),
            pictures: List.from(json["pictures"] ?? [])
                .map((e) => Picture.fromJson(e))
                .toList(),
            background: json["background"],
            relatedAnime: List.from(json["related_anime"] ?? [])
                .map((e) => RelatedContent.fromJson(e))
                .toList(),
            relatedManga: List.from(json["related_manga"] ?? []),
            recommendations: List.from(json["recommendations"] ?? [])
                .map((e) => Recommendation.fromJson(e))
                .toList(),
            studios: List.from(json["studios"] ?? [])
                .map((e) => AnimeStudio.fromJson(e))
                .toList(),
            statistics: AnimeStatistics.fromJson(json["statistics"]))
        : AnimeDetailed();
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "url": url,
      'additonalInfo': additonalInfo,
      "lastUpdated": lastUpdated.toString(),
      "fromCache": fromCache ?? false,
      "id": id,
      "title": title,
      "opening_themes": openingSongs ?? [],
      "ending_themes": endingSongs ?? [],
      "main_picture": mainPicture?.toJson(),
      "alternative_titles": alternateTitles?.toJson(),
      "start_date": startDate.toString(),
      "end_date": endDate.toString(),
      "synopsis": synopsis,
      "mean": mean,
      "rank": rank,
      'numListUsersFormatted': numListUsersFormatted,
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
      "num_episodes": numEpisodes,
      "start_season": startSeason?.toJson(),
      "broadcast": broadcast?.toJson(),
      "source": source,
      "average_episode_duration": averageEpisodeDuration,
      "rating": rating,
      "pictures": pictures ?? [],
      "background": background,
      "related_anime": relatedAnime ?? [],
      "related_manga": relatedManga ?? [],
      "recommendations": recommendations ?? [],
      "studios": studios ?? [],
      "statistics": statistics?.toJson(),
    };
  }

  static AnimeDetailed fromJikanJson(JikanAnime j) {
    return AnimeDetailed(
      id: j.malId,
      mainPicture: Picture(
        large: j.images?['jpg']?.largeJImageUrl,
        medium: j.images?['jpg']?.imageUrl,
      ),
      broadcast: Broadcast(
        dayOfTheWeek: j.broadcast?.day?.toLowerCase(),
        startTime: j.broadcast?.time,
      ),
      averageEpisodeDuration:
          int.tryParse(j.duration?.replaceAll(RegExp(r'\D'), '') ?? ''),
      numEpisodes: j.episodes,
      genres: [
        ..._getGenres(j.genres),
        ..._getGenres(j.themes),
        ..._getGenres(j.explicitGenres),
        ..._getGenres(j.demographics),
      ],
      numListUsers: j.members,
      popularity: j.popularity,
      rank: j.rank,
      rating: j.rating,
      mean: j.score,
      numScoringUsers: j.scoredBy,
      startSeason: Season(
        year: j.year,
        season: j.season,
      ),
      status: j.status,
      studios: j.studios?.map((e) => AnimeStudio(id: e.malId, name: e.name)).toList(),
      title: j.title,
      alternateTitles: AlternateTitles(
        en: j.titleEnglish,
        ja: j.titleJapanese,
        synonyms: j.titleSynonyms,
      ),
      mediaType: j.type,
    );
  }

  static List<MalGenre> _getGenres(List<JDemographic>? demographics) {
    return demographics
            ?.map((e) => MalGenre(
                  id: e.malId,
                  name: e.name,
                ))
            .toList() ??
        [];
  }
}
