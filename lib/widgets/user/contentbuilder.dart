import 'dart:convert';

import 'package:dailyanimelist/api/auth/auth.dart';
import 'package:dailyanimelist/api/maluser.dart';
import 'package:dailyanimelist/cache/cachemanager.dart';
import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/enums.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/main.dart';
import 'package:dailyanimelist/screens/generalsearchscreen.dart';
import 'package:dailyanimelist/user/hompagepref.dart';
import 'package:dailyanimelist/widgets/custombutton.dart';
import 'package:dailyanimelist/widgets/customfuture.dart';
import 'package:dailyanimelist/widgets/listsortfilter.dart';
import 'package:dailyanimelist/widgets/loading/expandedwidget.dart';
import 'package:dailyanimelist/widgets/user/contentlistwidget.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

class UserContentBuilder extends StatefulWidget {
  static const String serviceName = 'UserContentBuilder';
  final String category;
  final String? status;
  final String username;
  final String? refreshKey;
  final VoidCallback? onContentUpdate;
  final VoidCallback? onStatisticsUpdate;
  final ValueChanged<int>? countChange;
  final EdgeInsets? listPadding;
  final ScrollController? controller;

  const UserContentBuilder({
    this.category = "anime",
    this.status,
    required this.username,
    Key? key,
    this.onContentUpdate,
    this.refreshKey,
    this.onStatisticsUpdate,
    this.countChange,
    this.listPadding,
    this.controller,
  }) : super(key: key);

  @override
  _UserContentBuilderState createState() => _UserContentBuilderState();
}

class _UserContentBuilderState extends State<UserContentBuilder>
    with AutomaticKeepAliveClientMixin {
  late String key;
  List<BaseNode>? contentList;
  SearchStage research = SearchStage.notstarted;
  static const pageSize = 300;
  late String refKey;
  SortFilterDisplay? _sortFilterDisplay;
  SortFilterDisplay? _prevSortFilterDisplay;
  bool _enableSearch = false;
  TextEditingController _searchController = TextEditingController();
  final _searchNode = FocusNode();
  final _axisTileSizeMap = {
    2: HomePageTileSize.xl,
    3: HomePageTileSize.m,
    4: HomePageTileSize.xs,
  };

  @override
  void initState() {
    super.initState();
    refKey = MalAuth.codeChallenge(10);
    key = '${widget.category}-${widget.username}';
    _searchController.addListener(() {
      if (mounted) setState(() {});
    });
    _setSortFilterDisplayFuture();
  }

  void _setSortFilterDisplayFuture() async {
    final map = jsonDecode(await CacheManager.instance
            .getValueForService(UserContentBuilder.serviceName, key) ??
        '{}');
    _sortFilterDisplay = SortFilterDisplay.fromJson(map);
    if (mounted) setState(() {});
  }

  Future<List<BaseNode>> getContentList({
    int offset = 0,
    bool fromCache = false,
  }) async {
    try {
      final Future<SearchResult> future;
      final status = widget.status!.equals("all") ? null : widget.status;
      final sortFilterDisplay = _sortFilterDisplay!.clone();
      final _canBeFetchedFromAPI =
          canBeFetchedFromAPI(widget.category, sortFilterDisplay);
      final List<String> additionalFields = [];
      if (_canBeFetchedFromAPI) {
        future = MalUser.getMyContentList(
          limit: pageSize,
          fromCache: fromCache,
          category: widget.category,
          sortType: sortFilterDisplay.sort.value,
          offset: offset,
          username: widget.username,
          status: status,
          fields: additionalFields,
        );
      } else {
        if (offset != 0) return [];
        final orderMap = widget.category.equals('anime')
            ? animeListDefaultOrderMap
            : mangaListDefaultOrderMap;
        var orderMapContains =
            orderMap.containsKey(sortFilterDisplay.sort.value);
        List<String> fieldList = [
          ...additionalFields,
          if (!orderMapContains) sortFilterDisplay.sort.value,
          if (sortFilterDisplay.filterOutputs.isNotEmpty)
            ..._getAPIFieldsFromFilters(),
        ];
        bool? fromCache;
        if (_prevSortFilterDisplay != null) {
          fromCache = _prevSortFilterDisplay!.sort.value
                  .equals(sortFilterDisplay.sort.value) &&
              (_prevSortFilterDisplay!.filterOutputs.isNotEmpty &&
                  sortFilterDisplay.filterOutputs.isNotEmpty);
        }
        fromCache ??= false;
        future = MalUser.getAllUserList(
          widget.username,
          widget.category,
          status: status,
          sortType: orderMapContains ? sortFilterDisplay.sort.value : null,
          fromCache: fromCache,
          fields: fieldList.isEmpty ? null : fieldList.join(','),
        );
      }
      final contentResult = await future;
      return await getSortedFilteredData(
        contentResult,
        _canBeFetchedFromAPI,
        sortFilterDisplay,
        widget.category,
      );
    } catch (e) {
      logDal(e);
      showToast(S.current.Couldnt_connect_network);
      return [];
    }
  }

  Iterable<String> _getAPIFieldsFromFilters() {
    return getFilterOptions(widget.category)
        .map((e) => e.modalField)
        .where((e) => e != null)
        .map((e) => e!);
  }

  @override
  void didUpdateWidget(covariant UserContentBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (shouldRefresh(oldWidget)) {
      _refresh();
    }
  }

  Future<void> _refresh() async {
    refKey = MalAuth.codeChallenge(10);
    if (mounted) setState(() {});
  }

  bool shouldRefresh(UserContentBuilder oldWidget) {
    return widget.category != oldWidget.category ||
        widget.refreshKey != oldWidget.refreshKey;
  }

  @override
  Widget build(BuildContext context) {
    if (_sortFilterDisplay == null) return loadingCenterColored;
    return RefreshIndicator(
      onRefresh: _refresh,
      child: Stack(
        children: [
          Padding(
            padding: widget.listPadding ?? const EdgeInsets.only(top: 25.0),
            child: InfinitePagination(
              scrollController: widget.controller,
              refKey: _refKey,
              future: (offset) => getContentList(offset: offset),
              pageSize: pageSize,
              displayType: _sortFilterDisplay!.displayOption.displayType,
              countChange: widget.countChange,
              customFilterKey: '${_sortFilterDisplay!.filterOutputs.isEmpty}',
              enableCustomFilter:
                  _enableSearch && _searchController.text.isNotBlank,
              customFilterBuilder: (items) {
                var list = items.expand((e) => e).toList();
                if (_enableSearch && _searchController.text.isNotBlank) {
                  list = searchBaseNodes(list, _searchController.text);
                }
                return list;
              },
              gridChildCount:
                  _sortFilterDisplay!.displayOption.gridCrossAxisCount,
              itemBuilder: (_, item, index) => buildBaseNodePageItem(
                widget.category,
                item,
                index,
                _sortFilterDisplay!.displayOption.displayType,
                showEdit: widget.username.equals("@me"),
                homePageTileSize: _axisTileSizeMap[
                    _sortFilterDisplay!.displayOption.gridCrossAxisCount],
                displaySubType:
                    _sortFilterDisplay!.displayOption.displaySubType,
                gridAxisCount:
                    _sortFilterDisplay!.displayOption.gridCrossAxisCount,
                gridHeight: _sortFilterDisplay!.displayOption.gridHeight,
              ),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Material(
              child: _listSubHeaderWidget(),
            ),
          ),
        ],
      ),
    );
  }

  String get _refKey {
    return '''
    $refKey-
    ${_sortFilterDisplay!.sort.value}-
    ${_sortFilterDisplay!.sort.order.name}-
    ${_sortFilterDisplay!.filterOutputs.values.map((e) => e.value ?? ((e.includedOptions ?? []).join(',') + (e.excludedOptions ?? []).join(','))).join('.')}-
    ''';
  }

  Widget _listSubHeaderWidget() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
      child: Container(
        height: 35,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: SizedBox(
            height: 29.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _searchButton(),
                _sortDisplayRefresh(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ShadowButton _searchButton() {
    return ShadowButton(
      onPressed: _onStartSearch,
      padding: EdgeInsets.zero,
      shape: _enableSearch
          ? RoundedRectangleBorder(
              side: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(32))
          : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _onStartSearch,
            icon: Icon(
              Icons.search,
              size: 16.0,
            ),
          ),
          ExpandedSection(
            axis: Axis.horizontal,
            expand: _enableSearch,
            child: SizedBox(
              width: 80.0,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
                child: TextFormField(
                  controller: _searchController,
                  focusNode: _searchNode,
                  style: Theme.of(context).textTheme.bodySmall,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),
          ExpandedSection(
            axis: Axis.horizontal,
            expand: _enableSearch,
            child: IconButton(
              onPressed: () {
                _searchNode.unfocus();
                if (mounted)
                  setState(() {
                    _enableSearch = false;
                  });
              },
              icon: Icon(Icons.clear, size: 16.0),
            ),
          )
        ],
      ),
    );
  }

  void _onStartSearch() {
    if (!_enableSearch) {
      _searchNode.requestFocus();
      if (mounted)
        setState(() {
          _enableSearch = true;
        });
    }
  }

  Widget _sortDisplayRefresh() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ShadowButton(
          onPressed: () {},
          padding: EdgeInsets.symmetric(horizontal: 5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _refreshButton(),
              VerticalDivider(thickness: 1),
              _sortBySelect(),
            ],
          ),
        ),
      ],
    );
  }

  InkWell _refreshButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: _refresh,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        child: Icon(Icons.refresh, size: 18.0),
      ),
    );
  }

  Widget _sortBySelect() {
    final filterOutputs = _sortFilterDisplay!.filterOutputs;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        showContentListModal(
          context: context,
          sortFilterDisplay: _sortFilterDisplay!.clone(),
          category: widget.category,
          onSortFilterChange: _changeDropDownValue,
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        child: Icon(
            filterOutputs.isEmpty
                ? LineIcons.filter
                : filterLengthIcon(filterOutputs.length),
            size: 18.0),
      ),
    );
  }

  void _changeDropDownValue(SortFilterDisplay value) {
    _prevSortFilterDisplay = _sortFilterDisplay!.clone();
    _sortFilterDisplay = value.clone();
    CacheManager.instance.setValueForService(
        UserContentBuilder.serviceName, key, jsonEncode(value));
    if (mounted) setState(() {});
  }

  @override
  bool get wantKeepAlive => true;
}
