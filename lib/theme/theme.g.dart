// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserTheme _$UserThemeFromJson(Map<String, dynamic> json) => UserTheme(
      $enumDecode(_$UserThemeModeEnumMap, json['themeMode']),
      json['color'] as String,
      $enumDecode(_$UserThemeBgEnumMap, json['background']),
      Map<String, int>.from(json['userDefinedColors'] as Map),
    );

Map<String, dynamic> _$UserThemeToJson(UserTheme instance) => <String, dynamic>{
      'themeMode': _$UserThemeModeEnumMap[instance.themeMode]!,
      'color': instance.color,
      'background': _$UserThemeBgEnumMap[instance.background]!,
      'userDefinedColors': instance.userDefinedColors,
    };

const _$UserThemeModeEnumMap = {
  UserThemeMode.Auto: 'Auto',
  UserThemeMode.Light: 'Light',
  UserThemeMode.Dark: 'Dark',
};

const _$UserThemeBgEnumMap = {
  UserThemeBg.fall: 'fall',
  UserThemeBg.spring: 'spring',
  UserThemeBg.winter: 'winter',
  UserThemeBg.summer: 'summer',
  UserThemeBg.night: 'night',
};
