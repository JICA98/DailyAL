
import 'package:dal_api/cache/shared_preferences.dart';
import 'package:dal_api/services/helpers.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:shelf/shelf.dart';

class CacheManager {
  static CacheManager instance = CacheManager();
  static SharedPreferences pref = SharedPreferences();

  Future<dynamic> getCachedContent(String url) async {
    try {
      Map<String, dynamic> map = (await pref.getMap(url) ?? {});
      return map.isEmpty ? null : map;
    } catch (e) {
      logDal(e);
    }
    return null;
  }

  Future<Map<String, dynamic>?> getCachedOrNull(
    String key, [
    bool fromCache = true,
  ]) async {
    try {
      if (!fromCache) {
        return null;
      }
      Map<String, dynamic>? cachedResult = await getCachedContent(key);
      if (cachedResult != null &&
          !(shouldUpdateContentServer(result: cachedResult, timeinHours: 1))) {
        cachedResult["url"] = key;
        cachedResult["fromCache"] = true;
        return cachedResult;
      }
    } catch (e) {
      logDal(e);
    }
    return null;
  }

  String getKey(Request request) {
    final key = request.url.path;
    String qps = request.url.query
        .replaceAll('fromCache=true', '')
        .replaceAll('&fromCache=true', '')
        .replaceAll('fromCache=false', '')
        .replaceAll('&fromCache=false', '');
    return qps.isNotBlank ? '$key?$qps' : key;
  }

  Future<Map<String, dynamic>> getCachedResult(
    Request request,
    PathMatcher matcher, {
    required Future<Map<String, dynamic>> Function() orElse,
  }) async {
    final key = getKey(request);
    if (queryParams<bool>(request, 'fromCache') ?? true) {
      final result = await CacheManager.instance.getCachedOrNull(key);
      if (result != null &&
          hasAllFields(result, matcher.mandatoryCachedFeilds)) {
        return result;
      }
    }
    final result = await orElse();
    putMetaInResult(result, key);
    CacheManager.instance.setCachedDynamic(key, result);
    return result;
  }

  void putMetaInResult(Map<String, dynamic>? data, String key) {
    if (data != null) {
      data['lastUpdated'] = DateTime.now().toString();
      data['fromCache'] = false;
      data['url'] = key;
    }
  }

  bool hasAllFields(
      Map<String, dynamic> result, List<String> mandatoryCachedFeilds) {
    for (var field in mandatoryCachedFeilds) {
      final value = result[field];
      if (value == null || (value is List && value.isEmpty)) {
        return false;
      }
    }
    return true;
  }

  Future<bool> setCachedDynamic(String url, dynamic result) async {
    try {
      return await pref.setMap(url, result);
    } catch (e) {
      logDal(e);
    }
    return false;
  }
}
