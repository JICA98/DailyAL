import 'dart:convert';

import 'package:dailyanimelist/api/dalapi.dart';
import 'package:dailyanimelist/api/jikahelper.dart';
import 'package:dailyanimelist/api/malapi.dart';
import 'package:dailyanimelist/api/malforum.dart';
import 'package:dailyanimelist/api/maluser.dart';
import 'package:dailyanimelist/cache/cachemanager.dart';
import 'package:dailyanimelist/cache/history_data.dart';
import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/enums.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/main.dart';
import 'package:dailyanimelist/pages/animedetailed/intereststackwidget.dart';
import 'package:dailyanimelist/pages/search/allrankingwidget.dart';
import 'package:dailyanimelist/pages/search/seasonalwidget.dart';
import 'package:dailyanimelist/screens/contentdetailedscreen.dart';
import 'package:dailyanimelist/user/user.dart';
import 'package:dailyanimelist/util/streamutils.dart';
import 'package:dailyanimelist/widgets/avatarwidget.dart';
import 'package:dailyanimelist/widgets/club/clublistwidget.dart';
import 'package:dailyanimelist/widgets/custombutton.dart';
import 'package:dailyanimelist/widgets/customfuture.dart';
import 'package:dailyanimelist/widgets/forum/forumtopicwidget.dart';
import 'package:dailyanimelist/widgets/listsortfilter.dart';
import 'package:dailyanimelist/widgets/loading/expandedwidget.dart';
import 'package:dailyanimelist/widgets/search/filtermodal.dart';
import 'package:dailyanimelist/widgets/search/sliderwidget.dart';
import 'package:dailyanimelist/widgets/slivers.dart';
import 'package:dailyanimelist/widgets/user/contentlistwidget.dart';
import 'package:dailyanimelist/widgets/will_pop_widget.dart';
import 'package:dal_commons/commons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:line_icons/line_icons.dart';

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
  FocusNode focusNode = new FocusNode(canRequestFocus: true);
  double opacity = 0;
  bool autoFocus = true;
  bool searchedFromHistory = false;
  List<BaseNode> results = [];
  var seasonList = seasonMap.values.toList();
  bool showFilter = false;
  ScrollController scrollController = new ScrollController();
  bool showBackButton = false;
  String prevQuery = "";
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

  TextEditingController _searchController = new TextEditingController();

  late TabController tabController;
  late StreamListener<String> _searchTextListener;
  late Future<SearchResult> _seasonResult;
  late SortFilterDisplay _sortFilterDisplay;

  @override
  void initState() {
    super.initState();
    _searchTextListener = StreamListener('');
    _setDefaultSortFilterDisplay();

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
    _searchController.addListener(() {
      _searchTextListener.update(_searchController.text);
    });
  }

  DisplayOption get _displayOption => _sortFilterDisplay.displayOption;

  DisplayType get displayType => _displayOption.displayType;

  bool get _hasLoadMore {
    var length = searchResult?.data?.length;
    return length != null && length > 10;
  }

  Map<String, FilterOption> get _filterOutputs {
    try {
      return _sortFilterDisplay.filterOutputs;
    } catch (e) {
      return {};
    }
  }

  set _filterOutputs(Map<String, FilterOption> value) {
    _sortFilterDisplay = _sortFilterDisplay.copyWith(filterOutputs: value);
  }

  String get category {
    try {
      return _sortFilterDisplay.category;
    } catch (e) {
      return 'all';
    }
  }

  set category(String value) {
    _sortFilterDisplay = _sortFilterDisplay.copyWith(category: value);
  }

  _setDefaultSortFilterDisplay() async {
    _sortFilterDisplay = await SortFilterDisplay.fromCache(
        'searchService', 'sortFilterDisplay', _defaultSortFilterDisplay());
    _setWidgetOptions();
    _checkAutoSearch();
    if (mounted) setState(() {});
  }

  void _setWidgetOptions() {
    final superCategory = widget.category ?? 'all';
    if (superCategory.notEquals('all')) {
      category = superCategory;
    }
    _filterOutputs = widget.filterOutputs ?? {};
  }

  void _checkAutoSearch() {
    if (widget.searchQuery != null) {
      _searchController.text = widget.searchQuery!;
      if (widget.searchQuery!.startsWith("#")) {
        isSpecialQuery = true;
      }
      startInitSearch();
    }

    if (_filterOutputs.isNotEmpty) {
      _searchController.text = "";
      startInitSearch();
    }
  }

  SortFilterDisplay _defaultSortFilterDisplay() {
    return SortFilterDisplay(
      sort: SortOption(name: 'name', value: 'value'),
      displayOption: DisplayOption(
        displayType: user.pref.defaultDisplayType,
        displaySubType: DisplaySubType.comfortable,
      ),
      category: widget.category ?? "all",
      filterOutputs: widget.filterOutputs ?? {},
    );
  }

  void startInitSearch() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      startSearch(_searchController.text, isSpecialQuery: isSpecialQuery);
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

    if (_filterOutputs.isNotEmpty) {
      String q = _searchController.text;
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
              filters: _filterOutputs);
        } else if (category.equals("club")) {
          searchResult = await MalApi.searchClubs(query);
        } else if (category.equals("user")) {
          searchResult =
              await MalUser.searchUser(query, filters: _filterOutputs);
          handleUserSearchResult(query, searchResult);
        } else if (["featured", "news"].contains(category)) {
          searchResult = await DalApi.i.searchFeaturedArticles(
            query: query,
            category: category,
            tag: _filterOutputs['tags']?.value,
          );
        } else if (category.equals('interest_stack')) {
          searchResult = await DalApi.i.searchInterestStacks(
            query: query,
            type: _filterOutputs['type']?.apiValues?.elementAt(
                (_filterOutputs['type']
                    ?.values
                    ?.indexOf(_filterOutputs['type']!.value!))!),
          );
        } else if (_filterOutputs.isNotEmpty ||
            jikanSearchTypes.contains(category)) {
          searchResult = await JikanHelper.jikanSearch(query,
              category: jikanTypeConv[category] ?? category,
              fromCache: true,
              filters: _filterOutputs);
        } else {
          if (int.tryParse(query) != null) {
            searchResult =
                await MalApi.searchById(int.tryParse(query)!, category);
          } else {
            searchResult = await MalApi.searchForContent(query,
                category: category,
                fromCache: fromCache,
                limit: 31,
                fields: [
                  "num_episodes,broadcast,alternative_titles,start_date,status,mean,num_list_users,genres,media_type,num_volumes,my_list_status"
                ]);
          }
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
      String query = _searchController.text;
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
              filters: _filterOutputs,
              offset: int.tryParse(searchResult!.paging!.next!) ?? 24);
        } else if (["featured", "news"].contains(category)) {
          _searchResult = await DalApi.i.searchFeaturedArticles(
              query: query,
              category: category,
              tag: _filterOutputs['tags']?.value,
              page: int.tryParse(searchResult!.paging!.next!) ?? 2);
        } else if (category.equals('interest_stack')) {
          _searchResult = await DalApi.i.searchInterestStacks(
            query: query,
            page: int.tryParse(searchResult?.paging?.next ?? '1') ?? 1,
            type: _filterOutputs['type']?.apiValues?.elementAt(
                (_filterOutputs['type']
                    ?.values
                    ?.indexOf(_filterOutputs['type']!.value!))!),
          );
        } else if (jikanSearchTypes.contains(category) ||
            _filterOutputs.isNotEmpty) {
          _searchResult = await JikanHelper.jikanSearch(query ?? "",
              category: jikanTypeConv[category] ?? category,
              fromCache: fromCache,
              filters: _filterOutputs,
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
    _searchController.dispose();
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
        _filterOutputs = {};
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

  void _onFilterChange(SortFilterDisplay option) {
    showFilter = false;
    if (_sortFilterDisplay.hasOnlyDisplayTypeChanged(option)) {
      _sortFilterDisplay = option.clone();
      _setFiltersInCache();
    } else {
      _sortFilterDisplay = option.clone();
      if (_filterOutputs.isEmpty) {
        reset();
      }
      resetFilter();
      if (_searchController.text.isNotBlank || _filterOutputs.isNotEmpty) {
        startSearch(_searchController.text);
      }
      _setFiltersInCache();
    }
  }

  void _setFiltersInCache() {
    CacheManager.instance.setValueForService(
        'searchService', 'sortFilterDisplay', jsonEncode(_sortFilterDisplay));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.exclusiveScreen) {
      return Scaffold(
        appBar: _exclusiveAppBar(),
        body: Stack(
          children: [
            _onSearchBuild(context, AsyncSnapshot.nothing()),
            _filterSection(),
          ],
        ),
      );
    }
    return WillPopWidget(
      child: Scaffold(
        body: Stack(
          children: [
            StreamBuilder<HistoryData>(
              initialData: StreamUtils.i.initalData(StreamType.search_page),
              stream: StreamUtils.i.getStream(StreamType.search_page),
              builder: _onSearchBuild,
            ),
            searchbar(),
            Padding(padding: EdgeInsets.only(top: 83), child: _filterSection()),
          ],
        ),
      ),
      onWillPop: _onWillScope,
    );
  }

  AppBar _exclusiveAppBar() {
    return AppBar(
      title: buildListHeader(),
      actions: [
        IconButton(
          onPressed: _flipFliter,
          icon: Icon(LineIcons.filter),
        ),
        IconButton(
          onPressed: () => _gotToFullSearch(),
          icon: Icon(Icons.search),
        ),
      ],
    );
  }

  void _gotToFullSearch() {
    gotoPage(
      context: context,
      newPage: GeneralSearchScreen(
        filterOutputs: _filterOutputs,
        category: category,
        autoFocus: false,
      ),
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
      return StreamBuilder<bool>(
        stream: DalApi.i.autoCompleteCacheLoaded.stream,
        initialData: DalApi.i.autoCompleteCacheLoaded.currentValue,
        builder: (_, snapshot) {
          final autoCompleteCacheLoaded = snapshot.data ?? false;
          return StreamBuilder<String>(
            stream: _searchTextListener.stream
                .throttle(const Duration(milliseconds: 500)),
            builder: (_, snap) {
              final text = snap.data;
              if (text != null && text.isNotBlank) {
                return CFutureBuilder(
                  future: _seasonResult,
                  done: (_snap) => _animeTypeSearch(
                      text, _snap.data, data, autoCompleteCacheLoaded),
                  loadingChild: _buildHistory(data),
                );
              }
              return _buildHistory(data);
            },
          );
        },
      );
    } else {
      return _buildHistory(data);
    }
  }

  Widget _animeTypeSearch(String text, SearchResult? result, HistoryData? data,
      bool autoCompleteCacheLoaded) {
    text = text.trim().toLowerCase();
    if (text.length < 3) {
      return _buildHistory(data);
    }
    return CFutureBuilder<List<AnimeAutoComplete>>(
      done: (animeLink) => _buildHistory(data, animeLink.data),
      loadingChild: _buildHistory(data, [], autoCompleteCacheLoaded),
      future: DalApi.i.autoCompleteAnime(text),
    );
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
        const SizedBox(height: 120.0),
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
          const SizedBox(height: 20),
          _buildResultLayout(),
          const SizedBox(height: 20),
          if (_hasLoadMore) loadMoreContent(),
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
              _buildListResults(_results, e.value),
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
      else if (_filterOutputs.length == 1 &&
          (_filterOutputs['genres']?.includedOptions ?? []).length == 1 &&
          (_filterOutputs['genres']?.excludedOptions ?? []).length == 0)
        return listHeading(
            '${_filterOutputs['genres']!.includedOptions![0].replaceAll('_', ' ')} $category');
      else if (_filterOutputs.length == 1 &&
          _filterOutputs['producer']?.value != null)
        return listHeading(
            '${_filterOutputs['producer']!.value!.standardize()} $category');
      else
        return listHeading(S.current.Search_Results);
    } else {
      String query = _searchController.text;
      var ifSeason = seasonalLogic(query.replaceAll("#", "")) ?? false;
      return ifSeason
          ? seasonHeader()
          : listHeading(
              "Top ${query.replaceAll("#", "").replaceAll("@", " ").capitalizeAll()!.standardize()}");
    }
  }

  Widget _buildResultLayout() {
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
        return _buildListResults(results, category);
    }
  }

  Widget showGridLayout() {
    if (contentTypes.contains(category) || category.equals('interest_stack'))
      return _buildResultLayout();
    return buildGridResults(results, category, scrollController, context);
  }

  Widget _buildHistory(HistoryData? data,
      [List<AnimeAutoComplete>? searchNodes,
      bool showAutoCompleteProgress = false]) {
    final queryHistory = data?.queryHistory ?? [];
    final recentAnime = data?.recentAnime ?? [];
    final recentManga = data?.recentManga ?? [];
    final _searchNodes = searchNodes ?? [];
    final padding = EdgeInsets.only(top: 90.0);

    return CustomScrollWrapper([
      SliverToBoxAdapter(
        child: Padding(padding: padding),
      ),
      if (showFilter) SliverWrapper(_searchDivider()),
      if (showAutoCompleteProgress)
        SliverToBoxAdapter(
            child: Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 560),
          child: SB.z,
        )),
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
          _buildNodeSearch(_searchNodes),
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

  SliverList _buildNodeSearch(List<AnimeAutoComplete> nodes) {
    return SliverList.builder(
      itemBuilder: (_, index) {
        final node = nodes[index];
        return ListTile(
          leading: SizedBox(
            height: 50.0,
            width: 50.0,
            child: AvatarWidget(
              url: node.picture,
            ),
          ),
          title:
              Text(node.title, style: Theme.of(context).textTheme.labelMedium),
          onTap: () {
            HistoryData.setHistory(
                dataType: HistoryDataType.query, value: node.title);
            gotoPage(
                context: context,
                newPage: ContentDetailedScreen(
                  node: Node(
                    id: int.tryParse(node.malId ?? ''),
                    mainPicture: Picture(large: node.picture),
                    title: node.title,
                  ),
                  category: 'anime',
                ));
          },
          trailing: ToolTipButton(
            message: S.current.Search,
            usePadding: true,
            onTap: () {
              focusNode.unfocus();
              _searchController.text = node.title;
              startSearch(node.title);
            },
            child: Icon(Icons.arrow_outward),
          ),
        );
      },
      itemCount: nodes.length,
    );
  }

  SliverToBoxAdapter _buildRecentNodes(List<Node> nodes, String category) {
    return SliverToBoxAdapter(
      child: Container(
        child: horizontalList(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          items: nodes.map((e) => BaseNode(content: e)).toList(),
          category: category,
          onClose: (i) => HistoryData.setHistory(
            remove: true,
            value: nodes.elementAt(i),
            dataType: category.equals("anime")
                ? HistoryDataType.anime
                : HistoryDataType.manga,
          ),
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
            _searchController.text = queryHistory[index];
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
            queryHistory[index],
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
    String query = _searchController.text;
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
                    _searchController.text = "#" +
                        seasonList.elementAt(value) +
                        "@" +
                        yearList[yearIndex].toString();
                    isSpecialQuery = true;
                    startSearch(_searchController.text, isSpecialQuery: true);
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
                    _searchController.text = "#" +
                        seasonList.elementAt(seasonIndex) +
                        "@" +
                        yearList[value].toString();
                    isSpecialQuery = true;
                    startSearch(_searchController.text, isSpecialQuery: true);
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
      padding: EdgeInsets.zero,
      topics: results as List<ForumTopicsData>,
    );
  }

  Widget _buildListResults(List<BaseNode>? _results, String _category) {
    if (_results == null || _results.isEmpty) return SB.z;
    Widget build;
    if (contentTypes.contains(category)) {
      build = _contentTypesList(_category, _results);
    } else {
      build = _contentList(_category, _results);
    }
    return CustomScrollWrapper(
      [build],
      shrink: true,
    );
  }

  Widget _contentList(String _category, List<BaseNode> _results) {
    return ContentListWidget(
      category: _category,
      contentList: _results,
      displayType: DisplayType.list_vert,
      showIndex: false,
      showEdit: false,
      updateCacheOnEdit: true,
      showBackgroundImage: false,
      showStatus: false,
      padding: EdgeInsets.only(top: 0),
      onContentUpdate: () {},
      aspectRatio: 2.35,
      imageAspectRatio: .6,
    );
  }

  Widget _contentTypesList(String _category, List<BaseNode> _results) {
    return ContentListWithDisplayType(
      category: _category,
      items: _results,
      sortFilterDisplay: _sortFilterDisplay,
      showIndex: true,
      showEdit: true,
      updateCacheOnEdit: true,
      showStatus: true,
    );
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
                              _buildSearchFormField(),
                              _buildFilter(),
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
    return StreamBuilder<String>(
      stream: _searchTextListener.stream,
      builder: (context, snapshot) {
        return IconButton(
          onPressed: () {
            if (snapshot.data != null && snapshot.data!.isNotBlank) {
              _searchController.clear();
              if (isSpecialQuery && mounted) {
                setState(() {
                  isSpecialQuery = false;
                });
              }
            } else {
              Navigator.pop(context);
            }
          },
          icon: Icon(snapshot.data != null && snapshot.data!.isNotBlank
              ? Icons.clear
              : Icons.arrow_back),
        );
      },
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
          controller: _searchController,
          onFieldSubmitted: (value) {
            if (value.isBlank) {
              return;
            }
            showFilter = false;
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
            hintText: '${S.current.Search} $category',
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

  void _onCategorySelect(String value) {
    if (prevQuery.isBlank) {
      category = value;
      reset();
    } else {
      if (prevQuery.notEquals(_searchController.text)) {
        return;
      }
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

  Widget _filterSection() {
    try {
      return ExpandedSection(
        expand: showFilter,
        child: Container(
          width: double.infinity,
          child: SortFilterPopup(
            sortFilterDisplay: _sortFilterDisplay,
            onSortFilterChange: _onFilterChange,
            showText: category.equals("featured"),
            additional: S.current.Tags_unApplied,
            independent: false,
            sortFilterOptions: SortFilterOptions(
              sortOptions: [],
              filterOptions: isSpecialQuery
                  ? []
                  : _removeExclusiveFilters(getFilterOptions()),
              displayOptions: _getDisplayOptions(),
              categories:
                  (widget.exclusiveScreen || isSpecialQuery) ? [] : searchTypes,
            ),
            onCategoryChange: (value) {
              _onCategorySelect(value);
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
    } catch (e) {
      return SB.z;
    }
  }

  List<SelectDisplayOption> _getDisplayOptions() {
    switch (category) {
      case 'anime':
      case 'manga':
        return SortFilterOptions.getDisplayOptions(category: category);
      default:
        return [];
    }
  }

  Widget _buildFilter() {
    return SizedBox(
      height: 38.0,
      width: 55.0,
      child: ShadowButton(
          onPressed: () {
            _flipFliter();
          },
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: ToolTipButton(
            onTap: _flipFliter,
            message: S.current.Filter,
            child: Icon(getFilterIcon(_filterOutputs.keys)),
          )),
    );
  }

  void _flipFliter() {
    if (mounted)
      setState(() {
        showFilter = !showFilter;
      });
  }

  List<FilterOption> _removeExclusiveFilters(List<FilterOption> filters) {
    if (!widget.exclusiveScreen) return filters;
    return filters.map((element) {
      var filterOutputs = _filterOutputs;
      if (filterOutputs.length == 1) {
        if (element.apiFieldName == filterOutputs.values.first.apiFieldName) {
          final clone = element.clone();
          clone.hideOption = true;
          return clone;
        }
      }
      return element;
    }).toList();
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
    desc: S.current.Genre_Include_Exclude_desc_v2,
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

enum DisplaySubType { compact, comfortable, cover_only_grid, spacious, custom }
