import 'package:dailyanimelist/api/dalapi.dart';
import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/screens/generalsearchscreen.dart';
import 'package:dailyanimelist/screens/plainscreen.dart';
import 'package:dailyanimelist/util/pathutils.dart';
import 'package:dailyanimelist/widgets/anime_graph.dart';
import 'package:dailyanimelist/widgets/common/share_builder.dart';
import 'package:dailyanimelist/widgets/customappbar.dart';
import 'package:dailyanimelist/widgets/custombutton.dart';
import 'package:dailyanimelist/widgets/customfuture.dart';
import 'package:dailyanimelist/widgets/listsortfilter.dart';
import 'package:dailyanimelist/widgets/slivers.dart';
import 'package:dailyanimelist/widgets/user/contentlistwidget.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:dal_commons/src/model/anime/anime_graph.dart';
import 'package:flutter/material.dart';
import 'package:dailyanimelist/generated/l10n.dart';

enum _SelectedView {
  list,
  graph,
}

class RelatedAnimeWidget extends StatefulWidget {
  final List<RelatedContent> relatedAnimeList;
  final String category;
  final double horizPadding;
  final DisplayType displayType;
  final int id;
  final Map<int, MyListStatus>? statusMap;
  const RelatedAnimeWidget({
    required this.relatedAnimeList,
    this.category = "anime",
    required this.horizPadding,
    required this.id,
    this.displayType = DisplayType.list_horiz,
    this.statusMap,
  });

  @override
  _RelatedAnimeWidgetState createState() => _RelatedAnimeWidgetState();
}

class _RelatedAnimeWidgetState extends State<RelatedAnimeWidget>
    with AutomaticKeepAliveClientMixin {
  Map<String, List<BaseNode>> animeWidgets = {};
  int pageIndex = 0;
  bool isHoriz = true;
  dynamic _graph;
  _SelectedView _selectedView = _SelectedView.list;

  @override
  void initState() {
    super.initState();
    isHoriz = widget.displayType == DisplayType.list_horiz;
    widget.relatedAnimeList.forEach((relatedAnime) {
      final baseNodes = animeWidgets[relatedAnime.relationTypeFormatted] ?? [];
      final myListStatus = relatedAnime.relatedNode?.myListStatus;
      final node = relatedAnime.relatedNode;
      baseNodes.add(BaseNode(content: node, myListStatus: myListStatus));
      animeWidgets[relatedAnime.relationTypeFormatted!] = baseNodes;
    });
    if (!isHoriz) {
      _setAnimeGraph();
    }
  }

  void _setAnimeGraph() async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch / 1000;
      _graph = await DalApi.i.getAnimeGraph(widget.id);
      final then = DateTime.now().millisecondsSinceEpoch / 1000;
      if ((then - now) > 1) {
        showSnackBar(_graphSnackBar(), Duration(seconds: 3));
      }
    } catch (e) {
      _graph = e;
      showSnackBar(_graphSnackBar());
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: animeWidgets.keys.length,
      child: isHoriz ? _horizView : _animeGraph,
    );
  }

  Widget get _animeGraph {
    if (_selectedView == _SelectedView.list) {
      return _gridView;
    } else {
      if (_graph is AnimeGraph) {
        return _graphWidget(_graph);
      } else {
        return _noContentView();
      }
    }
  }

  Widget _noContentView() {
    return TitlebarScreen(
      Center(child: showNoContent()),
      appbarTitle: _appBarTitle,
      actions: _getActions(false),
      autoIncludeSearch: false,
    );
  }

  Widget _graphWidget(AnimeGraph data) {
    return AnimeGraphWidget(
      id: widget.id,
      graph: data,
      statusMap: widget.statusMap ?? {},
      actions: _getActions(true),
    );
  }

  NestedScrollView get _gridView {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverAppBarWrapper(
          bottom: _tabBar,
          expandedHeight: 93,
          title: Text(_appBarTitle),
          actions: _getActions(innerBoxIsScrolled),
        )
      ],
      body: TabBarView(
        children: animeWidgets.values
            .map((e) => CustomScrollWrapper([
                  SB.lh20,
                  _contentListWidget(e),
                  SB.lh60,
                ]))
            .toList(),
      ),
    );
  }

  String get _appBarTitle => '${S.current.Related} ${widget.category}';

  Widget _graphSnackBar() {
    return Row(
      children: [
        Expanded(
          child: Text(
            _graph is AnimeGraph
                ? S.current.Graph_loaded
                : S.current.Couldnt_generate_graph,
          ),
        ),
        SB.w10,
        if (_graph is AnimeGraph)
          ShadowButton(
            onPressed: () => _switchView(),
            child: Text(S.current.Switch),
          )
      ],
    );
  }

  List<Widget> _getActions(bool innerBoxIsScrolled) {
    return [
      if (_graph is AnimeGraph)
        IconButton(
          onPressed: () => _switchView(),
          icon: Icon(
            _selectedView == _SelectedView.list
                ? Icons.graphic_eq
                : Icons.list_alt,
          ),
        ),
      if (_graph == null && !innerBoxIsScrolled)
        SizedBox(
          width: 25,
          height: 25,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
          ),
        ),
      PopupMenuBuilder(
        menuItems: [
          shareMenuItem()
            ..onTap = () {
              openShareBuilder(
                context,
                animeWidgets.entries
                    .map((e) => ShareInput(
                          title: e.key,
                          content: e.value
                              .map((f) => buildShareOutput(
                                    buildShareInputs(
                                      f.content,
                                      DalPathUtils.browserUrl(DalNode(
                                        category: widget.category,
                                        id: f.content!.id!,
                                      )),
                                      category: widget.category,
                                    ),
                                    props: ShareOutputProps(prefix: '\t'),
                                  ))
                              .reduce((e1, e2) => '$e1 \n$e2'),
                        ))
                    .toList(),
                S.current.Related,
                props: ShareOutputProps(termSpace: '\n', forceReducer: true),
              );
            },
          AppbarMenuItem(
            S.current.Edit,
            createIcon(Icons.edit),
            onTap: () => DalPathUtils.launchNodeInBrowser(
              DalNode(
                  id: widget.id,
                  category: widget.category,
                  dalSubType: DalSubType.relations,
                  queryParams: {
                    '${widget.category.equals('anime') ? "aid" : "mid"}':
                        widget.id,
                  }),
              context,
            ),
          ),
        ],
      ),
    ];
  }

  void _switchView() {
    setState(() {
      _selectedView = _selectedView == _SelectedView.list
          ? _SelectedView.graph
          : _SelectedView.list;
    });
  }

  Column get _horizView {
    final nodeList = animeWidgets[animeWidgets.keys.elementAt(pageIndex)];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _relationTypeHeader,
        SB.h20,
        horizontalList(
          category: widget.category,
          items: nodeList ?? [],
        ),
      ],
    );
  }

  Widget _contentListWidget(List<BaseNode>? nodeList) {
    return ContentListWithDisplayType(
      category: widget.category,
      items: nodeList ?? [],
      sortFilterDisplay: SortFilterDisplay.withDisplayType(
        DisplayOption(
          displayType: DisplayType.grid,
          displaySubType: DisplaySubType.compact,
        ),
      ),
    );
  }

  Widget get _relationTypeHeader {
    return Container(
      height: 32,
      child: _tabBar,
    );
  }

  PreferredSizeWidget get _tabBar {
    return TabBar(
      isScrollable: true,
      onTap: (index) => _onTabTapped(index),
      padding: EdgeInsets.symmetric(horizontal: widget.horizPadding),
      tabs: animeWidgets.keys
          .map((e) => Padding(
                padding: const EdgeInsets.all(6.0),
                child: Text(
                  e,
                  style: TextStyle(fontSize: 13.0),
                ),
              ))
          .toList(),
    );
  }

  _onTabTapped(int index) {
    setState(() {
      pageIndex = index;
    });
  }

  @override
  bool get wantKeepAlive => true;
}
