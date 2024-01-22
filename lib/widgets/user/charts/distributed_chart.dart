import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/util/insight_service.dart';
import 'package:dailyanimelist/widgets/barchart.dart';
import 'package:dailyanimelist/widgets/custombutton.dart';
import 'package:dailyanimelist/widgets/home/animecard.dart';
import 'package:dailyanimelist/widgets/selectbottom.dart';
import 'package:dailyanimelist/widgets/user/stats_screen.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ScoreItemDistributionWidget extends StatefulWidget {
  final Map<String, Map<String, ScoreItem>> scoreItemMap;
  final List<String> titleList;
  final List<String> availableFilters;
  final String category;
  final String title;
  final String notEnoughDataMsg;
  final bool Function(ScoreItem item, String selectedFilter)? onItemFilter;
  final String? Function(ScoreItem item) onItemName;
  final String itemColumnName;
  final void Function(ScoreItem item)? onItemPress;
  const ScoreItemDistributionWidget({
    required this.scoreItemMap,
    required this.titleList,
    required this.category,
    this.availableFilters = const [],
    required this.title,
    this.onItemFilter,
    required this.notEnoughDataMsg,
    required this.onItemName,
    this.onItemPress,
    required this.itemColumnName,
  });

  @override
  State<ScoreItemDistributionWidget> createState() =>
      _ScoreItemDistributionWidgetState();
}

class _ScoreItemDistributionWidgetState
    extends State<ScoreItemDistributionWidget> {
  int _selectedDataSetIndex = -1;
  int _rowsPerPage = 5;
  bool _sortAscending = false;
  int _sortColumnIndex = 2;
  late List<String> _availableFilters;
  String _selectedFilter = S.current.Select;
  late Set<String> _uniqueItemNameSet;
  late Map<String, Map<String, ScoreItem>> _scoreItemMap;

  @override
  void initState() {
    super.initState();
    _availableFilters = [...widget.availableFilters];
    if (_availableFilters.isNotEmpty) {
      _availableFilters.insert(0, S.current.Select);
    }
    _setScoreItemMap();
    _scoreItemMap['completed']
        ?.values
        .where((e) => !_uniqueItemNameSet.contains(e.genre?.name))
        .toList();
  }

  void _setScoreItemMap() {
    if (S.current.Select.equals(_selectedFilter)) {
      _scoreItemMap = _copyMap(widget.scoreItemMap);
      _setUniqueItemNames(_scoreItemMap);
      _scoreItemMap = _sortMapAscending(_scoreItemMap);
    } else {
      final copyMap = _copyMap(widget.scoreItemMap);
      final map = Map.fromEntries(
        copyMap.entries.expand<MapEntry<String, Map<String, ScoreItem>>>((e) {
          final list = e.value.entries.expand<MapEntry<String, ScoreItem>>((f) {
            final item = f.value;
            if (widget.onItemFilter != null) {
              if (widget.onItemFilter!(item, _selectedFilter)) {
                return [f];
              }
            }
            return [];
          }).toList();
          if (list.isEmpty) {
            return [];
          } else {
            return [MapEntry(e.key, Map.fromEntries(list))];
          }
        }),
      );
      _setUniqueItemNames(map);
      _scoreItemMap = _sortMapAscending(map);
    }
  }

  void _setUniqueItemNames(Map<String, Map<String, ScoreItem>> map) {
    _uniqueItemNameSet = {};
    final Set<String> uniqueItemNameSet = SplayTreeSet();
    for (var mapE in map.entries) {
      for (final element in mapE.value.entries) {
        var name = widget.onItemName(element.value);
        if (name != null) uniqueItemNameSet.add(name);
      }
    }
    _uniqueItemNameSet.addAll(uniqueItemNameSet);
    for (final entry in map.entries) {
      for (final name in _uniqueItemNameSet) {
        entry.value.putIfAbsent(name, () => ScoreItem(0, 0, 0.0));
      }
    }
  }

  Map<String, Map<String, ScoreItem>> _copyMap(
      Map<String, Map<String, ScoreItem>> map) {
    return Map.fromEntries(map.entries.map((e) => MapEntry(
        e.key,
        Map.fromEntries(
            e.value.entries.map((f) => MapEntry(f.key, f.value))))));
  }

  Map<String, Map<String, ScoreItem>> _sortMapAscending(
      Map<String, Map<String, ScoreItem>> map) {
    return Map.fromEntries(
      map.entries.map(
        (e) => MapEntry(
          e.key,
          SplayTreeMap.from(Map.fromEntries(
            e.value.entries.map((f) => MapEntry(f.key, f.value)),
          )),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var length = _uniqueItemNameSet.length;
    return ExpandedCard(
      title: widget.title,
      height: length >= 3 ? (length < 14 ? 360 : 420.0) : 180,
      width: 325.0,
      useCard: false,
      child: _uniqueItemNameSet.length >= 3
          ? _radarChart()
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(widget.notEnoughDataMsg),
            ),
      bottom: _bottomWidget(),
      expandedChild: _dataTable(),
      actions: [
        if (_availableFilters.isNotEmpty)
          SelectButton(
            selectedOption: _selectedFilter,
            options: _availableFilters,
            showSelectWhenNull: true,
            child: S.current.Select.equals(_selectedFilter)
                ? Icon(Icons.filter_alt)
                : Icon(Icons.filter_alt_off),
            onChanged: _onFilterChange,
          ),
      ],
    );
  }

  _onFilterChange(String value) {
    _selectedFilter = value;
    _selectedDataSetIndex = -1;
    _setScoreItemMap();
    setState(() {});
  }

  Widget _radarChart() {
    return RadarChartWidget(
      selectedDataSetIndex: _selectedDataSetIndex,
      getTitle: (index, angle) => RadarChartTitle(
        text: _uniqueItemNameSet
                .elementAtOrNull(index)
                ?.standardize()
                ?.substringToN(15) ??
            '?',
        angle: _uniqueItemNameSet.length > 15 ? angle + 90 : 0,
      ),
      keyColor: (key) => NodeStatusValue.fromString(key).color ?? Colors.white,
      data: Map.fromEntries(
        _scoreItemMap.entries.map(
          (e) => MapEntry(
            e.key,
            Map.fromEntries(
              e.value.entries.map(
                (f) => MapEntry(f.key, f.value.mean),
              ),
            ),
          ),
        ),
      ),
      title: widget.titleList,
      onIndexChange: _onIndexChange,
    );
  }

  Widget _dataTable() {
    var items = _scoreItemMap.entries
        .where((e) =>
            _selectedDataSetIndex == -1 ||
            NodeStatusValue.fromString(e.key).index == _selectedDataSetIndex)
        .map((e) => e.value)
        .expand((element) => element.values)
        .where((e) => e.status != null);
    if (_sortColumnIndex != -1) {
      items = items.sorted((a, b) {
        int comparison;
        if (_sortColumnIndex == 1) {
          comparison = a.mean.compareTo(b.mean);
        } else {
          comparison = a.count.compareTo(b.count);
        }
        return _sortAscending ? comparison : -comparison;
      });
    }
    final onItemPress = widget.onItemPress;
    final dataRows = items.map((e) {
      final itemName = widget.onItemName(e)?.standardize();
      final _itemText = Text(
        '$itemName',
        textAlign: TextAlign.start,
      );
      return DataRow(
        cells: [
          DataCell(onItemPress == null
              ? _itemText
              : PlainButton(
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                  onPressed: () => onItemPress(e),
                  child: _itemText,
                )),
          DataCell(Text('${e.mean.toStringAsFixed(2)}')),
          DataCell(Text('${e.count}')),
          if (_selectedDataSetIndex == -1)
            DataCell(Text('${e.status.toString().standardize()}')),
        ],
      );
    }).toList();
    return PaginatedDataTable(
      columns: [
        DataColumn(
          label: Text(widget.itemColumnName),
        ),
        DataColumn(
          label: Text(S.current.Mean_Score),
          onSort: _onSort,
        ),
        DataColumn(
          label: Text(S.current.Count),
          onSort: _onSort,
        ),
        if (_selectedDataSetIndex == -1)
          DataColumn(
            label: Text(S.current.Status),
          ),
      ],
      sortAscending: _sortAscending,
      sortColumnIndex: _sortColumnIndex,
      source: _DataSource(
        dataRows: dataRows,
      ),
      rowsPerPage: _rowsPerPage,
      availableRowsPerPage: [5, 10, 20, 50],
      onRowsPerPageChanged: (newRowsPerPage) {
        setState(() {
          if (newRowsPerPage != null) _rowsPerPage = newRowsPerPage;
        });
      },
    );
  }

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  void _onIndexChange(int index) {
    _selectedDataSetIndex = index;
    setState(() {});
  }

  Widget _bottomWidget() {
    return Wrap(
      children: widget.titleList
          .asMap()
          .map((index, value) {
            final isSelected = index == _selectedDataSetIndex;
            final color = Color(getStatusColor(index));
            return MapEntry(
              index,
              GestureDetector(
                onTap: () => _onIndexChange((_selectedDataSetIndex == -1 ||
                        _selectedDataSetIndex != index)
                    ? index
                    : -1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  height: 26,
                  decoration: BoxDecoration(
                    color: isSelected ? color : Colors.transparent,
                    borderRadius: BorderRadius.circular(46),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 6,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInToLinear,
                        padding: EdgeInsets.all(isSelected ? 8 : 6),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInToLinear,
                        style: TextStyle(
                            // color: isSelected ? Theme.of(context).textTheme. : Colors.blue,
                            ),
                        child: Text(value),
                      ),
                    ],
                  ),
                ),
              ),
            );
          })
          .values
          .toList(),
    );
  }
}

class _DataSource extends DataTableSource {
  final List<DataRow> dataRows;

  _DataSource({
    required this.dataRows,
  });

  @override
  DataRow? getRow(int index) {
    return dataRows[index];
  }

  @override
  int get rowCount => dataRows.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;

  @override
  void sort<T>(Comparable<T> getField(DataRow row), bool ascending) {
    dataRows.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });
  }
}
