import 'package:dal_commons/src/constants/constant.dart';
import 'package:html/dom.dart';

class PathUtils {
  static int? getId(Uri? uri) {
    int? id;
    if (uri == null) return null;
    if (uri.pathSegments.isNotEmpty) {
      switch (uri.pathSegments.first) {
        case 'anime':
        case 'manga':
        case 'news':
        case 'featured':
        case 'character':
        case 'stacks':
        case 'people':
          switch (uri.pathSegments.tryAt(1)) {
            case 'genre':
              id = int.tryParse(uri.pathSegments.tryAt(2) ?? '');
              break;
          }
          id ??= int.tryParse(uri.pathSegments.tryAt(1) ?? "");
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

  static int? getIdUrl(String? url) {
    return url != null ? getId(Uri.tryParse(url)) : null;
  }

  static int? getIdAnchor(Element? element) {
    if (element == null) return null;
    return getIdUrl(_getHref(_getAnchor(element)));
  }

  static String? getCategoryAnchor(Element? element) {
    if (element == null) return null;
    return getCategory(_getHref(_getAnchor(element)));
  }

  static String? getTitleAnchor(Element? element) {
    if (element == null) return null;
    return getTitle(_getHref(_getAnchor(element)));
  }

  static Element? _getAnchor(Element? element) {
    if (element == null) return null;
    if ((element.localName ?? '').equals('a')) {
      return element;
    } else {
      return element.querySelector('a');
    }
  }

  static String? _getHref(Element? anchor) {
    if (anchor == null) return null;
    return (anchor.attributes ?? {})['href'];
  }

  static String? getTitle(String? url) {
    Uri? uri = Uri.tryParse(url ?? '');
    if (uri == null) return null;
    if (uri.pathSegments.isNotEmpty) {
      switch (uri.pathSegments.first) {
        case 'anime':
        case 'manga':
        case 'news':
        case 'featured':
        case 'character':
        case 'people':
          return uri.pathSegments[2].standardize();
        case 'profile':
          return uri.pathSegments.tryAt(1);
        default:
          break;
      }
    }
    return null;
  }

  static String? getCategory(String? getHref) {
    if (getHref == null) return null;
    Uri? uri = Uri.tryParse(getHref);
    if (uri == null) return null;
    if (uri.pathSegments.isNotEmpty) {
      switch (uri.pathSegments.first) {
        case 'anime':
        case 'manga':
        case 'news':
        case 'featured':
        case 'character':
        case 'stacks':
        case 'people':
        case 'forum':
          return uri.pathSegments.first;
        default:
          break;
      }
    }
    return null;
  }
}
