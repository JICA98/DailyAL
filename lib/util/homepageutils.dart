import 'package:dailyanimelist/api/credmal.dart';
import 'package:dailyanimelist/api/dalapi.dart';
import 'package:dailyanimelist/api/malapi.dart';
import 'package:dailyanimelist/api/malforum.dart';
import 'package:dailyanimelist/api/maluser.dart';
import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/enums.dart';
import 'package:dailyanimelist/main.dart';
import 'package:dailyanimelist/pages/userpage.dart';
import 'package:dailyanimelist/screens/forumtopicsscreen.dart';
import 'package:dailyanimelist/screens/generalsearchscreen.dart';
import 'package:dailyanimelist/screens/plainscreen.dart';
import 'package:dailyanimelist/screens/seasonal_screen.dart';
import 'package:dailyanimelist/user/hompagepref.dart';
import 'package:dailyanimelist/user/user.dart';
import 'package:dailyanimelist/widgets/search/filtermodal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dal_commons/dal_commons.dart';

class HomePageUtils {
  HomePageUtils._internal();
  factory HomePageUtils() => HomePageUtils._internal();

  Future<dynamic> getFuture(HomePageApiPref apiPref,
      [bool forceUpdate = false]) async {
    var content = await _getContent(apiPref);
    if (forceUpdate ||
        shouldUpdateContent(
            result: content,
            timeinHours: user.pref.cacheUpdateFrequency[homeIndex])) {
      content = await _getContent(apiPref, fromCache: false);
    }
    return content;
  }

  Future<dynamic> _getContent(HomePageApiPref apiPref,
      {bool fromCache = true}) async {
    int _limit = user.pref.homePageItemsPerCategory;
    final _fields = user.status == AuthStatus.AUTHENTICATED
        ? ["my_list_status"]
        : <String>[];
    final _contentOnlyFields = [
      "mean",
      "num_list_users",
      "genres",
      'alternative_titles',
      'num_episodes',
    ];
    switch (apiPref.contentType) {
      case HomePageType.top_anime:
        return MalApi.getContentRanking(apiPref.value.rankingType,
            limit: _limit,
            fromCache: fromCache,
            fields: _fields + _contentOnlyFields);
      case HomePageType.seasonal_anime:
        if (apiPref.value.auto) {
          return MalApi.getCurrentSeason(
              limit: _limit,
              sortType: apiPref.value.sortType,
              fromCache: fromCache,
              fields: _fields + _contentOnlyFields);
        }
        return MalApi.getSeasonalAnime(
            apiPref.value.seasonType!, apiPref.value.year!,
            limit: _limit,
            fromCache: fromCache,
            sortType: apiPref.value.sortType,
            fields: _fields + _contentOnlyFields);
      case HomePageType.top_manga:
        return MalApi.getContentRanking(apiPref.value.mangaRanking,
            category: "manga",
            limit: _limit,
            fromCache: fromCache,
            fields: _fields + _contentOnlyFields);
      case HomePageType.sugg_anime:
        return MalUser.getContentSuggestions(
            category: "anime",
            limit: _limit,
            fromCache: fromCache,
            fields: _fields + _contentOnlyFields);
      case HomePageType.user_list:
        return MalUser.getMyContentList(
            category: apiPref.value.userCategory!,
            limit: _limit,
            fields: _contentOnlyFields,
            fromCache: fromCache,
            status: _getListStatus(apiPref));
      case HomePageType.forum:
        var forum = _buildForumDetails(apiPref);
        return MalForum.getForumTopics(
          boardId: forum.boardId,
          subBoardId: forum.subboardId,
          fromHtml: true,
          limit: _limit,
          fromCache: fromCache,
        );
      case HomePageType.news:
        return DalApi.i.searchFeaturedArticles(category: 'news', tag: 'all');
      default:
    }
  }

  Widget viewAllBuilder(HomePageApiPref apiPref) {
    String _query = "";
    String _category = "anime";
    Map<String, FilterOption>? filterOutputs;
    switch (apiPref.contentType) {
      case HomePageType.top_anime:
        _query = "#${rankingMap[apiPref.value.rankingType]}";
        break;
      case HomePageType.seasonal_anime:
        return SeasonalScreen(
          seasonType: apiPref.value.auto
              ? MalApi.getSeasonType()
              : apiPref.value.seasonType!,
          year: apiPref.value.auto
              ? MalApi.getCurrentSeasonYear()
              : apiPref.value.year!,
          sortType: apiPref.value.sortType,
        );
      case HomePageType.top_manga:
        _query = "#${mangaRankingMap[apiPref.value.mangaRanking]}@manga";
        break;
      case HomePageType.sugg_anime:
        _query = "#suggested@anime";
        break;
      case HomePageType.forum:
        var forum = _buildForumDetails(apiPref);
        return ForumTopicsScreen(
          boardId: forum.boardId,
          subBoardId: forum.subboardId,
          title: apiPref.value.title,
          offset: 50,
        );
      case HomePageType.user_list:
        return PlainScreen(
          title: S.current.My_List2,
          child: UserPage(
            hasExpanded: false,
            isSelf: false,
            initialStatus: _getListStatus(apiPref),
            category: apiPref.value.userCategory,
          ),
        );
      case HomePageType.news:
        _category = 'news';
        filterOutputs = {
          'tags': FilterOption(apiFieldName: 'tags', value: 'All')
        };
        break;
      default:
    }
    return GeneralSearchScreen(
      autoFocus: false,
      searchQuery: _query,
      showBackButton: true,
      category: _category,
      filterOutputs: filterOutputs,
    );
  }

  ForumHelper _buildForumDetails(HomePageApiPref apiPref) {
    var boardId = ForumConstants.boards.values
        .toList()
        .indexOf(apiPref.value.boardName ?? '');
    var subboardId = ForumConstants.subBoards.values
        .toList()
        .indexOf(apiPref.value.subboardName ?? '');
    return ForumHelper(
        boardId != -1 ? ForumConstants.boards.keys.elementAt(boardId) : null,
        subboardId != -1
            ? ForumConstants.subBoards.keys.elementAt(subboardId)
            : null);
  }

  String? _getListStatus(HomePageApiPref apiPref) {
    var keys = apiPref.value.userCategory!.equals("anime")
        ? allAnimeStatusMap.keys.toList()
        : allMangaStatusMap.keys.toList();
    var values = apiPref.value.userCategory!.equals("anime")
        ? allAnimeStatusMap.values.toList()
        : allMangaStatusMap.values.toList();
    int indexOf = values.indexOf(apiPref.value.userSubCategory ?? '');
    String value = "all";
    if (indexOf != -1) {
      value = keys.elementAt(indexOf);
    }
    if (value.equals("all")) {
      return null;
    }
    return value;
  }

  String titleBuilder(HomePageApiPref apiPref,
      [BuildContext? context, bool useChangedTitle = false]) {
    S ss = context != null ? S.of(context) : S.current;
    String? title;
    if (apiPref.value.titleChanged &&
        useChangedTitle &&
        apiPref.value.titleChanged &&
        apiPref.value.title.isNotBlank) {
      return apiPref.value.title;
    }
    switch (apiPref.contentType) {
      case HomePageType.top_anime:
        title = desiredTopAnimeOrderSS(ss)[apiPref.value.rankingType];
        break;
      case HomePageType.seasonal_anime:
        if (apiPref.value.auto) {
          var season = MalApi.getSeasonType();
          title = seasonMapCaps[season]! +
              " " +
              MalApi.getCurrentSeasonYear().toString() +
              " Anime";
        } else
          title =
              "${seasonMap[apiPref.value.seasonType]?.capitalizeAll()} ${apiPref.value.year} Anime";
        break;
      case HomePageType.sugg_anime:
        title = ss.suggested_anime;
        break;
      case HomePageType.top_manga:
        title = desiredMangaRankingMapSS(ss)[apiPref.value.mangaRanking];
        break;
      case HomePageType.forum:
        if (apiPref.value.boardName != null) {
          title = apiPref.value.boardName!;
        } else if (apiPref.value.subboardName != null) {
          title = apiPref.value.subboardName!;
        }
        break;
      case HomePageType.user_list:
        title = "My ${apiPref.value.userSubCategory} List";
        break;
      case HomePageType.news:
        title = ss.News;
        break;
      default:
    }
    return title ?? ss.No_Title;
  }

  List<HomePageApiPref> translateTitle(List<HomePageApiPref> apiPrefs,
      [BuildContext? context]) {
    return apiPrefs
        .map((e) => HomePageApiPref.fromValues(
            contentType: e.contentType,
            value: e.value..title = titleBuilder(e, context)))
        .toList();
  }
}

class ForumHelper {
  final int? boardId;
  final int? subboardId;

  ForumHelper(this.boardId, this.subboardId);
}
