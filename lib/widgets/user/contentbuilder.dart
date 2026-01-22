import 'dart:convert';

import 'package:dailyanimelist/api/auth/auth.dart';
import 'package:dailyanimelist/api/maluser.dart';
import 'package:dailyanimelist/cache/cachemanager.dart';
import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/enums.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/main.dart';
import 'package:dailyanimelist/pages/animedetailed/reviewpage.dart';
import 'package:dailyanimelist/screens/generalsearchscreen.dart';
import 'package:dailyanimelist/user/hompagepref.dart';
import 'package:dailyanimelist/widgets/custombutton.dart';
import 'package:dailyanimelist/widgets/customfuture.dart';
import 'package:dailyanimelist/widgets/listsortfilter.dart';
import 'package:dailyanimelist/widgets/loading/expandedwidget.dart';
import 'package:dailyanimelist/widgets/user/contentlistwidget.dart';
import 'package:dailyanimelist/widgets/user/customizedlist.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:dailyanimelist/util/responsive_helper.dart';

class CustomSearchInput {
  final int offset;
  final bool fromCache;
  final SortFilterDisplay sortFilterDisplay;
  final SortFilterDisplay? prevSortFilterDisplay;

  CustomSearchInput({
    required this.offset,
    required this.sortFilterDisplay,
    required this.fromCache,
    this.prevSortFilterDisplay,
  });
}

class UserContentBuilder extends StatefulWidget {
  static const String serviceName = 'UserContentBuilder';
  final String category;
  final String username;
  final String? refreshKey;
  final String? optionsCacheKey;
  final ValueChanged<int>? countChange;
  final EdgeInsets? listPadding;
  final ScrollController? controller;
  final SortOption? sortOption;
  final Future<List<BaseNode>> Function(CustomSearchInput) customFuture;
  final int pageSize;

  const UserContentBuilder({
    this.category = "anime",
    required this.username,
    Key? key,
    this.refreshKey,
    this.countChange,
    this.listPadding,
    this.controller,
    required this.customFuture,
    this.pageSize = 300,
    this.optionsCacheKey,
    this.sortOption,
  }) : super(key: key);

  @override
  _UserContentBuilderState createState() => _UserContentBuilderState();
}

class _UserContentBuilderState extends State<UserContentBuilder>
    with AutomaticKeepAliveClientMixin {
  late String key;
  List<BaseNode>? contentList;
  SearchStage research = SearchStage.notstarted;
  late String refKey;
  SortFilterDisplay? _sortFilterDisplay;
  SortFilterDisplay? _prevSortFilterDisplay;
  bool _enableSearch = false;
  TextEditingController _searchController = TextEditingController();
  final _searchNode = FocusNode();
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    refKey = MalAuth.codeChallenge(10);
    key = '${widget.category}-${widget.username}';
    _searchController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_sortFilterDisplay == null) {
      _setSortFilterDisplayFuture();
    }
  }

  void _setSortFilterDisplayFuture() async {
    _sortFilterDisplay =
        await SortFilterDisplay.fromCache(_cacheKey, key, _defaultObject());
    _sortFilterDisplay =
        _sortFilterDisplay!.copyWith(category: widget.category);
    logDal('SortFilterDisplay: $_cacheKey ${jsonEncode(_sortFilterDisplay)}');
    if (widget.sortOption != null) {
      _sortFilterDisplay = _sortFilterDisplay!.copyWith(
        sort: widget.sortOption!,
      );
    }
    if (mounted) setState(() {});
  }

  String get _cacheKey =>
      UserContentBuilder.serviceName + (widget.optionsCacheKey ?? '');

  SortFilterDisplay _defaultObject() {
    final isTablet = ResponsiveHelper.isTabletOrLarger(context);
    return SortFilterDisplay(
      sort: SortOption(name: 'Updated At', value: 'list_updated_at'),
      displayOption: DisplayOption(
        displayType: isTablet ? DisplayType.grid : user.pref.defaultDisplayType,
        displaySubType:
            isTablet ? DisplaySubType.compact : DisplaySubType.comfortable,
        gridCrossAxisCount: ResponsiveHelper.getCrossAxisCount(context),
      ),
      filterOutputs: {},
    );
  }

  Future<List<BaseNode>> getContentList({
    int offset = 0,
    bool fromCache = false,
  }) async {
    try {
      final sortFilterDisplay = _sortFilterDisplay!.copyWith(
        display: (_sortFilterDisplay?.displayOption.displaySubType ==
                    DisplaySubType.custom &&
                widget.category.notEquals('anime'))
            ? _sortFilterDisplay?.displayOption.copyWith(
                displayType: DisplayType.list_vert,
                displaySubType: DisplaySubType.comfortable,
              )
            : _sortFilterDisplay?.displayOption,
      );
      _sortFilterDisplay = sortFilterDisplay.clone();
      return _getFuture(fromCache, sortFilterDisplay, offset);
    } catch (e) {
      logDal(e);
      showToast(S.current.Couldnt_connect_network);
      return [];
    }
  }

  Future<List<BaseNode>> _getFuture(
    bool fromCache,
    SortFilterDisplay sortFilterDisplay,
    int offset,
  ) {
    return widget.customFuture(
      CustomSearchInput(
        offset: offset,
        sortFilterDisplay: sortFilterDisplay,
        fromCache: fromCache,
        prevSortFilterDisplay: _prevSortFilterDisplay,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant UserContentBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (shouldRefresh(oldWidget)) {
      _refresh();
    }
  }

  Future<void> _refresh() async {
    if (_isRefreshing) return;
    logDal('Refreshing');
    _isRefreshing = true;
    refKey = MalAuth.codeChallenge(10);
    if (mounted) setState(() {});

    await Future.delayed(const Duration(milliseconds: 500));
    _isRefreshing = false;
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
              refKey: _sortFilterDisplay?.refKey(refKey),
              future: (offset) => getContentList(offset: offset),
              pageSize: widget.pageSize,
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
              itemBuilder: (_, item, index) {
                return buildBaseNodePageItem(
                  widget.category,
                  item,
                  index,
                  _sortFilterDisplay!.displayOption.displayType,
                  showEdit: widget.username.equals("@me"),
                  displaySubType:
                      _sortFilterDisplay!.displayOption.displaySubType,
                  gridAxisCount:
                      _sortFilterDisplay!.displayOption.gridCrossAxisCount,
                  gridHeight: _sortFilterDisplay!.displayOption.gridHeight,
                  id: _sortFilterDisplay!.displayOption.id,
                );
              },
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
              height: 27.0,
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
        showSortFilterDisplayModal(
          context: context,
          sortFilterDisplay: _sortFilterDisplay!.clone(),
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
    value.toCache(_cacheKey, key);
    if (mounted) setState(() {});
  }

  @override
  bool get wantKeepAlive => true;
}
