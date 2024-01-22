import 'package:dailyanimelist/api/malapi.dart';
import 'package:dailyanimelist/enums.dart';
import 'package:dailyanimelist/user/hompagepref.dart';
import 'package:dailyanimelist/util/homepageutils.dart';
import 'package:json_annotation/json_annotation.dart';
part 'prefvalue.g.dart';

@JsonSerializable()
class PrefValue {
  String title;
  bool titleChanged;

  /// For seasonal anime
  int? year;
  SeasonType? seasonType;
  SortType? sortType;

  /// For Top Anime
  RankingType? rankingType;

  MangaRanking? mangaRanking;

  bool authOnly;

  //For forum
  String? boardName;
  String? subboardName;

  //for Userlist
  String? userCategory;
  String? userSubCategory;

  //pick values automatically
  bool auto;

  PrefValue({
    this.rankingType,
    this.seasonType,
    this.title = "No Title",
    this.year,
    this.mangaRanking,
    this.boardName,
    this.subboardName,
    this.userCategory,
    this.userSubCategory,
    this.auto = false,
    this.authOnly = false,
    this.sortType,
    this.titleChanged = false,
  });

  factory PrefValue.fromApiPref(HomePageApiPref pref) {
    var _rankingType, _year, _seasonType, _mangaRanking, _sortType;
    bool _authOnly = false, _auto = false;
    String? _boardName;
    String? _userCategory, _userSubCategory;
    switch (pref.contentType) {
      case HomePageType.top_anime:
        _rankingType = RankingType.ALL;
        break;
      case HomePageType.seasonal_anime:
        _auto = true;
        _year = MalApi.getCurrentSeasonYear();
        _seasonType = MalApi.getSeasonType();
        _sortType = SortType.AnimeNumListUsers;
        break;
      case HomePageType.top_manga:
        _mangaRanking = MangaRanking.all;
        break;
      case HomePageType.sugg_anime:
        _authOnly = true;
        break;
      case HomePageType.forum:
        _boardName = "Anime Series";
        break;
      case HomePageType.user_list:
        _userCategory = "anime";
        _userSubCategory = "All";
        _authOnly = true;
        break;
      default:
    }
    return PrefValue(
      rankingType: _rankingType,
      seasonType: _seasonType,
      year: _year,
      auto: _auto,
      title: HomePageUtils().titleBuilder(pref),
      mangaRanking: _mangaRanking,
      subboardName: _boardName,
      userCategory: _userCategory,
      userSubCategory: _userSubCategory,
      authOnly: _authOnly,
      sortType: _sortType,
    );
  }

  factory PrefValue.fromJson(Map<String, dynamic> json) =>
      _$PrefValueFromJson(json);
  Map<String, dynamic> toJson() => _$PrefValueToJson(this);
}
