import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dailyanimelist/api/dalapi.dart';
import 'package:dailyanimelist/api/jikahelper.dart';
import 'package:dailyanimelist/api/malapi.dart';
import 'package:dailyanimelist/cache/history_data.dart';
import 'package:dailyanimelist/enums.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/main.dart';
import 'package:dailyanimelist/pages/animedetailed/adaptations.dart';
import 'package:dailyanimelist/pages/animedetailed/animecharacterwidget.dart';
import 'package:dailyanimelist/pages/animedetailed/animeforums.dart';
import 'package:dailyanimelist/pages/animedetailed/animepictures.dart';
import 'package:dailyanimelist/pages/animedetailed/animestatisticswidget.dart';
import 'package:dailyanimelist/pages/animedetailed/articlepage.dart';
import 'package:dailyanimelist/pages/animedetailed/intereststackwidget.dart';
import 'package:dailyanimelist/pages/animedetailed/media_platforms.dart';
import 'package:dailyanimelist/pages/animedetailed/recommanimewidget.dart';
import 'package:dailyanimelist/pages/animedetailed/relatedanimewidget.dart';
import 'package:dailyanimelist/pages/animedetailed/reviewpage.dart';
import 'package:dailyanimelist/pages/animedetailed/synopsiswidget.dart';
import 'package:dailyanimelist/pages/animedetailed/userupdates.dart';
import 'package:dailyanimelist/pages/animedetailed/videoswidget.dart';
import 'package:dailyanimelist/pages/settings/anime_manga_settings.dart';
import 'package:dailyanimelist/screens/forumtopicsscreen.dart';
import 'package:dailyanimelist/screens/generalsearchscreen.dart';
import 'package:dailyanimelist/screens/moreinfo.dart';
import 'package:dailyanimelist/screens/plainscreen.dart';
import 'package:dailyanimelist/user/anime_manga_tab_pref.dart';
import 'package:dailyanimelist/user/user.dart';
import 'package:dailyanimelist/util/pathutils.dart';
import 'package:dailyanimelist/util/streamutils.dart';
import 'package:dailyanimelist/widgets/autosize_copy_text.dart';
import 'package:dailyanimelist/widgets/avatarwidget.dart';
import 'package:dailyanimelist/widgets/background.dart';
import 'package:dailyanimelist/widgets/common/image_preview.dart';
import 'package:dailyanimelist/widgets/common/share_builder.dart';
import 'package:dailyanimelist/widgets/customappbar.dart';
import 'package:dailyanimelist/widgets/custombutton.dart';
import 'package:dailyanimelist/widgets/customfuture.dart';
import 'package:dailyanimelist/widgets/home/bookmarks_widget.dart';
import 'package:dailyanimelist/widgets/loading/expandedwidget.dart';
import 'package:dailyanimelist/widgets/shimmecolor.dart';
import 'package:dailyanimelist/widgets/slivers.dart';
import 'package:dailyanimelist/widgets/user/contenteditwidget.dart';
import 'package:dal_commons/commons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../constant.dart';

enum TitleLang { en, ja, ro }

class VisibleSection {
  final String title;
  final Widget child;
  final skipTitle;
  final bool isTab;
  final VoidCallback? onViewAll;

  VisibleSection(
    this.title,
    this.child, {
    this.isTab = true,
    this.onViewAll,
    this.skipTitle = false,
  });
}

class ContentDetailedScreen extends StatefulWidget {
  final Node? node;
  final int? id;
  final String category;
  final VoidCallback? onUpdateList;
  final String? heroTag;

  ContentDetailedScreen({
    this.node,
    this.id,
    this.category = "anime",
    this.onUpdateList,
    this.heroTag,
  });
  @override
  _ContentDetailedScreenState createState() => _ContentDetailedScreenState();
}

class _ContentDetailedScreenState extends State<ContentDetailedScreen>
    with TickerProviderStateMixin {
  static const horizPadding = 15.0;
  int pageIndex = 0;
  bool transition = false;
  bool showPromo = true;
  bool isCacheRefreshed = false;
  bool isContentLoaded = false;
  bool cacheRefreshFailed = false;
  bool showAdvancedEdit = false;
  bool isAnime = true;
  TitleLang titleLang = TitleLang.ro;
  dynamic contentDetailed;
  AnimeDetailedHtml? animeDetailedHtml;
  AnimeVideoV4? animeVideoV4;
  ForumTopicsHtml? forumTopicsHtml;
  late StreamListener<bool> fabListener;
  late Stream<bool> fabIsVisible;
  TabController? _tabController;
  AutoScrollController? _autoScrollController;
  NumberFormat userCountFormat =
      NumberFormat.currency(decimalDigits: 0, name: "");
  NumberFormat ratingFormat = NumberFormat.currency(name: "");
  int pageSelected = 0;
  String? promoVideoUrl;
  var visibleSections = <VisibleSection>[];
  var visibleTabSections = <String>[];

  ScrollController bodyHeaderController = new ScrollController();
  int episodesPage = 1;
  bool showContentEdit = false;
  final GlobalKey _listKey = GlobalKey();
  List<GlobalKey> _globalKeys = [];
  ScheduleData? _scheduleData;

  int get _id => (widget.node != null ? widget.node!.id : widget.id)!;
  String get _title =>
      widget.node?.title != null ? widget.node?.title : contentDetailed?.title;

  @override
  void initState() {
    super.initState();
    isAnime = widget.category.equals("anime");
    titleLang = user.pref.preferredAnimeTitle;
    _autoScrollController = AutoScrollController();
    _addFabListener();
    Future.delayed(Duration.zero).then((_) {
      getPageContent();
    });
  }

  void _addFabListener() {
    fabListener = StreamListener<bool>(true);
    fabIsVisible = fabListener.stream;
    _autoScrollController?.addListener(() {
      fabListener.update(_autoScrollController!.position.userScrollDirection ==
          ScrollDirection.forward);
    });
  }

  _setHistory() {
    final node = contentDetailed;
    if (node != null &&
        node.id != null &&
        node.title != null &&
        node.mainPicture != null)
      HistoryData.setHistory(
        dataType: isAnime ? HistoryDataType.anime : HistoryDataType.manga,
        value: node,
      );
  }

  getPageContent() {
    try {
      getMalApiContent();
      getMalApiHtmlContent();
      getJikanVideos();
      if (user.status != AuthStatus.AUTHENTICATED) {
        isCacheRefreshed = true;
      }
    } catch (e) {
      showToast(S.current.Couldnt_connect_network);
      cacheRefreshFailed = true;
      if (mounted) setState(() {});
      logDal(e);
    }
  }

  void getMalApiContent() async {
    contentDetailed = await (widget.category.equals('anime')
        ? MalApi.getAnimeDetails(_id)
        : MalApi.getMangaDetails(_id));
    await _setScheduleData();
    setStatus();
    updateVisibleSections();
    _setHistory();
  }

  Future<void> _setScheduleData() async {
    _scheduleData = (await DalApi.i.scheduleForMalIds)[_id];
  }

  void getMalApiHtmlContent() async {
    animeDetailedHtml =
        (await DalApi.i.getContent(widget.category, _id, htmlOnly: true)).html;
    updateVisibleSections();
  }

  void getJikanVideos() async {
    animeVideoV4 = await JikanHelper.getAnimeVideos(_id);
    updateVisibleSections();
  }

  void updateVisibleSections() {
    visibleSections = widget.category.equals("anime")
        ? _animeVisibleSections
        : widget.category.equals("manga")
            ? _mangaVisibleSections
            : [];
    visibleTabSections =
        visibleSections.where((e) => e.isTab).map((e) => e.title).toList();
    _tabController = TabController(
        length: visibleTabSections.length, vsync: this, initialIndex: 0);
    _globalKeys = List.generate(
      visibleSections.length,
      (index) => GlobalKey(debugLabel: index.toString()),
    );
    _autoScrollController?.addListener(() {
      if (_tabController != null) {
        _tabController!.index = _getCenterItemIndex();
      }
    });
    if (mounted) setState(() {});
  }

  setStatus() {
    if (user.status == AuthStatus.AUTHENTICATED &&
        contentDetailed != null &&
        mounted) {
      setState(() {
        isCacheRefreshed = true;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _autoScrollController?.dispose();
    _tabController?.dispose();
    fabListener.dispose();
  }

  List<VisibleSection> get _animeVisibleSections {
    return user.pref.animeMangaPagePreferences.animeTabs
        .map(_getAnimeSectionForType)
        .where((e) => e != null)
        .map((e) => e!)
        .toList();
  }

  VisibleSection _buildInterestStack() {
    return VisibleSection(
      S.current.Interest_Stacks,
      InterestStackContentList(
        horizPadding: horizPadding,
        interestStacks: animeDetailedHtml!.interestStacks!,
      ),
      onViewAll: _showInterestStackAll,
    );
  }

  bool get isStreamingBlank {
    return (animeDetailedHtml == null &&
            user.pref.preferredLinkType != LinkType.otherLists) ||
        _scheduleData?.relatedLinks == null &&
            nullOrEmpty(
              animeDetailedHtml?.links
                  ?.where((e) => e.url.isNotBlank && e.name.isNotBlank)
                  .toList(),
            );
  }

  Widget get _buildMediaWidget {
    final sp = AddtionalMediaPlatforms(
      animeDetailedHtml?.links ?? [],
      relatedLinks: _scheduleData?.relatedLinks,
    );
    final vW = VideosWidget(
      videos: animeVideoV4,
      horizPadding: horizPadding,
      endingSongs: contentDetailed?.endingSongs,
      openingSongs: contentDetailed?.openingSongs,
    );
    if (isAnimeVideosBlank) return sp;
    if (isStreamingBlank) return vW;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [sp, SB.h20, vW],
    );
  }

  List<VisibleSection> get _mangaVisibleSections {
    return user.pref.animeMangaPagePreferences.mangaTabs
        .map(_getMangaSectionForType)
        .where((e) => e != null)
        .map((e) => e!)
        .toList();
  }

  bool get isAnimeVideosBlank {
    if (animeVideoV4 == null) return true;
    if (nullOrEmpty(animeVideoV4?.episodes) &&
        nullOrEmpty(animeVideoV4?.musicVideos) &&
        nullOrEmpty(animeVideoV4?.promo) &&
        nullOrEmpty(contentDetailed?.openingSongs) &&
        nullOrEmpty(contentDetailed?.endingSongs)) return true;
    return false;
  }

  VisibleSection? _getAnimeSectionForType(AnimeMangaTabPreference pref) {
    if (!pref.visibility) return null;
    return switch (pref.tabType) {
      TabType.Adaptations => _nullIf(
          !nullOrEmpty(animeDetailedHtml?.adaptedNodes),
          () => VisibleSection(
                S.current.Adaptations,
                AdaptationsWidget(
                  imageUrl: _url,
                  nodes: animeDetailedHtml!.adaptedNodes!,
                ),
              )),
      TabType.Synopsis => _nullIf(
          contentDetailed != null,
          () => VisibleSection(
                S.current.Synopsis,
                SysonpsisWidget(
                  id: _id,
                  synopsis: contentDetailed.synopsis,
                  genres: contentDetailed.genres,
                  background: contentDetailed.background,
                  category: "anime",
                  horizPadding: horizPadding,
                  totalEpisodes: contentDetailed.numEpisodes,
                ),
              )),
      TabType.Media => _nullIf(
          (!isAnimeVideosBlank || !isStreamingBlank),
          () => VisibleSection(
                S.current.Media,
                _buildMediaWidget,
              )),
      TabType.Related => _nullIf(
          !nullOrEmpty(contentDetailed?.relatedAnime),
          () => VisibleSection(
                S.current.Related,
                RelatedAnimeWidget(
                  relatedAnimeList: contentDetailed.relatedAnime,
                  horizPadding: horizPadding,
                  id: _id,
                ),
                onViewAll: _relatedAll,
              )),
      TabType.Reviews => _nullIf(
          !nullOrEmpty(animeDetailedHtml?.animeReviewList),
          () => VisibleSection(
                S.current.Reviews,
                ContentReviewPage(
                  reviews: animeDetailedHtml!.animeReviewList!,
                  horizPadding: horizPadding,
                ),
                onViewAll: _reviewsShowAll,
              )),
      TabType.Recommendations => _nullIf(
          !nullOrEmpty(contentDetailed?.recommendations),
          () => VisibleSection(
                S.current.Recommendations,
                RecommendedAnimeWidget(
                  category: 'anime',
                  horizPadding: horizPadding,
                  recommAnime: contentDetailed.recommendations,
                ),
                onViewAll: _recommShowAll,
              )),
      TabType.Interest_Stacks => _nullIf(
          !nullOrEmpty(animeDetailedHtml?.interestStacks),
          () => _buildInterestStack()),
      TabType.Characters => _nullIf(
          !nullOrEmpty(animeDetailedHtml?.characterHtmlList),
          () => VisibleSection(
                S.current.Characters,
                AnimeCharacterWidget(
                  animeCharacterList: animeDetailedHtml!.characterHtmlList!,
                  horizPadding: horizPadding,
                ),
                onViewAll: _characterAll,
              )),
      TabType.Forums => _nullIf(
          !nullOrEmpty(animeDetailedHtml?.forumTopicsHtml?.data),
          () => VisibleSection(
                S.current.Forums,
                AnimeSubForum(
                  animeId: _id,
                  horizPadding: horizPadding,
                  topicsHtml: animeDetailedHtml!.forumTopicsHtml!,
                ),
                onViewAll: _forumShowAll,
              )),
      TabType.Related_Anime => null,
      TabType.Pictures => _nullIf(
          !nullOrEmpty(contentDetailed?.pictures),
          () => VisibleSection(
                S.current.Pictures,
                AnimePictures(
                  pictures: contentDetailed.pictures,
                  horizPadding: horizPadding,
                ),
              )),
      TabType.News => VisibleSection(
          S.current.News,
          ArticlePage(
            id: _id,
            horizPadding: horizPadding,
            additonalCategory: "news",
            category: widget.category,
          ),
        ),
      TabType.Featured_Articles => VisibleSection(
          S.current.Featured_Articles,
          ArticlePage(
            id: _id,
            horizPadding: horizPadding,
            additonalCategory: "featured",
            category: widget.category,
          ),
        ),
      TabType.User_Updates => VisibleSection(
          S.current.User_Updates,
          UserUpdatesPage(
            horizPadding: horizPadding,
            category: widget.category,
            id: _id,
          ),
        ),
      TabType.More_Info => _nullIf(
          contentDetailed != null,
          () => VisibleSection(
                S.current.More_Info,
                MoreInfoAnime(
                  contentDetailed: contentDetailed,
                  horizPadding: horizPadding,
                  additionalTitles: animeDetailedHtml?.additionalTitles,
                ),
              )),
      TabType.Stats => _nullIf(
          contentDetailed?.statistics != null,
          () => VisibleSection(
                S.current.Stats,
                AnimeStatisticsWidget(
                  statistics: contentDetailed.statistics,
                  horizPadding: horizPadding,
                ),
              )),
    };
  }

  Map<int, MyListStatus> _statusMap() {
    return Map.fromEntries(
        (contentDetailed.relatedAnime as List<RelatedContent>?)
                ?.map((e) {
                  var id = e.relatedNode?.id;
                  var myListStatus = e.relatedNode?.myListStatus;
                  if (id != null && myListStatus != null) {
                    return MapEntry(id, myListStatus);
                  }
                  return null;
                })
                .where((e) => e != null)
                .map((e) => e!)
                .toList() ??
            [])
      ..putIfAbsent(_id, () => contentDetailed.myListStatus);
  }

  T? _nullIf<T>(bool condition, T Function() child) {
    if (condition) {
      return child();
    } else {
      return null;
    }
  }

  VisibleSection? _getMangaSectionForType(AnimeMangaTabPreference pref) {
    if (!pref.visibility) return null;
    return switch (pref.tabType) {
      TabType.Synopsis => _nullIf(
          contentDetailed?.synopsis != null,
          () => VisibleSection(
                S.current.Synopsis,
                SysonpsisWidget(
                  id: _id,
                  synopsis: contentDetailed.synopsis,
                  genres: contentDetailed.genres,
                  background: contentDetailed.background,
                  category: "manga",
                  horizPadding: horizPadding,
                ),
              )),
      TabType.Media => null,
      TabType.Related => _nullIf(
          !nullOrEmpty(contentDetailed?.relatedManga),
          () => VisibleSection(
                S.current.Related,
                RelatedAnimeWidget(
                  relatedAnimeList: contentDetailed.relatedManga,
                  category: widget.category,
                  horizPadding: horizPadding,
                  id: _id,
                ),
                onViewAll: _relatedAll,
              )),
      TabType.Adaptations => _nullIf(
          !nullOrEmpty(animeDetailedHtml?.adaptedNodes),
          () => VisibleSection(
                S.current.Adaptations,
                AdaptationsWidget(
                  imageUrl: _url,
                  nodes: animeDetailedHtml!.adaptedNodes!,
                ),
              )),
      TabType.Reviews => _nullIf(
          !nullOrEmpty(animeDetailedHtml?.animeReviewList),
          () => VisibleSection(
                S.current.Reviews,
                ContentReviewPage(
                  reviews: animeDetailedHtml!.animeReviewList!,
                  horizPadding: horizPadding,
                  category: 'manga',
                ),
                onViewAll: _reviewsShowAll,
              )),
      TabType.Recommendations => _nullIf(
          !nullOrEmpty(contentDetailed?.recommendations),
          () => VisibleSection(
                S.current.Recommendations,
                RecommendedAnimeWidget(
                  recommAnime: contentDetailed.recommendations,
                  category: widget.category,
                  horizPadding: horizPadding,
                ),
                onViewAll: _recommShowAll,
              )),
      TabType.Interest_Stacks => _nullIf(
          !nullOrEmpty(animeDetailedHtml?.interestStacks),
          () => _buildInterestStack()),
      TabType.Characters => _nullIf(
          !nullOrEmpty(animeDetailedHtml?.mangaCharaList),
          () => VisibleSection(
                S.current.Characters,
                MangaCharacterWidget(
                  mangaCharacters: animeDetailedHtml!.mangaCharaList!,
                ),
                onViewAll: _onMangaCharacterViewAll,
              )),
      TabType.Forums => _nullIf(
          !nullOrEmpty(animeDetailedHtml?.forumTopicsHtml?.data),
          () => VisibleSection(
                S.current.Forums,
                AnimeSubForum(
                  animeId: _id,
                  horizPadding: horizPadding,
                  topicsHtml: animeDetailedHtml!.forumTopicsHtml!,
                ),
                onViewAll: _forumShowAll,
              )),
      TabType.Related_Anime => _nullIf(
          !nullOrEmpty(contentDetailed?.relatedAnime),
          () => VisibleSection(
                S.current.Related_Anime,
                RelatedAnimeWidget(
                  relatedAnimeList: contentDetailed.relatedAnime,
                  category: widget.category,
                  horizPadding: horizPadding,
                  id: _id,
                ),
              )),
      TabType.Pictures => _nullIf(
          !nullOrEmpty(contentDetailed?.pictures),
          () => VisibleSection(
                S.current.Pictures,
                AnimePictures(
                  pictures: contentDetailed.pictures,
                  horizPadding: horizPadding,
                ),
              )),
      TabType.News => VisibleSection(
          S.current.News,
          ArticlePage(
            id: _id,
            horizPadding: horizPadding,
            additonalCategory: "news",
            category: widget.category,
          ),
        ),
      TabType.Featured_Articles => VisibleSection(
          S.current.Featured_Articles,
          ArticlePage(
            id: _id,
            horizPadding: horizPadding,
            additonalCategory: "featured",
            category: widget.category,
          ),
        ),
      TabType.User_Updates => VisibleSection(
          S.current.User_Updates,
          UserUpdatesPage(
            horizPadding: horizPadding,
            category: widget.category,
            id: _id,
          ),
        ),
      TabType.More_Info => _nullIf(
          contentDetailed != null,
          () => VisibleSection(
                S.current.More_Info,
                MoreInfoAnime(
                  contentDetailed: contentDetailed,
                  category: "manga",
                  horizPadding: horizPadding,
                  additionalTitles: animeDetailedHtml?.additionalTitles,
                ),
              )),
      TabType.Stats => null,
    };
  }

  void _forumShowAll() {
    final screen = widget.category.equals("anime")
        ? ForumTopicsScreenLess(animeId: _id, padding: EdgeInsets.only(top: 20))
        : ForumTopicsScreenLess(
            mangaId: _id, padding: EdgeInsets.only(top: 20));
    gotoPage(
      context: context,
      newPage: TitlebarScreen(
        screen,
        appbarTitle: S.current.Forums,
        actions: [
          PopupMenuBuilder(
            menuItems: [
              browserMenuItem()
                ..onTap = () => launchURLWithConfirmation(
                    DalNode(
                            id: _id,
                            category: widget.category,
                            dalSubType: DalSubType.forum)
                        .toUrl(),
                    context: context),
            ],
          )
        ],
      ),
    );
  }

  void _reviewsShowAll() {
    gotoPage(
        context: context,
        newPage: TitlebarScreen(
          ContentReviewPage(
            reviews: animeDetailedHtml!.animeReviewList!,
            horizPadding: horizPadding,
            category: widget.category,
            axis: Axis.vertical,
            id: _id,
          ),
          useAppbar: false,
        ));
  }

  void _recommShowAll() {
    gotoPage(
        context: context,
        newPage: TitlebarScreen(
          ContentFullRecommendation(id: _id, category: widget.category),
          appbarTitle: S.current.Recommendations,
          actions: [
            PopupMenuBuilder(
              menuItems: [
                shareMenuItem()
                  ..onTap = () => openShareBuilder(
                        context,
                        [
                          ShareInput(
                              title: S.current.Url,
                              content: _buildRecommDalNode().toUrl()),
                          ...(contentDetailed.recommendations
                                  as List<Recommendation>)
                              .map((e) => ShareInput(
                                    title:
                                        '${e.numRecommendations} ${S.current.Recommendations}',
                                    content: buildShareOutput(
                                        buildShareInputs(
                                            e.recommNode,
                                            DalNode(
                                              category: widget.category,
                                              id: e.recommNode!.id!,
                                            ).toUrl()),
                                        props: ShareOutputProps(prefix: '\t')),
                                  ))
                              .toList()
                        ],
                        S.current.Recommendations,
                        props: ShareOutputProps(termSpace: '\n'),
                      ),
                bookMarkMenuItem(context),
                browserMenuItem()
                  ..onTap = () => launchURLWithConfirmation(
                      _buildRecommDalNode().toUrl(),
                      context: context)
              ],
            )
          ],
        ));
  }

  DalNode _buildRecommDalNode() {
    return DalNode(
      category: widget.category,
      id: _id,
      dalSubType: DalSubType.userrecs,
    );
  }

  void _relatedAll() {
    gotoPage(
        context: context,
        newPage: TitlebarScreen(
          RelatedAnimeWidget(
            relatedAnimeList: isAnime
                ? contentDetailed.relatedAnime
                : contentDetailed.relatedManga,
            category: widget.category,
            horizPadding: horizPadding,
            id: _id,
            displayType: DisplayType.grid,
            statusMap: _statusMap(),
          ),
          appbarTitle: S.current.Related,
          useAppbar: false,
        ));
  }

  void _characterAll() {
    gotoPage(
        context: context,
        newPage: TitlebarScreen(
          AllCharsWidget(
            category: widget.category,
            id: _id,
          ),
          appbarTitle: S.current.Characters_and_staff,
          actions: [
            PopupMenuBuilder(
              menuItems: [
                shareMenuItem()
                  ..onTap = () => openShareBuilder(
                      context,
                      [
                        ShareInput(
                            title: S.current.Url,
                            content: _buildCharactersNode().toUrl()),
                        ...animeDetailedHtml!.characterHtmlList!.map(
                          (e) => ShareInput(
                              title:
                                  '${e.characterName ?? "-"} (${e.characterType ?? "-"})',
                              content:
                                  '${e.seiyuuName ?? "-"} (${e.seiyuuOrigin ?? "-"})'),
                        )
                      ],
                      '${S.current.Characters}'),
                bookMarkMenuItem(context),
                browserMenuItem()
                  ..onTap = () => launchURLWithConfirmation(
                      _buildCharactersNode().toUrl(),
                      context: context)
              ],
            )
          ],
        ));
  }

  DalNode _buildCharactersNode() {
    return DalNode(
        id: _id, category: widget.category, dalSubType: DalSubType.characters);
  }

  void _showInterestStackAll() {
    gotoPage(
      context: context,
      newPage: TitlebarScreen(
        StateFullFutureWidget<List<InterestStack>>(
          done: (data) => InterestStackContentList(
            horizPadding: 0.0,
            interestStacks: data.data ?? [],
            type: DisplayType.list_vert,
          ),
          loadingChild: loadingCenterColored,
          future: () => DalApi.i
              .getInterestStackList(category: widget.category, categoryId: _id),
        ),
        appbarTitle: S.current.Interest_Stacks,
        actions: [
          PopupMenuBuilder(
            menuItems: [
              bookMarkMenuItem(context),
              browserMenuItem()
                ..onTap = () => launchURLWithConfirmation(
                    DalNode(
                      category: widget.category,
                      dalSubType: DalSubType.stacks,
                      id: _id,
                    ).toUrl(),
                    context: context),
            ],
          )
        ],
      ),
    );
  }

  void _onMangaCharacterViewAll() {
    gotoPage(
      context: context,
      newPage: TitlebarScreen(
        AllCharsWidget(
          category: widget.category,
          id: _id,
        ),
        appbarTitle: S.current.Characters_and_staff,
        actions: [
          PopupMenuBuilder(
            menuItems: [
              bookMarkMenuItem(context),
              browserMenuItem()
                ..onTap = () => launchURLWithConfirmation(
                      _mangaCharNode.toUrl(),
                      context: context,
                    )
            ],
          )
        ],
      ),
    );
  }

  DalNode get _mangaCharNode => DalNode(
        category: 'manga',
        dalSubType: DalSubType.characters,
        id: _id,
      );

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (showContentEdit && mounted) {
          setState(() {
            showContentEdit = false;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        floatingActionButtonLocation:
            showContentEdit ? FloatingActionButtonLocation.centerFloat : null,
        floatingActionButton: _floatingActionBtn(),
        floatingActionButtonAnimator: NoScalingAnimation(),
        body: Stack(
          children: [
            CustomScrollView(
              key: _listKey,
              controller: _autoScrollController,
              slivers: [
                _appBar,
                contentDetailedBody,
                SB.lh80,
              ],
            ),
            if (contentDetailed != null) ...[
              scrollStreamWidget(
                  Positioned(
                    bottom: 80.0,
                    right: 16.0,
                    child: _bookmarkTag(),
                  ),
                  (_) => _ && !showContentEdit)
            ],
            ExpandedSection(
              expand: showContentEdit,
              axisAlignment: 0.0,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 100),
                child: ContentEditWidget(
                  applyHero: false,
                  editMode: EditMode.floating,
                  category: widget.category,
                  contentDetailed: contentDetailed,
                  isCacheRefreshed: isCacheRefreshed,
                  applyPopScope: true,
                  onListStatusChange: (myListStatus) {
                    if (mounted)
                      setState(() {
                        contentDetailed.myListStatus = myListStatus;
                      });
                  },
                  onUpdate: (didUpdate) {
                    if (didUpdate) {
                      if (widget.onUpdateList != null) {
                        widget.onUpdateList!();
                      }
                    }
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget scrollStreamWidget(Widget child, bool Function(bool) onChange) {
    return StreamBuilder<bool>(
      stream: fabIsVisible,
      initialData: fabListener.initialData,
      builder: (context, snapshot) {
        final visible = snapshot.data ?? true;
        if (onChange(visible)) {
          return child;
        } else {
          return SB.z;
        }
      },
    );
  }

  SliverAppBar get _appBar {
    return SliverAppBar(
        pinned: true,
        floating: false,
        snap: false,
        expandedHeight: 460,
        toolbarHeight: 40.0,
        title: scrollStreamWidget(Text(animeTitle), (viseble) => !viseble),
        flexibleSpace: FlexibleSpaceBar(
          collapseMode: CollapseMode.pin,
          background: ShimmerConditionally(
            showShimmer: contentDetailed == null,
            child: animeHeader,
            baseColor: Theme.of(context).scaffoldBackgroundColor,
            highlightColor:
                Theme.of(context).scaffoldBackgroundColor.withOpacity(.3),
          ),
        ),
        bottom: tabBarWidget,
        actions: [
          IconButton(
              onPressed: () => gotoPage(
                  context: context,
                  newPage: GeneralSearchScreen(autoFocus: false)),
              icon: Icon(Icons.search)),
          AppMenuWidget(
            menuItems: _buildMenuItems,
            onUserTap: () {},
          ),
        ]);
  }

  List<AppbarMenuItem> get _buildMenuItems {
    return [
      shareMenuItem()
        ..onTap = () => openShareBuilder(
              context,
              buildShareInputs(
                contentDetailed,
                _getShareableContent(),
                title: animeTitle,
                category: widget.category,
              ),
              '$animeTitle - DailyAL',
              title:
                  '${S.current.Share} ${widget.category.standardize()} ${S.current.Preview}',
            ),
      browserMenuItem()
        ..onTap = () =>
            launchURLWithConfirmation(_getShareableContent(), context: context),
      bookMarkMenuItem(context),
      AppbarMenuItem(S.current.More_Info, Icon(Icons.info_outline),
          onTap: _openMoreInfo),
      if (isAnime)
        AppbarMenuItem(S.current.Customize_tabs, Icon(Icons.edit_square),
            onTap: _editAnimeMangaTabs),
      if (!isAnime)
        AppbarMenuItem(S.current.Customize_tabs, Icon(Icons.edit_square),
            onTap: _editAnimeMangaTabs),
    ];
  }

  FloatingActionButton _floatingActionBtn() {
    if (contentDetailed == null || !isCacheRefreshed) {
      return FloatingActionButton(
        child: loadingCenter(),
        onPressed: () {},
      );
    } else {
      final editIcon = Icon(showContentEdit ? Icons.close : Icons.edit);
      if (showContentEdit || contentDetailed.myListStatus?.status == null) {
        return FloatingActionButton(
          heroTag: 'compact-floating',
          onPressed: () => _onButtonPressed(),
          child: editIcon,
        );
      } else {
        return FloatingActionButton.extended(
          onPressed: () => _onButtonPressed(),
          isExtended: true,
          heroTag: 'extended-floating',
          icon: contentDetailed.myListStatus?.status != null
              ? text(combinedStatusMap[
                  (contentDetailed.myListStatus.status as String)]!)
              : SB.z,
          label: editIcon,
        );
      }
    }
  }

  _onButtonPressed() {
    if (mounted)
      setState(() {
        showContentEdit = !showContentEdit;
      });
  }

  PreferredSizeWidget get tabBarWidget {
    final tabBar = TabBar(
      isScrollable: true,
      controller: _tabController,
      tabAlignment: TabAlignment.start,
      onTap: (index) => _autoScrollController?.scrollToIndex(
        index,
        preferPosition: AutoScrollPosition.middle,
      ),
      tabs: visibleTabSections.map((e) => Tab(text: e)).toList(),
    );
    if (contentDetailed == null) {
      return PreferredSize(
          child: ShimmerColor(SB.z), preferredSize: Size(double.infinity, 40));
    } else {
      return tabBar;
    }
  }

  Widget get contentDetailedBody {
    if (contentDetailed == null) {
      return const SliverWrapper(const SysonpsisWidget());
    }
    return SliverList(
        delegate: SliverChildBuilderDelegate(
      ((context, index) => _buildVisibleSection(index)),
      childCount: visibleSections.length,
    ));
  }

  Widget _buildVisibleSection(int index) {
    final section = visibleSections[index];
    final sectionWidget = Column(
      children: [
        if (index != 0 && !section.skipTitle)
          Padding(
            padding: const EdgeInsets.only(
              left: horizPadding + 10,
              top: 25,
              right: horizPadding + 10,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                text(section.title, fontSize: 22),
                if (section.onViewAll != null) ...[
                  Expanded(child: SB.z),
                  Padding(
                    padding: const EdgeInsets.only(right: horizPadding),
                    child: PlainButton(
                      padding:
                          const EdgeInsets.symmetric(horizontal: horizPadding),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      onPressed: section.onViewAll,
                      child: Icon(Icons.arrow_forward),
                    ),
                  ),
                ]
              ],
            ),
          ),
        SB.h20,
        section.child,
        // SB.h10,
      ],
    );

    if (section.isTab) {
      final titleIndex = visibleTabSections.indexOf(section.title);
      return wrapScrollTag(
        controller: _autoScrollController!,
        index: titleIndex,
        child: SizedBox(
          key: _globalKeys[titleIndex],
          child: sectionWidget,
        ),
      );
    } else {
      return sectionWidget;
    }
  }

  List<double> _listViewBoundaries() {
    final listViewBox =
        _listKey.currentContext!.findRenderObject() as RenderBox?;
    final listViewTop = listViewBox!.localToGlobal(Offset.zero).dy;
    final listViewBottom = listViewTop + listViewBox.size.height;
    final listViewCenter = listViewTop + listViewBox.size.height / 2;
    return [listViewTop, listViewBottom, listViewCenter];
  }

  /// Got from https://medium.com/@tkarmakar27112000/renderbox-in-flutter-locating-center-widget-in-a-listview-builder-d00499059f19
  int _getCenterItemIndex() {
    final [_, listViewBottom, listViewCenter] = _listViewBoundaries();

    for (var i = 0; i < visibleTabSections.length; i++) {
      var itemTop = 0.0;
      var itemBottom = 0.0;
      try {
        final itemBox =
            _globalKeys[i].currentContext!.findRenderObject() as RenderBox?;
        itemTop = itemBox!.localToGlobal(Offset.zero).dy;
        itemBottom = itemTop + itemBox.size.height;
      } catch (e) {
        // handle exception if item is not visible
      }

      if (itemTop > listViewBottom) {
        break;
      }

      if (itemTop <= listViewCenter && itemBottom >= listViewCenter) {
        return i;
      }
    }

    return 0; // if no item is in the center of the screen
  }

  Widget langChangeWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          height: 25,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 30,
                child: ShadowButton(
                  padding: EdgeInsets.zero,
                  backgroundColor:
                      titleLang == TitleLang.ro ? null : Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12))),
                  onPressed: () {
                    if (mounted)
                      setState(() {
                        titleLang = TitleLang.ro;
                      });
                  },
                  child: Text(
                    "TI",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 12,
                        color: titleLang == TitleLang.ro ? null : Colors.white),
                  ),
                ),
              ),
              Container(
                width: 30,
                child: ShadowButton(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0)),
                  backgroundColor:
                      titleLang == TitleLang.en ? null : Colors.transparent,
                  onPressed: () {
                    if (mounted)
                      setState(() {
                        titleLang = TitleLang.en;
                      });
                  },
                  child: Text(
                    "EN",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 12,
                        color: titleLang == TitleLang.en ? null : Colors.white),
                  ),
                ),
              ),
              Container(
                width: 30,
                child: ShadowButton(
                  padding: EdgeInsets.zero,
                  backgroundColor:
                      titleLang == TitleLang.ja ? null : Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomRight: Radius.circular(12))),
                  onPressed: () {
                    if (mounted)
                      setState(() {
                        titleLang = TitleLang.ja;
                      });
                  },
                  child: Text(
                    "JA",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 12,
                        color: titleLang == TitleLang.ja ? null : Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget get animeDetailsHeader {
    return Padding(
      padding: EdgeInsets.only(left: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            contentDetailed?.rank == null
                ? "# ?"
                : "# " + contentDetailed.rank.toString(),
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 20),
          ),
          const SizedBox(
            height: 7,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                height: 22,
                child: Image.asset("assets/images/star.png"),
              ),
              const SizedBox(
                width: 5,
              ),
              Expanded(
                child: Text(
                    (contentDetailed?.mean == null
                            ? "?"
                            : ratingFormat.format(contentDetailed.mean)) +
                        " ",
                    style: TextStyle(fontSize: 26)),
              ),
            ],
          ),
          SB.h5,
          Text(
              (contentDetailed?.numScoringUsers == null
                      ? "?"
                      : userCountFormat
                          .format(contentDetailed.numScoringUsers)) +
                  " ${S.current.Users}",
              style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(
            height: 10,
          ),
          Text(
            (contentDetailed?.mediaType == null
                    ? "?"
                    : contentDetailed.mediaType.toUpperCase()) +
                " " +
                (widget.category.equals("anime")
                    ? (((contentDetailed?.numEpisodes != null &&
                            contentDetailed.numEpisodes == 0)
                        ? ""
                        : ("(" +
                            (contentDetailed?.numEpisodes == null
                                ? "?"
                                : contentDetailed.numEpisodes.toString()) +
                            " eps)")))
                    : (((contentDetailed?.numVolumes != null &&
                            contentDetailed.numVolumes == 0)
                        ? ""
                        : ("(" +
                            (contentDetailed?.numVolumes == null
                                ? "?"
                                : contentDetailed.numVolumes.toString()) +
                            " vols)")))),
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withOpacity(.7)),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            widget.category.equals("anime")
                ? S.current.Aired
                : S.current.Serialization,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.color
                    ?.withOpacity(.7)),
          ),
          const SizedBox(
            height: 3,
          ),
          Text(
            widget.category.equals("anime")
                ? ((contentDetailed?.startSeason?.season
                            ?.toString()
                            ?.capitalize() ??
                        "?") +
                    " " +
                    (contentDetailed?.startSeason?.year?.toString() ?? "?"))
                : ((contentDetailed?.serialization == null ||
                        contentDetailed.serialization.length == 0)
                    ? "?"
                    : (contentDetailed?.serialization
                            ?.map((e) => e.name)
                            ?.reduce(
                                (value, element) => value + "," + element)) ??
                        "?"),
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          SB.h10,
          Text(
            S.current.Popularity,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.color
                    ?.withOpacity(.7)),
          ),
          const SizedBox(
            height: 3,
          ),
          Text(
            "# " + (contentDetailed?.popularity?.toString() ?? '?'),
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall,
          ),
          SB.h10,
          Text(
            widget.category.equals("anime")
                ? S.current.Studios
                : S.current.Authors,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.color
                    ?.withOpacity(.7)),
          ),
          const SizedBox(
            height: 3,
          ),
          Text(
            widget.category.equals("anime")
                ? ((contentDetailed?.studios == null ||
                        contentDetailed.studios.length == 0)
                    ? "?"
                    : contentDetailed.studios
                        .map((e) => e.name)
                        .reduce((value, element) => value + "," + element))
                : ((contentDetailed?.authors == null ||
                        contentDetailed.authors.length == 0)
                    ? "?"
                    : contentDetailed.authors
                        .map((e) => e.author.firstName)
                        .reduce((value, element) => value + "," + element)),
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall,
          ),
          SB.h10,
          Text(
            S.current.Members,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.color
                    ?.withOpacity(.7)),
          ),
          const SizedBox(
            height: 3,
          ),
          Text(
            userCountFormat.format(contentDetailed?.numListUsers ?? 0.0) ?? '?',
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }

  Widget animeDetailsHeaderLoading() {
    return Padding(
      padding: EdgeInsets.only(top: 10, left: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 10,
          ),
          Container(
            width: 40,
            height: 10,
          ),
        ],
      ),
    );
  }

  Widget get animeHeader {
    final headerContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 35),
        _titleWidget,
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(child: const SizedBox()),
            Expanded(flex: 9, child: animeCard),
            if (user.pref.isRtl) Expanded(child: Container()),
            Expanded(flex: 7, child: animeDetailsHeader)
          ],
        ),
        const SizedBox(height: 15),
      ],
    );
    return Stack(children: [
      new Background(
        context: context,
        forceBg: user.pref.showAnimeMangaBg,
        url: widget.node?.mainPicture?.large != null
            ? widget.node?.mainPicture?.large
            : contentDetailed?.mainPicture?.large,
      ),
      if (contentDetailed != null)
        Material(
          color: Colors.transparent,
          child: headerContent,
        ),
      if (contentDetailed == null) headerContent
    ]);
  }

  Widget get _titleWidget {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: SizedBox(
        height: 40.0,
        width: double.infinity,
        child: Center(
          child: AutoSizeCopyText(
            animeTitle,
            style: TextStyle(fontSize: 24),
            overflow: TextOverflow.fade,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget get animeTitleWidget {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          animeTitle,
          style: TextStyle(fontSize: 24.0),
        ),
        langChangeWidget()
      ],
    );
  }

  String get animeTitle => titleLang == TitleLang.ro
      ? (contentDetailed?.title?.toString() ?? widget.node?.title ?? "?")
      : contentDetailed?.alternateTitles == null
          ? '?'
          : titleLang == TitleLang.en
              ? contentDetailed.alternateTitles.en.toString().equals("")
                  ? (widget.node?.title ?? contentDetailed?.title?.toString())
                  : contentDetailed.alternateTitles.en.toString()
              : contentDetailed.alternateTitles.ja.toString().equals("")
                  ? (widget.node?.title ?? contentDetailed?.title?.toString())
                  : contentDetailed.alternateTitles.ja;

  Widget _heroWrapper(Widget child) {
    if (widget.heroTag != null) {
      return Hero(
        tag: widget.heroTag!,
        child: child,
      );
    } else {
      return child;
    }
  }

  String get _url =>
      widget.node?.mainPicture?.large ??
      contentDetailed?.mainPicture?.large ??
      "";

  Widget get animeCard {
    final urlList = [_url];
    if (!nullOrEmpty(contentDetailed?.pictures)) {
      List<String> list = (contentDetailed.pictures as List<Picture>)
          .map((e) => e.large ?? e.medium ?? "")
          .toList();
      urlList.addAll(list);
    }
    return _heroWrapper(
      SizedBox(
        height: 320.0,
        child: Stack(
          children: [
            InkWell(
              onTap: () => zoomInImageList(context, urlList),
              borderRadius: BorderRadius.circular(6),
              child: CachedNetworkImage(
                imageUrl: urlList.first,
                placeholder: (context, url) => loadingInner(),
                errorWidget: (context, url, error) => loadingError(),
                imageBuilder: (context, imageProvider) => Ink(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      image: DecorationImage(
                          fit: BoxFit.cover, image: imageProvider)),
                ),
              ),
            ),
            Positioned(top: 5, right: 5, child: langChangeWidget()),
            Positioned(bottom: 5, right: 5, child: _moreInfoButton()),
          ],
        ),
      ),
    );
  }

  SizedBox _moreInfoButton() {
    return SizedBox(
      width: 40,
      height: 40,
      child: ShadowButton(
        padding: EdgeInsets.zero,
        onPressed: () => _openMoreInfo(),
        child: Icon(Icons.info),
      ),
    );
  }

  Widget _bookmarkTag() {
    if (contentDetailed == null) return SB.z;
    return BookMarkFloatingButton(
      type: BookmarkType.values.byName(widget.category),
      id: _id,
      data: _getNode(),
      addIcon: Icons.bookmark_outline,
      removeIcon: Icons.bookmark,
    );
  }

  Node _getNode() {
    return Node(
      id: _id,
      title: _title,
      nodeCategory: widget.category,
      mainPicture: Picture(large: _url, medium: _url),
    );
  }

  Future<bool> _openMoreInfo() {
    return openAlertDialog(
      context: context,
      title: S.current.More_Information,
      useDefaultBtns: false,
      additionalAction: alertButton(context, S.current.Close),
      contentPadding:
          const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
      insetPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 24.0),
      content: MoreInfoAnime(
        category: widget.category,
        contentDetailed: contentDetailed,
        horizPadding: 0,
        isModal: true,
        additionalTitles: animeDetailedHtml?.additionalTitles,
      ),
    );
  }

  Future<bool> _editAnimeMangaTabs() {
    final tabs = isAnime
        ? user.pref.animeMangaPagePreferences.animeTabs
        : user.pref.animeMangaPagePreferences.mangaTabs;
    return openAlertDialog(
      context: context,
      title: S.current.Customize_tabs,
      useDefaultBtns: false,
      additionalAction: alertButton(context, S.current.Close),
      contentPadding:
          const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      insetPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 24.0),
      content: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: 320.0,
        child: SingleChildScrollView(
          child: AnimeMangaPageTabEdit(
            '',
            tabs,
            onListChange: () {
              user.setIntance(shouldNotify: false, updateAuth: false);
              updateVisibleSections();
            },
            showAccordion: false,
          ),
        ),
      ),
    );
  }

  String _getShareableContent() {
    return DalPathUtils.browserUrl(
      DalNode(
        category: widget.category,
        id: _id,
        title: _title?.getFormattedTitleForHtml() ?? '_',
      ),
    );
  }
}

class NoScalingAnimation extends FloatingActionButtonAnimator {
  late double _x;
  late double _y;
  @override
  Offset getOffset(
      {required Offset begin, required Offset end, required double progress}) {
    _x = begin.dx + (end.dx - begin.dx) * progress;
    _y = begin.dy + (end.dy - begin.dy) * progress;
    return Offset(_x, _y);
  }

  @override
  Animation<double> getRotationAnimation({required Animation<double> parent}) {
    return Tween<double>(begin: 1.0, end: 1.0).animate(parent);
  }

  @override
  Animation<double> getScaleAnimation({required Animation<double> parent}) {
    return Tween<double>(begin: 1.0, end: 1.0).animate(parent);
  }
}

