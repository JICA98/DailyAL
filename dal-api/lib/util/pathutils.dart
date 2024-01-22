import 'package:dal_commons/dal_commons.dart';
import 'package:html/dom.dart';

class PathUtils {
  static int? getId(Uri uri) {
    int? id;
    if (uri.pathSegments.isNotEmpty) {
      switch (uri.pathSegments.first) {
        case 'anime':
        case 'manga':
        case 'news':
        case 'featured':
        case 'character':
        case 'people':
          id = int.tryParse(uri.pathSegments[1]);
          break;
        case 'forum':
          id = int.tryParse(uri.queryParameters["topicid"] ?? "");
          break;
        default:
          break;
      }
    }
    return id;
  }

  static int? getIdUrl(String url) {
    return getId(Uri.parse(url));
  }

  static int? getIdAnchor(Element anchor) {
    return getIdUrl(anchor.querySelector('a')?.attributes['href'] ?? '');
  }

  static String? getTitleAnchor(Element anchor) {
    return getTitle(anchor.querySelector('a')?.attributes['href'] ?? '');
  }

  static String? getTitle(String? url) {
    Uri? uri = Uri.tryParse(url ?? '');
    if (uri?.pathSegments != null && uri!.pathSegments.isNotEmpty) {
      switch (uri.pathSegments.first) {
        case 'anime':
        case 'manga':
        case 'news':
        case 'featured':
        case 'character':
        case 'people':
          return uri.pathSegments[2].standardize();
        default:
          break;
      }
    }
    return null;
  }
}
