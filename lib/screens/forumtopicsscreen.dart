import 'package:dailyanimelist/api/auth/auth.dart';
import 'package:dailyanimelist/api/malforum.dart';
import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/screens/plainscreen.dart';
import 'package:dailyanimelist/widgets/customfuture.dart';
import 'package:dailyanimelist/widgets/forum/forumtopicwidget.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:flutter/material.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/util/responsive_helper.dart';
import 'package:dailyanimelist/screens/forumposts.dart';

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
  final List<Widget>? actions;
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
    this.actions,
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

  ForumTopicsData? _selectedTopic;
  double _leftWidth = 350;
  final GlobalKey _listKey = GlobalKey();

  Widget screen() {
    final isTablet = ResponsiveHelper.isTabletOrLarger(context);
    if (isTablet) {
      if (_selectedTopic != null) {
        return Row(
          children: [
            SizedBox(
              width: _leftWidth.clamp(
                  200.0, MediaQuery.of(context).size.width - 200),
              child: Column(
                children: [
                  SizedBox(
                    height: kToolbarHeight + MediaQuery.of(context).padding.top,
                    child: AppBar(
                      title: Text(widget.title ?? ''),
                      actions: widget.actions ?? [searchIconButton(context)],
                    ),
                  ),
                  Expanded(child: _buildList(true)),
                ],
              ),
            ),
            GestureDetector(
              onHorizontalDragUpdate: (details) {
                setState(() {
                  _leftWidth += details.delta.dx;
                });
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeColumn,
                child: Container(
                  width: 8,
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                  child: Center(
                    child: Container(
                      width: 2,
                      height: 40,
                      color: Theme.of(context).dividerColor.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ForumPostsScreen(
                key: ValueKey(_selectedTopic?.id),
                topic: _selectedTopic,
                showAppbar: false,
              ),
            )
          ],
        );
      } else {
        return Column(
          children: [
            SizedBox(
              height: kToolbarHeight + MediaQuery.of(context).padding.top,
              child: AppBar(
                title: Text(widget.title ?? ''),
                actions: widget.actions ?? [searchIconButton(context)],
              ),
            ),
            Expanded(child: _buildList(true)),
          ],
        );
      }
    }
    return _buildList(false);
  }

  Widget _buildList(bool isTablet) {
    return RefreshIndicator(
      key: _listKey,
      onRefresh: () async {
        refKey = MalAuth.codeChallenge(10);
        if (mounted) setState(() {});
      },
      child: InfinitePagination<ForumTopicsData>(
        refKey: refKey,
        future: (offset) => getForumTopics(offset),
        pageSize: limit,
        initialIndex: widget.offset ?? 0,
        itemBuilder: (_, item, i) => ForumTopicWidget(
          topic: item.rowItems.first,
          isSelected: isTablet && _selectedTopic?.id == item.rowItems.first.id,
          onTopicSelect: isTablet
              ? (topic) {
                  if (mounted) setState(() => _selectedTopic = topic);
                }
              : null,
        ),
      ),
    );
  }
}

class ForumTopicsScreen extends StatefulWidget {
  final int? boardId;
  final int? subBoardId;
  final int? animeId;
  final int? mangaId;
  final String? title;
  final String? query;
  final int? offset;
  final List<Widget>? actions;

  const ForumTopicsScreen(
      {Key? key,
      this.boardId,
      this.subBoardId,
      this.animeId,
      this.mangaId,
      this.title,
      this.query,
      this.offset = 0,
      this.actions})
      : super(key: key);
  @override
  _ForumTopicsScreenState createState() => _ForumTopicsScreenState();
}

class _ForumTopicsScreenState extends State<ForumTopicsScreen> {
  @override
  Widget build(BuildContext context) {
    bool isTablet = ResponsiveHelper.isTabletOrLarger(context);
    return Scaffold(
      appBar: isTablet
          ? null
          : AppBar(
              title: Text(widget.title ?? ''),
              actions: widget.actions ?? [searchIconButton(context)],
            ),
      body: ForumTopicsScreenLess(
        boardId: widget.boardId,
        subBoardId: widget.subBoardId,
        animeId: widget.animeId,
        mangaId: widget.mangaId,
        title: widget.title,
        offset: widget.offset,
        query: widget.query,
        actions: widget.actions,
      ),
    );
  }
}
