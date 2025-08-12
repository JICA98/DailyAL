// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anime_manga_pref.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnimeMangaPagePreferences _$AnimeMangaPagePreferencesFromJson(
        Map<String, dynamic> json) =>
    AnimeMangaPagePreferences(
      animeTabs: (json['animeTabs'] as List<dynamic>)
          .map((e) =>
              AnimeMangaTabPreference.fromJson(e as Map<String, dynamic>))
          .toList(),
      mangaTabs: (json['mangaTabs'] as List<dynamic>)
          .map((e) =>
              AnimeMangaTabPreference.fromJson(e as Map<String, dynamic>))
          .toList(),
      timezonePref:
          $enumDecodeNullable(_$TimezonePrefEnumMap, json['timezonePref']) ??
              TimezonePref.local,
      defaultTab: json['defaultTab'] as String?,
      defaultAnimeTab: json['defaultAnimeTab'] as String?,
      defaultMangaTab: json['defaultMangaTab'] as String?,
      contentCardProps: (json['contentCardProps'] as List<dynamic>?)
          ?.map((e) => ContentCardProps.fromJson(e as Map<String, dynamic>?))
          .toList(),
    );

Map<String, dynamic> _$AnimeMangaPagePreferencesToJson(
        AnimeMangaPagePreferences instance) =>
    <String, dynamic>{
      'animeTabs': instance.animeTabs,
      'mangaTabs': instance.mangaTabs,
      'timezonePref': _$TimezonePrefEnumMap[instance.timezonePref]!,
      'defaultTab': instance.defaultTab,
      'defaultAnimeTab': instance.defaultAnimeTab,
      'defaultMangaTab': instance.defaultMangaTab,
      'contentCardProps': instance.contentCardProps,
    };

const _$TimezonePrefEnumMap = {
  TimezonePref.utc: 'utc',
  TimezonePref.jst: 'jst',
  TimezonePref.local: 'local',
};
