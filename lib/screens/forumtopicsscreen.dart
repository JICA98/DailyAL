import 'package:dailyanimelist/api/auth/auth.dart';
import 'package:dailyanimelist/api/malforum.dart';
import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/screens/plainscreen.dart';
import 'package:dailyanimelist/widgets/customfuture.dart';
import 'package:dailyanimelist/widgets/forum/forumtopicwidget.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:flutter/material.dart';
import 'package:dailyanimelist/generated/l10n.dart';

class ForumTopicsScreenLess extends StatefulWidget {
  final int? boardId;
  final int? subBoardId;
  final int? animeId;
  final int? mangaId;
  final String? title;
  final String? query;
  final bool shrinkWrap;
  final bool fromHtml;
  final int? offset;
  final EdgeInsetsGeometry? padding;
  const ForumTopicsScreenLess({
    Key? key,
    this.boardId,
    this.subBoardId,
    this.title,
    this.mangaId,
    this.shrinkWrap = false,
    this.animeId,
    this.fromHtml = true,
    this.offset = 0,
    this.query,
    this.padding,
  }) : super(key: key);
  @override
  _ForumTopicsScreenLessState createState() => _ForumTopicsScreenLessState();
}

class _ForumTopicsScreenLessState extends State<ForumTopicsScreenLess> {
  int limit = 40;
  late String refKey;

  @override
  void initState() {
    super.initState();
    refKey = MalAuth.codeChallenge(10);
  }

  Future<List<ForumTopicsData>> getForumTopics(int pageOffset,
      {bool fromCache = false}) async {
    try {
      final topics = await MalForum.getForumTopics(
        fromCache: fromCache,
        boardId: widget.boardId,
        subBoardId: widget.subBoardId,
        animeId: widget.animeId,
        mangaId: widget.mangaId,
        offset: pageOffset,
        q: widget.query,
        fromHtml: widget.fromHtml,
        limit: limit,
      );
      return topics?.data ?? [];
    } catch (e) {
      logDal(e);
      showToast(S.current.Couldnt_connect_network);
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return screen();
  }

  Widget screen() {
    return RefreshIndicator(
      onRefresh: () async {
        refKey = MalAuth.codeChallenge(10);
        if (mounted) setState(() {});
      },
      child: InfinitePagination<ForumTopicsData>(
        refKey: refKey,
        future: (offset) => getForumTopics(offset),
        pageSize: limit,
        initialIndex: widget.offset ?? 0,
        itemBuilder: (_, item, i) =>
            ForumTopicWidget(topic: item.rowItems.first),
      ),
    );
  }
}

class ForumTopicsScreen extends StatefulWidget {
  final int? boardId;
  final int? subBoardId;
  final String? title;
  final String? query;
  final int? offset;

  const ForumTopicsScreen(
      {Key? key,
      this.boardId,
      this.subBoardId,
      this.title,
      this.query,
      this.offset = 0})
      : super(key: key);
  @override
  _ForumTopicsScreenState createState() => _ForumTopicsScreenState();
}

class _ForumTopicsScreenState extends State<ForumTopicsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(widget.title ?? '', context),
      body: ForumTopicsScreenLess(
        boardId: widget.boardId,
        subBoardId: widget.subBoardId,
        title: widget.title,
        offset: widget.offset,
        query: widget.query,
      ),
    );
  }
}
