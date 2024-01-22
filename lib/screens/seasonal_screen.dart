import 'package:dailyanimelist/api/auth/auth.dart';
import 'package:dailyanimelist/api/malapi.dart';
import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/enums.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/main.dart';
import 'package:dailyanimelist/screens/generalsearchscreen.dart';
import 'package:dailyanimelist/widgets/custombutton.dart';
import 'package:dailyanimelist/widgets/customfuture.dart';
import 'package:dailyanimelist/widgets/selectbottom.dart';
import 'package:dailyanimelist/widgets/slivers.dart';
import 'package:dailyanimelist/widgets/user/contentlistwidget.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:flutter/material.dart';

class SeasonalConstants {
  static const totalYears = 64;
  static final maxYear = DateTime.now().year + 1;
}

class _Season {
  final int year;
  final SeasonType seasonType;
  final String display;

  _Season(this.year, this.seasonType, this.display);
}

class SeasonalScreen extends StatefulWidget {
  final SeasonType seasonType;
  final int year;
  final SortType? sortType;

  const SeasonalScreen({
    Key? key,
    required this.seasonType,
    required this.year,
    this.sortType,
  }) : super(key: key);

  @override
  State<SeasonalScreen> createState() => _SeasonalScreenState();
}

class _SeasonalScreenState extends State<SeasonalScreen>
    with TickerProviderStateMixin {
  static final tabsLength = yearList.length;
  static final seasonList = seasonMapCaps.values.toList().reversed.toList();
  static final yearList = List.generate(SeasonalConstants.totalYears,
          (index) => (SeasonalConstants.maxYear - index).toString())
      .expand((year) => seasonList
          .map((e) => _Season(
              int.parse(year), seasonMapInverse[e.toLowerCase()]!, '$e $year'))
          .toList())
      .toList();
  static final seasonImage = {
    SeasonType.FALL: 'assets/images/fall.jpg',
    SeasonType.SPRING: 'assets/images/cherry.jpg',
    SeasonType.SUMMER: 'assets/images/summer.jpg',
    SeasonType.WINTER: 'assets/images/winter.png',
  };
  static final seasonMap = SeasonType.values.asMap();
  late int currentYearIndex;
  late int currentSeasonIndex;
  int currPageIndex = 0;
  SortType? sortType;
  late String imageUrl;
  DisplayType displayType = DisplayType.list_vert;
  List<String> sortTypeOptions = [
    S.current.None,
    ...SortType.values.asNameMap().keys
  ];
  final displayTypeOptions = {
    DisplayType.list_vert: 'List View',
    DisplayType.grid: 'Grid View',
  };
  late String refKey;
  int get pageLimit => sortType == SortType.AnimeScore ? 500 : 14;

  @override
  void initState() {
    super.initState();
    currentSeasonIndex = widget.seasonType.index;
    currentYearIndex = widget.year;
    sortType = widget.sortType;
    refKey = MalAuth.codeChallenge(10);
    setImageUrl();
  }

  @override
  void dispose() {
    super.dispose();
  }

  int getInitialIndex() {
    final seasonsLength = seasonList.length;
    final int yearOffset = (currentYearIndex - SeasonalConstants.maxYear).abs();
    return yearOffset * seasonsLength +
        (seasonsLength - 1 - currentSeasonIndex).abs();
  }

  void setImageUrl() {
    imageUrl = seasonImage[seasonMap[currentSeasonIndex]]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: tabsLength,
        initialIndex: getInitialIndex(),
        child: NestedScrollView(
          headerSliverBuilder: (_, __) => [_buildAppBar()],
          body: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return TabBarView(
      physics: const NeverScrollableScrollPhysics(),
      children: yearList.map((e) => _buildStateFullSeason(e)).toList(),
    );
  }

  SliverAppBarWrapper _buildAppBar() {
    return SliverAppBarWrapper(
      title: Text(S.current.Seasonal),
      implyLeading: true,
      toolbarHeight: 120,
      expandedHeight: 120,
      snap: false,
      flexSpace: _backgroundImage(),
      bottom: _buildTabBar(),
      actions: _buildActions,
    );
  }

  List<Widget> get _buildActions {
    return [
      ToolTipButton(
        message: S.current.Search_Bar_Text,
        onTap: () => gotoPage(
            context: context,
            newPage: GeneralSearchScreen(
              showBackButton: true,
              autoFocus: false,
            )),
        child: Icon(Icons.search),
      ),
      SB.w20,
      SizedBox(
        child: SelectButton(
          options: displayTypeOptions.values.toList(),
          selectedOption: displayTypeOptions[displayType],
          selectType: SelectType.select_top,
          popupText: S.current.Select_One,
          child: Icon(
            displayType == DisplayType.list_vert
                ? Icons.view_agenda
                : Icons.view_column,
          ),
          onChanged: (value) async {
            setState(() {
              displayType = displayTypeOptions.keys
                  .elementAt(displayTypeOptions.values.toList().indexOf(value));
            });
          },
        ),
      ),
      SB.w20,
      SelectButton(
        options: sortTypeOptions,
        selectedOption: sortType?.name ?? S.current.None,
        selectType: SelectType.select_top,
        popupText: S.current.Sort_the_list_based_on,
        child: Icon(Icons.sort),
        onChanged: (value) {
          setState(() {
            sortType = SortType.values.asNameMap()[value];
          });
        },
      ),
    ];
  }

  Opacity _backgroundImage() {
    return Opacity(
      opacity: .2,
      child: Image.asset(
        imageUrl,
        fit: BoxFit.cover,
      ),
    );
  }

  TabBar _buildTabBar() {
    return TabBar(
      isScrollable: true,
      onTap: _onTabChange,
      indicatorSize: TabBarIndicatorSize.label,
      tabs: yearList.map((e) => Tab(text: e.display)).toList(),
    );
  }

  void _onTabChange(int index) {
    final date = DateTime.now();
    final _season = yearList[index];
    currentSeasonIndex = _season.seasonType.index;
    currentYearIndex = _season.year;
    setImageUrl();
    if (mounted) setState(() {});
    logDal('Date-${DateTime.now().difference(date)}');
  }

  Future<List<BaseNode>> seasonalFuture(_Season e, int offset) async {
    final seasonalAnime = await MalApi.getSeasonalAnime(
      e.seasonType,
      e.year,
      sortType: sortType,
      fields: [MalApi.listDetailedFields, MalApi.userAnimeFields],
      offset: offset,
      limit: pageLimit,
    );
    return sortAnimeNodes(seasonalAnime.data ?? []);
  }

  List<BaseNode> sortAnimeNodes(List<BaseNode> nodes) {
    if (sortType == SortType.AnimeScore) {
      nodes.sort((a, b) {
        final contentA = a.content;
        final contentB = b.content;
        if (contentA is AnimeDetailed && contentB is AnimeDetailed) {
          return contentB.mean?.compareTo(contentA.mean ?? -1) ?? -1;
        }
        return 0;
      });
      return nodes;
    } else {
      return nodes;
    }
  }

  Widget _buildStateFullSeason(_Season e) {
    return RefreshIndicator(
      onRefresh: () async {
        refKey = MalAuth.codeChallenge(10);
        setState(() {});
      },
      child: InfinitePagination<BaseNode>(
        refKey: '${e.seasonType}-${e.year}-${sortType}-${displayType}-$refKey',
        future: (offset) => seasonalFuture(e, offset),
        pageSize: pageLimit,
        displayType: displayType,
        itemBuilder: (_, item, index) => buildBaseNodePageItem(
          'anime',
          item,
          index,
          displayType,
          gridAxisCount: 2,
          gridHeight: 280.0,
        ),
      ),
    );
  }
}
