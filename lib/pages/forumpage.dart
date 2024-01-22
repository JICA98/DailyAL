import 'package:dailyanimelist/api/credmal.dart';
import 'package:dailyanimelist/api/malclubs.dart';
import 'package:dailyanimelist/api/malforum.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/main.dart';
import 'package:dailyanimelist/screens/forumtopicsscreen.dart';
import 'package:dailyanimelist/widgets/club/clublistwidget.dart';
import 'package:dailyanimelist/widgets/forum/boardwidget.dart';
import 'package:dailyanimelist/widgets/forum/forumtopicwidget.dart';
import 'package:dailyanimelist/widgets/headerwidget.dart';
import 'package:dailyanimelist/widgets/homeappbar.dart';
import 'package:dailyanimelist/widgets/loading/shimmerwidget.dart';
import 'package:dailyanimelist/widgets/slivers.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:flutter/material.dart';

import '../constant.dart';

class ForumPage extends StatefulWidget {
  // final ForumTopics animeDisc, mangaDisc;

  const ForumPage({
    Key? key,
    //  this.animeDisc, this.mangaDisc
  }) : super(key: key);

  @override
  _ForumPageState createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> with TickerProviderStateMixin {
  bool hasOpened = false;
  int discussionIndex = 0;
  int contentIndex = 0;
  ClubListHtml? clubListHtml;
  ForumTopics? animeDisc, mangaDisc;
  Categories? categories;
  var discussionList = [
    S.current.Anime_Discussions,
    S.current.Manga_Discussions,
  ];
  final topHeaders = [S.current.Forums, S.current.Clubs];
  final iconMap = {
    S.current.Forums: Icons.forum,
    S.current.Clubs: Icons.castle,
  };

  @override
  void initState() {
    super.initState();
    startOpeningAnimation();
    _getStuff();
  }

  void _getStuff() {
    animeDisc = mangaDisc = clubListHtml = null;
    getClubsInfo(contentIndex == 0);
    getCategories();
    getAnimeDiscussions(contentIndex == 1);
    getMangaDiscussions(contentIndex == 1);
  }

  getClubsInfo([bool fromCache = false]) async {
    clubListHtml = await getClubs(fromCache: fromCache);
    if (mounted) setState(() {});
  }

  getCategories() async {
    categories = await MalForum.getForumBoards(fromCache: true);
    if (mounted) setState(() {});
  }

  Future<ClubListHtml?> getClubs({bool fromCache = true}) async {
    var _clubs = await MalClub.getClubs(fromCache: fromCache);
    if (shouldUpdateContent(
        result: _clubs, timeinHours: user.pref.cacheUpdateFrequency[1])) {
      return await getClubs(fromCache: false);
    } else {
      return _clubs;
    }
  }

  startOpeningAnimation() {
    Future.delayed(Duration(milliseconds: 10)).then((value) {
      if (mounted) {
        setState(() {
          hasOpened = true;
        });
      }
    });
  }

  void gotoForumTopicsPage() {
    gotoPage(
        context: context,
        newPage: ForumTopicsScreen(
          boardId: discussionIndex + 1,
          offset: 50,
          title: discussionList.elementAt(discussionIndex),
        ));
  }

  Future<ForumTopics?> getDiscussion(
    int boardId, {
    bool fromCache = true,
    bool useDalEndPoint = false,
    bool fromHtml = true,
  }) async {
    return await MalForum.getForumTopics(
        fromCache: fromCache,
        boardId: boardId,
        useDalEndPoint: useDalEndPoint,
        fromHtml: fromHtml);
  }

  getAnimeDiscussions([bool fromCache = false]) async {
    animeDisc = await getDiscussion(1, fromCache: fromCache);
    if (mounted) setState(() {});
    if (shouldUpdateContent(
        result: animeDisc, timeinHours: user.pref.cacheUpdateFrequency[1])) {
      animeDisc = (await getDiscussion(1, fromCache: false)) ?? animeDisc;
    }
    if (mounted) setState(() {});
  }

  getMangaDiscussions([bool fromCache = false]) async {
    mangaDisc = await getDiscussion(2, fromCache: fromCache);
    if (mounted) setState(() {});
    if (shouldUpdateContent(
        result: mangaDisc, timeinHours: user.pref.cacheUpdateFrequency[1])) {
      mangaDisc = (await getDiscussion(2, fromCache: false)) ?? mangaDisc;
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedOpacity(
          opacity: hasOpened ? 1 : 0,
          duration: Duration(milliseconds: 300),
          child: _defaultTab(),
        ),
        if (contentIndex == 1)
          Positioned(
            bottom: 10.0,
            right: 30.0,
            child: FloatingActionButton(
              onPressed: () => launchURLWithConfirmation(
                  '${CredMal.htmlEnd}clubs.php?action=create',
                  context: context),
              child: Icon(Icons.add),
            ),
          ),
      ],
    );
  }

  Widget _defaultTab() {
    return DefaultTabController(
      length: topHeaders.length,
      child: NestedScrollView(
        // controller: scrollController,
        headerSliverBuilder: (_, __) => [_buildAppBar()],
        body: RefreshIndicator(
          onRefresh: () async {
            _getStuff();
          },
          child: IndexedStack(
            index: contentIndex,
            children: [
              _forumPage(),
              _clubPage(),
            ],
          ),
        ),
      ),
    );
  }

  SliverLayoutBuilder _buildAppBar() {
    return SliverLayoutBuilder(
      builder: (p0, c) => SliverAppBar(
        automaticallyImplyLeading: false,
        pinned: true,
        floating: true,
        expandedHeight: 120,
        title: Padding(
          padding: const EdgeInsets.only(bottom: 5.0),
          child: AppBarHome(
            onUiChange: () {
              if (mounted) setState(() {});
            },
          ),
        ),
        titleSpacing: 0.0,
        bottom: _headerWidget(),
        // bottom: TabBar(tabs: iconMap.entries.map((e) => Tab(text: e.key, icon: Icon(e.value),)).toList()),
        toolbarHeight: kToolbarHeight,
        actions: [SB.z],
      ),
    );
  }

  PreferredSize _headerWidget() {
    return PreferredSize(
        preferredSize: Size(double.infinity, 63),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 6, top: 7.0),
          child: Container(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: HeaderWidget(
                    header: topHeaders,
                    shouldAnimate: false,
                    selectedIndex: contentIndex,
                    onPressed: (value) {
                      if (mounted)
                        setState(() {
                          contentIndex = value;
                        });
                    },
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _forumPage() {
    return CustomScrollView(
      slivers: [
        SliverWrapper(buildBoards()),
        SB.lh20,
        SliverWrapper(HeaderWidget(
          header: discussionList,
          selectedIndex: discussionIndex,
          onPressed: (value) {
            if (mounted)
              setState(() {
                discussionIndex = value;
              });
          },
        )),
        SliverWrapper(discussionIndex == 0
            ? ForumTopicsList(
                topics: animeDisc?.data,
                onPressed: () {
                  gotoForumTopicsPage();
                },
                showViewAllButton: true,
              )
            : ForumTopicsList(
                topics: mangaDisc?.data,
                onPressed: () {
                  gotoForumTopicsPage();
                },
                showViewAllButton: true,
              )),
        SB.lh80,
      ],
    );
  }

  Widget _clubPage() {
    return SingleChildScrollView(
      child: clubListHtml?.clubs == null
          ? ShimmerWidget()
          : clubListHtml!.clubs!.isEmpty
              ? showNoContent()
              : ClubListWidget(
                  clubListHtml: clubListHtml!,
                ),
    );
  }

  final pageController = PageController(initialPage: 0, viewportFraction: .89);

  Widget buildBoards() {
    return Container(
      height: 188.0,
      padding: const EdgeInsets.only(top: 10.0),
      child: categories?.forums == null
          ? ShimmerWidget(
              itemCount: 2,
              padding: EdgeInsets.zero,
            )
          : PageView.builder(
              controller: pageController,
              allowImplicitScrolling: true,
              itemCount: 2,
              itemBuilder: (context, index) => Column(
                children: [
                  BoardWidget(
                    forum: categories!.forums!.elementAt(2 * index),
                    forunIndex: 2 * index,
                  ),
                  BoardWidget(
                    forum: categories!.forums!.elementAt(2 * index + 1),
                    forunIndex: 2 * index + 1,
                  )
                ],
              ),
            ),
    );
  }
}
