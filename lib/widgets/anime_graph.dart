import 'dart:collection';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dailyanimelist/constant.dart';
import 'package:dal_commons/commons.dart' as dal;
import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';

class AnimeGraphWidget extends StatefulWidget {
  final dal.AnimeGraph graph;
  final int id;
  const AnimeGraphWidget({
    super.key,
    required this.graph,
    required this.id,
  });

  @override
  State<AnimeGraphWidget> createState() => _AnimeGraphWidgetState();
}

class _AnimeGraphWidgetState extends State<AnimeGraphWidget> {
  final Graph graph = Graph()..isTree = false;
  final BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();
  late Algorithm algorithm;
  final Map<int, dal.GraphNode> nodes = HashMap();

  @override
  void initState() {
    super.initState();
    widget.graph.nodes?.forEach((node) => nodes[node.id!] = node);
    widget.graph.edges?.forEach((edge) {
      var fromNodeId = edge.source;
      var toNodeId = edge.target;
      graph.addEdge(Node.Id(fromNodeId), Node.Id(toNodeId))
        ..paint = (Paint()..color = getColorByRelationType(edge.relationType!));
    });

    builder
      ..siblingSeparation = (100)
      ..levelSeparation = (150)
      ..subtreeSeparation = (150)
      ..orientation = (BuchheimWalkerConfiguration.ORIENTATION_LEFT_RIGHT);

    algorithm = BuchheimWalkerAlgorithm(builder, TreeEdgeRenderer(builder))
      ..setFocusedNode(Node.Id(widget.id));
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
    return InteractiveViewer(
        constrained: false,
        boundaryMargin: EdgeInsets.all(100),
        minScale: 0.01,
        maxScale: 5.6,
        child: Padding(
          padding: const EdgeInsets.all(100.0),
          child: GraphView(
            graph: graph,
            algorithm: algorithm,
            // paint: Paint()
            //   ..color = Colors.green
            //   ..strokeWidth = 1
            //   ..style = PaintingStyle.stroke,
            builder: (Node node) {
              // I can decide what widget should be shown here based on the id
              var a = node.key?.value as int?;
              return rectangleWidget(nodes[a]!);
            },
          ),
        ));
  }

  Widget rectangleWidget(dal.GraphNode a) {
    return Column(
      children: [
        SizedBox(
          height: 60.0,
          width: 60.0,
          child: CircleAvatar(
            backgroundColor: Colors.blue,
            backgroundImage:
                CachedNetworkImageProvider(a.mainPicture?.large ?? ""),
          ),
        ),
        SB.h10,
        SizedBox(
          width: 120.0,
          height: 40.0,
          child: AutoSizeText(
            a.title ?? "",
            maxLines: 2,
            minFontSize: 8.0,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
