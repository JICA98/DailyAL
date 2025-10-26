import 'package:dailyanimelist/user/anime_manga_tab_pref.dart';
import 'package:dailyanimelist/user/list_pref.dart';
import 'package:dailyanimelist/util/error/error_reporting.dart';
import 'package:json_annotation/json_annotation.dart';

part 'anime_manga_pref.g.dart';

enum TimezonePref { utc, jst, local }

@JsonSerializable()
class AnimeMangaPagePreferences {
  List<AnimeMangaTabPreference> animeTabs;
  List<AnimeMangaTabPreference> mangaTabs;
  TimezonePref timezonePref;
  String? defaultTab;
  String? defaultAnimeTab;
  String? defaultMangaTab;
  String? defaultAnimeAddToList;
  String? defaultMangaAddToList;
  List<ContentCardProps>? contentCardProps;

  AnimeMangaPagePreferences({
    required this.animeTabs,
    required this.mangaTabs,
    this.timezonePref = TimezonePref.local,
    this.defaultTab,
    this.defaultAnimeTab,
    this.defaultMangaTab,
    this.contentCardProps,
    this.defaultAnimeAddToList,
    this.defaultMangaAddToList,
  });

  String get defaultTabSelected {
    return defaultTab ?? 'none';
  }

  String get defaultAnimeTabSelected {
    return defaultAnimeTab ?? 'none';
  }

  String get defaultMangaTabSelected {
    return defaultMangaTab ?? 'none';
  }

  String get defaultAnimeAddToListSelected {
    return defaultAnimeAddToList ?? 'watching';
  }

  String get defaultMangaAddToListSelected {
    return defaultMangaAddToList ?? 'reading';
  }

  factory AnimeMangaPagePreferences.defaultObject() {
    return AnimeMangaPagePreferences(
      animeTabs: defaultAnimeTabs,
      mangaTabs: defaultMangaTabs,
    );
  }

  factory AnimeMangaPagePreferences.fromJson(Map<String, dynamic> json) {
    final prefs = _$AnimeMangaPagePreferencesFromJson(json);
    // Migration: Add missing tabs from defaults
    prefs._migrateTabs();
    return prefs;
  }

  /// Migrates tabs by adding any missing TabTypes from defaults
  void _migrateTabs() {
    // Migrate anime tabs
    final existingAnimeTypes = animeTabs.map((e) => e.tabType).toSet();
    for (var defaultTab in defaultAnimeTabs) {
      if (!existingAnimeTypes.contains(defaultTab.tabType)) {
        // Find the position to insert (after Stats if it's Score_Stats)
        if (defaultTab.tabType == TabType.Score_Stats) {
          final statsIndex = animeTabs.indexWhere((t) => t.tabType == TabType.Stats);
          if (statsIndex != -1) {
            animeTabs.insert(statsIndex + 1, AnimeMangaTabPreference(defaultTab.tabType, true));
          } else {
            animeTabs.add(AnimeMangaTabPreference(defaultTab.tabType, true));
          }
        } else {
          animeTabs.add(AnimeMangaTabPreference(defaultTab.tabType, true));
        }
      }
    }

    // Migrate manga tabs (Score_Stats not added to manga as it's anime-only)
    final existingMangaTypes = mangaTabs.map((e) => e.tabType).toSet();
    for (var defaultTab in defaultMangaTabs) {
      if (!existingMangaTypes.contains(defaultTab.tabType)) {
        mangaTabs.add(AnimeMangaTabPreference(defaultTab.tabType, true));
      }
    }
  }

  Map<String, dynamic> toJson() => _$AnimeMangaPagePreferencesToJson(this);
}
