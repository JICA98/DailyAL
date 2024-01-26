import 'dart:collection';

import 'package:dailyanimelist/cache/book_marks.dart';
import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/enums.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/main.dart';
import 'package:dailyanimelist/pages/animedetailed/intereststackwidget.dart';
import 'package:dailyanimelist/screens/generalsearchscreen.dart';
import 'package:dailyanimelist/util/streamutils.dart';
import 'package:dailyanimelist/widgets/forum/forumtopicwidget.dart';
import 'package:dailyanimelist/widgets/slivers.dart';
import 'package:dailyanimelist/widgets/user/contentlistwidget.dart';
import 'package:dal_commons/commons.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:flutter/material.dart';

enum BookmarkType {
  anime,
  manga,
  news,
  featured,
  character,
  person,
  malUser,
  forumTopics,
  interestStacks,
  clubs,
}

class _Tab {
  final BookmarkType value;
  final String displayTxt;

  _Tab(this.value, this.displayTxt);
}

class BookmarkTag extends StatefulWidget {
  final BookmarkType type;
  final int id;
  final dynamic data;
  final IconData? addIcon;
  final IconData? removeIcon;
  const BookmarkTag({
    Key? key,
    required this.type,
    required this.id,
    required this.data,
    this.addIcon,
    this.removeIcon,
  }) : super(key: key);

  @override
  State<BookmarkTag> createState() => _BookmarkTagState();
}

class _BookmarkTagState extends State<BookmarkTag> {
  @override
  Widget build(BuildContext context) {
    final type = widget.type;
    final id = widget.id.toString();
    final addIcon = widget.addIcon ?? Icons.bookmark_add;
    final removeIcon = widget.removeIcon ?? Icons.bookmark_remove;

    return bookmarkStream(
      type: type,
      id: id,
      done: (data) {
        if (data == null) {
          return IconButton(
            icon: Icon(addIcon),
            onPressed: () => addBookmark(type, id, widget.data),
          );
        } else {
          return IconButton(
            icon: Icon(removeIcon),
            onPressed: () => removeBookmark(type, id),
          );
        }
      },
    );
  }
}

class BookMarkFloatingButton extends StatelessWidget {
  final BookmarkType type;
  final dynamic id;
  final dynamic data;
  final IconData? addIcon;
  final IconData? removeIcon;
  const BookMarkFloatingButton({
    Key? key,
    required this.type,
    required this.id,
    required this.data,
    this.addIcon,
    this.removeIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _id = id.toString();
    final _addIcon = addIcon ?? Icons.bookmark_outline;
    final _removeIcon = removeIcon ?? Icons.bookmark;

    return bookmarkStream(
      type: type,
      id: _id,
      done: (doneData) => FloatingActionButton(
        heroTag: 'bookmark-floating-button',
        child: Icon(doneData == null ? _addIcon : _removeIcon),
        onPressed: () {
          if (doneData == null) {
            addBookmark(type, _id, data);
          } else {
            removeBookmark(type, _id);
          }
        },
      ),
    );
  }
}

void removeBookmark(BookmarkType type, String id) {
  StreamUtils.i.addData<BookMarks>(StreamType.book_marks, (bookmark) {
    (bookmark.toJson()[type.name] as Map).remove(id);
    return bookmark;
  });
}

void addBookmark(BookmarkType type, String id, dynamic data) {
  StreamUtils.i.addData<BookMarks>(StreamType.book_marks, (bookmark) {
    bookmark.toJson()[type.name][id] = data;
    return bookmark;
  });
}

StreamBuilder bookmarkStream<T>({
  required BookmarkType type,
  required String id,
  required Widget Function(T) done,
}) {
  return StreamBuilder<BookMarks>(
    initialData: StreamUtils.i.initalData(StreamType.book_marks),
    stream: StreamUtils.i.getStream(StreamType.book_marks),
    builder: (_, snap) =>
        done(((snap.data?.toJson() ?? {})[type.name] ?? {})[id]),
  );
}

class BookMarksWidget extends StatefulWidget {
  const BookMarksWidget({Key? key}) : super(key: key);

  @override
  State<BookMarksWidget> createState() => _BookMarksWidgetState();
}

class _BookMarksWidgetState extends State<BookMarksWidget> {
  final tabs = [
    _Tab(BookmarkType.anime, 'Anime'),
    _Tab(BookmarkType.manga, 'Manga'),
    _Tab(BookmarkType.character, S.current.Character),
    _Tab(BookmarkType.person, S.current.People_Caps),
    _Tab(BookmarkType.interestStacks, S.current.Interest_Stack),
    _Tab(BookmarkType.forumTopics, S.current.Forums),
    _Tab(BookmarkType.malUser, S.current.Users.capitalize()!),
    _Tab(BookmarkType.clubs, S.current.Clubs),
    _Tab(BookmarkType.news, S.current.News),
    _Tab(BookmarkType.featured, S.current.Featured_Articles),
  ];
  final scrollController = ScrollController();
  bool isSorted = false;
  final _nonImageTypes = [BookmarkType.malUser];
  final _categoryMap = {
    'malUser': 'user',
    'clubs': 'club',
  };

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  void _sortTabs(BookMarks data) {
    try {
      if (!isSorted) {
        final json = HashMap.from(data.toJson());
        tabs.sort(
            (a, b) => json[b.value.name].length - json[a.value.name].length);
      }
    } catch (e) {}
    isSorted = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<BookMarks>(
        initialData: StreamUtils.i.initalData(StreamType.book_marks),
        stream: StreamUtils.i.getStream(StreamType.book_marks),
        builder: (_, snap) {
          final data = snap.data;
          if (data != null) {
            _sortTabs(data);
            return nestedScrollView(data);
          } else {
            return loadingBelowText();
          }
        },
      ),
    );
  }

  Widget nestedScrollView(BookMarks bookMarks) {
    return DefaultTabController(
      length: tabs.length,
      child: NestedScrollView(
        controller: scrollController,
        headerSliverBuilder: (_, __) => [_buildAppBar()],
        body: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: TabBarView(
              children: tabs.map((b) => bookmark(b, bookMarks)).toList()),
        ),
      ),
    );
  }

  Widget bookmark(_Tab tab, BookMarks bookmarks) {
    final type = tab.value;
    return nothingFound(
      type.name,
      (bookmarks.toJson()[type.name] as Map<String, dynamic>?)
              ?.values
              .toList() ??
          [],
      (list) => _buildBookmarkNodes(type, list),
    );
  }

  Widget nothingFound(String type, List content, Widget Function(List) child) {
    if (content.isEmpty) {
      return Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 35.0),
          child: title('${S.current.Nothing_bookmarked_in} ${type}'),
        ),
      );
    } else {
      return child(content);
    }
  }

  Widget _buildBookmarkNodes(BookmarkType type, List<dynamic> nodes) {
    if (type == BookmarkType.interestStacks) {
      return InterestStackContentList(
          horizPadding: 10.0,
          type: DisplayType.list_vert,
          interestStacks: nodes
              .where((e) => e is InterestStack)
              .map((e) => e as InterestStack)
              .toList());
    } else if (type == BookmarkType.forumTopics) {
      return ForumTopicsList(
        topics: nodes
            .where((e) => e is ForumTopicsData)
            .map((e) => e as ForumTopicsData)
            .toList(),
      );
    }
    return CustomScrollWrapper([
      ContentListWidget(
        returnSlivers: true,
        cardHeight: 170,
        cardWidth: 160,
        showImage: true,
        showEdit: contentTypes.contains(type.name),
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        contentList: adaptToBaseNodes(nodes),
        displayType: DisplayType.grid,
        category: _categoryMap[type.name] ?? type.name,
        onClose: (_, node) => removeBookmark(type, _getId(node)),
        updateCacheOnEdit: true,
      ),
    ]);
  }

  String _getId(node) {
    Node _node;
    if (node is BaseNode) {
      if (node.content is MUser) {
        return (node.content as MUser).username;
      } else {
        _node = node.content!;
      }
    } else {
      _node = node;
    }
    return (_node.id!).toString();
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      expandedHeight: 90.0,
      title: iconAndText(
        Icons.bookmark,
        S.current.Bookmarks,
        fontSize: 22,
        iconSize: 22,
      ),
      floating: true,
      pinned: true,
      bottom: TabBar(
        isScrollable: true,
        tabs: tabs.map((e) => Tab(text: e.displayTxt)).toList(),
      ),
      actions: [
        IconButton(
            onPressed: () => Navigator.pop(context), icon: Icon(Icons.close))
      ],
    );
  }

  List<BaseNode> adaptToBaseNodes(List nodes) {
    return nodes.map((e) {
      if (e is Node) {
        if (e is Featured) {
          return FeaturedBaseNode(e);
        }
        if (e is ClubHtml) {
          return BaseNode(
              content: Node(
                  id: e.clubId,
                  title: e.clubName,
                  mainPicture: Picture(large: e.imgUrl)));
        }
        return BaseNode(content: e);
      } else if (e is CharacterV4Data) {
        final url = e.images?.jpg?.imageUrl ?? e.images?.webp?.imageUrl;
        return BaseNode(
            content: Node(
                id: e.malId,
                title: e.name,
                mainPicture: Picture(
                  large: url,
                  medium: url,
                )));
      } else if (e is PeopleV4Data) {
        final url = e.images?.jpg?.imageUrl ?? e.images?.webp?.imageUrl;
        return BaseNode(
            content: Node(
                id: e.malId,
                title: e.name,
                mainPicture: Picture(large: url, medium: url)));
      } else if (e is ForumHtml) {
        return e;
      } else if (e is UserProf) {
        return BaseNode(content: MUser(e.name!, e.picture ?? '', ''));
      } else {
        throw Error();
      }
    }).toList();
  }
}
