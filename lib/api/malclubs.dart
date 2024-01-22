import 'package:dailyanimelist/api/credmal.dart';
import 'package:dailyanimelist/cache/cachemanager.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

import '../constant.dart';

class MalClub {
  static Future<ClubListHtml?> getClubs(
      {int page = 1, bool fromCache = true}) async {
    var url = "${CredMal.htmlEnd}clubs.php?p=$page";
    if (fromCache) {
      Map<String, dynamic>? _map =
          await CacheManager.instance.getCachedContent(url);
      var _result = _map == null ? null : ClubListHtml.fromJson(_map);
      if (_result != null) return _result;
    }

    ClubListHtml? result;

    var response = await http.get(Uri.parse(url));
    if (response == null || response.statusCode != 200) {
      logDal(response.body);
    } else {
      result = HtmlParsers.clubListHtmlFromHtml(parse(response.body));
      result.fromCache = true;
      CacheManager.instance.setCachedJson(url, result.toJson());
      result.fromCache = false;
    }
    return result;
  }
}
