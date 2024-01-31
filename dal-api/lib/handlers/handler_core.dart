import 'package:dal_api/cache/cache_manager.dart';
import 'package:dal_api/handlers/environemt.dart';
import 'package:dal_commons/commons.dart';
import 'package:html/dom.dart';
import 'package:shelf/shelf.dart';

import '../client/http_connect.dart';
import '../client/request_payload/request_payload.dart';
import '../services/helpers.dart';

class HandlerCore {
  late List<PathMatcher> _pathMatchers;

  _noSuchPath(String path) =>
      throw ArgumentError('No such path: \'$path\' was found!');

  HandlerCore() {
    _pathMatchers = [
      PathMatcher('anime/*id', _handleAnime, ['api']),
      PathMatcher('manga/*id', _handleManga, ['api']),
      PathMatcher('news', _handleNews, ['data']),
      PathMatcher('featured', _handleFeatured, ['data']),
      PathMatcher('reviews', _handleReviews),
      PathMatcher('content/characters', _handleAllCharacters, ['data']),
      PathMatcher('character/*id', _handleCharacterInfo, ['data']),
      PathMatcher('character/*id/pics', _handleCharacterPics),
      PathMatcher('characters', _handleCharacterHome),
      PathMatcher('people/*id', _handlePeopleInfo, ['data']),
      PathMatcher('people/*id/pics', _handlePeoplePics),
      PathMatcher('people', _handlePeopleHome),
      PathMatcher('recommendations', _handleRecommendations),
      PathMatcher('stacks/*stackType', _handleContentStackDetailed),
      PathMatcher('magazines', _handleMagazines, ['data']),
      PathMatcher('studios', _handleStudios, ['data']),
      PathMatcher('schedules', _handleSchedules, ['data']),
      PathMatcher('users/about', _handleUserAbout, ['data']),
      PathMatcher('users/friends', _handleUserFriends, ['data']),
      PathMatcher('users/history', _handleUserHistory, ['data']),
      PathMatcher('clubs', _handleClubs, ['data']),
      PathMatcher('clubs/type', _handleClubViewAll, ['data']),
      PathMatcher('genres', _handleGenres, ['data']),
      PathMatcher('favicon.ico', _handleFavicon, ['data']),
    ];
  }

  Future<Map<String, dynamic>?> handleRequestAsJson(Request request) async {
    try {
      logDal(request.method);
      logDal(request.url);
      final uri = request.url;
      final url = uri.path;
      PathMatcher matcher = _pathMatchers.firstWhere(
        (matcher) => matcher.hasMatch(url),
        orElse: () => _noSuchPath(uri.path),
      );
      return await CacheManager.instance.getCachedResult(
        request,
        matcher,
        orElse: () => matcher.handler(matcher, request),
      );
    } catch (e) {
      logDal(e);
      return {'error': true};
    }
  }

  Future<Response> handleRequest(Request request) async {
    final json = await handleRequestAsJson(request);
    if (json != null && (json['error'] ?? false)) {
      return Response.internalServerError(body: 'Internal Server Error');
    } else {
      return okResponse(json ?? {});
    }
  }

  Future<dynamic> handleLambdaEvent(context, event) async {
    dalLogConfig.debugMode = false;
    logDal("event: $event");
    if (event is RequestPaylodEvent) {
      RequestPayload payload = RequestPayload.fromJson(event.json);
      logDal(payload);
      final uri = Uri.parse(
          'http://localhost:8080${payload.rawPath}?${payload.rawQueryString}');
      logDal(uri);
      return await handleRequestAsJson(Request('GET', uri));
    } else {
      return 'FAILED';
    }
  }

  Future<Map<String, dynamic>> _handleCharacterPics(
          PathMatcher path, Request request) =>
      _handlePics(ContentType.character, path, request);

  Future<Map<String, dynamic>> _handlePeoplePics(
          PathMatcher path, Request request) =>
      _handlePics(ContentType.people, path, request);

  Future<Map<String, dynamic>> _handleAnime(
          PathMatcher path, Request request) =>
      _handleContent(ContentType.anime, path, request);

  Future<Map<String, dynamic>> _handleManga(
          PathMatcher path, Request request) =>
      _handleContent(ContentType.manga, path, request);

  Future<Map<String, dynamic>> _handleNews(PathMatcher path, Request request) =>
      _handleNewsAndFeatured(ContentType.news, path, request);

  Future<Map<String, dynamic>> _handleFeatured(
          PathMatcher path, Request request) =>
      _handleNewsAndFeatured(ContentType.featured, path, request);

  Future<Map<String, dynamic>> _handleCharacterInfo(
          PathMatcher path, Request request) =>
      _handleCharacterPeopleInfo(ContentType.characters, path, request);

  Future<Map<String, dynamic>> _handlePeopleInfo(
          PathMatcher path, Request request) =>
      _handleCharacterPeopleInfo(ContentType.people, path, request);

  Future<Map<String, dynamic>> _handleMagazines(
          PathMatcher path, Request request) =>
      _handleContentProducer(ContentType.manga, path, request);

  Future<Map<String, dynamic>> _handleStudios(
          PathMatcher path, Request request) =>
      _handleContentProducer(ContentType.anime, path, request);

  Future<Map<String, dynamic>> _handleCharacterHome(
          PathMatcher path, Request request) =>
      _handlePeopleCharacterHome(ContentType.character, path, request);

  Future<Map<String, dynamic>> _handlePeopleHome(
          PathMatcher path, Request request) =>
      _handlePeopleCharacterHome(ContentType.people, path, request);

  Future<Map<String, dynamic>> _handleContentProducer(
      ContentType type, PathMatcher path, Request request) async {
    return {
      'data': await HttpConnect.htmlPage<Map<String, String>>(
          '${Constants.htmlEnd}${type.name}.php',
          (p0) => HtmlParsers.parseMagazines(p0, type))
    };
  }

  Future<Map<String, dynamic>> _handleContent(
      ContentType type, PathMatcher path, Request request) async {
    final id = path.pathParam<int>(request.url.path);
    final htmlOnly = queryParams(request, 'htmlOnly', false)!;
    if (htmlOnly) {
      return {
        'url': request.url.path,
        'fromCache': false,
        'html': await _gethtmlContent(type, id)
      };
    } else {
      final results = await Future.wait([
        HttpConnect.retryGetChecked(
          '${Constants.endPoint}${type.name}/$id${type == ContentType.anime ? animeFields : mangaFields}',
          {Constants.clientHeader: Environment.i.malClientId ?? ''},
        ),
        _gethtmlContent(type, id)
      ]);
      return {
        'url': request.url.path,
        'api': results[0],
        'html': results[1],
        'fromCache': false,
      };
    }
  }

  Future<Map<String, dynamic>> _gethtmlContent(ContentType type, int id) async {
    final results = await Future.wait([
      HttpConnect.htmlPage<Map<String, dynamic>>(
        '${Constants.htmlEnd}${type.name}/$id/_',
        (p0) => HtmlParsers.animeDetailedHtmlfromHtml(p0, type: type),
      ),
      HttpConnect.htmlPage<List<Map<String, dynamic>>>(
        '${Constants.htmlEnd}${type.name}/$id/_/reviews',
        (p0) => (p0.querySelectorAll('.review-element') ?? [])
            .map((e) => HtmlParsers.animeReviewHtmlfromHtml(e)?.toJson())
            .where((element) => element != null)
            .map((e) => e!)
            .toList(),
      ),
    ]);
    final htmlDetailed = results[0];
    if (htmlDetailed != null && htmlDetailed is Map<String, dynamic>) {
      htmlDetailed['animeReviewList'] = results[1];
    }
    return htmlDetailed as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> _handlePics(
    ContentType type,
    PathMatcher path,
    Request request,
  ) async {
    final id = path.pathParam<int>(request.url.path);
    final result = await HttpConnect.htmlPage<List<String>>(
      '${Constants.htmlEnd}${type.name}/$id/Brook/pics',
      (p0) =>
          p0
              .querySelector('.mb8')
              ?.nextElementSibling
              ?.querySelectorAll('td')
              .map((e) => HtmlParsers.parseCharacterPage(e))
              .where((e) => e != null)
              .map((e) => e!)
              .toList() ??
          [],
    );
    return {'pictures': result};
  }

  Future<Map<String, dynamic>> _handleNewsAndFeatured(
    ContentType type,
    PathMatcher path,
    Request request,
  ) async {
    int page = queryParams<int>(request, 'page') ?? 1;
    String containerName =
        queryParams<String>(request, 'containerName') ?? "news-list";
    String url = _buildNewsFeaturedUrl(page, type, request);
    final result = await HttpConnect.htmlPage<Map<String, dynamic>>(
      url,
      (doc) => HtmlParsers.featuredResultFromHtml(
        doc,
        category: type.name,
        containerName: containerName,
      ),
    );
    if (result != null) {
      result['paging'] = Paging(next: '${page + 1}', previous: url);
    }
    return result as Map<String, dynamic>;
  }

  String _buildNewsFeaturedUrl(int page, ContentType type, Request request) {
    String? query = queryParams<String>(request, 'query');
    String? tag = queryParams<String>(request, 'tag');
    String category = type.name;
    String additonalCategory =
        queryParams<String>(request, 'additonalCategory') ??
            ContentType.anime.name;
    int? id = queryParams<int>(request, 'id');

    String url;
    if (id != null) {
      url = '${Constants.htmlEnd}$additonalCategory/$id/null/$category?p=$page';
    } else {
      url = "${Constants.htmlEnd}$category";
      if (tag != null) {
        if (tag.equalsIgnoreCase("all")) {
          url = "$url?p=$page";
        } else {
          url =
              "$url/tag/${tag.toLowerCase().getFormattedTitleForHtml(category.equals('news'))}?p=$page";
        }
      } else {
        url = "$url/search?q=$query&cat=$category&p=$page";
      }
    }

    return url;
  }

  Future<Map<String, dynamic>> _handlePeopleCharacterHome(
    ContentType type,
    PathMatcher path,
    Request request,
  ) async {
    final page = (queryParams(request, 'page', 1)! - 1).abs();
    return await HttpConnect.htmlPage(
      '${Constants.htmlEnd}${type.name}.php?limit=${page * 50}',
      (p0) => HtmlParsers.parseCharacterPeopleHome(p0, type),
    );
  }

  Future<Map<String, dynamic>> _handleCharacterPeopleInfo(
    ContentType type,
    PathMatcher path,
    Request request,
  ) async {
    final id = path.pathParam<int>(request.url.path);
    return await HttpConnect.retryGetChecked(
            '${Constants.jikanV4}${type.name}/$id/full', {})
        as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> _handleReviews(
    PathMatcher p1,
    Request request,
  ) async {
    final category =
        queryParams<String?>(request, 'category', ContentType.anime.name);
    final categoryId = queryParams<int?>(request, 'id');
    final page = queryParams(request, 'page', 1);
    final url = categoryId == null
        ? '${Constants.htmlEnd}reviews.php?t=$category&p=$page'
        : '${Constants.htmlEnd}$category/$categoryId/_/reviews?sort=mostvoted&p=$page';
    return await HttpConnect.htmlPage<Map<String, dynamic>>(
      url,
      (p0) => HtmlParsers.getReviews(p0),
    ) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> _handleRecommendations(
    PathMatcher p1,
    Request request,
  ) async {
    final category =
        queryParams<String>(request, 'category', ContentType.anime.name);
    final categoryId = queryParams<int>(request, 'id');
    final page = (queryParams(request, 'page', 1)! - 1).abs();
    final url = categoryId == null
        ? '${Constants.htmlEnd}recommendations.php?t=$category&s=recentrecs&show=${page * 50}'
        : '${Constants.htmlEnd}$category/$categoryId/_/userrecs';
    return await HttpConnect.htmlPage<Map<String, dynamic>>(
      url,
      (p0) => HtmlParsers.getRecommendations(p0, categoryId == null),
    ) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> _handleContentStackDetailed(
      PathMatcher p1, Request p2) async {
    final stackType =
        interestStackTypeMap.tryAt(p1.pathParam<String>(p2.url.path));
    String url;
    Map<String, String>? headers;
    dynamic Function(Document) fromHtml;
    switch (stackType) {
      case InterestStackType.detailed:
        final int? id = queryParams<int>(p2, 'id');
        if (id == null) {
          continue nullCase;
        }
        url = '${Constants.htmlEnd}stacks/$id?view_style=seasonal';
        headers = {'Accept-Language': 'en-US,en'};
        fromHtml =
            (p0) => HtmlParsers.interestStackDetailedFromHtml(p0, id)?.toJson();
        break;
      case InterestStackType.content:
        final String? category = queryParams(p2, 'category');
        final int? categoryId = queryParams(p2, 'categoryId');
        final int offset = (queryParams(p2, 'page', 1)! - 1) * 20;
        if (category == null || categoryId == null) {
          continue nullCase;
        }
        url =
            '${Constants.htmlEnd}$category/$categoryId/_/stacks?offset=$offset';
        fromHtml = (p0) => Map<String, dynamic>.of(
            {'data': HtmlParsers.interestStackListContentFromHtml(p0)});
        break;
      case InterestStackType.search:
        url = '${Constants.htmlEnd}stacks/search?${buildQueryParams({
              'type': queryParams<String>(p2, 'type'),
              'q': queryParams<String>(p2, 'query'),
              'p': queryParams(p2, 'page', 1),
            })}';
        fromHtml = (p0) => Map<String, dynamic>.of(
            {'data': HtmlParsers.interestStackListContentFromHtml(p0, false)});
        break;
      nullCase:
      default:
        return {};
    }
    return await HttpConnect.htmlPage(
      url,
      fromHtml,
      headers: headers,
    );
  }

  Future<Map<String, dynamic>> _handleSchedules(
      PathMatcher path, Request request) async {
    final type = queryParams(request, 'type', 'all');
    var currSeason = _getSeason();
    final year = queryParams(request, 'year', currSeason.year);
    final season = SeasonType.values.asNameMap()[
        queryParams(request, 'season', currSeason.seasonType.name)];
    return {
      'data': await HttpConnect.htmlPage(
        'https://www.livechart.me/${season?.name}-$year/$type',
        (p0) => HtmlParsers.parseLiveChartSchedule(p0),
      )
    };
  }

  Future<Map<String, dynamic>> _handleUserAbout(
      PathMatcher path, Request request) async {
    var username = queryParams(request, 'username', '');
    return {
      'data': await HttpConnect.htmlPage(
        '${Constants.htmlEnd}profile/$username',
        (p0) => HtmlParsers.parseUserAboutPage(p0),
      )
    };
  }

  Future<Map<String, dynamic>> _handleAllCharacters(
      PathMatcher path, Request request) async {
    final type = queryParams(request, 'category', 'anime')!;
    final id = queryParams(request, 'id', 'id');
    return {
      'data': await HttpConnect.htmlPage(
        '${Constants.htmlEnd}$type/$id/_/characters',
        (p0) => HtmlParsers.parseCharacterAllPage(p0, type),
      )
    };
  }

  Future<Map<String, dynamic>> _handleUserFriends(
      PathMatcher p1, Request p2) async {
    final username = queryParams(p2, 'username', '');
    return {
      'data': await HttpConnect.htmlPage(
        '${Constants.htmlEnd}profile/$username/friends',
        (p0) => HtmlParsers.parseUserFriends(p0),
      )
    };
  }

  Future<Map<String, dynamic>> _handleUserHistory(
      PathMatcher p1, Request p2) async {
    final username = queryParams(p2, 'username', '');
    final type = queryParams(p2, 'type', '');
    final url = '${Constants.htmlEnd}history/$username/$type';
    return {
      'data': await HttpConnect.htmlPage(
        url,
        (p0) => HtmlParsers.parseUserHistory(p0, type),
      )
    };
  }

  Future<Map<String, dynamic>> _handleClubs(PathMatcher p1, Request p2) async {
    final id = queryParams<int>(p2, 'id');
    return {
      'data': await HttpConnect.htmlPage(
        '${Constants.htmlEnd}clubs.php?cid=$id',
        (p0) => HtmlParsers.parseClubPage(p0),
      )
    };
  }

  Future<Map<String, dynamic>> _handleFavicon(
      PathMatcher p1, Request p2) async {
    return {
      'data': 'favicon.ico',
    };
  }

  static const typePageMap = {
    'members': 36,
    'forum': 50,
    'comments': 20,
  };

  Future<Map<String, dynamic>> _handleClubViewAll(
      PathMatcher p1, Request p2) async {
    final type = queryParams<String>(p2, 'type')!;
    final id = queryParams<int>(p2, 'id');
    final offset = queryParams<int>(p2, 'offset', 0);
    final url = type.equals('forum')
        ? '${Constants.htmlEnd}forum/?clubid=$id&show=$offset'
        : '${Constants.htmlEnd}clubs.php?action=view&t=$type&id=$id&show=$offset';
    return {
      'data': await HttpConnect.htmlPage(
        url,
        (p0) => HtmlParsers.parseClubPageViewAll(p0, type),
      )
    };
  }

  Future<Map<String, dynamic>> _handleGenres(PathMatcher p1, Request p2) async {
    final String category = queryParams(p2, 'category', 'anime')!;
    return {
      'data': await HttpConnect.htmlPage(
        '${Constants.htmlEnd}$category.php',
        (p0) => HtmlParsers.parseGenres(p0, category),
      )
    };
  }
}

enum SeasonType {
  ///January, February, March,
  winter,

  /// April, May, June
  spring,

  /// July, August, September
  summer,

  /// October, November, December
  fall
}

class _SeasonYear {
  final int year;
  final SeasonType seasonType;

  _SeasonYear(this.year, this.seasonType);
}

_SeasonYear _getSeason() {
  final date = DateTime.now();
  final month = date.month;
  final day = date.day;
  var year = date.year;
  final SeasonType seasonType;
  if ((month == 12 && day >= 28) ||
      (month == 1) ||
      (month == 2) ||
      (month == 3 && day < 28)) {
    seasonType = SeasonType.winter;
    if (month == 12 && day >= 28) {
      year += 1;
    }
  } else if ((month == 3 && day >= 28) ||
      (month == 4) ||
      (month == 5) ||
      (month == 6 && day < 28)) {
    seasonType = SeasonType.spring;
  } else if ((month == 6 && day >= 28) ||
      (month == 7) ||
      (month == 8) ||
      (month == 9 && day < 28)) {
    seasonType = SeasonType.summer;
  } else {
    seasonType = SeasonType.fall;
  }
  return _SeasonYear(year, seasonType);
}
