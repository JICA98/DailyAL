import 'package:dailyanimelist/api/malforum.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/main.dart';
import 'package:dailyanimelist/pages/clubspage.dart';
import 'package:dailyanimelist/screens/forumtopicsscreen.dart';
import 'package:dailyanimelist/util/responsive_helper.dart';
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
  ForumTopics? animeDisc, mangaDisc, suggestionsDisc, seriesDisc, newDisc;
  Categories? categories;
  var discussionList = [
    S.current.Anime_Discussions,
    S.current.Manga_Discussions,
  ];

  @override
  void initState() {
    super.initState();
    startOpeningAnimation();
    _getStuff();
  }

  void _getStuff() {
    animeDisc = mangaDisc = suggestionsDisc = seriesDisc = newDisc = null;
    getCategories();
    getAnimeDiscussions();
    getMangaDiscussions();
    getSuggestionsDiscussions();
    getSeriesDiscussions();
    getNewDiscussions();
  }

  getCategories() async {
    categories = await MalForum.getForumBoards(fromCache: true);
    if (mounted) setState(() {});
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

  getSuggestionsDiscussions([bool fromCache = false]) async {
    suggestionsDisc = await getDiscussion(6,
        fromCache: fromCache); // DB Mods board for suggestions
    if (mounted) setState(() {});
    if (shouldUpdateContent(
        result: suggestionsDisc,
        timeinHours: user.pref.cacheUpdateFrequency[1])) {
      suggestionsDisc =
          (await getDiscussion(6, fromCache: false)) ?? suggestionsDisc;
    }
    if (mounted) setState(() {});
  }

  getSeriesDiscussions([bool fromCache = false]) async {
    seriesDisc = await getDiscussion(15,
        fromCache: fromCache); // Series Discussion board
    if (mounted) setState(() {});
    if (shouldUpdateContent(
        result: seriesDisc, timeinHours: user.pref.cacheUpdateFrequency[1])) {
      seriesDisc = (await getDiscussion(15, fromCache: false)) ?? seriesDisc;
    }
    if (mounted) setState(() {});
  }

  getNewDiscussions([bool fromCache = false]) async {
    newDisc =
        await getDiscussion(5, fromCache: fromCache); // News & Discussion board
    if (mounted) setState(() {});
    if (shouldUpdateContent(
        result: newDisc, timeinHours: user.pref.cacheUpdateFrequency[1])) {
      newDisc = (await getDiscussion(5, fromCache: false)) ?? newDisc;
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: hasOpened ? 1 : 0,
      duration: Duration(milliseconds: 300),
      child: _buildForumPage(),
    );
  }

  Widget _buildForumPage() {
    final isTablet = ResponsiveHelper.isTabletOrLarger(context);

    if (isTablet) {
      return DefaultTabController(
        length: 2,
        child: Column(
          children: [
            // TabBar for tablet
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TabBar(
                tabs: [
                  Tab(text: S.current.Forums),
                  Tab(text: S.current.Clubs),
                ],
              ),
            ),
            // Tab content
            Expanded(
              child: TabBarView(
                children: [
                  RefreshIndicator(
                    onRefresh: () async {
                      _getStuff();
                    },
                    child: Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: _forumPage(),
                    ),
                  ),
                  ClubsPage(hideAppBar: true),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverLayoutBuilder(
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
              toolbarHeight: kToolbarHeight,
              actions: [SB.z],
              bottom: TabBar(
                tabs: [
                  Tab(text: S.current.Forums),
                  Tab(text: S.current.Clubs),
                ],
              ),
            ),
          )
        ],
        body: TabBarView(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                _getStuff();
              },
              child: _forumPage(),
            ),
            ClubsPage(hideAppBar: true),
          ],
        ),
      ),
    );
  }

  Widget _forumPage() {
    final isTablet = ResponsiveHelper.isTabletOrLarger(context);
    final contentPadding = ResponsiveHelper.getContentPadding(context);
    final sectionSpacing = ResponsiveHelper.getSectionSpacing(context);

    if (isTablet) {
      return _buildTabletForumLayout(contentPadding, sectionSpacing);
    }

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

  Widget _buildTabletForumLayout(
      EdgeInsets contentPadding, double sectionSpacing) {
    final screenSize = ResponsiveHelper.getScreenSize(context);
    final isLargeTablet = screenSize.index >= ScreenSize.expanded.index;

    return CustomScrollView(
      slivers: [
        // Top Row: Anime and Manga Discussions
        SliverPadding(
          padding: contentPadding,
          sliver: SliverToBoxAdapter(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Anime Discussions
                Expanded(
                  child: _buildContentSection(
                    title: S.current.Anime_Discussions,
                    onViewAll: () {
                      setState(() => discussionIndex = 0);
                      gotoForumTopicsPage();
                    },
                    child: _buildLimitedForumTopics(animeDisc, 0,
                        limit: isLargeTablet ? 6 : 4),
                  ),
                ),
                SizedBox(width: sectionSpacing),

                // Manga Discussions
                Expanded(
                  child: _buildContentSection(
                    title: S.current.Manga_Discussions,
                    onViewAll: () {
                      setState(() => discussionIndex = 1);
                      gotoForumTopicsPage();
                    },
                    child: _buildLimitedForumTopics(mangaDisc, 1,
                        limit: isLargeTablet ? 6 : 4),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: sectionSpacing)),

        // Second Row: Additional Discussion Categories
        if (isLargeTablet) ...[
          SliverPadding(
            padding: contentPadding,
            sliver: SliverToBoxAdapter(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Series Discussions
                  Expanded(
                    child: _buildContentSection(
                      title: "Series Discussion",
                      onViewAll: () {
                        gotoPage(
                          context: context,
                          newPage: ForumTopicsScreen(
                            boardId: 15,
                            offset: 50,
                            title: "Series Discussion",
                          ),
                        );
                      },
                      child: _buildLimitedForumTopics(seriesDisc, 15, limit: 4),
                    ),
                  ),
                  SizedBox(width: sectionSpacing),

                  // News & Discussion
                  Expanded(
                    child: _buildContentSection(
                      title: "News & Discussion",
                      onViewAll: () {
                        gotoPage(
                          context: context,
                          newPage: ForumTopicsScreen(
                            boardId: 5,
                            offset: 50,
                            title: "News & Discussion",
                          ),
                        );
                      },
                      child: _buildLimitedForumTopics(newDisc, 5, limit: 4),
                    ),
                  ),
                  SizedBox(width: sectionSpacing),

                  // Suggestions
                  Expanded(
                    child: _buildContentSection(
                      title: "DB Modifications",
                      onViewAll: () {
                        gotoPage(
                          context: context,
                          newPage: ForumTopicsScreen(
                            boardId: 6,
                            offset: 50,
                            title: "DB Modifications",
                          ),
                        );
                      },
                      child: _buildLimitedForumTopics(suggestionsDisc, 6,
                          limit: 4),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: sectionSpacing)),
        ] else ...[
          // For smaller tablets, show in 2 columns
          SliverPadding(
            padding: contentPadding,
            sliver: SliverToBoxAdapter(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildContentSection(
                      title: "Series Discussion",
                      onViewAll: () {
                        gotoPage(
                          context: context,
                          newPage: ForumTopicsScreen(
                            boardId: 15,
                            offset: 50,
                            title: "Series Discussion",
                          ),
                        );
                      },
                      child: _buildLimitedForumTopics(seriesDisc, 15, limit: 3),
                    ),
                  ),
                  SizedBox(width: sectionSpacing),
                  Expanded(
                    child: _buildContentSection(
                      title: "News & Discussion",
                      onViewAll: () {
                        gotoPage(
                          context: context,
                          newPage: ForumTopicsScreen(
                            boardId: 5,
                            offset: 50,
                            title: "News & Discussion",
                          ),
                        );
                      },
                      child: _buildLimitedForumTopics(newDisc, 5, limit: 3),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: sectionSpacing)),
        ],

        // Bottom: Compact Forum Boards Section
        SliverPadding(
          padding: contentPadding,
          sliver: SliverToBoxAdapter(
            child: _buildCompactBoardsSection(),
          ),
        ),
        SB.lh80,
      ],
    );
  }

  Widget _buildLimitedForumTopics(ForumTopics? topics, int boardId,
      {int limit = 5}) {
    if (topics?.data == null) {
      return ShimmerWidget(padding: EdgeInsets.zero);
    }

    final limitedTopics = topics!.data!.take(limit).toList();

    return ForumTopicsList(
      topics: limitedTopics,
      onPressed: () {
        gotoPage(
          context: context,
          newPage: ForumTopicsScreen(
            boardId: boardId,
            offset: 50,
            title: topics.data!.first.title ?? '',
          ),
        );
      },
      showViewAllButton: false,
    );
  }

  Widget _buildCompactBoardsSection() {
    if (categories?.forums == null) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.2),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ShimmerWidget(padding: EdgeInsets.zero),
        ),
      );
    }

    final screenSize = ResponsiveHelper.getScreenSize(context);
    final isLargeTablet = screenSize.index >= ScreenSize.expanded.index;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.current.Forums,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            _buildCompactBoardGrid(isLargeTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactBoardGrid(bool isLargeTablet) {
    // Flatten all boards from all forums
    final allBoards = <Board>[];
    for (var forum in categories!.forums!) {
      if (forum.boards != null) {
        allBoards.addAll(forum.boards!);
      }
    }

    final crossAxisCount = isLargeTablet ? 3 : 2;
    final itemCount = allBoards.length.clamp(0, 9);

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: 110,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => _buildCompactBoardCard(
        allBoards[index],
      ),
    );
  }

  Widget _buildCompactBoardCard(Board board) {
    return InkWell(
      onTap: () {
        gotoPage(
          context: context,
          newPage: ForumTopicsScreen(
            boardId: board.id ?? 0,
            offset: 50,
            title: board.title ?? '',
          ),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withOpacity(0.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.forum_outlined,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    board.title ?? '',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (board.description != null &&
                      board.description!.isNotEmpty) ...[
                    SizedBox(height: 2),
                    Text(
                      board.description!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.color
                                ?.withOpacity(0.7),
                            fontSize: 11,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.color
                  ?.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSection({
    required String title,
    required Widget child,
    VoidCallback? onViewAll,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (onViewAll != null)
                  TextButton(
                    onPressed: onViewAll,
                    child: Text(S.current.View_All),
                  ),
              ],
            ),
            SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget buildBoards() {
    final isTablet = ResponsiveHelper.isTabletOrLarger(context);
    final boardHeight = isTablet ? 220.0 : 188.0;

    return Container(
      height: boardHeight,
      padding: const EdgeInsets.only(top: 10.0),
      child: categories?.forums == null
          ? ShimmerWidget(
              itemCount: 2,
              padding: EdgeInsets.zero,
            )
          : isTablet
              ? _buildTabletBoardsLayout()
              : PageView.builder(
                  controller:
                      PageController(initialPage: 0, viewportFraction: .89),
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

  Widget _buildTabletBoardsLayout() {
    final screenSize = ResponsiveHelper.getScreenSize(context);
    final crossAxisCount =
        screenSize.index >= ScreenSize.expanded.index ? 2 : 1;

    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 8,
        crossAxisSpacing: 12,
        mainAxisExtent: 80,
      ),
      itemCount: categories!.forums!.length.clamp(0, 4),
      itemBuilder: (context, index) => BoardWidget(
        forum: categories!.forums!.elementAt(index),
        forunIndex: index,
      ),
    );
  }
}
