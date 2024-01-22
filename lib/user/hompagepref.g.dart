// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hompagepref.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HomePageApiPref _$HomePageApiPrefFromJson(Map<String, dynamic> json) =>
    HomePageApiPref()
      ..contentType =
          $enumDecodeNullable(_$HomePageTypeEnumMap, json['contentType'])
      ..value = PrefValue.fromJson(json['value'] as Map<String, dynamic>);

Map<String, dynamic> _$HomePageApiPrefToJson(HomePageApiPref instance) =>
    <String, dynamic>{
      'contentType': _$HomePageTypeEnumMap[instance.contentType],
      'value': instance.value,
    };

const _$HomePageTypeEnumMap = {
  HomePageType.top_anime: 'top_anime',
  HomePageType.top_manga: 'top_manga',
  HomePageType.forum: 'forum',
  HomePageType.seasonal_anime: 'seasonal_anime',
  HomePageType.sugg_anime: 'sugg_anime',
  HomePageType.user_list: 'user_list',
  HomePageType.news: 'news',
};
