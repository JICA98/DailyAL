import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dailyanimelist/api/auth/auth.dart';
import 'package:dailyanimelist/api/credmal.dart';
import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/main.dart';
import 'package:dailyanimelist/cache/cachemanager.dart';
import 'package:dailyanimelist/user/user.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:dal_commons/dal_commons.dart' as commons;
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:retry/retry.dart';

class MalConnect {
  static const _options = RetryOptions(maxAttempts: 8);
  static const _retryDuration = const Duration(seconds: 10);

  static Future<http.Response> retryGet(
    String url,
    Map<String, String> headers,
  ) async {
    final response = await _options.retry(
      // Make a GET request
      () => http.get(Uri.parse(url), headers: headers).timeout(_retryDuration),
      // Retry on SocketException or TimeoutException
      retryIf: (e) {
        logDal('retrying... on $e');
        return e is SocketException || e is TimeoutException;
      },
    );
    return response;
  }

  static Future<http.Response> retryGetNoH(String url) => retryGet(url, Map());

  /// Standard Http Get Request with Auth Header
  static Future<dynamic> httpGetAsync(String url,
      {Map<String, String>? headers, bool usePlainOld = false}) async {
    if (headers == null) {
      headers = new Map();
    }
    if (!usePlainOld) {
      headers["X-MAL-Client-ID"] = CredMal.clientId;
      headers["Accept"] = "application/json";
      if (user.status == AuthStatus.AUTHENTICATED) {
        try {
          if (MalAuth.checkIfTokenExpired(user.authResponse!)) {
            await MalAuth.refreshToken();
          }
        } catch (e) {
          logDal(e);
        }
        headers["Authorization"] = user.authResponse!.tokenType! +
            " " +
            user.authResponse!.accessToken!;
      }
    }

    return retryGet(url, headers);
  }

  /// Standard GetContent from Cache or API
  static Future<dynamic> getContent(
    String url, {
    Map<String, String>? headers,
    bool withNoHeaders = false,
    bool includeNsfw = true,
    bool fromCache = true,
    bool retryOnFail = true,
    bool useTimeout = false,
    Duration? timeoutDuration,
    int? timeinHours,
  }) async {
    if (user?.pref?.nsfw != null && includeNsfw) {
      String op = Uri.dataFromString(url).queryParameters.isEmpty ? "?" : "&";
      url = "$url${op}nsfw=${user.pref.nsfw ? '1' : '0'}&fromCache=$fromCache";
    }

    bool timeoutCache = false;
    dynamic cachedResult;

    if (fromCache) {
      logDal("Cache ->> $url");
      Map<String, dynamic>? _result =
          await CacheManager.instance.getCachedContent(url);
      if (_result != null) {
        cachedResult = _result;
        if (!shouldUpdateContent(
          result: _result,
          timeinHours: timeinHours ?? user.pref.cacheUpdateFrequency[homeIndex],
        )) {
          _result["url"] = url;
          _result["fromCache"] = true;
          return _result;
        }
      }
    }
    logDal("API ->> $url");
    if (headers == null) {
      headers = new Map();
    }
    if (!withNoHeaders) {
      headers["X-MAL-Client-ID"] = CredMal.clientId;
      headers["Accept"] = "application/json";
      if (user.status == AuthStatus.AUTHENTICATED) {
        try {
          if (MalAuth.checkIfTokenExpired(user.authResponse!)) {
            await MalAuth.refreshToken();
          }
          headers["Authorization"] = user.authResponse!.tokenType! +
              " " +
              user.authResponse!.accessToken!;
        } catch (e) {
          logDal(e);
        }
      }
    }
    http.Response response;
    try {
      final httpRespFuture = retryOnFail
          ? retryGet(url, headers)
          : useTimeout
              ? http
                  .get(Uri.parse(url), headers: headers)
                  .timeout(timeoutDuration!, onTimeout: () {
                  timeoutCache = true;
                  return http.Response('cached', 200);
                })
              : http.get(Uri.parse(url), headers: headers);
      response = await httpRespFuture;
      if (response != null && response.statusCode == 200) {
        if (timeoutCache) {
          logDal('from timeoutCache --> $url');
          return cachedResult;
        } else {
          Map<String, dynamic> result =
              timeoutCache ? cachedResult : jsonDecode(response.body) ?? {};
          result["url"] = url;
          result["fromCache"] = false;
          CacheManager.instance.setCachedJson(url, result);
          result["lastUpdated"] = DateTime.now().toString();
          return result;
        }
      } else {
        return null;
      }
    } catch (e) {
      logDal(e);
      return null;
    }
  }

  static Future<Map<String, String>> get _headers async {
    Map<String, String> headers = Map();
    headers["X-MAL-Client-ID"] = CredMal.clientId;
    headers["Accept"] = "application/json";
    if (user.status == AuthStatus.AUTHENTICATED) {
      try {
        if (MalAuth.checkIfTokenExpired(user.authResponse!)) {
          await MalAuth.refreshToken();
        }
      } catch (e) {
        logDal(e);
      }
      headers["Authorization"] =
          user.authResponse!.tokenType! + " " + user.authResponse!.accessToken!;
    }
    return headers;
  }

  /// Standard Http Put Request with Auth Header
  static Future<http.Response> httpPutAsync(String url,
      {Map<String, String>? headers, Map<String, dynamic>? body}) async {
    if (headers == null) {
      headers = new Map();
    }
    if (body == null) {
      body = new Map();
    }
    headers["X-MAL-Client-ID"] = CredMal.clientId;
    headers["Accept"] = "application/json";
    if (user.status == AuthStatus.AUTHENTICATED) {
      try {
        if (MalAuth.checkIfTokenExpired(user.authResponse!)) {
          await MalAuth.refreshToken();
        }
      } catch (e) {
        logDal(e);
      }
      headers["Authorization"] =
          user.authResponse!.tokenType! + " " + user.authResponse!.accessToken!;
    }
    return http.put(Uri.parse(url), body: body, headers: headers);
  }

  static Future<http.Response> delete(String url) async {
    return http.delete(Uri.parse(url), headers: await _headers);
  }

  static Future<SearchResult?> htmlListPage(
    String url,
    String nextUrl,
    Function(Document) fromHtml, {
    bool fromCache = false,
    List<int> validCodes = const [200],
  }) async {
    SearchResult? result;
    logDal('Html --> $url');
    var response = await retryGet(url, Map());
    if (response == null || !validCodes.contains(response.statusCode)) {
      logDal(response.body);
    } else {
      result = fromHtml(parse(response.body));
      result!.fromCache = false;
      if (result.data != null && result.data!.isNotEmpty) {
        result.paging = Paging(next: nextUrl, previous: url);
      } else {
        result.paging = Paging();
      }
    }

    return result;
  }

  static Future<commons.Node?> htmlPage(
      String url, commons.Node Function(Document) fromHtml,
      {bool fromCache = false}) async {
    commons.Node? result;
    logDal(url);
    var response = await retryGet(url, Map());
    if (response.statusCode != 200) {
      logDal(response.body);
    } else {
      result = fromHtml(parse(response.body));
      result.fromCache = false;
    }

    return result;
  }

  static Future<T?> cachedHtml<T>(
    String url,
    T Function(Document) fromHtml,
    T Function(Map<String, dynamic>) fromJson, {
    bool fromCache = true,
    int? timeinHours,
  }) async {
    T? result;
    if (fromCache) {
      Map<String, dynamic> _result =
          await CacheManager.instance.getCachedContent(url);
      if (_result != null) {
        if (!shouldUpdateContent(
          result: _result,
          timeinHours: timeinHours ?? user.pref.cacheUpdateFrequency[homeIndex],
        )) {
          logDal("Cache ->> $url");
          _result["url"] = url;
          _result["fromCache"] = true;
          return fromJson(_result);
        }
      }
    }
    logDal("Hitting ->> $url");
    var response = await retryGet(url, Map());
    if (response == null || response.statusCode != 200) {
      logDal(response.body);
    } else {
      result = fromHtml(parse(response.body));
    }

    return result;
  }
}
