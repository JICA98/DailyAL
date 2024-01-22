import 'package:dailyanimelist/api/malapi.dart';
import 'package:dailyanimelist/enums.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/user/prefvalue.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'hompagepref.g.dart';

enum HomePageType {
  top_anime,
  top_manga,
  forum,
  seasonal_anime,
  sugg_anime,
  user_list,
  news
}

enum EndPointType { mal, jikan, html, dal }

@JsonSerializable()
class HomePageApiPref {
  HomePageType? contentType;

  //Value
  late PrefValue value;
  HomePageApiPref() {
    value = PrefValue();
  }

  static HomePageApiPref defaultPref() {
    return HomePageApiPref.fromValues(value: PrefValue());
  }

  HomePageApiPref.fromValues({
    this.contentType,
    required this.value,
  });

  factory HomePageApiPref.fromJson(Map<String, dynamic> json) =>
      _$HomePageApiPrefFromJson(json);
  Map<String, dynamic> toJson() => _$HomePageApiPrefToJson(this);
}

final defaultHPPrefList = [
  HomePageApiPref.fromValues(
    contentType: HomePageType.news,
    value: PrefValue(title: 'News'),
  ),
  HomePageApiPref.fromValues(
    contentType: HomePageType.seasonal_anime,
    value: PrefValue(
      auto: true,
      title: seasonMapCaps[MalApi.getSeasonType()]! +
          " " +
          MalApi.getCurrentSeasonYear().toString() +
          " Anime",
      sortType: SortType.AnimeNumListUsers,
    ),
  ),
  HomePageApiPref.fromValues(
      contentType: HomePageType.sugg_anime,
      value: PrefValue(
        title: "Suggested Anime",
        authOnly: true,
      )),
  HomePageApiPref.fromValues(
    contentType: HomePageType.top_anime,
    value: PrefValue(
      title: desiredTopAnimeOrder[RankingType.ALL]!,
      rankingType: RankingType.ALL,
    ),
  ),
  HomePageApiPref.fromValues(
    contentType: HomePageType.top_anime,
    value: PrefValue(
        title: desiredTopAnimeOrder[RankingType.UPCOMING]!,
        rankingType: RankingType.UPCOMING),
  ),
  HomePageApiPref.fromValues(
    contentType: HomePageType.top_manga,
    value: PrefValue(
        title: desiredMangaRankingMap[MangaRanking.all]!,
        mangaRanking: MangaRanking.all),
  ),
  HomePageApiPref.fromValues(
    contentType: HomePageType.top_manga,
    value: PrefValue(
      title: desiredMangaRankingMap[MangaRanking.bypopularity]!,
      mangaRanking: MangaRanking.bypopularity,
    ),
  ),
  HomePageApiPref.fromValues(
    contentType: HomePageType.top_anime,
    value: PrefValue(
        title: desiredTopAnimeOrder[RankingType.BYPOPULARITY]!,
        rankingType: RankingType.BYPOPULARITY),
  ),
  HomePageApiPref.fromValues(
    contentType: HomePageType.top_anime,
    value: PrefValue(
        title: desiredTopAnimeOrder[RankingType.FAVOURITE]!,
        rankingType: RankingType.FAVOURITE),
  ),
  HomePageApiPref.fromValues(
    contentType: HomePageType.top_anime,
    value: PrefValue(
        title: desiredTopAnimeOrder[RankingType.TV]!,
        rankingType: RankingType.TV),
  ),
  HomePageApiPref.fromValues(
    contentType: HomePageType.top_anime,
    value: PrefValue(
        title: desiredTopAnimeOrder[RankingType.SPECIAL]!,
        rankingType: RankingType.SPECIAL),
  ),
];

enum HomePageTileSize { xs, s, m, l, xl }

class _TileSize {
  final double contentHeight;
  final double contentWidth;
  final double containerHeight;
  final double loadingContainerHeight;
  const _TileSize({
    required this.contentHeight,
    required this.contentWidth,
    required this.containerHeight,
    required this.loadingContainerHeight,
  });
}

const tileMap = {
  HomePageTileSize.xs: _TileSize(
    contentHeight: 104,
    contentWidth: 80,
    containerHeight: 187.6,
    loadingContainerHeight: 130,
  ),
  HomePageTileSize.s: _TileSize(
    contentHeight: 130,
    contentWidth: 100,
    containerHeight: 215,
    loadingContainerHeight: 162.5,
  ),
  HomePageTileSize.m: _TileSize(
    contentHeight: 160,
    contentWidth: 120,
    containerHeight: 237,
    loadingContainerHeight: 200,
  ),
  HomePageTileSize.l: _TileSize(
    contentHeight: 200,
    contentWidth: 150,
    containerHeight: 280,
    loadingContainerHeight: 250,
  ),
  HomePageTileSize.xl: _TileSize(
    contentHeight: 230,
    contentWidth: 172.93,
    containerHeight: 322,
    loadingContainerHeight: 287.5,
  )
};
