import 'dart:collection';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/screens/contentdetailedscreen.dart';
import 'package:dailyanimelist/widgets/avatarwidget.dart';
import 'package:dailyanimelist/widgets/common/image_preview.dart';
import 'package:dailyanimelist/widgets/custombutton.dart';
import 'package:dailyanimelist/widgets/home/animecard.dart';
import 'package:dailyanimelist/widgets/loading/expandedwidget.dart';
import 'package:dal_commons/commons.dart' as dal;
import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';

class AnimeGraphWidget extends StatefulWidget {
  final dal.AnimeGraph graph;
  final int id;
  final Map<int, dal.MyListStatus> statusMap;
  const AnimeGraphWidget({
    super.key,
    required this.graph,
    required this.id,
    required this.statusMap,
  });

  @override
  State<AnimeGraphWidget> createState() => _AnimeGraphWidgetState();
}

class _AnimeGraphWidgetState extends State<AnimeGraphWidget> {
  final Graph graph = Graph()..isTree = true;
  final BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();
  late Algorithm algorithm;
  final Map<int, dal.GraphNode> nodes = HashMap();
  final List<int> _expandedIds = [];
  final TransformationController controller = TransformationController();

  @override
  void initState() {
    super.initState();
    widget.graph.nodes?.forEach((node) => nodes[node.id!] = node);
    final Map<int, Node> idMap = Map.fromEntries(widget.graph.nodes
            ?.map((node) => MapEntry(node.id!, Node.Id(node.id!)))
            .toList() ??
        []);
    widget.graph.edges?.forEach((edge) {
      final fromNodeId = idMap[edge.source]!;
      final toNodeId = idMap[edge.target]!;
      graph.addEdge(fromNodeId, toNodeId)
        ..paint = (Paint()
          ..color = getColorByRelationType(edge.relationType!)
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke);
    });

    algorithm = SugiyamaAlgorithm(
      SugiyamaConfiguration()
        ..bendPointShape = CurvedBendPointShape(curveLength: 64.0)
        ..nodeSeparation = 40
        ..levelSeparation = 80,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      algorithm.setFocusedNode(idMap[widget.id]!);
      if (mounted) setState(() {});
    });
  }

  Color getColorByRelationType(dal.GRelationType? relationType) {
    switch (relationType) {
      case dal.GRelationType.sequel:
        return Colors.green;
      case dal.GRelationType.prequel:
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InteractiveViewer(
          constrained: false,
          boundaryMargin: EdgeInsets.all(double.infinity),
          minScale: 0.01,
          maxScale: 5.6,
          transformationController: controller,
          child: Padding(
            padding: const EdgeInsets.all(0.0),
            child: GraphView(
              graph: graph,
              algorithm: algorithm,
              animated: true,
              builder: (Node node) {
                // I can decide what widget should be shown here based on the id
                var a = node.key?.value as int?;
                return rectangleWidget(nodes[a]!);
              },
            ),
          ),
        ),
        Positioned(
            bottom: 20,
            left: 20,
            child: IconButton.filled(
              onPressed: () {
                algorithm.setFocusedNode(Node.Id(widget.id));
                controller.value = Matrix4.identity();
                if (mounted) setState(() {});
              },
              icon: Icon(Icons.location_searching),
            )),
      ],
    );
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
    var textWidget = SizedBox(
      width: 130.0,
      height: 50.0,
      child: GestureDetector(
        onTap: () => _setExpanded(a),
        child: Center(
          child: AutoSizeText(
            a.title ?? "",
            maxLines: 2,
            minFontSize: 10.0,
            textAlign: isExpanded ? TextAlign.start : TextAlign.center,
          ),
        ),
      ),
    );
    final column = _getNodeDetails(isExpanded, a, textWidget);
    return Card(
      color: Theme.of(context).cardColor.withOpacity(isExpanded ? 1 : .7),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: !isExpanded ? textWidget : column,
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
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              textWidget,
              IconButton(
                onPressed: () {
                  _setExpanded(a);
                },
                icon: Icon(isExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down),
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
              Badge(
                child: ToolTipButton(
                  onTap: () => _onNodeTap(a),
                  child: Icon(
                    Icons.open_in_new,
                    size: 18.0,
                  ),
                  message: S.current.Open,
                ),
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
    var image = AvatarWidget(
      width: 120,
      height: 120,
      url: imageUrl,
      useUserImageOnError: false,
      radius: BorderRadius.circular(64),
      onTap: () => _setExpanded(a),
      onLongPress: () => zoomInImage(context, imageUrl),
    );
    final myListStatus = widget.statusMap[a.id];
    final value = NodeStatusValue.fromListStatus(myListStatus);
    final statusOutline = Container(
      height: 120.0,
      width: 120.0,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
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
      child: Stack(
        children: [
          if (widget.id == a.id) centerBorder,
          statusOutline,
          image,
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
