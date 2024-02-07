import 'package:dailyanimelist/api/auth/auth.dart';
import 'package:dailyanimelist/api/credmal.dart';
import 'package:dailyanimelist/api/jikahelper.dart';
import 'package:dailyanimelist/api/maluser.dart';
import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/enums.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/main.dart';
import 'package:dailyanimelist/screens/contentdetailedscreen.dart';
import 'package:dailyanimelist/screens/generalsearchscreen.dart';
import 'package:dailyanimelist/screens/plainscreen.dart';
import 'package:dailyanimelist/screens/user_profile.dart';
import 'package:dailyanimelist/user/user.dart';
import 'package:dailyanimelist/util/streamutils.dart';
import 'package:dailyanimelist/widgets/avatarwidget.dart';
import 'package:dailyanimelist/widgets/custombutton.dart';
import 'package:dailyanimelist/widgets/home/bookmarks_widget.dart';
import 'package:dailyanimelist/widgets/homeappbar.dart';
import 'package:dailyanimelist/widgets/loading/expandedwidget.dart';
import 'package:dailyanimelist/widgets/slivers.dart';
import 'package:dailyanimelist/widgets/togglebutton.dart';
import 'package:dailyanimelist/widgets/user/contentbuilder.dart';
import 'package:dailyanimelist/widgets/user/signinpage.dart';
import 'package:dailyanimelist/widgets/user/userchart.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:flutter/material.dart';

List<int?> userStatusData(
  String category,
  UserProfileV4? jikanUser,
  UserProf? userProf, [
  bool isSelf = true,
]) =>
    isSelf
        ? [
            category.equals("manga")
                ? jikanUser?.statistics?.manga?.reading
                : userProf?.animeStatistics?.numItemsWatching?.toInt(),
            category.equals("manga")
                ? jikanUser?.statistics?.manga?.completed
                : userProf?.animeStatistics?.numItemsCompleted?.toInt(),
            category.equals("manga")
                ? jikanUser?.statistics?.manga?.onHold
                : userProf?.animeStatistics?.numItemsOnHold?.toInt(),
            category.equals("manga")
                ? jikanUser?.statistics?.manga?.dropped
                : userProf?.animeStatistics?.numItemsDropped?.toInt(),
            category.equals("manga")
                ? jikanUser?.statistics?.manga?.planToRead
                : userProf?.animeStatistics?.numItemsPlanToWatch?.toInt(),
          ]
        : [
            category.equals("manga")
                ? jikanUser?.statistics?.manga?.reading
                : jikanUser?.statistics?.anime?.watching,
            category.equals("manga")
                ? jikanUser?.statistics?.manga?.completed
                : jikanUser?.statistics?.anime?.completed,
            category.equals("manga")
                ? jikanUser?.statistics?.manga?.onHold
                : jikanUser?.statistics?.anime?.onHold,
            category.equals("manga")
                ? jikanUser?.statistics?.manga?.dropped
                : jikanUser?.statistics?.anime?.dropped,
            category.equals("manga")
                ? jikanUser?.statistics?.manga?.planToRead
                : jikanUser?.statistics?.anime?.planToWatch,
          ];

class HeaderButton extends StatelessWidget {
  final bool active;
  final VoidCallback onTap;
  final String title;
  final IconData iconData;
  const HeaderButton({
    required this.active,
    required this.onTap,
    required this.title,
    required this.iconData,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var child = ExpandedIconAndText(title, iconData, active);
    return Padding(
        padding: EdgeInsets.only(left: 10),
        child: active
            ? ShadowButton(
                padding: EdgeInsets.symmetric(horizontal: 15.0),
                onPressed: onTap,
                child: child,
              )
            : IconButton(
                padding: EdgeInsets.zero,
                icon: child,
                onPressed: onTap,
              ));
  }
}

class ExpandedIconAndText extends StatelessWidget {
  final String title;
  final IconData iconData;
  final bool expand;
  const ExpandedIconAndText(this.title, this.iconData, this.expand, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      children: [
        Icon(iconData, size: 16),
        const SizedBox(
          width: 10,
        ),
        ExpandedSection(
          expand: expand,
          axis: Axis.horizontal,
          child: Center(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}

class UserPage extends StatefulWidget {
  final int initalPageIndex;
  final String username;
  final String? initialStatus;
  final bool? hasExpanded;
  final String? category;
  final bool isSelf;
  final ScrollController? controller;
  const UserPage({
    this.initalPageIndex = 1,
    this.initialStatus,
    this.hasExpanded,
    this.username = "@me",
    this.category,
    this.isSelf = true,
    this.controller,
  });
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> with TickerProviderStateMixin {
  bool hasOpened = false;
  bool listUpdated = false;
  UserProf? userProf;
  late String category = "anime";
  SearchResult? contentResult;
  List<BaseNode>? contentList;
  SearchStage research = SearchStage.notstarted;
  int pageIndex = 1;
  int socialIndex = 0;
  String username = "@me";
  Map<String, String> refreshKeyMap = {};
  UserProfileV4? jikanUser;
  late AuthStatus previousStatus;
  Map<String, IconData> pageHeadersMap = {
    S.current.Collapse: Icons.keyboard_arrow_up,
    S.current.List: Icons.view_list_outlined,
    S.current.About: Icons.info,
    S.current.Social: Icons.people_alt,
    S.current.Favorites: Icons.favorite,
  };
  TabController? controller;
  ScrollController? scrollController;
  ScrollController? pageController;
  String? refKey;
  late StreamListener<Map<String, int?>> animeCountListener;
  late StreamListener<Map<String, int?>> mangaCountListener;

  void setRefKey() {
    refKey = MalAuth.codeChallenge(10);
  }

  @override
  void initState() {
    super.initState();
    setRefKey();
    var initalIndex = 0;
    bool hasExpanded = true;
    hasOpened = false;
    pageIndex = widget.initalPageIndex;
    username = widget.username;
    hasExpanded = user.pref.detailsExpanded;
    if (widget.hasExpanded != null) {
      hasExpanded = widget.hasExpanded!;
    }
    if (username.equals("@me")) {
      pageHeadersMap[S.current.WeeklyAnime] = Icons.weekend;
    }
    scrollController = ScrollController(
        initialScrollOffset: hasExpanded ? 0.0 : pageHeaderSize);
    pageController = ScrollController();
    if (widget.initialStatus != null) {
      if (allListHeaders.contains(widget.initialStatus)) {
        initalIndex = allListHeaders.indexOf(widget.initialStatus!);
      }
    }
    controller = TabController(
        length: tabLength, vsync: this, initialIndex: initalIndex);

    previousStatus = user.status;
    startOpeningAnimation();
    Future.delayed(Duration.zero).then((value) {
      user.addListener(() {
        if (mounted) setState(() {});
        if (user.status != previousStatus &&
            user.status == AuthStatus.AUTHENTICATED) {
          getUserData();
        }
      });
    });
    if (username.notEquals("@me") || user.status == AuthStatus.AUTHENTICATED)
      getUserData();

    _initCountMap();
    _initRefreshMap();
  }

  void _initCountMap() {
    animeCountListener = StreamListener(_setCountMap(allAnimeStatusMap));
    mangaCountListener = StreamListener(_setCountMap(allMangaStatusMap));
  }

  void _resetCountMap() {
    animeCountListener.update(_setCountMap(allAnimeStatusMap));
    mangaCountListener.update(_setCountMap(allMangaStatusMap));
  }

  Map<String, int> _setCountMap(Map<String, String> map) {
    return Map.fromEntries(map.keys.map((e) => MapEntry(e, 0)));
  }

  _initRefreshMap() {
    contentTypes.forEach((type) {
      ([
        "all",
        ...(type.equals("anime") ? myAnimeStatusMap : myMangaStatusMap).keys
      ]).forEach((status) {
        refreshKeyMap['$status'] = MalAuth().getRandomString(26);
      });
    });
  }

  void getUserData() async {
    getUserProfile(refreshJikanFutures: true, fromCache: false);
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

  getUserProfile(
      {bool fromCache = true, bool refreshJikanFutures = false}) async {
    if (!fromCache & mounted) {
      setState(() {
        userProf = null;
        jikanUser = null;
      });
    }
    try {
      String _username = username;
      if (username.equals("@me")) {
        userProf = await MalUser.getUserInfo(
            fields: ["anime_statistics", "manga_statistics"],
            username: username,
            fromCache: fromCache);
        _username = userProf!.name!;
        if (mounted) setState(() {});
      }
      jikanUser = ((await JikanHelper.getUserInfo(
              username: _username, fromCache: fromCache))
          .data);
      if (mounted) setState(() {});
    } catch (e) {
      logDal(e);
    }
  }

  void resetData({bool profileCache = false}) {
    refreshKeyMap[currRefKey] = MalAuth().getRandomString(26);
    if (mounted) setState(() {});
    getUserProfile(fromCache: profileCache);
  }

  void changeCategory(String _category) {
    if (mounted) {
      category = _category;
      user.pref.userPageCategory = category;
      user.setIntance(updateAuth: false, shouldNotify: false);
      setState(() {});
      Future.delayed(const Duration(milliseconds: 100)).then((_) {
        _resetCountMap();
      });
    }
  }

  void changePage(int index) {
    if (mounted)
      setState(() {
        pageIndex = index;
      });
    Future.delayed(const Duration(milliseconds: 300)).then((value) {
      pageController?.animateTo(pageIndex * 160.0,
          duration: const Duration(milliseconds: 100), curve: Curves.ease);
    });
  }

  @override
  void didUpdateWidget(covariant UserPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category != null &&
        widget.category != null &&
        widget.category!.notEquals(oldWidget.category)) {
      changeCategory(widget.category!);
    }
  }

  @override
  void dispose() {
    super.dispose();
    controller?.dispose();
    scrollController?.dispose();
    animeCountListener.dispose();
    mangaCountListener.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: hasOpened ? 1 : 0,
      duration: Duration(milliseconds: 300),
      child:
          (username.notEquals("@me") || user.status == AuthStatus.AUTHENTICATED)
              ? userPaged()
              : _notAuthPage(),
    );
  }

  Widget _notAuthPage() {
    return Scaffold(
      body: SigninWidget(),
      appBar: PreferredSize(
          preferredSize: Size(double.infinity, kToolbarHeight),
          child: Padding(
            padding: const EdgeInsets.only(top: 35.0),
            child: AppBarHome(),
          )),
    );
  }

  static const int collapseIndex = 0;
  double get bottomSize => isListPage ? 150 : kToolbarHeight;
  double get bodySize => isListPage ? 170 : 80;
  bool get isListPage => pageIndex == 1;
  bool get isSocialPage => pageIndex == 3;
  double get pageHeaderSize => isListPage ? 420 : 350;
  List<String> get allListHeaders => [
        "all",
        ...(category.equals("anime") ? myAnimeStatusMap : myMangaStatusMap).keys
      ];

  List<String> displayHeaders(List<int?> data) => [
        ...(category.equals("anime") ? allAnimeStatusMap : allMangaStatusMap)
            .values
            .toList()
            .asMap()
            .entries
            .map((m) => '${m.value} (${data[m.key] ?? 0})')
      ];
  int get tabLength => isListPage ? allListHeaders.length : 1;
  String get currRefKey => allListHeaders[controller!.index];

  String get actualUsername =>
      jikanUser?.username ?? userProf?.name ?? username;

  int? get userId => userProf?.id ?? jikanUser?.malId;
  bool get callJikanApi => actualUsername.notEquals('@me');

  Widget userPaged() {
    if (!widget.isSelf) {
      return Stack(
        children: [_otherUserView(), _floatingCategoryChangeWIdget()],
      );
    }
    return NestedScrollView(
      key: PageStorageKey('${widget.username}'),
      headerSliverBuilder: (context, innerBoxIsScrolled) =>
          [_appBar(innerBoxIsScrolled)],
      body: _tabBarView(),
    );
  }

  Positioned _floatingCategoryChangeWIdget() {
    return Positioned(
      bottom: 20,
      left: 20,
      child: FloatingActionButton.extended(
        backgroundColor: Theme.of(context).canvasColor,
        elevation: 6.0,
        onPressed: () {},
        label: _categoryChangeWidget(),
      ),
    );
  }

  NestedScrollView _otherUserView() {
    return NestedScrollView(
      controller: widget.controller,
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) =>
          [SliverWrapper(animeBodyHeader())],
      body: _tabBarView(),
    );
  }

  TabBarView _tabBarView() {
    return TabBarView(
      controller: controller,
      children: allListHeaders.map(
        (e) => UserContentBuilder(
            key: PageStorageKey('$category-$e-${username}'),
            category: category,
            status: e,
            username: username,
            refreshKey: refreshKeyMap[e],
            listPadding:
                widget.isSelf ? null : const EdgeInsets.only(top: 60.0),
            controller: widget.controller,
            onContentUpdate: () => resetData(profileCache: true),
            onStatisticsUpdate: () => getUserProfile(fromCache: false),
            countChange: (count) async {
              try {
                final userContentCountMap = _listener.currentValue;
                if (userContentCountMap != null &&
                    userContentCountMap.containsKey(e)) {
                  userContentCountMap[e] = count;
                  _listener.update(userContentCountMap);
                }
              } catch (e) {
                logDal(e);
              }
            },
          ),
      ).toList(),
    );
  }

  StreamListener<Map<String, int?>> get _listener =>
      category.equals('anime') ? animeCountListener : mangaCountListener;

  SliverAppBar _appBar(bool innerBoxIsScrolled) {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: kToolbarHeight,
      forceElevated: innerBoxIsScrolled,
      actions: <Widget>[SB.z],
      pinned: true,
      floating: true,
      title: widget.isSelf
          ? AppBarHome(titleWidget: _categoryChangeWidget())
          : SB.z,
      titleSpacing: 0.0,
      bottom: animeBodyHeader(),
    );
  }

  AnimeMangaChangeWidget _categoryChangeWidget() {
    return AnimeMangaChangeWidget(
      category: category,
      onCategoryChange: (value) => changeCategory(value),
    );
  }

  Widget get userHeader {
    return FlexibleSpaceBar(
      centerTitle: true,
      collapseMode: CollapseMode.parallax,
      background: Column(children: [
        const SizedBox(height: 100),
        userProfile(),
        pageChangeWidget(),
      ]),
    );
  }

  Widget body(Widget child) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Builder(
        builder: (_) =>
            Padding(padding: EdgeInsets.only(top: bodySize), child: child),
      ),
    );
  }

  Widget userProfile() {
    return Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(13),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.max,
          children: [
            const SizedBox(width: 7),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  UserChart(
                    height: 140,
                    width: 140,
                    showTitle: true,
                    username: (userProf?.name ?? jikanUser?.username),
                    gender: userProf?.gender ?? jikanUser?.gender,
                    data: _userStatusData,
                    category: category,
                    imageUrl: userimageUrl,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (jikanUser?.location != null &&
                      jikanUser!.location!.isNotBlank)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 16,
                        ),
                        Container(
                          constraints: BoxConstraints(maxWidth: 120),
                          child: ToolTipButton(
                            message: "${jikanUser?.location ?? "?"}",
                            padding: EdgeInsets.only(left: 5),
                            child: title("${jikanUser?.location ?? "?"}",
                                textOverflow: TextOverflow.ellipsis),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      title(jikanUser?.username ?? userProf?.name ?? username,
                          opacity: 1, fontSize: 20),
                      if (actualUsername.isNotBlank &&
                          !actualUsername.equals("@me"))
                        ToolTipButton(
                          message: S.current.Open_In_Browser,
                          onTap: () => launchURLWithConfirmation(
                            '${CredMal.htmlEnd}profile/$actualUsername',
                            context: context,
                          ),
                          child: Icon(
                            Icons.open_in_new,
                            size: 12,
                          ),
                        )
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 16,
                        child: Image.asset("assets/images/star.png"),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      RichText(
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                            text: (category.equals("anime")
                                    ? (jikanUser?.statistics?.anime?.meanScore
                                            ?.toStringAsFixed(2) ??
                                        userProf?.animeStatistics?.meanScore
                                            ?.toStringAsFixed(2) ??
                                        "?")
                                    : (jikanUser?.statistics?.manga?.meanScore
                                            ?.toStringAsFixed(2) ??
                                        "?")) +
                                " ",
                            style: TextStyle(fontSize: 18),
                            children: [
                              TextSpan(
                                text: "(" +
                                    (category.equals("anime")
                                        ? (jikanUser?.statistics?.anime
                                                ?.totalEntries
                                                ?.toStringAsFixed(0) ??
                                            userProf?.animeStatistics?.numItems
                                                ?.toStringAsFixed(0) ??
                                            "?")
                                        : (jikanUser?.statistics?.manga
                                                ?.totalEntries
                                                ?.toStringAsFixed(0) ??
                                            "?")) +
                                    " entries)",
                                style: TextStyle(fontSize: 12),
                              )
                            ]),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  title((category.equals("anime")
                          ? (jikanUser?.statistics?.anime?.daysWatched
                                  ?.toStringAsFixed(2) ??
                              userProf?.animeStatistics?.numDaysWatched
                                  ?.toStringAsFixed(2) ??
                              "?")
                          : (jikanUser?.statistics?.manga?.daysRead
                                  ?.toStringAsFixed(2) ??
                              "?")) +
                      " Days"),
                  const SizedBox(
                    height: 5,
                  ),
                  title(category.equals("anime")
                      ? ((jikanUser?.statistics?.anime?.episodesWatched
                                  ?.toString() ??
                              userProf?.animeStatistics?.numEpisodes
                                  ?.toStringAsFixed(0) ??
                              "0") +
                          " Eps")
                      : ((jikanUser?.statistics?.manga?.chaptersRead
                                      ?.toString() ??
                                  "0") +
                              " Chps") +
                          " - " +
                          (jikanUser?.statistics?.manga?.volumesRead
                                  ?.toString() ??
                              "0") +
                          " Vols"),
                  if (!username.equals('@me') && userId != null) ...[
                    const SizedBox(
                      height: 15,
                    ),
                    Container(
                      height: 25,
                      child: PlainButton(
                        shape: btnBorder(context),
                        onPressed: () {},
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text(S.current.Report_User),
                      ),
                    ),
                  ] else
                    SB.h5
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<int?> get _userStatusData =>
      userStatusData(category, jikanUser, userProf, username.equals("@me"));

  String? get userimageUrl =>
      userProf?.picture ?? jikanUser?.images?.jpg?.imageUrl;

  PreferredSizeWidget animeBodyHeader() {
    return PreferredSize(
      preferredSize: Size(double.infinity, 48),
      child: StreamBuilder<Map<String, int?>>(
          initialData: _listener.initialData,
          stream: _listener.stream,
          builder: (context, snapshot) {
            final userContentCountMap = snapshot.data;
            var statusData = _userStatusData;
            statusData = [
              statusData.reduce((a, b) => (a ?? 0) + (b ?? 0)),
              ...statusData
            ];
            if (userContentCountMap != null) {
              userContentCountMap.entries.indexed.forEach((entry) {
                final index = entry.$1;
                final value = entry.$2;
                final count = value.value;
                if (count != null && count > 0 && count < 300) {
                  try {
                    statusData[index] = count;
                  } catch (e) {
                    logDal(e);
                  }
                }
              });
            }
            final _displayValues = displayHeaders(statusData);
            return TabBar(
              controller: controller,
              isScrollable: true,
              indicatorSize: TabBarIndicatorSize.label,
              tabAlignment: TabAlignment.start,
              tabs: _displayValues
                  .map((e) => Tab(
                        text: '${e.capitalizeAll()}',
                      ))
                  .toList(),
            );
          }),
    );
  }

  Widget showInfo(String titleText, String content) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(titleText),
        const SizedBox(
          height: 5,
        ),
        Text(content, style: TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget pageChangeWidget() {
    return Container(
      height: 35,
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(horizontal: 17, vertical: 5),
        scrollDirection: Axis.horizontal,
        itemCount: pageHeadersMap.length,
        controller: pageController,
        itemBuilder: (_, i) => HeaderButton(
            active: pageIndex == i,
            iconData: pageHeadersMap.values.elementAt(i),
            title: pageHeadersMap.keys.elementAt(i),
            onTap: () => i == collapseIndex ? scrollUp() : changePage(i)),
      ),
    );
  }

  scrollUp() {
    scrollController?.animateTo(pageHeaderSize,
        duration: const Duration(milliseconds: 400), curve: Curves.ease);
  }

  void jumpToContent({required ContentDetailedScreen page}) {
    navigateTo(context, page);
  }
}

class AnimeMangaChangeWidget extends StatelessWidget {
  final String category;
  final ValueChanged<String> onCategoryChange;
  const AnimeMangaChangeWidget(
      {super.key, required this.category, required this.onCategoryChange});

  @override
  Widget build(BuildContext context) {
    return ButtonSwitch(
      isLeftSelected: category.equals('anime'),
      leftText: 'Anime',
      rightText: 'Manga',
      onLeft: () => onCategoryChange('anime'),
      onRight: () => onCategoryChange('manga'),
    );
  }
}
