import 'package:dailyanimelist/api/dalapi.dart';
import 'package:dailyanimelist/api/jikahelper.dart';
import 'package:dailyanimelist/api/malapi.dart';
import 'package:dailyanimelist/api/malforum.dart';
import 'package:dailyanimelist/api/maluser.dart';
import 'package:dailyanimelist/cache/history_data.dart';
import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/enums.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/main.dart';
import 'package:dailyanimelist/pages/animedetailed/intereststackwidget.dart';
import 'package:dailyanimelist/pages/search/allrankingwidget.dart';
import 'package:dailyanimelist/pages/search/seasonalwidget.dart';
import 'package:dailyanimelist/screens/contentdetailedscreen.dart';
import 'package:dailyanimelist/screens/plainscreen.dart';
import 'package:dailyanimelist/user/user.dart';
import 'package:dailyanimelist/util/streamutils.dart';
import 'package:dailyanimelist/widgets/club/clublistwidget.dart';
import 'package:dailyanimelist/widgets/custombutton.dart';
import 'package:dailyanimelist/widgets/customfuture.dart';
import 'package:dailyanimelist/widgets/forum/forumtopicwidget.dart';
import 'package:dailyanimelist/widgets/loading/expandedwidget.dart';
import 'package:dailyanimelist/widgets/search/filtermodal.dart';
import 'package:dailyanimelist/widgets/search/sliderwidget.dart';
import 'package:dailyanimelist/widgets/selectbottom.dart';
import 'package:dailyanimelist/widgets/slivers.dart';
import 'package:dailyanimelist/widgets/user/contentlistwidget.dart';
import 'package:dal_commons/commons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

List<BaseNode> searchBaseNodes(List<BaseNode> base, String text) {
  final filtered = base.where((f) {
    final e = f.content;
    if (e == null) return false;
    bool found = false;
    final title = e.title?.toLowerCase();
    if (title != null && title.isNotBlank) {
      found = title.contains(text);
      if (!found && e is AnimeDetailed) {
        final en = e.alternateTitles?.en?.toLowerCase();
        final ja = e.alternateTitles?.ja?.toLowerCase();
        if (en != null && ja != null) {
          found = en.contains(text) || ja.contains(text);
        }
      }
    }
    return found;
  });
  return filtered.toList();
}

class FadedScreenRoute extends MaterialPageRoute {
  FadedScreenRoute(
      {required WidgetBuilder builder, required RouteSettings settings})
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return new FadeTransition(opacity: animation, child: child);
  }
}

class GeneralSearchScreen extends StatefulWidget {
  final String? searchQuery;
  final bool? autoFocus;
  final bool showBackButton;
  final String? category;
  final Map<String, FilterOption>? filterOutputs;
  final bool exclusiveScreen;

  const GeneralSearchScreen({
    this.searchQuery,
    this.category = "all",
    this.showBackButton = false,
    this.filterOutputs,
    this.exclusiveScreen = false,
    this.autoFocus = true,
  });

  @override
  _GeneralSearchScreenState createState() => _GeneralSearchScreenState();
}

enum SearchStage { notstarted, started, loaded, empty }

class _GeneralSearchScreenState extends State<GeneralSearchScreen>
    with TickerProviderStateMixin {
  SearchStage stage = SearchStage.notstarted;
  SearchStage research = SearchStage.notstarted;
  SearchResult? searchResult;
  bool isSpecialQuery = false;
  String category = "all";
  FocusNode focusNode = new FocusNode(canRequestFocus: true);
  double opacity = 0;
  bool autoFocus = true;
  bool searchedFromHistory = false;
  List<BaseNode> results = [];
  var seasonList = seasonMap.values.toList();
  bool showFilter = false;
  ScrollController scrollController = new ScrollController();
  bool showBackButton = false;
  DisplayType displayType = DisplayType.list_vert;
  String prevQuery = "";
  static const nonFilterableTypes = ["all", "character", "person", "club"];
  static const nonSwitchableTypes = [
    "forum",
    "all",
    "featured",
    "news",
    "club",
    'interest_stack'
  ];
  List<String> allSectionSearch = [
    "anime",
    "manga",
    "character",
    "person",
    "forum",
    "club",
    "featured",
    "news"
  ];
  static const jikanTypeConv = {'character': 'characters', 'person': 'people'};

  TextEditingController searchController = new TextEditingController();

  Map<String, FilterOption> filterOutputs = {};

  late TabController tabController;
  late StreamListener<String> _searchTextListener;
  late Future<SearchResult> _seasonResult;

  @override
  void initState() {
    super.initState();
    category = widget.category ?? "all";
    _searchTextListener = StreamListener('');
    if (widget.searchQuery != null) {
      searchController.text = widget.searchQuery!;
      if (widget.searchQuery!.startsWith("#")) {
        isSpecialQuery = true;
      }
      startInitSearch();
    }

    if (widget.filterOutputs != null && widget.filterOutputs!.isNotEmpty) {
      searchController.text = "";
      filterOutputs = widget.filterOutputs ?? {};
      startInitSearch();
    }

    autoFocus = widget.autoFocus ?? false;
    if (autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_isNotBlank) {
        focusNode.requestFocus();
      });
    }
    showBackButton = widget.showBackButton;

    tabController = TabController(
        initialIndex: 0, length: allSectionSearch.length, vsync: this);
    _seasonResult = MalApi.getCurrentSeason(
      fields: ["my_list_status,alternative_titles"],
      fromCache: true,
      limit: 500,
    );
    searchController.addListener(() {
      _searchTextListener.update(searchController.text);
    });
  }

  void startInitSearch() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      startSearch(searchController.text, isSpecialQuery: isSpecialQuery);
    });
  }

  Future<bool> startSpecialSearch(String query,
      {bool fromCache = false}) async {
    if (rankingMap.values.contains(query)) {
      category = "anime";
      await getRankedContent(
          rankingMap.keys.elementAt(rankingMap.values.toList().indexOf(query)),
          fromCache: fromCache);
    } else if (query.contains("@")) {
      var split = query.split("@");
      if (seasonalLogic(query)) {
        category = "anime";
        await startSeasonSearch(split[0], int.parse(split[1]),
            fromCache: fromCache);
      } else if (suggestedLogic(query)) {
        category = "anime";
        await getSuggestedContent();
      } else if (genreLogic(query)) {
        category = "anime";
        await startGenreSearch(query.capitalize(), fromCache: fromCache);
      } else if (rankingMangaLogic(query)) {
        category = "manga";
        var split = query.replaceAll("#", '').split("@") ?? [];
        await getRankedContent(
            mangaRankingMap.keys
                .elementAt(mangaRankingMap.values.toList().indexOf(split[0])),
            fromCache: fromCache);
      } else
        return false;
    } else {
      return false;
    }
    return true;
  }

  bool seasonalLogic(String? query) {
    var split = query?.split("@") ?? [];
    return split.length == 2 &&
        seasonMap.containsValue(split[0]) &&
        int.tryParse(split[1]) != null &&
        split[1].length == 4;
  }

  bool suggestedLogic(String? query) {
    var split = query?.split("@") ?? [];
    return split.length == 2 &&
        split[0].equals("suggested") &&
        contentTypes.contains(split[1]);
  }

  bool rankingMangaLogic(String? query) {
    var split = query?.split("@") ?? [];
    return split.length == 2 &&
        split[1].equals("manga") &&
        mangaRankingMap.values.contains(split[0]);
  }

  bool genreLogic(String? query) {
    var split = query?.split("@") ?? ["", ""];
    var _q =
        split[0].replaceAll("_", " ").capitalizeAll()!.replaceAll(" ", "_");

    return split.length == 2 &&
        ((split[1].equals("anime") && Mal.animeGenres.values.contains(_q)) ||
            (split[1].equals("manga") && Mal.mangaGenres.values.contains(_q)));
  }

  Future<void> getSuggestedContent({bool fromCache = false}) async {
    searchResult =
        await MalUser.getContentSuggestions(fromCache: fromCache, limit: 31);
    results = searchResult?.data ?? [];
  }

  Future<void> getRankedContent(dynamic rankingType,
      {bool fromCache = true}) async {
    searchResult = await MalApi.getContentRanking(
      rankingType,
      category: category,
      limit: 31,
      fromCache: fromCache,
      fields: [MalApi.listDetailedFields],
    );
    results = searchResult?.data ?? [];
  }

  Future<void> startGenreSearch(String? query,
      {bool fromCache = true, int page = 1, bool concat = false}) async {
    var split = query?.split("@") ?? [];
    String _category = split[1];
    int id = 1;
    category = _category;
    var _q =
        split[0].replaceAll("_", " ").capitalizeAll()!.replaceAll(" ", "_");

    if (_category.equals("anime")) {
      id = Mal.animeGenres.keys
          .elementAt(Mal.animeGenres.values.toList().indexOf(_q));
    } else {
      id = Mal.mangaGenres.keys
          .elementAt(Mal.animeGenres.values.toList().indexOf(_q));
    }

    searchResult = await JikanHelper.getGenre(
        id: id, fromCache: fromCache, category: _category, page: page);
    if (concat) {
      if (nullOrEmpty(searchResult?.data)) {
        research = SearchStage.empty;
      } else {
        results.addAll(searchResult!.data!);
        research = SearchStage.loaded;
      }
    } else {
      results = searchResult?.data ?? [];
    }
  }

  Future<void> startSeasonSearch(String season, int year,
      {bool fromCache = true}) async {
    searchResult = await MalApi.getSeasonalAnime(
        seasonMapInverse[season.toLowerCase()]!, year,
        limit: 31, fromCache: fromCache, fields: [MalApi.listDetailedFields]);
    if (shouldUpdateContent(result: searchResult, timeinHours: 1)) {
      await startSeasonSearch(season, year, fromCache: false);
    }
    results = searchResult?.data ?? [];
  }

  Future<void> startSearch(String query,
      {bool isSpecialQuery = false, bool fromCache = true}) async {
    if (stage == SearchStage.started) {
      return;
    }
    if (fromCache && user.status == AuthStatus.AUTHENTICATED) {
      fromCache = false;
    }

    if (!query.startsWith('#') && query.length >= 3) {
      HistoryData.setHistory(dataType: HistoryDataType.query, value: query);
    }

    if (filterOutputs.isNotEmpty) {
      String q = searchController.text;
      if (q != null && q.notEquals("")) {
        query = q;
      }
    }

    prevQuery = query;

    if (mounted)
      setState(() {
        stage = SearchStage.started;
        research = SearchStage.notstarted;
        opacity = 0;
      });

    try {
      if (query.startsWith("#")) {
        if (!await startSpecialSearch(query.replaceFirst("#", ""))) {
          stage = SearchStage.notstarted;
          return;
        }
      } else {
        if (category.equals("all")) {
          searchResult = await MalApi.searchAllCategories(query);
          generateAllSectionList();
          if (mounted)
            setState(() {
              stage = SearchStage.loaded;
            });
          startAnimation();
          return;
        } else if (category.equals("forum")) {
          searchResult = await MalForum.getForumTopics(
              q: query,
              fromCache: fromCache,
              limit: 31,
              filters: filterOutputs);
        } else if (category.equals("club")) {
          searchResult = await MalApi.searchClubs(query);
        } else if (category.equals("user")) {
          searchResult =
              await MalUser.searchUser(query, filters: filterOutputs);
          handleUserSearchResult(query, searchResult);
        } else if (["featured", "news"].contains(category)) {
          searchResult = await DalApi.i.searchFeaturedArticles(
            query: query,
            category: category,
            tag: filterOutputs['tags']?.value,
          );
        } else if (category.equals('interest_stack')) {
          searchResult = await DalApi.i.searchInterestStacks(
            query: query,
            type: filterOutputs['type']?.apiValues?.elementAt(
                (filterOutputs['type']
                    ?.values
                    ?.indexOf(filterOutputs['type']!.value!))!),
          );
        } else if (filterOutputs.isNotEmpty ||
            jikanSearchTypes.contains(category)) {
          searchResult = await JikanHelper.jikanSearch(query,
              category: jikanTypeConv[category] ?? category,
              fromCache: true,
              filters: filterOutputs);
        } else {
          searchResult = await MalApi.searchForContent(query,
              category: category,
              fromCache: fromCache,
              limit: 31,
              fields: [
                "num_episodes,broadcast,alternative_titles,start_date,status,mean,num_list_users,genres,media_type,num_volumes,my_list_status"
              ]);
        }
        if (stage != SearchStage.started) {
          return;
        }
        results = searchResult?.data ?? [];
      }
    } catch (e) {
      showToast(S.current.Couldnt_connect_network);
      logDal(e);
    }

    if (searchResult?.data != null && searchResult!.data!.isNotEmpty) {
      stage = SearchStage.loaded;
    } else {
      stage = SearchStage.empty;
    }

    startAnimation();
    if (mounted) setState(() {});
  }

  void startAnimation() {
    Future.delayed(Duration(milliseconds: 100)).then((value) => {
          if (mounted)
            setState(() {
              opacity = 1;
            })
        });
  }

  void generateAllSectionList() {
    var _data = (searchResult as AllSearchResult).allData ?? {};
    if (_data.keys.isNotEmpty) {
      allSectionSearch = _data.keys.toList();
    }
  }

  Future<void> loadMoreResults({bool fromCache = true}) async {
    try {
      var _searchResult;
      String query = searchController.text;
      if (query.isNotBlank && genreLogic(query?.replaceFirst("#", ""))) {
        await startGenreSearch(query.replaceFirst("#", "").capitalize(),
            concat: true,
            fromCache: true,
            page: int.tryParse(searchResult?.paging?.next ?? '') ?? 1);
      } else {
        if (category.equals("forum")) {
          _searchResult = await MalForum.loadMoreForumTopics(
              page: searchResult!.paging!, fromCache: fromCache);
        } else if (category.equals("club")) {
          _searchResult = await MalApi.searchClubs(
              query, int.tryParse(searchResult!.paging!.next!) ?? 2);
        } else if (category.equals("user")) {
          _searchResult = await MalUser.searchUser(query,
              filters: filterOutputs,
              offset: int.tryParse(searchResult!.paging!.next!) ?? 24);
        } else if (["featured", "news"].contains(category)) {
          _searchResult = await DalApi.i.searchFeaturedArticles(
              query: query,
              category: category,
              tag: filterOutputs['tags']?.value,
              page: int.tryParse(searchResult!.paging!.next!) ?? 2);
        } else if (category.equals('interest_stack')) {
          _searchResult = await DalApi.i.searchInterestStacks(
            query: query,
            page: int.tryParse(searchResult?.paging?.next ?? '1') ?? 1,
            type: filterOutputs['type']?.apiValues?.elementAt(
                (filterOutputs['type']
                    ?.values
                    ?.indexOf(filterOutputs['type']!.value!))!),
          );
        } else if (jikanSearchTypes.contains(category) ||
            filterOutputs.isNotEmpty) {
          _searchResult = await JikanHelper.jikanSearch(query ?? "",
              category: jikanTypeConv[category] ?? category,
              fromCache: fromCache,
              filters: filterOutputs,
              pageNumber: int.tryParse(searchResult!.paging!.next!) ?? 1);
        } else {
          _searchResult = await MalApi.getContentListPage(searchResult!.paging!,
              fromCache: fromCache);
        }
        if (shouldUpdateContent(result: _searchResult, timeinHours: 1)) {
          loadMoreResults(fromCache: false);
          return;
        }
        if (_searchResult?.data == null) {
          research = SearchStage.empty;
        } else {
          research = SearchStage.loaded;
          results.addAll(_searchResult.data);
          searchResult = _searchResult;
        }
      }
    } catch (e) {
      logDal(e);
    }

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    searchController.dispose();
    _searchTextListener.dispose();
    super.dispose();
  }

  void onSearch(composing, _query, _category, [bool isSpecialQuery = false]) {
    if (composing.start == -1 && composing.end == -1) {
      if (_query.trim().length <= 1) {
        if (mounted)
          setState(() {
            showBackButton = false;
            stage = SearchStage.notstarted;
          });
        return;
      }

      category = _category;

      startSearch(_query.trim(), isSpecialQuery: isSpecialQuery);
    }
  }

  void reset() {
    if (mounted)
      setState(() {
        stage = SearchStage.notstarted;
        research = SearchStage.notstarted;
        searchResult = null;
        results = [];
        filterOutputs = {};
      });
  }

  void resetFilter() {
    if (mounted)
      setState(() {
        stage = SearchStage.notstarted;
        research = SearchStage.notstarted;
        searchResult = null;
        results = [];
      });
  }

  void leavePage(Widget newPage) {
    gotoPage(context: context, newPage: newPage);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.exclusiveScreen) {
      return Scaffold(
        appBar: AppBar(
          title: buildListHeader(),
          actions: [
            IconButton(
              onPressed: () {
                gotoPage(
                  context: context,
                  newPage: GeneralSearchScreen(
                    filterOutputs: filterOutputs,
                    category: category,
                    autoFocus: false,
                  ),
                );
              },
              icon: Icon(Icons.search),
            ),
          ],
        ),
        body: _onSearchBuild(context, AsyncSnapshot.nothing()),
      );
    }
    return WillPopScope(
      child: Scaffold(
        body: Stack(
          children: [
            StreamBuilder<HistoryData>(
              initialData: StreamUtils.i.initalData(StreamType.search_page),
              stream: StreamUtils.i.getStream(StreamType.search_page),
              builder: _onSearchBuild,
            ),
            Padding(padding: EdgeInsets.only(top: 145), child: filterSection()),
            searchbar()
          ],
        ),
      ),
      onWillPop: _onWillScope,
    );
  }

  Widget _onSearchBuild(BuildContext _, AsyncSnapshot<HistoryData?> sp) {
    final topPadding = EdgeInsets.only(
        top: (stage == SearchStage.loaded ||
                stage == SearchStage.notstarted ||
                stage == SearchStage.empty)
            ? 0
            : 150);
    return Padding(
      padding: topPadding,
      child: stage == SearchStage.notstarted
          ? _streamSimilarNames(sp.data)
          : stage == SearchStage.started
              ? loadingBelowText(mainAxisAlignment: MainAxisAlignment.start)
              : stage == SearchStage.loaded
                  ? showResults()
                  : _showNoResultsFound(),
    );
  }

  Widget _streamSimilarNames(HistoryData? data) {
    if (category.equals('anime') || category.equals('all')) {
      return StreamBuilder<String>(
        stream: _searchTextListener.stream,
        builder: (_, snap) {
          final text = snap.data;
          if (text != null && text.isNotBlank) {
            return CFutureBuilder(
              future: _seasonResult,
              done: (_snap) => _animeTypeSearch(text, _snap.data, data),
              loadingChild: _buildHistory(data),
            );
          }
          return _buildHistory(data);
        },
      );
    } else {
      return _buildHistory(data);
    }
  }

  Widget _animeTypeSearch(
      String text, SearchResult? result, HistoryData? data) {
    text = text.trim().toLowerCase();
    if (result != null) {
      final base = result.data;
      if (base != null && base.isNotEmpty) {
        final filtered =
            searchBaseNodes(base, text).take(5).map((e) => e.content!).toList();
        return _buildHistory(data, filtered);
      }
    }
    return _buildHistory(data);
  }

  Future<bool> _onWillScope() async {
    if (showFilter) {
      if (mounted)
        setState(() {
          showFilter = false;
        });
      return false;
    }
    return true;
  }

  Widget _showNoResultsFound() {
    return Column(
      children: [
        if (hasAdditionalWidget && !widget.exclusiveScreen) ...[
          const SizedBox(height: 90.0),
          additionalOptionsWidget(),
        ],
        const SizedBox(height: 90.0),
        if (searchResult is UserResult &&
            ((searchResult as UserResult).isUser ?? false))
          _showUserFound()
        else
          Center(
            child: Text(
              S.current.No_results_found,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13),
            ),
          ),
      ],
    );
  }

  Widget _showUserFound() {
    return PlainButton(
      onPressed: () {
        showUserPage(context: context, username: prevQuery.trim());
      },
      child: Text('${S.current.User_found_as}: $prevQuery'),
    );
  }

  Widget showResults() {
    Widget _build;
    if (category.equals("all")) {
      _build = Padding(
        padding: EdgeInsets.only(top: 135),
        child: allSectionBody(),
      );
    } else {
      _build = ListView(
        padding: EdgeInsets.only(
            top: widget.exclusiveScreen ? 0.0 : 90.0, bottom: 0),
        children: [
          if (!widget.exclusiveScreen) ...[
            if (hasAdditionalWidget) additionalOptionsWidget(),
            if (showFilter) _searchDivider(),
            const SizedBox(height: 20),
            buildListHeader(),
          ],
          const SizedBox(height: 20),
          displayType == DisplayType.list_vert
              ? showListLayout()
              : showGridLayout(),
          const SizedBox(height: 20),
          loadMoreContent(),
          const SizedBox(height: 20),
        ],
      );
    }

    return AnimatedOpacity(
      opacity: opacity,
      child: _build,
      duration: Duration(milliseconds: 500),
    );
  }

  Widget allSectionBody() {
    return TabBarView(
      controller: tabController,
      children: allSectionSearch.asMap().entries.map((e) {
        var _results =
            (searchResult as AllSearchResult).allData![e.value] ?? [];
        if (_results.isEmpty) {
          return showNoContent();
        } else {
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              SB.h20,
              buildListResults(_results, e.value),
              SB.h40,
              longButton(
                  text: "${S.current.Search_for} '$prevQuery' in ${e.value}",
                  onPressed: () {
                    focusNode.canRequestFocus = false;
                    if (mounted) setState(() {});
                    gotoPage(
                        context: context,
                        newPage: GeneralSearchScreen(
                          autoFocus: false,
                          category: e.value,
                          searchQuery: prevQuery,
                          showBackButton: true,
                        ));
                  }),
              SB.h120,
            ],
          );
        }
      }).toList(),
    );
  }

  Widget buildListHeader() {
    if (!isSpecialQuery) {
      if (category.equals("forum"))
        return listHeading(S.current.Discussions);
      else if (category.equals("featured"))
        return listHeading(S.current.Featured_Articles);
      else if (category.equals("news"))
        return listHeading(S.current.News);
      else if (filterOutputs.length == 1 &&
          (filterOutputs['genres']?.includedOptions ?? []).length == 1 &&
          (filterOutputs['genres']?.excludedOptions ?? []).length == 0)
        return listHeading(
            '${filterOutputs['genres']!.includedOptions![0].replaceAll('_', ' ')} $category');
      else if (filterOutputs.length == 1 &&
          filterOutputs['producer']?.value != null)
        return listHeading(
            '${filterOutputs['producer']!.value!.standardize()} $category');
      else
        return listHeading(S.current.Search_Results);
    } else {
      String query = searchController.text;
      var ifSeason = seasonalLogic(query.replaceAll("#", "")) ?? false;
      return ifSeason
          ? seasonHeader()
          : listHeading(
              "Top ${query.replaceAll("#", "").replaceAll("@", " ").capitalizeAll()!.standardize()}");
    }
  }

  Widget showListLayout() {
    switch (category) {
      case 'interest_stack':
        return InterestStackContentList(
          horizPadding: 0.0,
          shrinkWrap: true,
          interestStacks: results
              .map<InterestStack>((e) => e.content as InterestStack)
              .toList(),
          type: DisplayType.list_vert,
        );
      case "forum":
        return buildForumTopics();
      case "club":
        return ClubList(
            clubs:
                results.map<ClubHtml>((e) => e.content as ClubHtml).toList());
      default:
        return buildListResults(results, category);
    }
  }

  Widget showGridLayout() {
    if (contentTypes.contains(category) || category.equals('interest_stack'))
      return showListLayout();
    return buildGridResults(results, category, scrollController, context);
  }

  Widget _buildHistory(HistoryData? data, [List<Node>? searchNodes]) {
    final queryHistory = data?.queryHistory ?? [];
    final recentAnime = data?.recentAnime ?? [];
    final recentManga = data?.recentManga ?? [];
    final _searchNodes = searchNodes ?? [];
    final padding = EdgeInsets.only(top: 90.0);

    return CustomScrollWrapper([
      SliverToBoxAdapter(
        child: Padding(padding: padding),
      ),
      if (hasAdditionalWidget) SliverWrapper(additionalOptionsWidget()),
      if (showFilter) SliverWrapper(_searchDivider()),
      if (queryHistory.isEmpty &&
          recentManga.isEmpty &&
          recentAnime.isEmpty &&
          _searchNodes.isEmpty)
        SliverToBoxAdapter(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: title(
                  S.current.Search_Page_Intro,
                  align: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: title(
                  '- ${S.current.or} -',
                  align: TextAlign.center,
                ),
              )
            ],
          ),
        )
      else ...[
        if (_searchNodes.isNotEmpty) ...[
          SB.lh30,
          _buildNodeSeach(_searchNodes),
        ],
        if (queryHistory.isNotEmpty) ...[
          SB.lh30,
          _historyHeader(
            text: S.current.History,
            onClear: () => HistoryData.setHistory(
                dataType: HistoryDataType.query, removeAll: true),
            showClear: queryHistory.isNotEmpty,
          ),
          SB.lh10,
          if (queryHistory.isNotEmpty)
            _buildSearchQueryList(queryHistory)
          else
            _sliverText(S.current.Nothing_yet),
        ],
        if (recentAnime.isNotEmpty) ...[
          SB.lh30,
          _historyHeader(
            text: S.current.Recent_Anime,
            onClear: () => HistoryData.setHistory(
                dataType: HistoryDataType.anime, removeAll: true),
            showClear: recentAnime.isNotEmpty,
          ),
          SB.lh10,
          if (recentAnime.isNotEmpty)
            _buildRecentNodes(recentAnime, 'anime')
          else
            _sliverText(S.current.Nothing_yet),
        ],
        if (recentManga.isNotEmpty) ...[
          SB.lh30,
          _historyHeader(
            text: S.current.Recent_Manga,
            onClear: () => HistoryData.setHistory(
                dataType: HistoryDataType.manga, removeAll: true),
            showClear: recentManga.isNotEmpty,
          ),
          SB.lh10,
          if (recentManga.isNotEmpty)
            _buildRecentNodes(recentManga, 'manga')
          else
            _sliverText(S.current.Nothing_yet),
        ]
      ],
      SB.lh30,
      _historyHeader(
        text: S.current.Search_By_Season,
        onClear: () {},
        showClear: false,
      ),
      SB.lh20,
      SeasonalWidget(
        useSlivers: true,
      ),
      SB.lh30,
      _historyHeader(
        text: 'Anime Categories',
        showClear: false,
      ),
      SB.lh20,
      SliverToBoxAdapter(
        child: AllRankingWidget(category: 'anime'),
      ),
      _historyHeader(
        text: 'Manga Categories',
        showClear: false,
      ),
      SB.lh20,
      SliverToBoxAdapter(
        child: AllRankingWidget(category: 'manga'),
      ),
      SB.lh60,
    ]);
  }

  SliverList _buildNodeSeach(List<Node> nodes) {
    return SliverList.builder(
      itemBuilder: (_, index) {
        final node = nodes[index];
        return ListTile(
          title: Text(getNodeTitle(node),
              style: Theme.of(context).textTheme.labelMedium),
          onTap: () {
            gotoPage(
                context: context,
                newPage: ContentDetailedScreen(
                  node: node,
                  category: 'anime',
                ));
          },
          trailing: Icon(Icons.arrow_outward),
        );
      },
      itemCount: nodes.length,
    );
  }

  SliverToBoxAdapter _buildRecentNodes(List<Node> nodes, String category) {
    return SliverToBoxAdapter(
      child: Container(
        height: 250,
        child: ContentListWidget(
          returnSlivers: false,
          cardHeight: 170,
          cardWidth: 160,
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          contentList: nodes.map((e) => BaseNode(content: e)).toList(),
          displayType: DisplayType.list_horiz,
          category: category,
          onClose: (i, _) => HistoryData.setHistory(
            remove: true,
            value: nodes.elementAt(i),
            dataType: category.equals("anime")
                ? HistoryDataType.anime
                : HistoryDataType.manga,
          ),
          updateCacheOnEdit: true,
        ),
      ),
    );
  }

  SliverList _buildSearchQueryList(List<String> queryHistory) {
    return SliverList(
        delegate: SliverChildBuilderDelegate(
      (context, index) {
        return ListTile(
          onTap: () {
            focusNode.unfocus();
            searchController.text = queryHistory[index];
            startSearch(queryHistory[index]);
          },
          minVerticalPadding: 0.0,
          contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 0),
          trailing: ToolTipButton(
            message: S.current.Clear,
            usePadding: true,
            onTap: () => HistoryData.setHistory(
                dataType: HistoryDataType.query,
                value: queryHistory[index],
                remove: true),
            child: Icon(Icons.close),
          ),
          title: title(
            queryHistory[index] ?? '?',
            align: TextAlign.left,
            opacity: .7,
          ),
        );
      },
      childCount: queryHistory.length,
    ));
  }

  Widget _sliverText(String text) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: title(text),
      ),
    );
  }

  Widget _historyHeader({
    String? text,
    VoidCallback? onClear,
    required bool showClear,
  }) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 7.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            title(text, fontSize: 18),
            if (showClear)
              ToolTipButton(
                usePadding: true,
                message: S.current.Clear_All_Desc,
                child: title(S.current.Clear_All),
                onTap: onClear!,
              )
          ],
        ),
      ),
    );
  }

  Widget seasonHeader() {
    String query = searchController.text;
    var yearList = List.generate(64, (index) => (1960 + index).toString());
    var season = "winter", year = "2021";
    var split = query.replaceAll("#", "").split("@");
    season = split[0];
    year = split[1];
    var seasonIndex = seasonList.indexOf(season),
        yearIndex = yearList.indexOf(year);
    return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                    child: SliderWidget(
                  itr: seasonList,
                  t: S.current.Season,
                  currItemIndex: seasonIndex,
                  width: 70,
                  horizontalPadding: 15,
                  fontSize: 16,
                  onIndexChange: (value) {
                    seasonIndex = value;
                    searchController.text = "#" +
                        seasonList.elementAt(value) +
                        "@" +
                        yearList[yearIndex].toString();
                    isSpecialQuery = true;
                    startSearch(searchController.text, isSpecialQuery: true);
                  },
                )),
                const SizedBox(
                  width: 0,
                ),
                Expanded(
                    child: SliderWidget(
                  itr: yearList,
                  currItemIndex: yearIndex,
                  t: S.current.Year,
                  fontSize: 19,
                  onIndexChange: (value) {
                    yearIndex = value;
                    searchController.text = "#" +
                        seasonList.elementAt(seasonIndex) +
                        "@" +
                        yearList[value].toString();
                    isSpecialQuery = true;
                    startSearch(searchController.text, isSpecialQuery: true);
                  },
                )),
              ],
            ),
          ],
        ));
  }

  Widget listHeading(String _title) {
    return conditional(
      on: !widget.exclusiveScreen,
      parent: (child) => Center(child: child),
      child: title(_title, opacity: 1, fontSize: 22),
    );
  }

  Widget buildForumTopics() {
    return ForumTopicsList(
      padding: EdgeInsets.only(top: 20),
      topics: results as List<ForumTopicsData>,
    );
  }

  Widget buildListResults(var _results, var _category) {
    if (_results == null || _results.isEmpty) return SB.z;
    return CustomScrollWrapper([
      ContentListWidget(
        category: _category,
        contentList: _results,
        displayType: displayType,
        showIndex: contentTypes.contains(_category),
        showEdit: contentTypes.contains(_category),
        updateCacheOnEdit: true,
        showBackgroundImage: false,
        showStatus: contentTypes.contains(_category),
        padding: EdgeInsets.only(top: 0),
        onContentUpdate: () {},
        aspectRatio: contentTypes.contains(_category) ? 2.35 : 3,
        imageAspectRatio: contentTypes.contains(_category) ? 0.5 : .6,
      )
    ], shrink: true);
  }

  Widget loadMoreContent() {
    return Container(
      height: 40,
      child: Center(
        child: (research == SearchStage.notstarted ||
                research == SearchStage.loaded)
            ? Container(
                width: double.infinity,
                height: 40,
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: PlainButton(
                  onPressed: () {
                    if (mounted)
                      setState(() {
                        research = SearchStage.started;
                      });
                    loadMoreResults();
                  },
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13)),
                  child: Center(
                    child: Text(
                      S.current.Load_More,
                      // overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ),
              )
            : research == SearchStage.started
                ? Column(
                    children: [loadingCenter()],
                  )
                : Container(
                    width: double.infinity,
                    child: Text(
                      S.current.No_More_found,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
      ),
    );
  }

  Widget searchbar() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        AnimatedContainer(
          width: double.infinity,
          curve: Curves.easeIn,
          duration: Duration(milliseconds: 300),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(0),
          ),
          child: Material(
            child: Padding(
              padding: EdgeInsets.only(top: 35),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Row(
                            children: [
                              _buildSearchLeading(),
                              if (isSpecialQuery) _buildSpecialQueryTag(),
                              _buildSearchFormField()
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (category.equals("all") && stage == SearchStage.loaded)
                    allSectionsHeader()
                  else if (!showFilter)
                    _searchDivider(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Divider _searchDivider() {
    return Divider(thickness: 1.0, endIndent: 0, indent: 0, height: 4.0);
  }

  Container _buildSpecialQueryTag() {
    return Container(
      height: 27,
      child: PlainButton(
        padding: const EdgeInsets.symmetric(),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        onPressed: () {},
        child: Text(
          'special',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }

  Widget _buildSearchLeading() {
    return IconButton(
      onPressed: () => Navigator.pop(context),
      icon: Icon(Icons.arrow_back),
    );
  }

  Flexible _buildSearchFormField() {
    return Flexible(
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: TextFormField(
          focusNode: focusNode,
          autofocus: false,
          controller: searchController,
          onFieldSubmitted: (value) {
            if (value.isBlank) {
              return;
            }
            resetFilter();
            startSearch(value);
          },
          onChanged: (value) {
            _onFieldValueChange(value);
          },
          onTap: () {},
          style: TextStyle(
            decoration: TextDecoration.none,
            fontWeight: isSpecialQuery ? FontWeight.bold : FontWeight.normal,
          ),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.zero,
            hintText: S.current.SearchBarHintText,
            disabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
            border: OutlineInputBorder(borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
            errorBorder: OutlineInputBorder(borderSide: BorderSide.none),
          ),
        ),
      ),
    );
  }

  void _onFieldValueChange(String value) {
    if (value != "" && value.trim().notEquals("")) {
      if (value.startsWith("#")) {
        if (!isSpecialQuery) {
          if (mounted)
            setState(() {
              isSpecialQuery = true;
            });
        }
      } else {
        if (isSpecialQuery) {
          if (mounted)
            setState(() {
              isSpecialQuery = false;
            });
        }
      }
    } else {
      if (mounted && stage != SearchStage.notstarted)
        setState(() {
          stage = SearchStage.notstarted;
        });
    }
  }

  void _onCategorySelect(String? value) {
    if (prevQuery.isBlank) {
      category = value ?? 'anime';
      displayType = DisplayType.list_vert;
      showFilter = false;
      reset();
    } else {
      gotoPage(
        context: context,
        newPage: GeneralSearchScreen(
          category: value,
          autoFocus: false,
          searchQuery: prevQuery,
        ),
      );
    }
  }

  Widget allSectionsHeader() {
    return TabBar(
      controller: tabController,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      tabs: allSectionSearch
          .map((e) => Tab(
                child: Text('${e.capitalize()}'),
              ))
          .toList(),
    );
  }

  Widget filterSection() {
    return ExpandedSection(
      expand: showFilter,
      child: Container(
        width: double.infinity,
        child: FilterModal(
          filterOptions: getFilterOptions(),
          filterOutputs: filterOutputs,
          hasApply: !['forum'].contains(category),
          showText: category.equals("featured"),
          additional: S.current.Tags_unApplied,
          onApply: () {
            showFilter = false;
            resetFilter();
            startSearch(searchController.text ?? "");
          },
          onChange: (fo) {
            if (fo != null && mounted) {
              filterOutputs = fo;
              if (fo.isEmpty) {
                reset();
              }
              setState(() {});
            }
          },
          onClose: () {
            if (mounted)
              setState(() {
                showFilter = false;
              });
          },
        ),
      ),
    );
  }

  bool get hasAdditionalWidget => !isSpecialQuery;

  Widget additionalOptionsWidget() {
    final extras = [
      if (!isSpecialQuery && !nonFilterableTypes.contains(category))
        _buildFilter(),
    ];
    return Container(
      width: double.infinity,
      height: 50,
      child: Material(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              if (extras.length > 0) SB.w10,
              ...extras,
              Expanded(
                child: SelectBar(
                  options: searchTypes,
                  selectedOption: category,
                  listPadding: EdgeInsets.only(
                      left: extras.length > 0 ? 5 : 15, right: 60.0),
                  onChanged: _onCategorySelect,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onDisplayTypeChange(value) {
    if (mounted) {
      setState(() {
        displayType = DisplayType.values.firstWhere((e) => e.name == value);
      });
    }
  }

  Widget _buildFilter() {
    final extras = [
      if (!nonSwitchableTypes.contains(category) &&
          stage == SearchStage.loaded) ...[
        VerticalDivider(thickness: 1),
        buildDisplayTypeSelector(displayType, _onDisplayTypeChange),
      ]
    ];
    return SizedBox(
      height: 38.0,
      child: ShadowButton(
          onPressed: () {
            if (extras.length == 1) _flipFliter();
          },
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            children: [
              ToolTipButton(
                onTap: _flipFliter,
                message: S.current.Filter,
                child: Icon(getFilterIcon(filterOutputs.keys)),
              ),
              ...extras,
            ],
          )),
    );
  }

  void _flipFliter() {
    if (mounted)
      setState(() {
        showFilter = !showFilter;
      });
  }

  List<FilterOption> getFilterOptions() {
    switch (category) {
      case "anime":
        return CustomFilters.animeFilters;
      case "manga":
        return CustomFilters.mangaFilters;
      case "forum":
        return CustomFilters.forumFilters;
      case "user":
        return CustomFilters.userFilters;
      case "featured":
        return CustomFilters.featuredFilters;
      case "news":
        return CustomFilters.newsFilters;
      case 'interest_stack':
        return CustomFilters.interestStackFilters;
      default:
        return [];
    }
  }

  void handleUserSearchResult(String _query, SearchResult? searchResult) {
    if (searchResult is UserResult && (searchResult.isUser ?? false)) {
      showUserPage(context: context, username: _query.trim());
    }
  }
}

Widget buildDisplayTypeSelector(
    DisplayType displayType, dynamic Function(String)? onChanged,
    [SelectType selectType = SelectType.dropdown, double? iconSize]) {
  final iconMap = {
    DisplayType.list_vert.name: Icons.list,
    DisplayType.grid.name: Icons.grid_view
  };
  return SelectButton(
    selectType: selectType,
    popupText: S.current.Select_One,
    selectedOption: displayType.name,
    options:
        [DisplayType.list_vert, DisplayType.grid].map((e) => e.name).toList(),
    child: Icon(iconMap[displayType.name], size: iconSize),
    displayValues: ['List View', 'Grid View'],
    iconMap: iconMap,
    onChanged: onChanged,
  );
}

class CustomFilters {
  static final genresMangaFilter = FilterOption(
    fieldName: S.current.Genre_Include_Exclude,
    type: FilterType.multiple,
    apiFieldName: "genres",
    excludeFieldName: "genres_exclude",
    modalField: 'genres',
    desc: S.current.Genre_Include_Exclude_desc,
    apiValues: Mal.mangaGenres.keys.toList(),
    values: Mal.mangaGenres.values.toList(),
  );
  static final genresAnimeFilter = FilterOption(
    fieldName: S.current.Genre_Include_Exclude,
    type: FilterType.multiple,
    apiFieldName: "genres",
    modalField: "genres",
    excludeFieldName: "genres_exclude",
    desc: S.current.Genre_Include_Exclude_desc,
    apiValues: Mal.animeGenres.keys.toList(),
    values: Mal.animeGenres.values.toList(),
  );
  static final animeStudiosFilter = FilterOption(
      fieldName: "Producer",
      type: FilterType.select,
      desc: "Producer",
      apiFieldName: "producer",
      modalField: "studios",
      apiValues: Mal.animeStudios.keys.toList(),
      values: Mal.animeStudios.values.toList());

  static final mangaMagazinesFilter = FilterOption(
      fieldName: "Magazines",
      type: FilterType.select,
      desc: "Magazines",
      apiFieldName: "magazines",
      apiValues: Mal.mangaMagazines.keys.toList(),
      values: Mal.mangaMagazines.values.toList());
  static final animeTypeFilter = FilterOption(
      fieldName: "Anime Type",
      type: FilterType.select,
      desc: S.current.Filter_type_of_results_anime,
      apiFieldName: "type",
      modalField: "media_type",
      values: enumList(AnimeType.values));

  static List<FilterOption> get forumFilters {
    return [
      FilterOption(
          fieldName: "Board",
          type: FilterType.select,
          desc: S.current.Select_either_Board_or_Sub_Board,
          apiFieldName: "board_id",
          mutualExclusive: "subboard_id",
          apiValues: ForumConstants.boards.keys.toList(),
          values: ForumConstants.boards.values.toList()),
      FilterOption(
          fieldName: "SubBoard",
          type: FilterType.select,
          desc: S.current.Select_either_Board_or_Sub_Board,
          apiFieldName: "subboard_id",
          mutualExclusive: "board_id",
          apiValues: ForumConstants.subBoards.keys.toList(),
          values: ForumConstants.subBoards.values.toList()),
      FilterOption(
          fieldName: "Topic Username",
          type: FilterType.equal,
          desc: S.current.Topic_Username_desc,
          apiFieldName: "topic_user_name"),
      FilterOption(
          fieldName: "Username",
          type: FilterType.equal,
          desc: S.current.Any_Username,
          apiFieldName: "user_name"),
    ];
  }

  static List<FilterOption> get mangaFilters {
    return [
      FilterOption(
          fieldName: "Manga Type",
          type: FilterType.select,
          apiFieldName: "type",
          modalField: 'media_type',
          desc: S.current.Filter_type_of_results,
          values: mangaTypeMap.values.toList()),
      FilterOption(
          fieldName: "Manga Status",
          type: FilterType.select,
          apiFieldName: "status",
          modalField: 'status',
          desc: S.current.Filter_status_of_results,
          values: mangaStatusMap.values.toList()),
      genresMangaFilter,
      FilterOption(
          fieldName: S.current.Order_by,
          type: FilterType.select,
          apiFieldName: "order_by",
          desc: S.current.Order_results_property,
          values: mangaOrderType.values.toList()),
      FilterOption(
          fieldName: S.current.Sort_By,
          type: FilterType.select,
          dependent: "order_by",
          apiFieldName: "sort",
          desc: S.current.Sort_Order_by,
          apiValues: enumList(sortTypeMap.keys.toList()),
          values: sortTypeMap.values.toList()),
      FilterOption(
          fieldName: "Score",
          type: FilterType.select,
          apiFieldName: "score",
          modalField: "mean",
          desc: S.current.Filter_score_of_results,
          apiValues:
              List.generate(9, (i) => (i + 1).toString()).reversed.toList(),
          values: List.generate(9, (i) => (i + 1).toString() + "+")
              .reversed
              .toList()),
      FilterOption(
          fieldName: S.current.Start_Date,
          type: FilterType.date,
          apiFieldName: "start_date",
          modalField: "start_date",
          desc: S.current.Filter_start_date_of_results),
      FilterOption(
          fieldName: S.current.End_Date,
          type: FilterType.date,
          apiFieldName: "end_date",
          modalField: "end_date",
          desc: S.current.Filter_end_date_of_results),
      mangaMagazinesFilter,
      FilterOption(
          fieldName: S.current.Starting_With,
          type: FilterType.select,
          apiFieldName: "letter",
          modalField: "title",
          desc: S.current.Starting_with_manga,
          values: List.generate(26, (i) => String.fromCharCode(i + 65))),
    ];
  }

  static List<FilterOption> get animeFilters {
    return [
      animeTypeFilter,
      FilterOption(
          fieldName: "Anime Status",
          type: FilterType.select,
          apiFieldName: "status",
          modalField: 'status',
          desc: S.current.Filter_status_of_results,
          values: jikanAnimeStatusMap.values.toList()),
      FilterOption(
          fieldName: "Rated",
          type: FilterType.select,
          apiFieldName: "rating",
          modalField: 'rating',
          desc: S.current.Filter_age_rating_of_results,
          apiValues: enumList(ratedMap.keys.toList()),
          values: user.pref.nsfw
              ? ratedMap.values.toList()
              : ratedMapSFW.values.toList()),
      genresAnimeFilter,
      FilterOption(
          fieldName: S.current.Order_by,
          type: FilterType.select,
          apiFieldName: "order_by",
          desc: S.current.Order_results_property,
          values: animeOrderType.values.toList()),
      FilterOption(
          fieldName: S.current.Sort_By,
          type: FilterType.select,
          dependent: "order_by",
          apiFieldName: "sort",
          desc: S.current.Sort_Order_by,
          apiValues: enumList(sortTypeMap.keys.toList()),
          values: sortTypeMap.values.toList()),
      FilterOption(
          fieldName: "Score",
          type: FilterType.select,
          apiFieldName: "score",
          modalField: 'mean',
          desc: S.current.Filter_score_of_results,
          apiValues:
              List.generate(9, (i) => (i + 1).toString()).reversed.toList(),
          values: List.generate(9, (i) => (i + 1).toString() + "+")
              .reversed
              .toList()),
      FilterOption(
          fieldName: S.current.Start_Date,
          type: FilterType.date,
          apiFieldName: "start_date",
          modalField: "start_date",
          desc: S.current.Filter_start_date_of_results),
      FilterOption(
          fieldName: S.current.End_Date,
          type: FilterType.date,
          apiFieldName: "end_date",
          modalField: "end_date",
          desc: S.current.Filter_end_date_of_results),
      animeStudiosFilter,
      FilterOption(
          fieldName: S.current.Starting_With,
          type: FilterType.select,
          apiFieldName: "letter",
          modalField: "title",
          desc: S.current.Starting_with_anime,
          values: List.generate(26, (i) => String.fromCharCode(i + 65))),
    ];
  }

  static List<FilterOption> get userFilters => [
        FilterOption(
            fieldName: S.current.Location,
            type: FilterType.equal,
            desc: "Ex: California",
            apiFieldName: "loc"),
        FilterOption(
            fieldName: S.current.Age_low,
            type: FilterType.equal,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            desc: "Ex: 18",
            apiFieldName: "agelow"),
        FilterOption(
            fieldName: S.current.Age_high,
            type: FilterType.equal,
            keyboardType: TextInputType.number,
            desc: "Ex: 24",
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            apiFieldName: "agehigh"),
        FilterOption(
            fieldName: S.current.Gender,
            type: FilterType.select,
            desc: S.current.Gender_desc,
            apiFieldName: "g",
            apiValues: [0, 1, 2, 3],
            values: ["Don't care", "Male", "Female", "Non-Binary"]),
      ];

  static final featuredFilters = [
    FilterOption(
      fieldName: S.current.Tags,
      type: FilterType.select,
      apiValues: ForumConstants.tags.keys.toList(),
      values: ForumConstants.tags.values.toList(),
      apiFieldName: "tags",
      desc: S.current.Featured_Tags_desc,
    )
  ];

  static final newsFilters = [
    FilterOption(
      fieldName: S.current.Tags,
      type: FilterType.single_list,
      singleList: ForumConstants.newsTags,
      apiFieldName: "tags",
      desc: S.current.News_Tags_desc,
    ),
  ];

  static final interestStackFilters = <FilterOption>[
    FilterOption(
      fieldName: S.current.Type,
      type: FilterType.select,
      apiValues: [null, 'anime', 'manga', 'myanimelist'],
      values: ['All', 'Anime', 'Manga', 'MyAnimeList'],
      apiFieldName: "type",
      desc: S.current.Interest_Stack_Type_Desc,
    ),
  ];
}

enum DisplayType { list_vert, grid, list_horiz }

enum DisplaySubType { compact, comfortable, cover_only_grid, spacious }
