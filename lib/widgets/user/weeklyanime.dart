import 'package:dailyanimelist/api/malapi.dart';
import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/enums.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/main.dart';
import 'package:dailyanimelist/screens/contentdetailedscreen.dart';
import 'package:dailyanimelist/screens/generalsearchscreen.dart';
import 'package:dailyanimelist/screens/plainscreen.dart';
import 'package:dailyanimelist/widgets/custombutton.dart';
import 'package:dailyanimelist/widgets/customfuture.dart';
import 'package:dailyanimelist/widgets/home/animecard.dart';
import 'package:dailyanimelist/widgets/listsortfilter.dart';
import 'package:dailyanimelist/widgets/search/filtermodal.dart';
import 'package:dailyanimelist/widgets/slivers.dart';
import 'package:dailyanimelist/widgets/user/contentlistwidget.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

class WeeklySchedulePage extends StatefulWidget {
  final SeasonType? seasonType;
  final int? year;
  const WeeklySchedulePage({super.key, this.seasonType, this.year});

  @override
  State<WeeklySchedulePage> createState() => _WeeklySchedulePageState();
}

class _WeeklySchedulePageState extends State<WeeklySchedulePage>
    with SingleTickerProviderStateMixin {
  final _sortOptions = [
    SortOption(name: S.current.Score, value: 'mean'),
    SortOption(name: S.current.numListUsers, value: 'num_list_users'),
    SortOption(name: S.current.numScoringUsers, value: 'num_scoring_users'),
  ];
  final List<FilterOption> _filterOptions = [
    FilterOption(
      fieldName: 'List Status',
      type: FilterType.select,
      apiFieldName: 'status',
      modalField: 'my_list_status',
      desc: S.current.Filter_type_of_results,
      values: myAnimeStatusMap.values.toList(),
      apiValues: myAnimeStatusMap.keys.toList(),
    ),
  ];
  late SortFilterDisplay _sortFilterDisplay;
  String serviceName = 'weekly_schedule';
  String serviceKey = '@me';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 8, vsync: this, initialIndex: DateTime.now().weekday - 1);
    _setSortFilterDisplayFuture();
  }

  void _setSortFilterDisplayFuture() async {
    _sortFilterDisplay = await SortFilterDisplay.fromCache(
        serviceName, serviceKey, _defaultObject());
    if (mounted) setState(() {});
  }

  SortFilterDisplay _defaultObject() {
    return SortFilterDisplay(
      sort: _sortOptions[0].clone(),
      displayOption: DisplayOption(
        displayType: DisplayType.list_vert,
        displaySubType: DisplaySubType.comfortable,
      ),
      filterOutputs: {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return TitlebarScreen(
      WeeklyAnimeWidget(
        seasonType: widget.seasonType,
        year: widget.year,
        sortFilterDisplay: _sortFilterDisplay,
        tabController: _tabController,
      ),
      appbarTitle: '${widget.seasonType?.name.titleCase()} ${widget.year}',
      actions: [
        IconButton(
          icon: Icon(LineIcons.filter),
          onPressed: () => showSortFilterDisplayModal(
            context: context,
            sortFilterDisplay: _sortFilterDisplay,
            category: 'anime',
            sortFilterOptions: SortFilterOptions(
              sortOptions: _sortOptions,
              filterOptions: _filterOptions,
              displayOptions: [
                ...SortFilterOptions.getDisplayOptions(),
                SelectDisplayOption(
                  name: S.current.Horizontal_List,
                  type: DisplayType.list_horiz,
                )
              ],
            ),
            onSortFilterChange: (sortFilterDisplay) {
              setState(() {
                _sortFilterDisplay = sortFilterDisplay.clone();
                sortFilterDisplay.toCache(serviceName, serviceKey);
              });
            },
          ),
        )
      ],
    );
  }
}

class WeeklyAnimeWidget extends StatefulWidget {
  final SeasonType? seasonType;
  final int? year;
  final SortFilterDisplay sortFilterDisplay;
  final TabController tabController;
  const WeeklyAnimeWidget({
    Key? key,
    this.seasonType,
    this.year,
    required this.sortFilterDisplay,
    required this.tabController,
  }) : super(key: key);

  @override
  _WeeklyAnimeWidgetState createState() => _WeeklyAnimeWidgetState();
}

class _WeeklyAnimeWidgetState extends State<WeeklyAnimeWidget> {
  late Future<List<List<BaseNode>>> _scheduleFeature;
  late SortFilterDisplay _sortFilterDisplay;
  var weekdays = [
    S.current.monday,
    S.current.tuesday,
    S.current.wednesday,
    S.current.thursday,
    S.current.friday,
    S.current.saturday,
    S.current.sunday,
    S.current.Others
  ];

  @override
  void initState() {
    super.initState();
    _sortFilterDisplay = widget.sortFilterDisplay.clone();
    _setFuture();
  }

  void _setFuture() {
    _scheduleFeature = getFuture();
  }

  Future<List<List<BaseNode>>> getFuture([bool fromCache = true]) async {
    return _applySortFilters(
      (await MalApi.getSchedule(
        currentYear: widget.year,
        seasonType: widget.seasonType,
        fromCache: fromCache,
      ))
          .map((e) => e
              .map((f) => BaseNode(content: f, myListStatus: f.myListStatus))
              .toList())
          .toList(),
    );
  }

  Future<List<List<BaseNode>>> _applySortFilters(
      List<List<BaseNode>> nodes) async {
    final List<List<BaseNode>> result = [];
    for (var nodesList in nodes) {
      var list = await getSortedFilteredData(
          nodesList, false, _sortFilterDisplay, 'anime');
      result.add(list);
    }
    return result;
  }

  @override
  void didUpdateWidget(covariant WeeklyAnimeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sortFilterDisplay != widget.sortFilterDisplay && mounted) {
      _sortFilterDisplay = widget.sortFilterDisplay.clone();
      _setFuture();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return CFutureBuilder(
      future: _scheduleFeature,
      done: _handleResult,
      loadingChild: loadingCenter(),
      onError: (error) => {logDal(error)},
    );
  }

  Widget _handleResult(AsyncSnapshot<List<List<BaseNode>>>? result) {
    if (result != null && result.hasData && !nullOrEmpty(result.data)) {
      var schedule = result.data!;
      return switch (_sortFilterDisplay.displayOption.displayType) {
        DisplayType.list_horiz => _handleHorizontalList(schedule),
        DisplayType.list_vert =>
          _handleTabbedList(schedule, DisplayType.list_vert),
        DisplayType.grid => _handleTabbedList(schedule, DisplayType.grid),
      };
    } else {
      return showNoContentRefesh;
    }
  }

  Widget _handleTabbedList(List<List<BaseNode>> schedule, DisplayType type) {
    return Column(
      children: [
        Material(
          child: TabBar(
            controller: widget.tabController,
            isScrollable: true,
            tabs: [
              for (int i = 0; i < weekdays.length; ++i)
                Tab(
                  text: '${weekdays[i]} (${schedule[i].length})',
                )
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: widget.tabController,
            children: [
              for (int i = 0; i < weekdays.length; ++i)
                _buildContentList(schedule[i]),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildContentList(List<BaseNode> nodes) {
    if (nodes.isEmpty)
      return showNoContent(mainAxisAlignment: MainAxisAlignment.start);
    return CustomScrollView(
      slivers: [
        SB.lh30,
        ContentListWithDisplayType(
          category: 'anime',
          items: nodes,
          sortFilterDisplay: _sortFilterDisplay,
          showTime: true,
        ),
        SB.lh80,
      ],
    );
  }

  Widget _handleHorizontalList(List<List<BaseNode>> schedule) {
    return CustomScrollView(
      slivers: [
        for (int weekIndex = 0; weekIndex < schedule.length; ++weekIndex) ...[
          if (nullOrEmpty(schedule[weekIndex]))
            SB.lz
          else ...[
            SB.lh20,
            SliverWrapper(
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: title(weekdays[weekIndex], fontSize: 20, opacity: 1),
              ),
            ),
            SB.lh20,
            SliverToBoxAdapter(
              child: Container(
                height: 255,
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  itemBuilder: (_, animeIndex) {
                    var node = schedule[weekIndex][animeIndex];
                    return AnimeGridCard(
                      height: 170,
                      width: 150,
                      showEdit: true,
                      showTime: true,
                      showCardBar: true,
                      node: node.content!,
                      updateCache: true,
                      onTap: () => navigateTo(
                          context,
                          ContentDetailedScreen(
                            node: node.content!,
                            id: node.content!.id,
                          )),
                    );
                  },
                  itemCount: schedule[weekIndex].length,
                  scrollDirection: Axis.horizontal,
                ),
              ),
            ),
          ],
        ],
        SB.lh120
      ],
    );
  }

  onRefresh() {
    setState(() {
      _scheduleFeature = getFuture();
    });
  }

  Widget get showNoContentRefesh {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SB.h40,
          title(S.current.No_Content, fontSize: 20),
          SB.h20,
          refreshButton
        ],
      ),
    );
  }

  Widget get refreshButton {
    return PlainButton(
      child: Text(S.current.refresh),
      onPressed: () => onRefresh(),
    );
  }
}
