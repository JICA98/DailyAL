import 'package:dailyanimelist/api/credmal.dart';
import 'package:dailyanimelist/api/malconnect.dart';
import 'package:dal_commons/dal_commons.dart';

class MalHtml {
  MalHtml._();
  static final i = MalHtml._();

  Future<Object?> getContentHtml(
    int id, {
    String category = "anime",
  }) {
    return MalConnect.cachedHtml(
      '${CredMal.htmlEnd}$category/$id/_',
      (p0) => HtmlParsers.animeDetailedHtmlfromHtml(p0),
      (p0) => AnimeDetailedHtml.fromJson(p0),
    );
  }
}
