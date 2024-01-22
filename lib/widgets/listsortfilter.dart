import 'package:collection/collection.dart';
import 'package:dailyanimelist/api/dalapi.dart';
import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/enums.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/main.dart';
import 'package:dailyanimelist/screens/generalsearchscreen.dart';
import 'package:dailyanimelist/widgets/custombutton.dart';
import 'package:dailyanimelist/widgets/search/filtermodal.dart';
import 'package:dailyanimelist/widgets/selectbottom.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:dal_commons/src/model/anime/schedule_data.dart';
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

bool canBeFetchedFromAPI(
    String category, SortFilterDisplay _sortFilterDisplay) {
  final _isAnime = category.equals('anime');
  final orderMap =
      _isAnime ? animeListDefaultOrderMap : mangaListDefaultOrderMap;

  return _sortFilterDisplay.filterOutputs.isEmpty &&
      orderMap.containsKey(_sortFilterDisplay.sort.value) &&
      orderMap[_sortFilterDisplay.sort.value] == _sortFilterDisplay.sort.order;
}

List<FilterOption> getFilterOptions(String category) {
  return (category.equals('anime')
          ? CustomFilters.animeFilters
          : CustomFilters.mangaFilters)
      .where((e) => e.modalField != null)
      .toList();
}

Future<List<BaseNode>> getSortedFilteredData(
  SearchResult contentResult,
  bool _canBeFetchedFromAPI,
  SortFilterDisplay _sortFilterDisplay,
  String category,
) async {
  var list = contentResult.data ?? [];
  if (!_canBeFetchedFromAPI) {
    if (_sortFilterDisplay.filterOutputs.isNotEmpty) {
      list =
          _filterCustomList(list, _sortFilterDisplay.filterOutputs, category);
    }
    final _isAnime = category.equals('anime');
    final orderMap =
        _isAnime ? animeListDefaultOrderMap : mangaListDefaultOrderMap;
    var sortValue = _sortFilterDisplay.sort.value;
    if (orderMap.containsKey(sortValue)) {
      var defaultOrder = orderMap[sortValue] == _sortFilterDisplay.sort.order;
      if (!defaultOrder) {
        list = list.reversed.toList();
      }
    } else {
      final scheduleForMalIds = await DalApi.i.scheduleForMalIds;
      list = _sortListCustom(list, _sortFilterDisplay, scheduleForMalIds);
    }
  }
  return list;
}

List<BaseNode> _filterCustomList(
  List<BaseNode> list,
  Map<String, FilterOption> filterOutputs,
  String category,
) {
  final isAnime = category.equals('anime');
  return list.where((e) {
    var content = e.content;
    if (content != null) {
      var json = content.toJson();
      forLoop:
      for (var entry in filterOutputs.entries) {
        var option = entry.value;
        final name = option.modalField!;
        var modalValue = json[name];
        if (modalValue == null) return false;
        String? selectedValue = option.value;
        if (selectedValue == null &&
            nullOrEmpty(option.includedOptions) &&
            nullOrEmpty(option.excludedOptions)) return false;
        switch (name) {
          case 'status':
            selectedValue = (isAnime
                ? animeStatusInverseMap
                : mangaStatusInverseMap)[selectedValue];
          case 'rating':
            final n1Rating = inverseRatedMap[modalValue];
            if (n1Rating == null) return false;
            modalValue = n1Rating;
            break;
          case 'genres':
            if (modalValue is List<MalGenre>) {
              final genres =
                  modalValue.map((g) => convertGenre(g, category)).toSet();
              final included = option.includedOptions?.toSet() ?? {};
              final excluded = option.excludedOptions?.toSet() ?? {};
              if (genres.isEmpty) return false;
              if (included.isNotEmpty && !genres.containsAll(included))
                return false;
              if (excluded.isNotEmpty &&
                  genres.intersection(excluded).isNotEmpty) return false;
              continue forLoop;
            }
            return false;
          case 'mean':
            if (int.parse(selectedValue!.replaceAll('+', '')) > modalValue)
              return false;
            else
              continue forLoop;
          case 'start_date':
          case 'end_date':
            final modalDate = DateTime.tryParse(modalValue);
            final selectedDate = DateTime.tryParse(selectedValue!);
            if (modalDate == null || selectedDate == null) return false;
            if (name.equals('start_date')) {
              if (selectedDate.isAfter(modalDate)) return false;
            } else {
              if (selectedDate.isBefore(modalDate)) return false;
            }
            continue forLoop;
          case 'studios':
            int id = option.apiValues!
                .elementAt(option.values!.indexOf(selectedValue!));
            if (modalValue is List<AnimeStudio> &&
                modalValue.map((e) => e.id).contains(id)) {
              continue forLoop;
            }
            return false;
          case 'title':
            if (modalValue is String) {
              if (modalValue
                  .toLowerCase()
                  .startsWith(selectedValue!.toLowerCase())) {
                continue forLoop;
              }
            }
            return false;
        }
        if (!modalValue.toString().equals(selectedValue)) return false;
      }
    }
    return true;
  }).toList();
}

List<BaseNode> _sortListCustom(
  List<BaseNode> list,
  SortFilterDisplay _sortFilterDisplay,
  Map<int, ScheduleData> scheduleForMalIds,
) {
  return list.sorted((b1, b2) {
    var n1 = b1.content;
    var n2 = b2.content;
    if (n1 != null && n2 != null) {
      var sortOption = _sortFilterDisplay.sort;
      var asc = sortOption.order == SortOrder.Ascending;
      var n1Value = n1.toJson()[sortOption.value];
      var n2Value = n2.toJson()[sortOption.value];
      int compare;
      switch (sortOption.value) {
        case 'num_episodes':
          if (n1Value == null || n1Value == 0) {
            n1Value = _getEpisodes(scheduleForMalIds[n1.id]) ?? n1Value;
          }
          if (n2Value == null || n2Value == 0) {
            n2Value = _getEpisodes(scheduleForMalIds[n2.id]) ?? n2Value;
          }
          break;
        case 'popularity':
          final temp = n1Value;
          n1Value = n2Value;
          n2Value = temp;
        default:
      }
      if (n1Value == null && n2Value == null) {
        compare = 0;
      } else if (n1Value == null) {
        compare = 1;
      } else if (n2Value == null) {
        compare = -1;
      } else {
        compare = n1Value.compareTo(n2Value);
      }
      return asc ? compare : -compare;
    }
    return 0;
  });
}

int? _getEpisodes(ScheduleData? node) {
  if (node != null) {
    return node.episode;
  }
  return null;
}

void showContentListModal({
  required BuildContext context,
  required SortFilterDisplay sortFilterDisplay,
  required String category,
  required ValueChanged<SortFilterDisplay> onSortFilterChange,
}) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return SortFilterPopup(
        category: category,
        sortFilterDisplay: sortFilterDisplay,
        onSortFilterChange: onSortFilterChange,
      );
    },
  );
}

class SortFilterPopup extends StatefulWidget {
  const SortFilterPopup({
    super.key,
    required this.category,
    required this.sortFilterDisplay,
    required this.onSortFilterChange,
  });

  final String category;
  final SortFilterDisplay sortFilterDisplay;
  final ValueChanged<SortFilterDisplay> onSortFilterChange;

  @override
  State<SortFilterPopup> createState() => _SortFilterPopupState();
}

class _SortFilterPopupState extends State<SortFilterPopup> {
  final tabs = [
    Tab(
      text: S.current.Sort,
    ),
    Tab(
      text: S.current.Filter,
    ),
    Tab(
      text: S.current.Display,
    ),
  ];
  final _displayOptions = {
    DisplayType.grid: {
      'name': S.current.Grid,
      'subType': [
        {
          'name': S.current.Comfortable,
          'value': DisplaySubType.comfortable,
        },
        {
          'name': S.current.Compact,
          'value': DisplaySubType.compact,
        },
        {
          'name': S.current.Cover_only,
          'value': DisplaySubType.cover_only_grid,
        },
      ],
    },
    DisplayType.list_vert: {
      'name': S.current.List,
      'subType': [
        {
          'name': S.current.Comfortable,
          'value': DisplaySubType.comfortable,
        },
        {
          'name': S.current.Compact,
          'value': DisplaySubType.compact,
        },
        {
          'name': S.current.Spacious,
          'value': DisplaySubType.spacious,
        },
      ],
    },
  };
  late SortFilterDisplay _originalSortFilterDisplay;
  late SortFilterDisplay _sortFilterDisplay;
  late List<SortOption> _sortOptions;
  late List<FilterOption> _filterOptions;

  @override
  void initState() {
    super.initState();
    _originalSortFilterDisplay = widget.sortFilterDisplay.clone();
    _sortFilterDisplay = widget.sortFilterDisplay.clone();
    _sortOptions = _getSortOptions();
    _filterOptions = getFilterOptions(widget.category);
  }

  bool get _isAnime => widget.category.equals('anime');

  List<SortOption> _getSortOptions() {
    var map = _isAnime ? animeListSortMap : mangaListSortMap;
    final defaultOptions = map.entries.map((e) {
      return SortOption(name: e.value, value: e.key);
    }).toList();
    defaultOptions.addAll(_additionalOptions());
    return defaultOptions.map((e) {
      var isSelected = _sortFilterDisplay.sort.value.equals(e.value);
      return e.copyWith(
          order: isSelected
              ? _sortFilterDisplay.sort.order
              : (_isAnime
                      ? animeListDefaultOrderMap
                      : mangaListDefaultOrderMap)[e.value] ??
                  SortOrder.Descending);
    }).toList();
  }

  List<SortOption> _additionalOptions() {
    if (_isAnime) {
      return [
        SortOption(
          name: S.current.Popularity,
          value: 'popularity',
        ),
        SortOption(
          name: S.current.numListUsers,
          value: 'num_list_users',
        ),
        SortOption(
          name: S.current.numScoringUsers,
          value: 'num_scoring_users',
        ),
        SortOption(
          name: S.current.numEpisodes,
          value: 'num_episodes',
        ),
        SortOption(
          name: S.current.broadCastStartDate,
          value: 'start_date',
        ),
        SortOption(
          name: S.current.broadCastEndDate,
          value: 'end_date',
        ),
      ];
    } else {
      return [
        SortOption(
          name: S.current.Popularity,
          value: 'popularity',
        ),
        SortOption(
          name: S.current.numListUsers,
          value: 'num_list_users',
        ),
        SortOption(
          name: S.current.numScoringUsers,
          value: 'num_scoring_users',
        ),
        SortOption(
          name: S.current.numVolumes,
          value: 'num_volumes',
        ),
        SortOption(
          name: S.current.numChapters,
          value: 'num_chapters',
        ),
        SortOption(
          name: S.current.publishedStartDate,
          value: 'start_date',
        ),
        SortOption(
          name: S.current.publishedEndDate,
          value: 'end_date',
        ),
      ];
    }
  }

  int _indexOfSortOption(SortOption sortOption) {
    return _sortOptions
        .indexWhere((element) => element.value.equals(sortOption.value));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      initialIndex: _sortFilterDisplay.selectedTab,
      child: Builder(builder: (tabContext) {
        return WillPopScope(
          onWillPop: () async {
            _prepareClose(tabContext);
            return false;
          },
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(tabContext).size.height * .8,
              minHeight: MediaQuery.of(tabContext).size.height * .3,
            ),
            child: Stack(
              children: [
                Material(
                  child: SizedBox.expand(),
                ),
                _tabBarView(),
                _tabs(),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _bottomBar(tabContext),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Material _tabs() {
    return Material(
      child: SizedBox(
        height: 50.0,
        child: TabBar(
          padding: EdgeInsets.zero,
          tabs: tabs,
        ),
      ),
    );
  }

  Widget _tabBarView() {
    return Padding(
      padding: const EdgeInsets.only(top: 40.0),
      child: TabBarView(
        children: [
          _sortView(),
          _filterView(),
          _displayView(),
        ],
      ),
    );
  }

  Widget _displayView() {
    var displayOption =
        _displayOptions[_sortFilterDisplay.displayOption.displayType];
    return CustomScrollView(
      slivers: [
        SB.lh20,
        SliverToBoxAdapter(
          child: ListTile(
            title: Text(S.current.Display_Type),
          ),
        ),
        SliverList.list(
            children: _displayOptions.entries.map((e) {
          return RadioListTile<DisplayType>(
            value: e.key,
            groupValue: _sortFilterDisplay.displayOption.displayType,
            title: Text(e.value['name'].toString()),
            onChanged: (value) {
              if (value == null) return;
              _sortFilterDisplay = _sortFilterDisplay.copyWith(
                display: _sortFilterDisplay.displayOption.copyWith(
                  displayType: value,
                  displaySubType: DisplaySubType.comfortable,
                ),
              );
              setState(() {});
            },
          );
        }).toList()),
        SliverToBoxAdapter(
          child: ListTile(
            title: Text(S.current.Display_Sub_Type),
          ),
        ),
        if (displayOption != null)
          SliverList.list(
              children: (displayOption['subType'] as List<Map>).map((e) {
            return RadioListTile<DisplaySubType>(
              value: e['value'],
              groupValue: _sortFilterDisplay.displayOption.displaySubType,
              title: Text(e['name'].toString()),
              onChanged: (value) {
                if (value == null) return;
                _sortFilterDisplay = _sortFilterDisplay.copyWith(
                  display: _sortFilterDisplay.displayOption.copyWith(
                    displaySubType: value,
                  ),
                );
                setState(() {});
              },
            );
          }).toList()),
        if (_sortFilterDisplay.displayOption.displayType ==
            DisplayType.grid) ...[
          SliverToBoxAdapter(
            child: _gridAxisSizeSliderWidget(),
          ),
          SB.lh10,
          SliverToBoxAdapter(
            child: _gridheightSliderWidget(),
          ),
        ],
        SB.lh80,
      ],
    );
  }

  Widget _sortView() {
    var initialIndex = _indexOfSortOption(_sortFilterDisplay.sort);
    return ScrollablePositionedList.builder(
      padding: const EdgeInsets.only(top: 20.0, bottom: 90.0),
      initialScrollIndex: initialIndex == -1 ? 0 : initialIndex,
      itemBuilder: (context, index) {
        var sortOption = _sortOptions[index];
        return ListTile(
          title: Text(sortOption.name),
          trailing: _sortTrailing(sortOption, index),
          onTap: () {
            _onSortChange(sortOption, index);
          },
        );
      },
      itemCount: _sortOptions.length,
    );
  }

  void _onSortChange(SortOption sortOption, int index) {
    var order = _isSortSelected(sortOption)
        ? (sortOption.order == SortOrder.Ascending
            ? SortOrder.Descending
            : SortOrder.Ascending)
        : null;
    var _sortOption = sortOption.copyWith(order: order);
    _sortOptions[index] = _sortOption;
    _sortFilterDisplay = _sortFilterDisplay.copyWith(
      sort: _sortOption,
    );
    setState(() {});
  }

  Widget? _sortTrailing(SortOption sortOption, int index) {
    if (_isSortSelected(sortOption)) {
      var isAsc = sortOption.order == SortOrder.Ascending;
      return SizedBox(
        height: 30.0,
        width: 80.0,
        child: ShadowButton(
          padding: EdgeInsets.zero,
          onPressed: () => _onSortChange(sortOption, index),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(isAsc ? 'asc' : 'desc'),
              SB.w5,
              Icon(
                isAsc ? Icons.arrow_upward : Icons.arrow_downward,
                size: 16.0,
              ),
            ],
          ),
        ),
      );
    } else {
      return null;
    }
  }

  bool _isSortSelected(SortOption sortOption) =>
      sortOption.value.equals(_sortFilterDisplay.sort.value);

  Widget _bottomBar(BuildContext controllerContext) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      child: Column(
        children: [
          Divider(
            height: 1.0,
          ),
          SB.h5,
          Row(
            children: [
              SB.w10,
              PlainButton(
                child: Text(S.current.Reset),
                onPressed: () => _onReset(controllerContext),
              ),
              Spacer(),
              ShadowButton(
                child: Text(S.current.Save),
                onPressed: () => _prepareClose(controllerContext),
              ),
              SB.w10,
            ],
          ),
        ],
      ),
    );
  }

  void _onReset(BuildContext controllerContext) {
    switch (DefaultTabController.of(controllerContext).index) {
      case 0:
        _sortFilterDisplay = _sortFilterDisplay.copyWith(
          sort: _originalSortFilterDisplay.sort.clone(),
        );
        break;
      case 1:
        _sortFilterDisplay = _sortFilterDisplay.copyWith(
          filterOutputs: {},
        );
        break;
      case 2:
        _sortFilterDisplay = _sortFilterDisplay.copyWith(
          display: _originalSortFilterDisplay.displayOption.clone(),
        );
        break;
      default:
    }
    if (mounted) setState(() {});
  }

  void _prepareClose(BuildContext controllerContext) {
    _setTabIndex(controllerContext);
    widget.onSortFilterChange(_sortFilterDisplay);
    Navigator.of(context).pop();
  }

  void _setTabIndex(BuildContext controllerContext) {
    _sortFilterDisplay = _sortFilterDisplay.copyWith(
      selectedTab: DefaultTabController.of(controllerContext).index,
    );
  }

  Widget _filterView() {
    return FilterModal(
      filterOptions: _filterOptions,
      filterOutputs: _sortFilterDisplay.filterOutputs,
      showBottombar: false,
      onChange: (fo) {
        if (mounted) {
          _sortFilterDisplay = _sortFilterDisplay.copyWith(
            filterOutputs: fo,
          );
          setState(() {});
        }
      },
    );
  }

  Widget _gridAxisSizeSliderWidget() {
    final axisCount = _sortFilterDisplay.displayOption.gridCrossAxisCount;
    final min = 2;
    final max = 4;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SB.h10,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Text(
            '${S.current.Grid_Axis_Size} ($axisCount)',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        SB.h10,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                SB.w10,
                Text('$min'),
                SB.w10,
                Expanded(
                  child: Slider(
                    value: axisCount.toDouble(),
                    min: min.toDouble(),
                    max: max.toDouble(),
                    divisions: 2,
                    label: _sortFilterDisplay.displayOption.gridCrossAxisCount
                        .toString(),
                    onChanged: (value) {
                      _sortFilterDisplay = _sortFilterDisplay.copyWith(
                        display: _sortFilterDisplay.displayOption.copyWith(
                          gridCrossAxisCount: value.toInt(),
                        ),
                      );
                      setState(() {});
                    },
                  ),
                ),
                SB.w10,
                Text('$max'),
                SB.w10,
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _gridheightSliderWidget() {
    final height = _sortFilterDisplay.displayOption.gridHeight;
    final min = 160.0;
    final max = 360.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SB.h10,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Text(
            '${S.current.Grid_Height} ($height)',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        SB.h10,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                SB.w10,
                Text('$min'),
                SB.w10,
                Expanded(
                  child: Slider(
                    value: height,
                    min: min,
                    max: max,
                    divisions: 100,
                    label:
                        _sortFilterDisplay.displayOption.gridHeight.toString(),
                    onChanged: (value) {
                      _sortFilterDisplay = _sortFilterDisplay.copyWith(
                        display: _sortFilterDisplay.displayOption.copyWith(
                          gridHeight: value,
                        ),
                      );
                      setState(() {});
                    },
                  ),
                ),
                SB.w10,
                Text('$max'),
                SB.w10,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class SortFilterDisplay {
  const SortFilterDisplay({
    required this.sort,
    required this.displayOption,
    required this.filterOutputs,
    this.selectedTab = 0,
  });

  final SortOption sort;
  final Map<String, FilterOption> filterOutputs;
  final DisplayOption displayOption;
  final int selectedTab;

  SortFilterDisplay clone() {
    return SortFilterDisplay(
      sort: sort.clone(),
      filterOutputs: _cloneFilters(),
      displayOption: displayOption.clone(),
      selectedTab: selectedTab,
    );
  }

  Map<String, FilterOption> _cloneFilters() {
    return filterOutputs.map((key, value) {
      return MapEntry(key, value.clone());
    });
  }

  SortFilterDisplay copyWith(
      {SortOption? sort,
      String? filterBy,
      String? filterValue,
      DisplayOption? display,
      Map<String, FilterOption>? filterOutputs,
      bool? isCached,
      int? selectedTab}) {
    return SortFilterDisplay(
      sort: sort ?? this.sort,
      displayOption: display ?? this.displayOption,
      filterOutputs: filterOutputs ?? this.filterOutputs,
      selectedTab: selectedTab ?? this.selectedTab,
    );
  }

  static SortFilterDisplay fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) {
      return defaultObject();
    }
    return SortFilterDisplay(
      sort: SortOption(
        name: json['sortName'],
        value: json['sortValue'],
        order: json['sortOrder'] == 'asc'
            ? SortOrder.Ascending
            : SortOrder.Descending,
      ),
      displayOption: DisplayOption(
        displayType: json['displayType'] == 'grid'
            ? DisplayType.grid
            : DisplayType.list_vert,
        displaySubType: json['displaySubType'] == 'comfortable'
            ? DisplaySubType.comfortable
            : json['displaySubType'] == 'compact'
                ? DisplaySubType.compact
                : json['displaySubType'] == 'spacious'
                    ? DisplaySubType.spacious
                    : DisplaySubType.cover_only_grid,
        gridCrossAxisCount: json['gridCrossAxisCount'] ?? 2,
        gridHeight: json['gridHeight'] ?? 280.0,
      ),
      filterOutputs: {},
      selectedTab: json['selectedTab'],
    );
  }

  static SortFilterDisplay defaultObject() {
    return SortFilterDisplay(
      sort: SortOption(name: 'Updated At', value: 'list_updated_at'),
      displayOption: DisplayOption(
        displayType: user.pref.defaultDisplayType,
        displaySubType: DisplaySubType.comfortable,
      ),
      filterOutputs: {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sortName': sort.name,
      'sortValue': sort.value,
      'sortOrder': sort.order == SortOrder.Ascending ? 'asc' : 'desc',
      'displayType':
          displayOption.displayType == DisplayType.grid ? 'grid' : 'list_vert',
      'displaySubType':
          displayOption.displaySubType == DisplaySubType.comfortable
              ? 'comfortable'
              : displayOption.displaySubType == DisplaySubType.compact
                  ? 'compact'
                  : displayOption.displaySubType == DisplaySubType.spacious
                      ? 'spacious'
                      : 'cover_only_grid',
      'gridCrossAxisCount': displayOption.gridCrossAxisCount,
      'filterOutputs': {},
      'selectedTab': selectedTab,
      'gridHeight': displayOption.gridHeight,
    };
  }
}

class SortOption {
  const SortOption({
    required this.name,
    required this.value,
    this.order = SortOrder.Descending,
  });

  final String name;
  final String value;
  final SortOrder order;

  SortOption copyWith({
    String? name,
    String? value,
    SortOrder? order,
  }) {
    return SortOption(
      name: name ?? this.name,
      value: value ?? this.value,
      order: order ?? this.order,
    );
  }

  SortOption clone() {
    return SortOption(
      name: name,
      value: value,
      order: order,
    );
  }
}

class DisplayOption {
  const DisplayOption({
    required this.displayType,
    required this.displaySubType,
    this.gridCrossAxisCount = 2,
    this.gridHeight = 280.0,
  });

  final DisplayType displayType;
  final DisplaySubType displaySubType;
  final int gridCrossAxisCount;
  final double gridHeight;

  DisplayOption copyWith(
      {DisplayType? displayType,
      DisplaySubType? displaySubType,
      int? gridCrossAxisCount,
      double? gridHeight}) {
    return DisplayOption(
      displayType: displayType ?? this.displayType,
      displaySubType: displaySubType ?? this.displaySubType,
      gridCrossAxisCount: gridCrossAxisCount ?? this.gridCrossAxisCount,
      gridHeight: gridHeight ?? this.gridHeight,
    );
  }

  DisplayOption clone() {
    return DisplayOption(
      displayType: displayType,
      displaySubType: displaySubType,
      gridCrossAxisCount: gridCrossAxisCount,
      gridHeight: gridHeight,
    );
  }
}
