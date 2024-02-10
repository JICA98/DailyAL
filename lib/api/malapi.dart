import 'dart:collection';

import 'package:connectivity/connectivity.dart';
import 'package:dailyanimelist/api/credmal.dart';
import 'package:dailyanimelist/api/malconnect.dart';
import 'package:dailyanimelist/api/maluser.dart';
import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/enums.dart';
import 'package:dailyanimelist/main.dart';
import 'package:dailyanimelist/pages/settings/about.dart';
import 'package:dailyanimelist/user/anime_manga_pref.dart';
import 'package:dailyanimelist/user/user.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:dal_commons/dal_commons.dart' as commons;
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

class MalApi {
  static const weekdaysOrderMap = {
    'monday': 1,
    'tuesday': 2,
    'wednesday': 3,
    'thursday': 4,
    'friday': 5,
    'saturday': 6,
    'sunday': 7
  };

  static const listDetailedFields =
      "num_episodes,broadcast,start_date,alternative_titles,status,mean,num_list_users,genres,media_type,num_volumes";

  static const userMangaFields =
      'my_list_status{is_rewatching,is_rereading,num_times_rewatched,num_times_reread,priority,rewatch_value,reread_value,start_date,finish_date,tags,comments}';

  static const userAnimeFields =
      'my_list_status{is_rewatching,is_rereading,num_times_rewatched,num_times_reread,priority,rewatch_value,reread_value,start_date,finish_date,tags,comments}';

  /// Get Animelist/Mangalist using query with default values limit=100, offset=0, category can be 'anime', 'manga'
  static Future<SearchResult> searchForContent(String query,
      {int limit = 100,
      String category = "anime",
      int offset = 0,
      List<String>? fields,
      bool fromCache = false}) async {
    String url = CredMal.endPoint +
        category +
        "?q=" +
        query.toString() +
        "&limit=" +
        limit.toString() +
        "&offset=" +
        offset.toString();

    if (fields != null && fields.length != 0) {
      url += "&fields=" +
          fields.reduce((value, element) => (value + "," + element));
    } else {
      url +=
          "?fields=id,title,main_picture,alternative_titles,start_date,end_date,synopsis,mean,rank,popularity,num_list_users,num_scoring_users,nsfw,created_at,updated_at,media_type,status,genres,my_list_status,num_episodes,start_season,broadcast,source,average_episode_duration,rating,pictures,background,related_anime,related_manga,recommendations,studios,statistics";
    }
    return SearchResult.fromJson(
        await MalConnect.getContent(url, fromCache: fromCache),
        category: category);
  }

  /// Get Next/Previous Animelist Page
  static Future<SearchResult> getContentListPage(Paging page,
      {PageDirection pageDirection = PageDirection.NEXT,
      bool showNoMoreAuth = false,
      bool fromCache = false}) async {
    String? url =
        pageDirection == PageDirection.NEXT ? page.next : page.previous;

    if (user.status != AuthStatus.AUTHENTICATED && showNoMoreAuth) {
      return SearchResult();
    }

    return SearchResult.fromJson(
        await MalConnect.getContent(url ?? '', fromCache: fromCache));
  }

  /// Get Any Anime using Id with default values for fields
  static Future<AnimeDetailed> getAnimeDetails(int animeId,
      {List<String>? fields, bool fromCache = false}) async {
    String url = CredMal.endPoint + "anime/" + animeId.toString();

    if (fields != null && fields.length != 0) {
      url += "?fields=" +
          fields.reduce((value, element) => (value + "," + element));
    } else {
      url +=
          "?fields=id,title,main_picture,alternative_titles,ending_themes,opening_themes,start_date,end_date,synopsis,mean,rank,popularity,num_list_users,num_scoring_users,nsfw,created_at,updated_at,media_type,status,genres,my_list_status{is_rewatching,is_rereading,num_times_rewatched,num_times_reread,priority,rewatch_value,reread_value,start_date,finish_date,tags,comments},num_episodes,start_season,broadcast,source,average_episode_duration,rating,pictures,background,related_anime{my_list_status,mean,num_list_users},related_manga,recommendations{my_list_status,mean,num_list_users},studios,statistics";
    }

    return AnimeDetailed.fromJson(
        await MalConnect.getContent(url, fromCache: fromCache));
  }

  /// Get AnimeRanking using RankingType with default values limit=100, offset=0
  static Future<SearchResult> getContentRanking(dynamic rankingType,
      {int limit = 100,
      int offset = 0,
      String category = "anime",
      List<String>? fields,
      bool fromCache = false}) async {
    String url = CredMal.endPoint +
        "$category/ranking?ranking_type=" +
        (category.equals("anime")
            ? rankingMap[rankingType]
            : mangaRankingMap[rankingType])! +
        "&limit=" +
        limit.toString() +
        "&offset=" +
        offset.toString();
    if (fields != null && fields.length != 0) {
      url += "&fields=" +
          fields.reduce((value, element) => (value + "," + element));
    }

    return SearchResult.fromJson(
      await MalConnect.getContent(url, fromCache: fromCache),
      category: category,
    );
  }

  /// Get AnimeRanking using RankingType with default values limit=100, offset=0
  static Future<SearchResult> getSeasonalAnime(SeasonType season, int year,
      {int limit = 100,
      int offset = 0,
      List<String>? fields,
      SortType? sortType,
      bool fromCache = false}) async {
    String url = CredMal.endPoint +
        "anime/season/" +
        year.toString() +
        "/" +
        seasonMap[season]! +
        "?limit=" +
        limit.toString() +
        "&offset=" +
        offset.toString();

    if (sortType != null) {
      url += "&sort=" + sortMap[sortType]!;
    }
    if (fields != null && fields.length != 0) {
      url += "&fields=" +
          fields.reduce((value, element) => (value + "," + element));
    }
    var result = await MalConnect.getContent(url, fromCache: fromCache);
    return SearchResult.fromJson(result);
  }

  static Future<SearchResult> getCurrentSeason(
      {int limit = 100,
      int offset = 0,
      List<String>? fields,
      SortType? sortType,
      bool fromCache = false}) async {
    return await getSeasonalAnime(
        MalApi.getSeasonType(), MalApi.getCurrentSeasonYear(),
        fields: fields,
        fromCache: fromCache,
        limit: limit,
        offset: offset,
        sortType: sortType);
  }

  ///Helper methods
  static SeasonType getSeasonType() {
    final date = DateTime.now();
    final month = date.month;
    final day = date.day;
    final seasonType;
    if ((month == 12 && day >= 28) ||
        (month == 1) ||
        (month == 2) ||
        (month == 3 && day < 28)) {
      seasonType = SeasonType.WINTER;
    } else if ((month == 3 && day >= 28) ||
        (month == 4) ||
        (month == 5) ||
        (month == 6 && day < 28)) {
      seasonType = SeasonType.SPRING;
    } else if ((month == 6 && day >= 28) ||
        (month == 7) ||
        (month == 8) ||
        (month == 9 && day < 28)) {
      seasonType = SeasonType.SUMMER;
    } else {
      seasonType = SeasonType.FALL;
    }
    return seasonType;
  }

  static DateTime getDateTimeForSeason(SeasonType seasonType, int year) {
    switch (seasonType) {
      case SeasonType.WINTER:
        return DateTime(year, 12, 28);
      case SeasonType.SPRING:
        return DateTime(year, 3, 28);
      case SeasonType.SUMMER:
        return DateTime(year, 6, 28);
      case SeasonType.FALL:
        return DateTime(year, 9, 28);
    }
  }

  static int getCurrentSeasonYear() {
    final date = DateTime.now();
    final month = date.month;
    final day = date.day;
    if ((month == 12 && day >= 28) ||
        (month == 1) ||
        (month == 2) ||
        (month == 3 && day < 28)) {
      if (month == 12 && day >= 28) {
        return date.year + 1;
      }
      return date.year;
    } else if ((month == 3 && day >= 28) ||
        (month == 4) ||
        (month == 5) ||
        (month == 6 && day < 28)) {
      return date.year;
    } else if ((month == 6 && day >= 28) ||
        (month == 7) ||
        (month == 8) ||
        (month == 9 && day < 28)) {
      return date.year;
    } else {
      return date.year;
    }
  }

  /// Get Animelist using URL
  static Future<SearchResult> getAnimeListFromUrl(String url,
      {bool fromCache = false}) async {
    return SearchResult.fromJson(
        await MalConnect.getContent(url, fromCache: fromCache));
  }

  /// Get Any Manga using Id with default values for fields
  static Future<MangaDetailed> getMangaDetails(int mangaId,
      {List<String>? fields, bool fromCache = false}) async {
    String url = CredMal.endPoint + "manga/" + mangaId.toString();

    if (fields != null && fields.length != 0) {
      url += "?fields=" +
          fields.reduce((value, element) => (value + "," + element));
    } else {
      url +=
          "?fields=id,title,main_picture,alternative_titles,start_date,end_date,synopsis,mean,rank,popularity,num_list_users,num_scoring_users,nsfw,created_at,updated_at,media_type,status,genres,my_list_status{is_rewatching,is_rereading,num_times_rewatched,num_times_reread,priority,rewatch_value,reread_value,start_date,finish_date,tags,comments},num_volumes,num_chapters,authors{first_name,last_name},pictures,background,related_anime,related_manga{my_list_status,mean,num_list_users},recommendations{my_list_status,mean,num_list_users},serialization{name}";
    }

    return MangaDetailed.fromJson(
        await MalConnect.getContent(url, fromCache: fromCache));
  }

  static Future<SearchResult?> searchAllCategories(String query) async {
    return await MalConnect.htmlListPage(
      CredMal.htmlEnd + "search/all?q=$query&cat=all",
      '',
      (doc) => HtmlParsers.allSearchResultFromHtml(doc),
    );
  }

  static Future<Featured> getFeaturedArticle(int id, String? title,
      {String category = "featured"}) async {
    String url = "${CredMal.htmlEnd}$category/$id";
    if (category.equals("featured")) {
      url = "$url/${title?.getFormattedTitleForHtml()}";
    }
    return await MalConnect.htmlPage(url,
            (doc) => HtmlParsers.featuredFromHtml(doc, id, category: category))
        as Featured;
  }

  static Future<SearchResult?> searchClubs(String query, [int page = 1]) async {
    return await MalConnect.htmlListPage(
        '${CredMal.htmlEnd}clubs.php?cat=club&catid=0&q=$query&action=find&p=$page',
        '${page + 1}',
        (doc) => HtmlParsers.clubListHtmlFromHtml(doc));
  }

  static Future<List<List<commons.Node>>> getSchedule({
    SeasonType? seasonType,
    int? currentYear,
    bool fromCache = true,
  }) async {
    seasonType ??= MalApi.getSeasonType();
    currentYear ??= MalApi.getCurrentSeasonYear();
    var seasonResult = await MalApi.getSeasonalAnime(
      seasonType,
      currentYear,
      fields: [
        "my_list_status",
        "broadcast",
        "status",
        "mean",
        "num_list_users"
      ],
      sortType: SortType.AnimeScore,
      fromCache: fromCache,
      limit: 500,
    );
    var result = SplayTreeMap<int?, List<commons.Node>>();
    if (seasonResult.data != null && seasonResult.data!.isNotEmpty) {
      for (var baseNode in seasonResult.data!) {
        var item = baseNode.content;
        if (item?.broadcast?.dayOfTheWeek != null &&
            item?.broadcast?.startTime != null &&
            item?.broadcast!.dayOfTheWeek != 'other') {
          final broadcast = item!.broadcast;
          final dateTime = broadcast != null ? getAiringDate(broadcast) : null;
          final adjustedTime = dateTime != null
              ? getAdjustedTime(dateTime, DateTime.now())
              : null;
          final weekday = adjustedTime?.weekday ??
              weekdaysOrderMap[dateTime?.weekday ?? broadcast!.dayOfTheWeek];
          if (result[weekday] == null) {
            result[weekday] = [baseNode.content!];
          } else {
            result[weekday]?.add(baseNode.content!);
          }
        } else {
          result[8] = [...(result[8] ?? []), baseNode.content!];
        }
      }
    }
    for (int i = 1; i <= 8; i++) {
      if (result[i] == null) {
        result[i] = [];
      }
    }
    return result.values.toList();
  }

  static DateTime? getAiringDate(Broadcast broadcast) {
    final nowDate = DateTime.now();
    try {
      final weekday = weekdaysOrderMap[broadcast.dayOfTheWeek];
      if (weekday != null) {
        final timeSplit = broadcast.startTime!.split(":");
        final hours = int.tryParse(timeSplit[0]);
        final mins = int.tryParse(timeSplit[1]);
        if (hours != null && mins != null)
          return nowDate.nextDate(weekday).add(Duration(
                hours: hours - 9,
                minutes: mins,
              ));
      }
    } catch (e) {
      logDal(e);
    }
    return null;
  }

  static timeZoneName(DateTime datetime) {
    return switch (user.pref.animeMangaPagePreferences.timezonePref) {
      TimezonePref.jst => 'JST',
      TimezonePref.utc => 'UTC',
      TimezonePref.local => datetime.timeZoneName,
    };
  }

  static String? getFormattedAiringDate(
    Broadcast broadcast, [
    DateFormat? dateFormat,
  ]) {
    try {
      final airingDate = getAiringDate(broadcast);
      dateFormat ??= DateFormat('h:mm a E');
      final nowDate = DateTime.now();
      if (airingDate != null) {
        final formatted =
            dateFormat.format(getAdjustedTime(airingDate, nowDate));
        return '$formatted (${timeZoneName(nowDate)})';
      }
    } catch (e) {
      logDal(e);
    }
    return null;
  }

  static DateTime getAdjustedTime(DateTime airingDate, DateTime nowDate) {
    return switch (user.pref.animeMangaPagePreferences.timezonePref) {
      TimezonePref.jst => airingDate.add(Duration(hours: 9)),
      TimezonePref.utc => airingDate,
      TimezonePref.local => airingDate.add(Duration(
          minutes: nowDate.timeZoneOffset.inMinutes,
        ))
    };
  }

  static Future<bool> isUnderMaintenance() async {
    if (!await _checkIfDeviceIsConnected()) {
      return false;
    }
    if (user.status == AuthStatus.AUTHENTICATED) {
      try {
        await MalUser.getUserInfo();
        return false;
      } catch (e) {
        return true;
      }
    } else {
      try {
        final animeDetails =
            await MalApi.getAnimeDetails(21, fields: ['title']);
        if (animeDetails.title == null) {
          return true;
        }
        return false;
      } catch (e) {
        return true;
      }
    }
  }

  static Future<bool> _checkIfDeviceIsConnected() async {
    try {
      final connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi) {
        await Dio().get(githubApiLink);
        return true;
      }
    } catch (e) {}
    return false;
  }
}

// curl 'https://api.myanimelist.net/v2/manga/2?fields=id,title,main_picture,alternative_titles,start_date,end_date,synopsis,mean,rank,popularity,num_list_users,num_scoring_users,nsfw,created_at,updated_at,media_type,status,genres,my_list_status,num_volumes,num_chapters,authors{first_name,last_name},pictures,background,related_anime,related_manga,recommendations,serialization{name}' \
