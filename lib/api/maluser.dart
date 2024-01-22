import 'dart:convert';

import 'package:dailyanimelist/api/credmal.dart';
import 'package:dailyanimelist/api/jikahelper.dart';
import 'package:dailyanimelist/api/malconnect.dart';
import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/main.dart';
import 'package:dailyanimelist/user/user.dart';
import 'package:dailyanimelist/widgets/search/filtermodal.dart';
import 'package:dal_commons/dal_commons.dart';

class MalUser {
  static Future<UserProf> getUserInfo(
      {List<String>? fields,
      bool fromCache = false,
      String username = "@me"}) async {
    if (username.notEquals('@me')) {
      return (await _adaptFromJikan(username, fromCache: fromCache)) ??
          UserProf();
    }
    String url = CredMal.endPoint + "users/$username";
    if (fields != null && fields.length != 0) {
      url += "?fields=" +
          fields.reduce((value, element) => (value + "," + element));
    }
    return UserProf.fromJson(await MalConnect.getContent(url,
        fromCache: fromCache, includeNsfw: false, retryOnFail: false));
  }

  static Future<UserProf?> _adaptFromJikan(
    String username, {
    bool fromCache = true,
  }) async {
    final result = ((await JikanHelper.getUserInfo(
            username: username, fromCache: fromCache))
        .data);
    if (result != null) {
      return UserProf(
        name: result.username,
        birthday: DateTime.tryParse(result.birthday ?? ''),
        gender: result.gender,
        id: result.malId,
        joinedAt: result.joined,
        location: result.location,
        picture: result.images?.jpg?.imageUrl ?? result.images?.webp?.imageUrl,
      );
    }
    return null;
  }

  static Future<MyAnimeListStatus?> updateMyAnimeListStatus(int animeId,
      {String? status,
      int? score,
      bool? isRewatching,
      int? priority,
      int? numTimesRewatched,
      int? rewatchValue,
      String? tags,
      String? comments,
      int? numEpisodesWatched,
      String? startDate,
      String? endDate}) async {
    String url =
        CredMal.endPoint + "anime/" + animeId.toString() + "/my_list_status";
    Map<String, dynamic> body = {};
    if (status != null) body["status"] = status;
    if (score != null) body["score"] = score.toString();
    if (numEpisodesWatched != null)
      body["num_watched_episodes"] = numEpisodesWatched.toString();
    if (rewatchValue != null) body["rewatch_value"] = rewatchValue.toString();
    if (isRewatching != null) body["is_rewatching"] = isRewatching.toString();
    if (numTimesRewatched != null)
      body["num_times_rewatched"] = numTimesRewatched.toString();
    if (tags != null) body["tags"] = tags;
    if (comments != null) body["comments"] = comments;
    if (startDate != null) body["start_date"] = startDate.toString();
    if (endDate != null) body["finish_date"] = endDate.toString();
    if (priority != null) body["priority"] = priority.toString();

    try {
      var response = await MalConnect.httpPutAsync(url, body: body);
      if (response.statusCode == 200 && response.body != null) {
        return MyAnimeListStatus.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      logDal(e);
    }
    return null;
  }

  static Future<MyMangaListStatus?> updateMyMangaListStatus(int mangaId,
      {String? status,
      final int? score,
      final int? numVolumesRead,
      final bool? isRereading,
      final DateTime? updatedAt,
      final int? numChaptersRead,
      final int? priority,
      int? numTimesReread,
      int? rereadValue,
      String? tags,
      String? comments,
      String? startDate,
      String? endDate}) async {
    String url =
        CredMal.endPoint + "manga/" + mangaId.toString() + "/my_list_status";
    Map<String, dynamic> body = {};
    if (status != null) body["status"] = status;
    if (score != null) body["score"] = score.toString();
    if (numVolumesRead != null)
      body["num_volumes_read"] = numVolumesRead.toString();
    if (numChaptersRead != null)
      body["num_chapters_read"] = numChaptersRead.toString();
    if (isRereading != null) body["is_rereading"] = isRereading.toString();
    if (numTimesReread != null)
      body["num_times_reread"] = numTimesReread.toString();
    if (tags != null) body["tags"] = tags;
    if (comments != null) body["comments"] = comments;
    if (startDate != null) body["start_date"] = startDate.toString();
    if (endDate != null) body["finish_date"] = endDate.toString();
    if (priority != null) body["priority"] = priority.toString();
    if (rereadValue != null) body["reread_value"] = rereadValue.toString();

    var response = await MalConnect.httpPutAsync(url, body: body);
    if (response.statusCode == 200 && response.body != null) {
      return MyMangaListStatus.fromJson(jsonDecode(response.body));
    } else {
      logDal(response.body);
    }
    return null;
  }

  /// Get Animelist using query with default values limit=100, offset=0
  static Future<SearchResult> getContentSuggestions(
      {int limit = 100,
      int offset = 0,
      String category = "anime",
      List<String>? fields,
      bool fromCache = false}) async {
    String url = CredMal.endPoint +
        "$category/suggestions?limit=" +
        limit.toString() +
        "&offset=" +
        offset.toString();

    if (fields != null && fields.length != 0) {
      url += "&fields=" +
          fields.reduce((value, element) => (value + "," + element));
    }

    return SearchResult.fromJson(
        await MalConnect.getContent(url, fromCache: fromCache));
  }

  /// Get User Anime Status
  static Future<SearchResult> getMyContentList(
      {int limit = 100,
      int offset = 0,
      String category = "anime",
      String? status = "all",
      String? sortType,
      List<String>? fields,
      String username = "@me",
      bool fromCache = false}) async {
    if (user.status != AuthStatus.AUTHENTICATED &&
        username != null &&
        username.notEquals("@me")) {
      return SearchResult();
    }
    String? fieldsString = !nullOrEmpty(fields)
        ? fields!.reduce((value, element) => (value + "," + element))
        : null;
    String url =
        "${CredMal.userEndPoint}$username/${category}list?fields=num_episodes,alternative_titles,broadcast,start_date,status,mean,num_list_users,genres,media_type,num_volumes,${fieldsString != null ? (fieldsString + ',') : ''}list_status{is_rewatching,is_rereading,num_times_rewatched,num_times_reread,priority,rewatch_value,reread_value,start_date,finish_date,tags,comments}&limit=$limit&offset=$offset";
    if (status != null) {
      url += "&status=$status";
    }
    if (sortType != null) {
      url += "&sort=$sortType";
    }

    return SearchResult.fromJson(
      await MalConnect.getContent(url, fromCache: fromCache),
      category: category,
    );
  }

  static Future<MyAnimeListStatus?> updateEpisodeCount(content,
      {int? episodes, int? add}) async {
    int _episodes = (episodes ?? 0) + (add ?? 0);
    String? watchStatus;
    if (_episodes < 0) {
      return null;
    }

    if ((content is AnimeDetailed) &&
        content?.numEpisodes != null &&
        (content.numEpisodes != 0)) {
      if (_episodes > content.numEpisodes!) {
        showToast("Maximum reached!");
        return null;
      }
      if (_episodes == content.numEpisodes) {
        watchStatus = "completed";
      }
    }

    var _content = content;
    if (content is BaseNode) {
      _content = content?.content;
    }
    var status = await MalUser.updateMyAnimeListStatus(_content.id,
        numEpisodesWatched: _episodes, status: watchStatus);
    if (status == null) {
      showToast("Couldn't Update!");
    }
    return status;
  }

  static Future<bool> deleteFromList(int id,
      {String category = "anime"}) async {
    try {
      var response = await MalConnect.delete(
          '${CredMal.endPoint}$category/$id/my_list_status');
      if (response != null && response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      logDal(e);
    }
    return false;
  }

  static Future<UserResult?> searchUser(String q,
      {Map<String, FilterOption>? filters, int offset = 0}) async {
    String url = '${CredMal.htmlEnd}users.php?cat=user&q=$q&show=$offset' +
        (JikanHelper.filterUrlBuilder(filters, category: "user") ?? '');
    return await MalConnect.htmlListPage(url, '${offset + 24}',
        (document) => HtmlParsers.userResultfromHtml(document),
        validCodes: [200, 404]) as UserResult?;
  }

  static Future<SearchResult> getAllUserList(
    String username,
    String category, {
    String? status,
    String? sortType,
    bool fromCache = true,
    String? fields,
  }) async {
    final limit = 1000;
    String url =
        '${CredMal.userEndPoint}$username/${category}list?fields=genres,media_type,start_date,broadcast,source,studios,list_status,mean${fields == null ? '' : ',${fields}'}&limit=$limit';
    if (status != null) {
      url += "&status=$status";
    }
    if (sortType != null) {
      url += "&sort=$sortType";
    }
    List<BaseNode> allNodes = [];
    final firstResult = SearchResult.fromJson(await MalConnect.getContent(url,
        retryOnFail: false, fromCache: fromCache));
    if (!nullOrEmpty(firstResult.data)) {
      allNodes.addAll(firstResult.data?.toList() ?? []);
    }
    var currentCount = firstResult.data?.length ?? 0;
    var nextUrl = firstResult.paging?.next;
    while (nextUrl != null && nextUrl.isNotBlank && currentCount == limit) {
      final nextResult = SearchResult.fromJson(await MalConnect.getContent(
          nextUrl,
          retryOnFail: false,
          fromCache: fromCache));
      nextUrl = nextResult.paging?.next;
      final list = nextResult.data?.toList() ?? [];
      allNodes.addAll(list);
      currentCount = list.length;
    }
    return SearchResult(data: allNodes);
  }
}
// {"id":7157100,"name":"OV3RKILL","gender":"male","birthday":"2022-09-29","location":"In Abyss","joined_at":"2018-04-12T06:33:38+00:00","picture":"https:\/\/api-cdn.myanimelist.net\/images\/userimages\/7157100.jpg?t=1610616600"}
// {"id":7157100,"name":"OV3RKILL","gender":"male","birthday":"2022-09-29","location":"In Abyss","joined_at":"2018-04-12T06:33:38+00:00","picture":"https:\/\/api-cdn.myanimelist.net\/images\/userimages\/7157100.jpg?t=1610616600"}
// {"id":7157100,"name":"OV3RKILL","gender":"male","birthday":"2022-09-29","location":"In Abyss","joined_at":"2018-04-12T06:33:38+00:00","picture":"https:\/\/api-cdn.myanimelist.net\/images\/userimages\/7157100.jpg?t=1610616600"}
// {"id":7157100,"name":"OV3RKILL","gender":"male","birthday":"2022-09-29","location":"In Abyss","joined_at":"2018-04-12T06:33:38+00:00","picture":"https:\/\/api-cdn.myanimelist.net\/images\/userimages\/7157100.jpg?t=1610616600","anime_statistics":{"num_items_watching":60,"num_items_completed":344,"num_items_on_hold":39,"num_items_dropped":71,"num_items_plan_to_watch":62,"num_items":576,"num_days_watched":157.29,"num_days_watching":26.4,"num_days_completed":120.93,"num_days_on_hold":3.58,"num_days_dropped":6.38,"num_days":157.29,"num_episodes":9758,"num_times_rewatched":0,"mean_score":8.09}}
// {"id":7157100,"name":"OV3RKILL","gender":"male","birthday":"2022-09-29","location":"In Abyss","joined_at":"2018-04-12T06:33:38+00:00","picture":"https:\/\/api-cdn.myanimelist.net\/images\/userimages\/7157100.jpg?t=1610616000","anime_statistics":{"num_items_watching":60,"num_items_completed":344,"num_items_on_hold":39,"num_items_dropped":71,"num_items_plan_to_watch":62,"num_items":576,"num_days_watched":157.29,"num_days_watching":26.4,"num_days_completed":120.93,"num_days_on_hold":3.58,"num_days_dropped":6.38,"num_days":157.29,"num_episodes":9758,"num_times_rewatched":0,"mean_score":8.09}}
// {"id":7157100,"name":"OV3RKILL","gender":"male","birthday":"2022-09-29","location":"In Abyss","joined_at":"2018-04-12T06:33:38+00:00","picture":"https:\/\/api-cdn.myanimelist.net\/images\/userimages\/7157100.jpg?t=1619960400","anime_statistics":{"num_items_watching":67,"num_items_completed":347,"num_items_on_hold":39,"num_items_dropped":71,"num_items_plan_to_watch":64,"num_items":588,"num_days_watched":157.71,"num_days_watching":26.48,"num_days_completed":121.28,"num_days_on_hold":3.58,"num_days_dropped":6.38,"num_days":157.72,"num_episodes":9785,"num_times_rewatched":0,"mean_score":8.1}}
