import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dailyanimelist/api/credmal.dart';
import 'package:dailyanimelist/api/dalapi.dart';
import 'package:dailyanimelist/api/maluser.dart';
import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/enums.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/main.dart';
import 'package:dailyanimelist/pages/animedetailed/intereststackwidget.dart';
import 'package:dailyanimelist/pages/animedetailed/reviewpage.dart';
import 'package:dailyanimelist/pages/search/all_genre_widget.dart';
import 'package:dailyanimelist/pages/search/allrankingwidget.dart';
import 'package:dailyanimelist/pages/search/seasonalwidget.dart';
import 'package:dailyanimelist/screens/characterscreen.dart';
import 'package:dailyanimelist/screens/contentdetailedscreen.dart';
import 'package:dailyanimelist/screens/generalsearchscreen.dart';
import 'package:dailyanimelist/screens/plainscreen.dart';
import 'package:dailyanimelist/user/user.dart';
import 'package:dailyanimelist/widgets/avatarwidget.dart';
import 'package:dailyanimelist/widgets/custombutton.dart';
import 'package:dailyanimelist/widgets/customfuture.dart';
import 'package:dailyanimelist/widgets/home/animecard.dart';
import 'package:dailyanimelist/widgets/homeappbar.dart';
import 'package:dailyanimelist/widgets/loading/loadingcard.dart';
import 'package:dailyanimelist/widgets/shimmecolor.dart';
import 'package:dailyanimelist/widgets/translator.dart';
import 'package:dal_commons/commons.dart';
import 'package:flutter/material.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  static const horizPadding = 20.0;
  static final radius = 12.0;
  static final borderRadius = BorderRadius.circular(radius);
  UserProf? userProf;
  String category = 'anime';

  @override
  void initState() {
    super.initState();
    if (user.status == AuthStatus.AUTHENTICATED) getUserProfile();
    user.addListener(() {
      if (user.status == AuthStatus.AUTHENTICATED) getUserProfile();
    });
  }

  bool get isAnime => category.equals('anime');

  getUserProfile() async {
    try {
      userProf = await MalUser.getUserInfo(
          fields: ["anime_statistics", "manga_statistics"], fromCache: true);
      if (mounted) setState(() {});
    } catch (e) {
      logDal(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SB.lh35,
        _wrapSliver(AppBarHome(
          onUiChange: () {
            if (mounted) setState(() {});
          },
        )),
        _buildAnimeMangaPicker,
        SB.lh20,
        _wrapSliver(_randomPickerWidget),
        SB.lh30,
        _wrapSliver(
          _leadingWidget(
            VisibleSection(
                S.current.Categories, AllRankingWidget(category: category)),
          ),
        ),
        _wrapSliver(
          AllGenreWidget(category: category),
        ),
        SliverList(
            delegate: SliverChildBuilderDelegate(
          (context, index) => slivers.elementAt(index),
          childCount: slivers.length,
        )),
        SB.lh80,
      ],
    );
  }

  List<Widget> get slivers => isAnime ? _animeSlivers : _mangaSlivers;

  List<Widget> get _animeSlivers => [
        _leadingWidget(
          VisibleSection(S.current.Seasonal, SeasonalWidget()),
        ),
        SB.h20,
        _leadingWidget(
          VisibleSection(
            S.current.Recommendations,
            RecomBuilderWidget('anime'),
            onViewAll: () => gotoPage(
              context: context,
              newPage: TitlebarScreen(
                RecomBuilderWidget(
                  'anime',
                  axis: Axis.vertical,
                  verticalPadding: 30,
                ),
                appbarTitle: S.current.Recommendations,
              ),
            ),
          ),
        ),
        SB.h20,
        _leadingWidget(
          VisibleSection(S.current.Reviews, _reviewsBuilder('anime'),
              onViewAll: () => _reviewsShowAll('anime')),
        ),
        SB.h20,
        _leadingWidget(VisibleSection(
          S.current.Interest_Stacks,
          _interestStackBuilder('anime'),
          onViewAll: () => _onInterestStackAll('anime'),
        )),
        SB.h20,
        _leadingWidget(
          VisibleSection(S.current.Characters, _characterBuilder),
        ),
        SB.h20,
        _leadingWidget(
          VisibleSection(S.current.Seiyuu, _seiyuuBuilder),
        ),
      ];

  List<Widget> get _mangaSlivers => [
        _leadingWidget(
          VisibleSection(
            S.current.Recommendations,
            RecomBuilderWidget('manga'),
            onViewAll: () => gotoPage(
              context: context,
              newPage: TitlebarScreen(
                RecomBuilderWidget(
                  'manga',
                  axis: Axis.vertical,
                  verticalPadding: 30,
                ),
                appbarTitle: S.current.Recommendations,
              ),
            ),
          ),
        ),
        SB.h20,
        _leadingWidget(
          VisibleSection(S.current.Reviews, _reviewsBuilder('manga'),
              onViewAll: () => _reviewsShowAll('manga')),
        ),
        SB.h20,
        _leadingWidget(
          VisibleSection(
            S.current.Interest_Stacks,
            _interestStackBuilder('manga'),
            onViewAll: () => _onInterestStackAll('manga'),
          ),
        ),
        SB.h20,
        _leadingWidget(
          VisibleSection(S.current.Characters, _characterBuilder),
        ),
        SB.h20,
        _leadingWidget(
          VisibleSection(S.current.Seiyuu, _seiyuuBuilder),
        ),
      ];

  Widget _reviewsBuilder(String revCat, [Axis axis = Axis.horizontal]) {
    return StateFullFutureWidget<List<AnimeReviewHtml>>(
      done: (p0) => ContentReviewPage(
        reviews: p0.data ?? [],
        horizPadding: horizPadding,
        category: revCat,
        axis: axis,
        selectSortBy: S.current.Date,
      ),
      loadingChild: loadingCardList(
        axis: axis,
        containerHeight: axis == Axis.horizontal ? 330 : null,
        height: 300,
        width: 300,
        listPadding: EdgeInsets.symmetric(horizontal: horizPadding),
      ),
      future: () => DalApi.i.getReviews(category: revCat),
      refKey: revCat,
    );
  }

  void _reviewsShowAll(String revCat) {
    gotoPage(
        context: context,
        newPage: TitlebarScreen(
          _reviewsBuilder(revCat, Axis.vertical),
          useAppbar: false,
        ));
  }

  Widget get _characterBuilder {
    return StateFullFutureWidget<CharacterListData>(
      future: () => DalApi.i.getCharacters(),
      done: (data) => _characterPeopleListWidget(
          data?.data?.data?.map((e) => CharPeopleCommon.fromChar(e)).toList()),
      loadingChild: _characterPeopleListWidget(null),
    );
  }

  Widget get _seiyuuBuilder {
    return StateFullFutureWidget<PeopleListData>(
      future: () => DalApi.i.getPeople(),
      done: (data) => _characterPeopleListWidget(
          data?.data?.data
              ?.map((e) => CharPeopleCommon.fromPerson(e))
              ?.toList(),
          'person'),
      loadingChild: _characterPeopleListWidget(null),
    );
  }

  Widget _characterPeopleListWidget(List<CharPeopleCommon?>? charData,
      [String extraCategory = 'character']) {
    if (nullOrEmpty(charData)) {
      charData = List.generate(12, (index) => null);
    }

    return Container(
      height: 210,
      child: ListView.builder(
        itemCount: charData!.length,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: horizPadding),
        itemBuilder: (context, index) {
          final data = charData![index];
          if (data == null) {
            return ShimmerColor(LoadingCard(width: 140));
          }
          final imageUrl = data.image?.large ?? data.image?.medium;
          final textTheme = Theme.of(context).textTheme;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Container(
              width: 160,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SB.h20,
                            Text('Rank', style: textTheme.bodySmall),
                            SB.h5,
                            Text(
                              data.rank?.toString() ?? '',
                              style: textTheme.displaySmall,
                            ),
                            SB.h20,
                            Icon(Icons.favorite),
                            SB.h5,
                            AutoSizeText(
                              userCountFormat.format(data?.favorites ?? 0),
                              maxLines: 1,
                            )
                          ],
                        ),
                      ),
                      SB.w10,
                      Container(
                        width: 110,
                        height: 160,
                        child: Material(
                          borderRadius: borderRadius,
                          elevation: 6,
                          child: InkWell(
                            borderRadius: borderRadius,
                            onTap: () => gotoPage(
                              context: context,
                              newPage: CharacterScreen(
                                charaCategory: extraCategory,
                                id: data.id,
                              ),
                            ),
                            child: cachedImage(borderRadius, imageUrl,
                                userRoundBorderforLoading: false),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SB.h10,
                  Text(
                    data.name ?? '',
                    style: textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (data.otherName != null && data.otherName!.isNotBlank) ...[
                    SB.h5,
                    Text(
                      data.otherName ?? '',
                      style: textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    )
                  ]
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget get _buildAnimeMangaPicker {
    final onAnimePressed = () {
      setState(() {
        category = 'anime';
      });
    };
    final onMangaPressed = () {
      setState(() {
        category = 'manga';
      });
    };
    return SliverAppBar(
      automaticallyImplyLeading: false,
      pinned: true,
      floating: true,
      snap: false,
      toolbarHeight: kToolbarHeight,
      expandedHeight: 0,
      bottom: PreferredSize(
        preferredSize: Size(double.infinity, kToolbarHeight),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            height: 35,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isAnime)
                  ShadowButton(
                    onPressed: onAnimePressed,
                    child: Text('Anime'),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 4),
                  )
                else
                  BorderButton(
                    child: Text('Anime'),
                    onPressed: onAnimePressed,
                  ),
                SB.w20,
                if (!isAnime)
                  ShadowButton(
                    onPressed: onAnimePressed,
                    child: Text('Manga'),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 4),
                  )
                else
                  BorderButton(
                    onPressed: onMangaPressed,
                    child: Text('Manga'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _wrapSliver(Widget child) {
    return SliverToBoxAdapter(child: child);
  }

  Widget get _randomPickerWidget {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: horizPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _randomButton(
            S.current.Random,
            Colors.green,
            Color.fromARGB(255, 43, 49, 43),
            Icons.shuffle,
            () => openFutureAndNavigate<int?>(
              text: isAnime
                  ? S.current.Loading_Random_Anime
                  : S.current.Loading_Random_Manga,
              future: DalApi.i.getRandom(category),
              onData: _onGetId,
              context: context,
            ),
          ),
          SB.w10,
          _randomButton(
            isAnime ? S.current.Watching : S.current.Reading,
            Colors.amber,
            Color.fromARGB(255, 126, 94, 0),
            isAnime ? Icons.tv : Icons.book,
            () => _openRandomWithStatus(
                isAnime ? MyStatus.watching : MyStatus.reading),
          ),
          SB.w10,
          _randomButton(
            isAnime ? S.current.Plan_To_Watch : S.current.Plan_To_Read,
            Colors.orange,
            Color.fromARGB(255, 98, 59, 0),
            Icons.history,
            () => _openRandomWithStatus(
                isAnime ? MyStatus.planToWatch : MyStatus.planToRead),
          ),
        ],
      ),
    );
  }

  Widget? _onGetId(id) {
    if (id == null) {
      showToast(S.current.Couldnt_connect_network);
      return null;
    }
    return ContentDetailedScreen(id: id, category: category);
  }

  void _openRandomWithStatus(String status) {
    if (user.status == AuthStatus.AUTHENTICATED) {
      openFutureAndNavigate<int?>(
        text:
            '${isAnime ? S.current.Loading_Random_Anime_From : S.current.Loading_Random_Manga_From} \'$status\' list',
        future: DalApi.i.getRandomFromList(category, status),
        onData: _onGetId,
        context: context,
        customError: '${S.current.No_Item_Found_In_Your} \'$status\' list',
      );
    } else {
      showToast(S.current.User_not_Logged_in);
    }
  }

  Widget _randomButton(
    String text,
    Color iconColor,
    Color overlayColor,
    IconData iconData,
    VoidCallback onPressed,
  ) {
    return ShadowButton(
      onPressed: onPressed,
      elevation: 12.0,
      overlayColor: overlayColor,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(iconData, size: 26, color: iconColor),
          SB.w10,
          Text(
            text,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _leadingWidget(VisibleSection section, [double padding = 25.0]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _titleWidget(section),
        Padding(
          padding: EdgeInsets.only(top: padding),
          child: section.child,
        ),
      ],
    );
  }

  Padding _titleWidget(VisibleSection section) {
    return Padding(
      padding: const EdgeInsets.only(
        left: horizPadding + 10,
        top: 0,
        right: horizPadding + 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(section.title, style: Theme.of(context).textTheme.titleLarge),
          if (section.onViewAll != null) ...[
            Expanded(child: SB.z),
            Padding(
              padding: const EdgeInsets.only(right: horizPadding),
              child: IconButton(
                onPressed: section.onViewAll,
                icon: Icon(Icons.arrow_forward_outlined),
              ),
            )
          ]
        ],
      ),
    );
  }

  void _onInterestStackAll(String category) {
    gotoPage(
      context: context,
      newPage: TitlebarScreen(
        _interestStackBuilder(category, Axis.vertical),
        appbarTitle: S.current.Interest_Stacks,
      ),
    );
  }

  Widget _interestStackBuilder(String category, [Axis axis = Axis.horizontal]) {
    return StateFullFutureWidget<List<InterestStack>>(
      done: (sp) => _interestStackList(sp.data ?? [], axis),
      loadingChild: _interestStackList([], axis),
      future: () => DalApi.i.searchInterestStacksAsList(type: category),
    );
  }

  Widget _interestStackList(List<InterestStack> interestStacks,
      [Axis axis = Axis.horizontal]) {
    if (nullOrEmpty(interestStacks))
      return axis != Axis.horizontal
          ? loadingCenterColored
          : loadingCardList(
              axis: Axis.horizontal,
              containerHeight: 240.0,
              height: 220,
              width: 260,
              listPadding: EdgeInsets.symmetric(horizontal: horizPadding),
            );

    return InterestStackContentList(
      horizPadding: horizPadding,
      interestStacks: interestStacks,
      type: axis == Axis.horizontal
          ? DisplayType.list_horiz
          : DisplayType.list_vert,
    );
  }
}

class CharPeopleCommon {
  late int id;
  int? rank;
  String? name;
  String? otherName;
  RefImage? image;
  int? favorites;

  CharPeopleCommon({
    required this.id,
    this.rank,
    this.name,
    this.otherName,
    this.image,
    this.favorites,
  });

  CharPeopleCommon.fromChar(CharData data) {
    id = data.id!;
    rank = data.rank;
    name = data.name;
    otherName = data.otherName;
    image = data.image;
    favorites = data.favorites;
  }

  CharPeopleCommon.fromPerson(PeopleData data) {
    id = data.id!;
    rank = data.rank;
    name = data.name;
    otherName = data.birthday;
    image = data.image;
    favorites = data.favorites;
  }
}

class RecomBuilderWidget extends StatelessWidget {
  final String category;
  final Axis axis;
  final double verticalPadding;
  const RecomBuilderWidget(
    this.category, {
    Key? key,
    this.axis = Axis.horizontal,
    this.verticalPadding = 0.0,
  }) : super(key: key);
  static const horizPadding = 20.0;
  static final radius = 12.0;
  static final radiusCircular = Radius.circular(radius);
  static final borderRadius = BorderRadius.circular(radius);

  @override
  Widget build(BuildContext context) {
    return StateFullFutureWidget<List<RecomCompare?>?>(
      done: (data) => _recommendationsWidget(data?.data),
      loadingChild: _recommendationsWidget(),
      future: () => DalApi.i.getRecommendations(category),
      refKey: category,
    );
  }

  bool get isHoriz => axis == Axis.horizontal;

  Widget _recommendationsWidget([List<RecomCompare?>? list]) {
    if (nullOrEmpty(list)) {
      list = List.generate(6, (index) => null).toList();
    }
    return Container(
      height: isHoriz ? 330 : null,
      child: ListView.builder(
        itemCount: list!.length,
        scrollDirection: axis,
        padding: EdgeInsets.symmetric(
            horizontal: isHoriz ? (horizPadding + 10) : 15.0,
            vertical: verticalPadding),
        itemBuilder: (context, index) {
          final item = list![index];
          if (item == null)
            return ShimmerColor(LoadingCard(
              width: 240,
              height: 310,
            ));
          final imageProvider = (Node node) => CachedNetworkImageProvider(
              node.mainPicture?.large ?? node.mainPicture?.medium ?? '');
          final inkwellNode = (Node node) => InkWell(
                borderRadius: borderRadius,
                onTap: () => gotoPage(
                  context: context,
                  newPage: ContentDetailedScreen(
                    id: node.id,
                    category: category,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: imageProvider(node),
                      ),
                      SB.w20,
                      Expanded(
                        child: title(
                          node.title,
                          textOverflow: TextOverflow.ellipsis,
                        ),
                      )
                    ],
                  ),
                ),
              );

          return Padding(
            padding: EdgeInsets.only(
                right: isHoriz ? horizPadding : 0.0, bottom: 10),
            child: Container(
              width: isHoriz ? 300 : double.infinity,
              child: Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SB.h10,
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: title(S.current.If_You_Liked, opacity: 1),
                      ),
                      SB.h10,
                      inkwellNode(item.first!),
                      SB.h10,
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: title(S.current.Then_You_Might, opacity: 1),
                      ),
                      SB.h10,
                      inkwellNode(item.second!),
                      SB.h15,
                      ToolTipButton(
                        message:
                            '${S.current.Recommendation_made_by} ${item.username}',
                        onTap: () => showUserPage(
                            context: context, username: item.username!),
                        child: title('by ' + (item.username ?? '?')),
                      ),
                      SB.h5,
                      conditional(
                        on: isHoriz,
                        parent: (child) => Expanded(child: child),
                        child: TranslaterWidget(
                          content: item.text,
                          buttonPadding: EdgeInsets.zero,
                          done: (data) => conditional(
                            on: isHoriz,
                            child: title(
                              data,
                              textOverflow: TextOverflow.fade,
                              selectable: true,
                              opacity: .9,
                            ),
                            parent: (child) => Expanded(child: child),
                          ),
                        ),
                      ),
                      SB.h5,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          title(item.timeAgo),
                          ToolTipButton(
                            message: S.current.Report_Recommendation,
                            onTap: () => reportWithConfirmation(
                              type: ReportType.recommendation,
                              context: context,
                              content: title(
                                  '${S.current.Recommendation_made_by} ${item.username} & id: ${item.id}'),
                              optionalUrl:
                                  '${CredMal.htmlEnd}dbchanges.php?go=reportanimerecommendation&id=${item.id}',
                            ),
                            child: title(S.current.Report),
                          ),
                        ],
                      ),
                      SB.h10,
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
