import 'package:dailyanimelist/user/anime_manga_tab_pref.dart';
import 'package:json_annotation/json_annotation.dart';

part 'anime_manga_pref.g.dart';

enum TimezonePref { utc, jst, local }

@JsonSerializable()
class AnimeMangaPagePreferences {
  List<AnimeMangaTabPreference> animeTabs;
  List<AnimeMangaTabPreference> mangaTabs;
  TimezonePref timezonePref;

  AnimeMangaPagePreferences({
    required this.animeTabs,
    required this.mangaTabs,
    this.timezonePref = TimezonePref.local,
  });

  factory AnimeMangaPagePreferences.defaultObject() {
    return AnimeMangaPagePreferences(
      animeTabs: defaultAnimeTabs,
      mangaTabs: defaultMangaTabs,
    );
  }

  factory AnimeMangaPagePreferences.fromJson(Map<String, dynamic> json) =>
      _$AnimeMangaPagePreferencesFromJson(json);
  Map<String, dynamic> toJson() => _$AnimeMangaPagePreferencesToJson(this);
}
