import 'package:json_annotation/json_annotation.dart';

part 'anime_manga_tab_pref.g.dart';

enum TabType {
  Synopsis,
  Media,
  Related,
  Adaptations,
  Reviews,
  Recommendations,
  Interest_Stacks,
  Characters,
  Forums,
  Related_Anime,
  Pictures,
  News,
  Featured_Articles,
  User_Updates,
  More_Info,
  Stats,
}

@JsonSerializable()
class AnimeMangaTabPreference {
  TabType tabType;
  bool visibility;
  AnimeMangaTabPreference(this.tabType, this.visibility);

  factory AnimeMangaTabPreference.fromJson(Map<String, dynamic> json) =>
      _$AnimeMangaTabPreferenceFromJson(json);
  Map<String, dynamic> toJson() => _$AnimeMangaTabPreferenceToJson(this);
}

final defaultAnimeTabs = [
  AnimeMangaTabPreference(TabType.Synopsis, true),
  AnimeMangaTabPreference(TabType.Media, true),
  AnimeMangaTabPreference(TabType.Related, true),
  AnimeMangaTabPreference(TabType.Adaptations, true),
  AnimeMangaTabPreference(TabType.Reviews, true),
  AnimeMangaTabPreference(TabType.Recommendations, true),
  AnimeMangaTabPreference(TabType.Interest_Stacks, true),
  AnimeMangaTabPreference(TabType.Characters, true),
  AnimeMangaTabPreference(TabType.Forums, true),
  AnimeMangaTabPreference(TabType.Pictures, true),
  AnimeMangaTabPreference(TabType.News, true),
  AnimeMangaTabPreference(TabType.Featured_Articles, true),
  AnimeMangaTabPreference(TabType.User_Updates, true),
  AnimeMangaTabPreference(TabType.Stats, true),
  AnimeMangaTabPreference(TabType.More_Info, true)
];

final defaultMangaTabs = [
  AnimeMangaTabPreference(TabType.Synopsis, true),
  AnimeMangaTabPreference(TabType.Related, true),
  AnimeMangaTabPreference(TabType.Adaptations, true),
  AnimeMangaTabPreference(TabType.Reviews, true),
  AnimeMangaTabPreference(TabType.Recommendations, true),
  AnimeMangaTabPreference(TabType.Interest_Stacks, true),
  AnimeMangaTabPreference(TabType.Characters, true),
  AnimeMangaTabPreference(TabType.Pictures, true),
  AnimeMangaTabPreference(TabType.Related_Anime, true),
  AnimeMangaTabPreference(TabType.Forums, true),
  AnimeMangaTabPreference(TabType.News, true),
  AnimeMangaTabPreference(TabType.Featured_Articles, true),
  AnimeMangaTabPreference(TabType.User_Updates, true),
  AnimeMangaTabPreference(TabType.More_Info, true)
];
