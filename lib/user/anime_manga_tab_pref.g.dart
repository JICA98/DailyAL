// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anime_manga_tab_pref.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnimeMangaTabPreference _$AnimeMangaTabPreferenceFromJson(
        Map<String, dynamic> json) =>
    AnimeMangaTabPreference(
      $enumDecode(_$TabTypeEnumMap, json['tabType']),
      json['visibility'] as bool,
    );

Map<String, dynamic> _$AnimeMangaTabPreferenceToJson(
        AnimeMangaTabPreference instance) =>
    <String, dynamic>{
      'tabType': _$TabTypeEnumMap[instance.tabType]!,
      'visibility': instance.visibility,
    };

const _$TabTypeEnumMap = {
  TabType.Synopsis: 'Synopsis',
  TabType.Media: 'Media',
  TabType.Related: 'Related',
  TabType.Adaptations: 'Adaptations',
  TabType.Reviews: 'Reviews',
  TabType.Recommendations: 'Recommendations',
  TabType.Interest_Stacks: 'Interest_Stacks',
  TabType.Characters: 'Characters',
  TabType.Forums: 'Forums',
  TabType.Related_Anime: 'Related_Anime',
  TabType.Pictures: 'Pictures',
  TabType.News: 'News',
  TabType.Featured_Articles: 'Featured_Articles',
  TabType.User_Updates: 'User_Updates',
  TabType.More_Info: 'More_Info',
  TabType.Stats: 'Stats',
};
