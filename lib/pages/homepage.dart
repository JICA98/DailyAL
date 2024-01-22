import 'dart:async';

import 'package:dailyanimelist/api/auth/auth.dart';
import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/main.dart';
import 'package:dailyanimelist/pages/home/newswidget.dart';
import 'package:dailyanimelist/screens/contentdetailedscreen.dart';
import 'package:dailyanimelist/screens/generalsearchscreen.dart';
import 'package:dailyanimelist/user/hompagepref.dart';
import 'package:dailyanimelist/user/user.dart';
import 'package:dailyanimelist/util/homepageutils.dart';
import 'package:dailyanimelist/widgets/customappbar.dart';
import 'package:dailyanimelist/widgets/custombutton.dart';
import 'package:dailyanimelist/widgets/forum/forumtopicwidget.dart';
import 'package:dailyanimelist/widgets/home/animecard.dart';
import 'package:dailyanimelist/widgets/homeappbar.dart';
import 'package:dailyanimelist/widgets/loading/loadingcard.dart';
import 'package:dailyanimelist/widgets/shimmecolor.dart';
import 'package:dailyanimelist/widgets/slivers.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool hasOpened = false;
  double height = 50;
  ScrollController scrollController = new ScrollController();
  ScrollController bodyHeaderController = new ScrollController();
  bool transition = false;
  var topHeaders = <String, GeneralSearchScreen>{};
  late String refKey;

  @override
  void initState() {
    super.initState();
    setRefKey();
    hasOpened = false;
    startOpeningAnimation();
    Future.delayed(Duration.zero).then((value) {
      initLangs();
      user.addListener(() {
        if (mounted) setState(() {});
      });
    });
  }

  void setRefKey() {
    refKey = MalAuth.codeChallenge(12);
  }

  startOpeningAnimation() async {
    Future.delayed(Duration.zero).then((value) {
      if (mounted) {
        setState(() {
          hasOpened = true;
          height = 0;
        });
      }
    });
  }

  initLangs() {
    topHeaders = {
      S.of(context).top_anime: GeneralSearchScreen(
        searchQuery: "#all",
        autoFocus: false,
        showBackButton: true,
      ),
      S.of(context).top_mange: GeneralSearchScreen(
        searchQuery: "#all@manga",
        autoFocus: false,
        showBackButton: true,
      ),
      S.of(context).top_airing: GeneralSearchScreen(
        searchQuery: "#airing",
        autoFocus: false,
        showBackButton: true,
      ),
      S.of(context).popular_anime: GeneralSearchScreen(
        searchQuery: "#bypopularity",
        autoFocus: false,
        showBackButton: true,
      ),
      S.of(context).popular_manga: GeneralSearchScreen(
        searchQuery: "#bypopularity@manga",
        autoFocus: false,
        showBackButton: true,
      )
    };
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 0, right: 0, top: 0),
      child: AnimatedOpacity(
        opacity: hasOpened ? 1 : 0,
        duration: Duration(milliseconds: 500),
        child: DefaultTabController(
          length: topHeaders.length,
          child: NestedScrollView(
            controller: scrollController,
            headerSliverBuilder: (_, __) => [_buildAppBar()],
            body: RefreshIndicator(
              onRefresh: () async {
                setRefKey();
                if (mounted) setState(() {});
              },
              child: CustomScrollWrapper(newSlivers()),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> newSlivers() {
    return [contentSliverBuilder(), SliverToBoxAdapter(child: SB.h80)];
  }

  SliverLayoutBuilder _buildAppBar() {
    return SliverLayoutBuilder(
      builder: (p0, c) => SliverAppBar(
        automaticallyImplyLeading: false,
        pinned: true,
        floating: true,
        title: Padding(
          padding: const EdgeInsets.only(bottom: 5.0),
          child: AppBarHome(
            onUiChange: () {
              if (mounted) setState(() {});
            },
          ),
        ),
        actions: <Widget>[SB.z],
        titleSpacing: 0.0,
        backgroundColor: c.scrollOffset > 0 ? null : Colors.transparent,
        toolbarHeight: kToolbarHeight,
        bottom: _buildTopHeader(c),
      ),
    );
  }

  PreferredSize _buildTopHeader(SliverConstraints c) {
    return PreferredSize(
      preferredSize: Size(double.infinity, 52),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10, top: 7.0),
        child: Container(
          height: 35,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            children: topHeaders.keys
                .map((key) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: ShadowButton(
                        elevation: 0.0,
                        child: Text(
                          key,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        onPressed: () => gotoPage(
                            context: context, newPage: topHeaders[key]!),
                        backgroundColor: Color(c.scrollOffset > 0
                                ? Theme.of(context).cardColor.value
                                : Theme.of(context).cardColor.value)
                            .withOpacity(c.scrollOffset > 0 ? 0.1 : 0.4),
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                      ),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget contentSliverBuilder() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, index) => ContentHomeWidget(
          refKey: refKey,
          apiPref: user.pref.hpApiPrefList.elementAt(index),
        ),
        childCount: user.pref.hpApiPrefList.length,
      ),
    );
  }
}

class ContentHomeWidget extends StatefulWidget {
  final HomePageApiPref apiPref;
  final String refKey;
  ContentHomeWidget({required this.apiPref, required this.refKey});
  @override
  _ContentHomeWidgetState createState() => _ContentHomeWidgetState();
}

class _ContentHomeWidgetState extends State<ContentHomeWidget>
    with AutomaticKeepAliveClientMixin {
  dynamic content;
  late HomePageApiPref apiPref;

  @override
  void initState() {
    super.initState();
    apiPref = widget.apiPref;
    getData();
  }

  @override
  void didUpdateWidget(covariant ContentHomeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    bool forceUpdate = (!oldWidget.refKey.equals(widget.refKey));
    if ((widget.apiPref != apiPref && mounted) || forceUpdate) {
      setState(() {
        content = null;
        apiPref = widget.apiPref;
        getData(forceUpdate);
      });
    }
  }

  void getData([bool forceUpdate = false]) async {
    try {
      content = await HomePageUtils().getFuture(apiPref, forceUpdate);
      if (mounted) setState(() {});
    } catch (e) {
      logDal(e);
    }
  }

  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    if (!apiPref.value.authOnly || user.status == AuthStatus.AUTHENTICATED) {
      if (content == null) {
        return _loadingWidget;
      } else {
        return _doneWidget;
      }
    } else
      return SB.z;
  }

  Widget get _doneWidget {
    switch (apiPref.contentType) {
      case HomePageType.top_manga:
        return _columnWidget;
      case HomePageType.forum:
        return _forumTopics;
      case HomePageType.user_list:
        return _columnWidget;
      case HomePageType.news:
        return content is FeaturedResult ? _buildNewsWidget : _loadingWidget;
      default:
    }
    return _columnWidget;
  }

  Widget get _forumTopics {
    return Column(
      children: [
        SB.h20,
        HomePageTitleWidget(content, apiPref),
        ForumTopicsList(
          topics: content?.data,
          shimmerItemCount: 3,
          padding: EdgeInsets.zero,
          showMax: 6,
        )
      ],
    );
  }

  Widget get _buildNewsWidget {
    return Column(
      children: [
        SB.h10,
        HomePageTitleWidget(content, apiPref),
        SB.h5,
        if (content?.data == null || content.data.isEmpty)
          HomePageNewsWidget(List.generate(6, (index) => FeaturedBaseNode()))
        else
          HomePageNewsWidget(content?.data)
      ],
    );
  }

  Widget get _columnWidget {
    String category =
        apiPref.contentType == HomePageType.top_manga ? 'manga' : 'anime';
    if (apiPref.value.userCategory != null) {
      category = apiPref.value.userCategory!;
    }
    final tile = tileMap.tryAt(user.pref.homePageTileSize);
    return Column(children: [
      SB.h15,
      HomePageTitleWidget(content, apiPref),
      SB.h15,
      (content?.data != null && content.data.isNotEmpty)
          ? Container(
              height: tile!.containerHeight,
              child: ListView.builder(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  itemCount: content.data.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    var heroTag = MalAuth.codeChallenge(10);
                    return Hero(
                      tag: heroTag,
                      child: AnimeGridCard(
                        node: content.data[index].content,
                        category: category,
                        showEdit: true,
                        showCardBar: true,
                        updateCache: true,
                        showGenres: true,
                        height: tile.contentHeight,
                        width: tile.contentWidth,
                        homePageTileSize: user.pref.homePageTileSize,
                        parentNsv: apiPref.contentType == HomePageType.user_list
                            ? NodeStatusValue.fromStatus(content.data[index])
                            : null,
                        onTap: () => navigateTo(
                            context,
                            ContentDetailedScreen(
                              node: content.data[index].content,
                              category: category,
                            )),
                      ),
                    );
                  }),
            )
          : ShimmerColor(
              Container(
                height: tile!.loadingContainerHeight,
                child: ListView.builder(
                  padding: EdgeInsets.only(left: 15, right: 15),
                  itemCount: 10,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) => LoadingCard(
                    height: tile.contentHeight,
                    width: tile.contentWidth,
                  ),
                ),
              ),
            ),
    ]);
  }

  Widget get _loadingWidget {
    switch (apiPref.contentType) {
      case HomePageType.forum:
        return _forumTopics;
      case HomePageType.news:
        return _buildNewsWidget;
      default:
    }
    return _columnWidget;
  }

  @override
  bool get wantKeepAlive => true;
}

class HomePageTitleWidget extends StatelessWidget {
  final content;
  final HomePageApiPref apiPref;
  const HomePageTitleWidget(this.content, this.apiPref, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String _title = apiPref.value?.title ?? '';
    _title = HomePageUtils().titleBuilder(apiPref, context, true);
    return Padding(
      padding: EdgeInsets.only(left: 15, right: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              _title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward),
            onPressed: (content?.data != null && content.data.isNotEmpty)
                ? () {
                    if ((content?.data != null && content.data.isNotEmpty))
                      gotoPage(
                          context: context,
                          newPage: HomePageUtils().viewAllBuilder(apiPref));
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
