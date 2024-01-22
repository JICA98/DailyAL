import 'package:dailyanimelist/api/auth/auth.dart';
import 'package:dailyanimelist/api/credmal.dart';
import 'package:dailyanimelist/main.dart';
import 'package:dailyanimelist/pages/userpage.dart';
import 'package:dailyanimelist/screens/characterscreen.dart';
import 'package:dailyanimelist/screens/contentdetailedscreen.dart';
import 'package:dailyanimelist/screens/featurescreen.dart';
import 'package:dailyanimelist/screens/forumposts.dart';
import 'package:dailyanimelist/screens/forumtopicsscreen.dart';
import 'package:dailyanimelist/screens/generalsearchscreen.dart';
import 'package:dailyanimelist/screens/homescreen.dart';
import 'package:dailyanimelist/screens/intro/introscreen.dart';
import 'package:dailyanimelist/screens/user_profile.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:flutter/widgets.dart';

import '../constant.dart';

enum DalSubType { relations, reviews, userrecs, characters, forum, stacks }

class DalNode {
  final String category;
  final int? id;
  final int? topicid;
  final int? boardid;
  final int? subBoardid;
  final String? title;
  final DalSubType? dalSubType;
  final Map<String, dynamic>? queryParams;
  DalNode({
    required this.category,
    this.id,
    this.topicid,
    this.boardid,
    this.subBoardid,
    this.title,
    this.dalSubType,
    this.queryParams,
  });

  String toUrl() {
    return DalPathUtils.browserUrl(this);
  }
}

class DalPathUtils {
  static String browserUrl(DalNode node) {
    String url = CredMal.htmlEnd;
    String category = node.category;
    switch (category) {
      case 'character':
      case 'people':
      case 'anime':
      case 'manga':
        if (node.dalSubType != null) {
          switch (node.dalSubType) {
            case DalSubType.relations:
              url =
                  '${CredMal.dbChangesEnd}?${buildQueryParams(node.queryParams!..['t'] = DalSubType.relations.name)}';
              break;
            case DalSubType.stacks:
            case DalSubType.forum:
            case DalSubType.characters:
            case DalSubType.userrecs:
            case DalSubType.reviews:
              url += '${node.category}/${node.id}/_/${node.dalSubType!.name}';
              break;
            default:
          }
        } else {
          url += '$category/${node.id}/${node.title ?? "_"}';
        }
        break;
      case 'stacks':
        url += 'stacks/${node.id}';
        break;
      case 'forum':
        url += '';
        break;
      case 'news':
      case 'featured':
        url += '';
        break;
      case 'search':
        url += '';
        break;
    }
    return url;
  }

  static void launchNodeInBrowser(DalNode node, BuildContext context) {
    launchURLWithConfirmation(browserUrl(node), context: context);
  }

  static Future<Widget?> handleUri(Uri? uri, [BuildContext? context]) async {
    Widget? widget;
    if (uri != null) {
      switch (uri.pathSegments.tryAt()) {
        case 'anime':
        case 'manga':
          widget = _contentDetailed(uri);
          break;
        case 'forum':
          widget = _forumPage(uri);
          break;
        case 'news':
        case 'featured':
          widget = _handleNewsFeatured(uri);
          break;
        case 'character':
        case 'people':
          widget = _handleCharacterPeople(uri);
          break;
        case 'search':
          widget = GeneralSearchScreen(searchQuery: uri.pathSegments[1]);
          break;
        case 'profile':
          final username = uri.pathSegments.tryAt(1);
          if (username != null && context != null) {
            widget = UserProfilePage(username: username, isSelf: false);
          }
        default:
          if (await MalAuth.checkIfSignIn(uri)) {
            if (user.pref.firstTime) {
              return IntroScreen(index: 1);
            } else {
              return HomeScreen(pageIndex: userIndex);
            }
          } else {
            showToast("Couldn't handle Url");
          }
          break;
      }
    }
    return widget;
  }

  static Future<void> navigateByNode(Node node) async {
    await Navigator.pushNamed(
      MyApp.navigatorKey.currentContext!,
      '${node.nodeCategory}/${node.id}/${node.title}',
      arguments: [true],
    );
  }

  static int? getId(Uri? uri) {
    int? id;
    if (uri?.pathSegments != null && uri!.pathSegments.isNotEmpty) {
      switch (uri.pathSegments.first) {
        case 'anime':
        case 'manga':
        case 'news':
        case 'featured':
        case 'character':
        case 'people':
          id = int.tryParse(uri.pathSegments[1] ?? "");
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

  static Widget? _contentDetailed(Uri uri) {
    try {
      return ContentDetailedScreen(
        category: uri.pathSegments.first,
        id: int.tryParse(uri.pathSegments[1]),
        node: Node(
            id: int.tryParse(uri.pathSegments[1]), title: uri.pathSegments[2]),
      );
    } catch (e) {
      logDal(e);
    }
    return null;
  }

  static Widget _forumPage(Uri uri) {
    Widget widget = HomeScreen(pageIndex: forumIndex);
    try {
      var topicid = int.tryParse(uri.queryParameters["topicid"] ?? "");
      var boardid = int.tryParse((uri.queryParameters["board"] ?? ""));
      var subBoardid = int.tryParse((uri.queryParameters["subboard"] ?? ""));
      if (topicid != null) {
        widget = ForumPostsScreen(topic: ForumTopicsData(id: topicid));
      } else if (boardid != null) {
        widget = ForumTopicsScreen(boardId: boardid);
      } else if (subBoardid != null) {
        widget = ForumTopicsScreen(subBoardId: subBoardid);
      }
    } catch (e) {
      logDal(e);
    }
    return widget;
  }

  static Widget _handleNewsFeatured(Uri uri) {
    Widget widget = HomeScreen(pageIndex: exploreIndex);
    try {
      var _id = int.tryParse(uri.pathSegments[1] ?? "");
      if (_id != null) {
        widget = FeaturedScreen(
          category: uri.pathSegments.first,
          id: _id,
        );
      }
    } catch (e) {
      logDal(e);
    }
    return widget;
  }

  static Widget? _handleCharacterPeople(Uri uri) {
    Widget? widget;
    try {
      var _id = int.tryParse(uri.pathSegments[1] ?? "");
      if (_id != null) {
        widget = CharacterScreen(
          charaCategory: uri.pathSegments.first,
          id: _id,
        );
      }
    } catch (e) {
      logDal(e);
    }
    return widget;
  }
}
