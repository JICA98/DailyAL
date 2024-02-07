import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:dailyanimelist/api/dalapi.dart';
import 'package:dailyanimelist/cache/cachemanager.dart';
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
  List<BaseNode>? nodes,
  bool _canBeFetchedFromAPI,
  SortFilterDisplay _sortFilterDisplay,
  String category,
) async {
  var list = nodes ?? [];
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
          case 'my_list_status':
            if (modalValue is Map) {
              String? status = modalValue[option.apiFieldName];
              if (status == null) return false;
              final convertValue = _convertValue(selectedValue!, option);
              if (status.equals(convertValue)) {
                continue forLoop;
              } else {
                return false;
              }
            }
            break;
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
              if (_evaluateIncludedExcluded(genres, option)) {
                continue forLoop;
              } else {
                return false;
              }
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

bool _evaluateIncludedExcluded(
  Set<String> options,
  FilterOption option,
) {
  final included = option.includedOptions?.toSet() ?? {};
  final excluded = option.excludedOptions?.toSet() ?? {};
  if (options.isEmpty) return false;
  if (included.isNotEmpty && !options.containsAll(included)) return false;
  if (excluded.isNotEmpty && options.intersection(excluded).isNotEmpty)
    return false;
  return true;
}

String _convertValue(String value, FilterOption option) {
  try {
    if (!nullOrEmpty(option.apiValues)) {
      final index = option.values!.indexOf(value);
      if (index != -1) {
        return option.apiValues!.elementAt(index).toString();
      }
    }
  } catch (e) {}
  return value;
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
        compare = -1;
      } else if (n2Value == null) {
        compare = 1;
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

void showSortFilterDisplayModal({
  required BuildContext context,
  required SortFilterDisplay sortFilterDisplay,
  required String category,
  required ValueChanged<SortFilterDisplay> onSortFilterChange,
  SortFilterOptions? sortFilterOptions,
}) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return SortFilterPopup(
        category: category,
        sortFilterDisplay: sortFilterDisplay,
        onSortFilterChange: onSortFilterChange,
        sortFilterOptions: sortFilterOptions,
      );
    },
  );
}

class SelectDisplayOption {
  final DisplayType? type;
  final String name;
  final DisplaySubType? subType;
  final List<SelectDisplayOption>? subOptions;

  SelectDisplayOption({
    this.type,
    required this.name,
    this.subType,
    this.subOptions,
  });
}

class SortFilterOptions {
  final List<SortOption> sortOptions;
  final List<FilterOption> filterOptions;
  final List<SelectDisplayOption> displayOptions;

  SortFilterOptions({
    required this.sortOptions,
    required this.filterOptions,
    required this.displayOptions,
  });

  static List<SelectDisplayOption> getDisplayOptions() {
    return [
      SelectDisplayOption(
        name: S.current.Grid,
        type: DisplayType.grid,
        subOptions: [
          SelectDisplayOption(
            name: S.current.Comfortable,
            subType: DisplaySubType.comfortable,
          ),
          SelectDisplayOption(
            name: S.current.Compact,
            subType: DisplaySubType.compact,
          ),
          SelectDisplayOption(
            name: S.current.Cover_only,
            subType: DisplaySubType.cover_only_grid,
          ),
        ],
      ),
      SelectDisplayOption(
        name: S.current.List,
        type: DisplayType.list_vert,
        subOptions: [
          SelectDisplayOption(
            name: S.current.Comfortable,
            subType: DisplaySubType.comfortable,
          ),
          SelectDisplayOption(
            name: S.current.Compact,
            subType: DisplaySubType.compact,
          ),
          SelectDisplayOption(
            name: S.current.Spacious,
            subType: DisplaySubType.spacious,
          ),
        ],
      ),
    ];
  }

  static List<SortOption> getSortOptions(
      bool isAnime, SortOption selectedOption) {
    var map = isAnime ? animeListSortMap : mangaListSortMap;
    final defaultOptions = map.entries.map((e) {
      return SortOption(name: e.value, value: e.key);
    }).toList();
    defaultOptions.addAll(_additionalOptions(isAnime));
    return defaultOptions.map((e) {
      var isSelected = selectedOption.value.equals(e.value);
      return e.copyWith(
          order: isSelected
              ? selectedOption.order
              : (isAnime
                      ? animeListDefaultOrderMap
                      : mangaListDefaultOrderMap)[e.value] ??
                  SortOrder.Descending);
    }).toList();
  }

  static List<SortOption> _additionalOptions(bool isAnime) {
    if (isAnime) {
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
}

class SortFilterPopup extends StatefulWidget {
  const SortFilterPopup({
    super.key,
    required this.category,
    required this.sortFilterDisplay,
    required this.onSortFilterChange,
    this.sortFilterOptions,
  });

  final String category;
  final SortFilterDisplay sortFilterDisplay;
  final ValueChanged<SortFilterDisplay> onSortFilterChange;
  final SortFilterOptions? sortFilterOptions;

  @override
  State<SortFilterPopup> createState() => _SortFilterPopupState();
}

class _SortFilterPopupState extends State<SortFilterPopup> {
  late List<Tab> _tabs;
  late SortFilterDisplay _originalSortFilterDisplay;
  late SortFilterDisplay _sortFilterDisplay;
  late SortFilterOptions _sortFilterOptions;

  @override
  void initState() {
    super.initState();
    _originalSortFilterDisplay = widget.sortFilterDisplay.clone();
    _sortFilterDisplay = widget.sortFilterDisplay.clone();
    _sortFilterOptions =
        widget.sortFilterOptions ?? _getDefaultSortFilterOption();
    _tabs = [
      if (_sortFilterOptions.sortOptions.isNotEmpty)
        Tab(
          text: S.current.Sort,
        ),
      if (_sortFilterOptions.filterOptions.isNotEmpty)
        Tab(
          text: S.current.Filter,
        ),
      if (_sortFilterOptions.displayOptions.isNotEmpty)
        Tab(
          text: S.current.Display,
        ),
    ];
  }

  bool get _isAnime => widget.category.equals('anime');

  SortFilterOptions _getDefaultSortFilterOption() {
    return SortFilterOptions(
      sortOptions:
          SortFilterOptions.getSortOptions(_isAnime, _sortFilterDisplay.sort),
      filterOptions: getFilterOptions(widget.category),
      displayOptions: SortFilterOptions.getDisplayOptions(),
    );
  }

  int _indexOfSortOption(SortOption sortOption) {
    return _sortFilterOptions.sortOptions
        .indexWhere((element) => element.value.equals(sortOption.value));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
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
                _buildTabs(),
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

  Material _buildTabs() {
    return Material(
      child: SizedBox(
        height: 50.0,
        child: TabBar(
          padding: EdgeInsets.zero,
          tabs: _tabs,
        ),
      ),
    );
  }

  Widget _tabBarView() {
    return Padding(
      padding: const EdgeInsets.only(top: 40.0),
      child: TabBarView(
        children: _tabs
            .map((e) => switchCase<String, Widget>(e.text, {
                  [S.current.Sort]: (_) => _sortView(),
                  [S.current.Filter]: (_) => _filterView(),
                  [S.current.Display]: (_) => _displayView(),
                }))
            .map((e) => e!)
            .toList(),
      ),
    );
  }

  Widget _displayView() {
    final displayOption = _sortFilterOptions.displayOptions.firstWhere((e) {
      return e.type == _sortFilterDisplay.displayOption.displayType;
    });
    return CustomScrollView(
      slivers: [
        SB.lh20,
        SliverToBoxAdapter(
          child: ListTile(
            title: Text(S.current.Display_Type),
          ),
        ),
        SliverList.list(
            children: _sortFilterOptions.displayOptions.map((e) {
          return RadioListTile<DisplayType>(
            value: e.type!,
            groupValue: _sortFilterDisplay.displayOption.displayType,
            title: Text(e.name),
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
        if (displayOption.subOptions != null) ...[
          SliverToBoxAdapter(
            child: ListTile(
              title: Text(S.current.Display_Sub_Type),
            ),
          ),
          SliverList.list(
              children: displayOption.subOptions!.map((e) {
            return RadioListTile<DisplaySubType>(
              value: e.subType!,
              groupValue: _sortFilterDisplay.displayOption.displaySubType,
              title: Text(e.name),
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
        ],
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
        var sortOption = _sortFilterOptions.sortOptions[index];
        return ListTile(
          title: Text(sortOption.name),
          trailing: _sortTrailing(sortOption, index),
          onTap: () {
            _onSortChange(sortOption, index);
          },
        );
      },
      itemCount: _sortFilterOptions.sortOptions.length,
    );
  }

  void _onSortChange(SortOption sortOption, int index) {
    var order = _isSortSelected(sortOption)
        ? (sortOption.order == SortOrder.Ascending
            ? SortOrder.Descending
            : SortOrder.Ascending)
        : null;
    var _sortOption = sortOption.copyWith(order: order);
    _sortFilterOptions.sortOptions[index] = _sortOption;
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
    switchCase(_tabs[DefaultTabController.of(controllerContext).index].text, {
      [S.current.Sort]: (_) {
        _sortFilterDisplay = _sortFilterDisplay.copyWith(
          sort: _originalSortFilterDisplay.sort.clone(),
        );
      },
      [S.current.Filter]: (_) {
        _sortFilterDisplay = _sortFilterDisplay.copyWith(
          filterOutputs: {},
        );
      },
      [S.current.Display]: (_) {
        _sortFilterDisplay = _sortFilterDisplay.copyWith(
          display: _originalSortFilterDisplay.displayOption.clone(),
        );
      },
    });

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
      filterOptions: _sortFilterOptions.filterOptions,
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

  String refKey(String prefix) {
    return '''
    $prefix-
    ${sort.value}-
    ${sort.order.name}-
    ${filterOutputs.values.map((e) => e.value ?? ((e.includedOptions ?? []).join(',') + (e.excludedOptions ?? []).join(','))).join('.')}-
    ''';
  }

  static Future<SortFilterDisplay> fromCache(
    String serviceName,
    String key,
    SortFilterDisplay defaultObject,
  ) async {
    final map = jsonDecode(
        await CacheManager.instance.getValueForService(serviceName, key) ??
            '{}');
    return SortFilterDisplay.fromJson(map, defaultObject);
  }

  Future<void> toCache(String serviceName, String key) async {
    await CacheManager.instance
        .setValueForService(serviceName, key, jsonEncode(this));
  }

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

  factory SortFilterDisplay.withDisplayType(DisplayOption option) {
    return SortFilterDisplay(
      sort: SortOption(name: '_', value: '_'),
      displayOption: option,
      filterOutputs: {},
    );
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

  static SortFilterDisplay fromJson(
      Map<String, dynamic>? json, SortFilterDisplay defaultObject) {
    if (json == null || json.isEmpty) {
      return defaultObject;
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
