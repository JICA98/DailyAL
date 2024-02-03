import 'dart:collection';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dailyanimelist/cache/cachemanager.dart';
import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/screens/contentdetailedscreen.dart';
import 'package:dailyanimelist/screens/plainscreen.dart';
import 'package:dailyanimelist/widgets/common/image_preview.dart';
import 'package:dailyanimelist/widgets/home/animecard.dart';
import 'package:dailyanimelist/widgets/selectbottom.dart';
import 'package:dal_commons/commons.dart' as dal;
import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';

enum _GraphOrderType {
  by_sequel,
  from_selected,
}

class AnimeGraphWidget extends StatefulWidget {
  final dal.AnimeGraph graph;
  final int id;
  final Map<int, dal.MyListStatus> statusMap;
  final List<Widget> actions;
  const AnimeGraphWidget({
    super.key,
    required this.graph,
    required this.id,
    required this.statusMap,
    required this.actions,
  });

  @override
  State<AnimeGraphWidget> createState() => _AnimeGraphWidgetState();
}

class _AnimeGraphWidgetState extends State<AnimeGraphWidget> {
  Graph _graph = Graph()..isTree = false;
  late SugiyamaAlgorithm _algorithm;
  final Map<int, dal.GraphNode> _nodeMap = HashMap();
  final List<int> _expandedIds = [];
  final TransformationController _controller = TransformationController();
  final _edgeColorMap = {
    dal.GRelationType.sequel: Colors.green,
    dal.GRelationType.prequel: Colors.red,
  };
  final _edgeStrokeWidthMap = {
    dal.GRelationType.sequel: 3.0,
    dal.GRelationType.prequel: 3.0,
  };
  final _graphTypeMap = {
    _GraphOrderType.by_sequel: S.current.Graph_Order_By_Sequel,
    _GraphOrderType.from_selected: S.current.Graph_Order_From_Selected,
  };
  _GraphOrderType _graphOrderType = _GraphOrderType.by_sequel;

  @override
  void initState() {
    super.initState();
    widget.graph.nodes?.forEach((node) => _nodeMap[node.id!] = node);
    _setGraph();

    _algorithm = SugiyamaAlgorithm(SugiyamaConfiguration()
      ..bendPointShape = CurvedBendPointShape(curveLength: 120.0)
      ..nodeSeparation = 40
      ..levelSeparation = 80);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setInitialPosition();
    });
  }

  void _setGraph() {
    _graph = Graph()..isTree = false;
    widget.graph.edges?.forEach((edge) {
      if (_graphOrderType == _GraphOrderType.by_sequel) {
        if (edge.relationType == dal.GRelationType.prequel) {
          _addEdge(dal.GraphEdge(
            source: edge.target,
            target: edge.source,
            relationType: dal.GRelationType.sequel,
            relationTypeFormatted: S.current.Sequel,
          ));
          return;
        }
      }
      _addEdge(edge);
    });
  }

  void _addEdge(dal.GraphEdge edge) {
    final fromNodeId = Node.Id(edge.source);
    final toNodeId = Node.Id(edge.target);
    _graph.addEdge(fromNodeId, toNodeId)
      ..paint = (Paint()
        ..color = _getColorByRelationType(edge.relationType)
        ..strokeWidth = _edgeStrokeWidthMap[edge.relationType] ?? 1.0
        ..style = PaintingStyle.stroke);
  }

  void _setInitialPosition([Size? size]) {
    final position = _algorithm.nodeData.keys.firstWhere((e) {
      return e.key?.value == widget.id;
    }).position;
    final contextSize = size ?? MediaQuery.of(context).size;
    _controller.value = Matrix4.identity()
      ..scale(0.6, 0.6)
      ..translate(
        -(position.dx - (contextSize.width / 2)),
        -(position.dy - (contextSize.height / 2)),
      );
  }

  Color _getColorByRelationType(dal.GRelationType? relationType) {
    return _edgeColorMap[relationType] ?? Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    return TitlebarScreen(
      Stack(
        children: [
          InteractiveViewer(
            constrained: false,
            boundaryMargin: EdgeInsets.all(double.infinity),
            minScale: 0.01,
            maxScale: 5.6,
            transformationController: _controller,
            child: GraphView(
              graph: _graph,
              algorithm: _algorithm,
              animated: false,
              builder: (Node node) {
                var a = node.key?.value as int?;
                return rectangleWidget(_nodeMap[a]!);
              },
            ),
          ),
          _bottomBar(),
        ],
      ),
      appbarTitle: '${S.current.Related} anime',
      autoIncludeSearch: false,
      actions: [
        SelectButton(
          popupText: S.current.Order_by,
          selectedOption: _graphTypeMap[_graphOrderType],
          child: Icon(Icons.swap_horiz),
          options: _graphTypeMap.values.toList(),
          onChanged: (p0) {
            _graphOrderType = _graphTypeMap.entries
                .firstWhere((element) => element.value == p0)
                .key;
            _setGraph();
            if (mounted) setState(() {});
            Future.delayed(Duration(milliseconds: 100), () {
              _setInitialPosition();
            });
          },
        ),
        ...widget.actions,
      ],
    );
  }

  Widget _bottomBar() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Row(
        children: [
          IconButton.filled(
            onPressed: () {
              _setInitialPosition();
              if (mounted) setState(() {});
            },
            icon: Icon(Icons.location_searching),
          ),
          Spacer(),
          IconButton.filled(
            onPressed: () => _onEdgeInfo(),
            icon: Icon(Icons.info),
          )
        ],
      ),
    );
  }

  void _onEdgeInfo() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        S.current.Graph_Edge_Info,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              ..._getIndicator(S.current.Sequel, Colors.green),
              ..._getIndicator(S.current.Prequel, Colors.red),
              ..._getIndicator(S.current.Others, Colors.blue),
              SB.h20,
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _getIndicator(String text, Color color) {
    return [
      SB.h20,
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Text(
          text,
          textAlign: TextAlign.start,
        ),
      ),
      SB.h10,
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
        child: SizedBox(
          child: Container(
            height: 5.0,
            width: double.infinity,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
      )
    ];
  }

  Widget rectangleWidget(dal.GraphNode a) {
    return Column(
      children: [
        _imageCover(a),
        SB.h10,
        _textWidget(a),
      ],
    );
  }

  Widget _textWidget(dal.GraphNode a) {
    bool isExpanded = _expandedIds.contains(a.id);
    final textWidget = SizedBox(
      width: 130.0,
      height: 50.0,
      child: Center(
        child: AutoSizeText(
          a.title ?? "",
          maxLines: 2,
          minFontSize: 10.0,
          textAlign: TextAlign.center,
        ),
      ),
    );
    final column = _getNodeDetails(isExpanded, a, textWidget);
    return Card(
      color: Theme.of(context).cardColor.withOpacity(isExpanded ? 1 : .7),
      child: InkWell(
        onTap: () => _setExpanded(a),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: !isExpanded ? textWidget : column,
        ),
      ),
    );
  }

  Widget _getNodeDetails(
      bool isExpanded, dal.GraphNode a, SizedBox textWidget) {
    var starField2 = starField(
      a.mean?.toString() ?? '?',
      starHeight: 15,
      textStyle: TextStyle(fontSize: 12),
      useIcon: true,
    );
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              textWidget,
              IconButton.filledTonal(
                onPressed: () => _onNodeTap(a),
                icon: Icon(Icons.open_in_new),
              ),
            ],
          ),
          SB.h5,
          Row(
            children: [
              starField2,
              SB.w10,
              Badge(
                label: Text(
                    '${a.startSeason?.season?.name.titleCase() ?? "?"} ${a.startSeason?.year ?? "?"}'),
              ),
            ],
          ),
          SB.h10,
          Row(
            children: [
              SB.w10,
              Badge(
                label: Text(a.mediaType?.toUpperCase() ?? "?"),
              ),
              SB.w10,
              Badge(
                label: Text(a.status?.standardize() ?? "?"),
              ),
              SB.w10,
            ],
          )
        ],
      ),
    );
  }

  void _setExpanded(dal.GraphNode a) {
    if (mounted) {
      setState(() {
        if (_expandedIds.contains(a.id)) {
          _expandedIds.remove(a.id);
        } else {
          _expandedIds.add(a.id!);
        }
      });
    }
  }

  Widget _imageCover(dal.GraphNode a) {
    final imageUrl = a.mainPicture?.large ?? a.mainPicture?.medium ?? "";
    var image = SizedBox(
      width: 120,
      height: 120,
      child: InkWell(
        borderRadius: BorderRadius.circular(64),
        onTap: () => _setExpanded(a),
        onLongPress: () => zoomInImage(context, imageUrl),
        child: Ink(
          child: CircleAvatar(
            backgroundImage: NetworkImage(imageUrl),
          ),
        ),
      ),
    );
    final myListStatus = widget.statusMap[a.id];
    final value = NodeStatusValue.fromListStatus(myListStatus);
    final statusOutline = Container(
      height: 140.0,
      width: 140.0,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).cardColor,
          boxShadow: [
            if (_expandedIds.contains(a.id))
              BoxShadow(
                color: value.color?.withOpacity(0.1) ??
                    Colors.white.withOpacity(0.1),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3), // changes position of shadow
              ),
          ],
          border: Border.all(
            color: value.color ?? Colors.transparent,
            width: 3.0,
          )),
    );
    final centerBorder = Container(
      height: 120.0,
      width: 120.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
    );
    return SizedBox(
      height: 140.0,
      width: 140.0,
      child: Stack(
        children: [
          if (widget.id == a.id) centerBorder,
          statusOutline,
          Positioned(
            top: 10,
            left: 10,
            child: image,
          )
        ],
      ),
    );
  }

  void _onNodeTap(dal.GraphNode a) {
    gotoPage(
        context: context,
        newPage: ContentDetailedScreen(
          node: dal.Node(
              id: a.id,
              title: a.title,
              mainPicture: dal.Picture(
                large: a.mainPicture?.large,
                medium: a.mainPicture?.medium,
              )),
        ));
  }
}
