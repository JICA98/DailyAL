// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prefvalue.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PrefValue _$PrefValueFromJson(Map<String, dynamic> json) => PrefValue(
      rankingType:
          $enumDecodeNullable(_$RankingTypeEnumMap, json['rankingType']),
      seasonType: $enumDecodeNullable(_$SeasonTypeEnumMap, json['seasonType']),
      title: json['title'] as String? ?? "No Title",
      year: json['year'] as int?,
      mangaRanking:
          $enumDecodeNullable(_$MangaRankingEnumMap, json['mangaRanking']),
      boardName: json['boardName'] as String?,
      subboardName: json['subboardName'] as String?,
      userCategory: json['userCategory'] as String?,
      userSubCategory: json['userSubCategory'] as String?,
      auto: json['auto'] as bool? ?? false,
      authOnly: json['authOnly'] as bool? ?? false,
      sortType: $enumDecodeNullable(_$SortTypeEnumMap, json['sortType']),
      titleChanged: json['titleChanged'] as bool? ?? false,
    );

Map<String, dynamic> _$PrefValueToJson(PrefValue instance) => <String, dynamic>{
      'title': instance.title,
      'titleChanged': instance.titleChanged,
      'year': instance.year,
      'seasonType': _$SeasonTypeEnumMap[instance.seasonType],
      'sortType': _$SortTypeEnumMap[instance.sortType],
      'rankingType': _$RankingTypeEnumMap[instance.rankingType],
      'mangaRanking': _$MangaRankingEnumMap[instance.mangaRanking],
      'authOnly': instance.authOnly,
      'boardName': instance.boardName,
      'subboardName': instance.subboardName,
      'userCategory': instance.userCategory,
      'userSubCategory': instance.userSubCategory,
      'auto': instance.auto,
    };

const _$RankingTypeEnumMap = {
  RankingType.ALL: 'ALL',
  RankingType.AIRING: 'AIRING',
  RankingType.UPCOMING: 'UPCOMING',
  RankingType.TV: 'TV',
  RankingType.OVA: 'OVA',
  RankingType.MOVIE: 'MOVIE',
  RankingType.SPECIAL: 'SPECIAL',
  RankingType.BYPOPULARITY: 'BYPOPULARITY',
  RankingType.FAVOURITE: 'FAVOURITE',
  RankingType.ONA: 'ONA',
};

const _$SeasonTypeEnumMap = {
  SeasonType.WINTER: 'WINTER',
  SeasonType.SPRING: 'SPRING',
  SeasonType.SUMMER: 'SUMMER',
  SeasonType.FALL: 'FALL',
};

const _$MangaRankingEnumMap = {
  MangaRanking.all: 'all',
  MangaRanking.manga: 'manga',
  MangaRanking.oneshots: 'oneshots',
  MangaRanking.doujin: 'doujin',
  MangaRanking.lightnovels: 'lightnovels',
  MangaRanking.novels: 'novels',
  MangaRanking.manhwa: 'manhwa',
  MangaRanking.manhua: 'manhua',
  MangaRanking.bypopularity: 'bypopularity',
  MangaRanking.favorite: 'favorite',
};

const _$SortTypeEnumMap = {
  SortType.AnimeScore: 'AnimeScore',
  SortType.AnimeNumListUsers: 'AnimeNumListUsers',
};
