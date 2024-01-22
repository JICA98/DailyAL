import 'package:dal_commons/src/model/anime/myanimeliststatus.dart';
import 'package:dal_commons/src/model/global/paging.dart';
import 'package:dal_commons/src/model/manga/mymangaliststatus.dart';

import '../anime/season.dart' as ss;
import 'animenode.dart';
import 'myliststatus.dart';

class SearchResult {
  final List<BaseNode>? data;
  Paging? paging;
  final ss.Season? season;
  String? url;
  bool? fromCache;
  DateTime? lastUpdated;

  SearchResult(
      {this.data,
      this.url,
      this.paging,
      this.season,
      this.fromCache,
      this.lastUpdated});

  factory SearchResult.fromJson(Map<String, dynamic>? json,
      {String category = "anime"}) {
    return json != null
        ? SearchResult(
            url: json["url"],
            fromCache: json["fromCache"] ?? false,
            lastUpdated:
                DateTime.tryParse(json["lastUpdated"]?.toString() ?? "") ??
                    DateTime.now(),
            data: List.from(json["data"] ?? [])
                .map((e) => BaseNode.fromJson(e, category: category))
                .toList(),
            season: ss.Season.fromJson(json["season"]),
            paging: Paging.fromJson(json["paging"]))
        : SearchResult();
  }
  Map<String, dynamic> toJson() {
    return {
      "url": url,
      "fromCache": fromCache ?? false,
      "lastUpdated": lastUpdated.toString(),
      "data": data ?? [],
      "paging": paging?.toJson(),
      "season": season?.toJson(),
    };
  }

  static MyListStatus? getStatus(category, e) {
    try {
      return category.equals("anime")
          ? MyAnimeListStatus(
              isRewatching: false,
              numEpisodesWatched: e.watchedEpisodes,
              numTimesRewatched: 1,
              score: e.score)
          : category.equals("manga")
              ? MyMangaListStatus(
                  isRereading: false,
                  numChaptersRead: e.readChapters,
                  numVolumesRead: e.readVolumes,
                  score: e.score,
                )
              : null;
    } catch (e) {
      return null;
    }
  }
}
