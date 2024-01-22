import 'dart:convert';

import 'package:dailyanimelist/api/credmal.dart';
import 'package:dailyanimelist/api/jikahelper.dart';
import 'package:dailyanimelist/api/malconnect.dart';
import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/enums.dart';
import 'package:dailyanimelist/main.dart';
import 'package:dailyanimelist/cache/cachemanager.dart';
import 'package:dailyanimelist/notifservice.dart';
import 'package:dailyanimelist/widgets/search/filtermodal.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:dal_commons/dal_commons.dart' as nn;
import 'package:flutter/cupertino.dart';

import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class MalForum {
  /// Get Forum Boards
  static Future<Categories> getForumBoards({bool fromCache = false}) async {
    return Categories.fromJson(await MalConnect.getContent(
        "${CredMal.endPoint}forum/boards",
        fromCache: fromCache));
  }

  static String getEndPoint(int? boardId, int? subBoardId,
      {bool useDalEndPoint = false, bool fromHtml = false}) {
    if (fromHtml) {
      return CredMal.htmlEnd;
    }
    try {
      tz.initializeTimeZones();
      if (!useDalEndPoint ||
          (boardId == null &&
              subBoardId == null &&
              tz.local.name.equals("US"))) {
        return CredMal.endPoint;
      } else {
        return '';
      }
    } catch (e) {
      return CredMal.endPoint;
    }
  }

  /// Get Forum Topics
  static Future<ForumTopics?> getForumTopics(
      {int? boardId,
      int? subBoardId,
      int? animeId,
      int? mangaId,
      int limit = 14,
      int offset = 0,
      String sort = "recent",
      String? q,
      String? topicUserName,
      String? userName,
      bool useDalEndPoint = false,
      bool fromHtml = false,
      Map<String, FilterOption>? filters,
      bool fromCache = false}) async {
    String endPoint = getEndPoint(boardId, subBoardId,
        useDalEndPoint: useDalEndPoint, fromHtml: fromHtml);
    String url = "", nextUrl = "";
    String? custom = JikanHelper.filterUrlBuilder(filters, category: "forum");
    if (fromHtml) {
      url = "${endPoint}forum/?";
      if (boardId != null) {
        url += "board=$boardId";
      }
      if (subBoardId != null) {
        url += "subboard=$subBoardId";
      }
      if (animeId != null) {
        url += "animeid=$animeId";
      }
      if (mangaId != null) {
        url += "mangaid=$mangaId";
      }
      nextUrl = "$url&show=${offset + 50}";
      url += "&show=$offset";
    } else {
      url =
          "${endPoint}forum/topics?limit=$limit&offset=$offset${custom ?? ''}";
      if (boardId != null) {
        url += "&board_id=$boardId";
      }
      if (subBoardId != null) {
        url += "&subboard_id=$subBoardId";
      }

      if (q != null) {
        url += "&q=$q";
      }

      if (topicUserName != null) {
        url += "&topic_user_name=$topicUserName";
      }

      if (userName != null) {
        url += "&user_name=$userName";
      }
    }
    logDal(url);
    if (fromHtml) {
      return getForumTopicsPage(url, nextUrl: nextUrl, fromCache: fromCache);
    } else {
      return ForumTopics.fromJson(
          await MalConnect.getContent(url, fromCache: fromCache));
    }
  }

  // Load More Forum Topics
  static Future<ForumTopics> loadMoreForumTopics({
    bool fromCache = false,
    required Paging page,
    PageDirection pageDirection = PageDirection.NEXT,
  }) async {
    return ForumTopics.fromJson(await MalConnect.getContent(
        (pageDirection == PageDirection.NEXT ? page.next : page.previous) ?? '',
        fromCache: fromCache));
  }

  // loadMoreForumPosts
  static Future<ForumTopicData> loadMoreForumPosts({
    bool fromCache = false,
    required Paging page,
    PageDirection pageDirection = PageDirection.NEXT,
  }) async {
    return ForumTopicData.fromJson(await MalConnect.getContent(
        (pageDirection == PageDirection.NEXT ? page.next : page.previous) ?? '',
        fromCache: fromCache));
  }

  ///Get forum topic detail
  static Future<ForumTopicData> getForumTopicDetail(
    int id, {
    bool fromCache = false,
    int limit = 14,
    int offset = 0,
  }) async {
    logDal("${CredMal.endPoint}forum/topic/$id?limit=$limit&offset=$offset");
    return ForumTopicData.fromJson(await MalConnect.getContent(
        "${CredMal.endPoint}forum/topic/$id?limit=$limit&offset=$offset",
        fromCache: fromCache));
  }

  static Future<ForumTopicsHtml?> getForumTopicsPage(String url,
      {bool fromCache = true, String? nextUrl}) async {
    ForumTopicsHtml? result;
    if (fromCache) {
      Map<String, dynamic>? _map =
          await CacheManager.instance.getCachedContent(url);
      ForumTopicsHtml? _result =
          _map == null ? null : ForumTopicsHtml.fromJson(_map);
      if (_result != null) return _result;
    }
    var response = await MalConnect.httpGetAsync(url, usePlainOld: true);
    if (response == null || response.statusCode != 200) {
      logDal(response.body);
    } else {
      result = HtmlParsers.forumTopicsHtmlFromHtml(parse(response.body));
      result.fromCache = true;
      if (result?.data != null && result.data!.isNotEmpty) {
        result.paging = Paging(next: nextUrl, previous: url);
      } else {
        result.paging = Paging();
      }
      CacheManager.instance.setCachedJson(url, result.toJson());
    }

    return result;
  }

  static Future<SearchResult> getUserClubs(
      {required String username, bool fromCache = false}) async {
    String url = "${CredMal.htmlEnd}profile/$username/clubs";
    SearchResult result = SearchResult();
    try {
      if (fromCache) {
        Map<String, dynamic>? _map =
            await CacheManager.instance.getCachedContent(url);
        var _result = _map == null ? null : SearchResult.fromJson(_map);
        if (_result != null &&
            !shouldUpdateContent(
                result: _result,
                timeinHours: user.pref.cacheUpdateFrequency[0])) return _result;
      }
      var response = await MalConnect.httpGetAsync(url, usePlainOld: true);
      if (response == null || response.statusCode != 200) {
        logDal(response.body);
      } else {
        result = _getClubForUserHtml(parse(response.body ?? ''), url);
        result.fromCache = true;
      }
      CacheManager.instance.setCachedJson(url, result.toJson());
    } catch (e) {}

    return result;
  }

  static SearchResult _getClubForUserHtml(Document? document, String url) {
    if (document == null) {
      return SearchResult();
    }
    SearchResult result = SearchResult();
    final horiNav = document.querySelector('#horiznav_nav');
    final oL = horiNav?.nextElementSibling;
    final li = oL?.querySelectorAll('li');
    if (!nullOrEmpty(li)) {
      result = SearchResult(
        data: li!.map((e) {
          var a = e.getElementsByTagName("a").first;
          var clubLink = a.attributes["href"];
          return BaseNode(
              content: nn.Node(
                  title: a.text,
                  id: int.tryParse(
                      clubLink?.substring(clubLink.indexOf("cid=") + 4) ??
                          '')));
        }).toList(),
        fromCache: false,
        lastUpdated: DateTime.now(),
        paging: Paging(),
        url: url,
      );
    }
    return result;
  }
}
