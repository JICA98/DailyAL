import 'dart:collection';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dailyanimelist/api/malapi.dart';
import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/enums.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/screens/contentdetailedscreen.dart';
import 'package:dailyanimelist/screens/plainscreen.dart';

import 'package:dailyanimelist/widgets/home/animecard.dart';
import 'package:dailyanimelist/widgets/selectbottom.dart';
import 'package:dal_commons/commons.dart' as dal;
import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

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
  _GraphOrderType _graphOrderType = _GraphOrderType.from_selected;
  late int _selectedId;
  final GlobalKey _globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _selectedId = widget.id;
    widget.graph.nodes?.forEach((node) => _nodeMap[node.id!] = node);
    _setGraph();

    _algorithm = SugiyamaAlgorithm(SugiyamaConfiguration()
      ..bendPointShape = CurvedBendPointShape(curveLength: 120.0)
      ..nodeSeparation = 60
      ..levelSeparation = 100);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setInitialPosition();
    });
  }

  void _setGraph() {
    _graph = Graph()..isTree = false;
    final edges = widget.graph.edges?.map(_mapEdges).toList() ?? [];
    edges.forEach(_addEdge);
  }

  dal.GraphEdge _mapEdges(edge) {
    if (_graphOrderType == _GraphOrderType.by_sequel) {
      if (edge.relationType == dal.GRelationType.prequel) {
        return dal.GraphEdge(
          source: edge.target,
          target: edge.source,
          relationType: dal.GRelationType.sequel,
        );
      } else if (edge.relationType != dal.GRelationType.sequel) {
        final getEdge = _getEdge(edge);
        if (getEdge != null) return getEdge;
      }
    }
    return edge;
  }

  dal.GraphEdge? _getEdge(dal.GraphEdge edge) {
    int? source, target;
    final seasonOne = _nodeMap[edge.source!]?.startSeason;
    final seasonTwo = _nodeMap[edge.target!]?.startSeason;
    if (seasonOne?.year == null && seasonTwo?.year != null) {
      source = edge.target;
      target = edge.source;
    } else if (seasonOne?.year != null && seasonTwo?.year == null) {
      source = edge.source;
      target = edge.target;
    } else if (seasonOne?.year == null ||
        seasonTwo?.year == null ||
        seasonOne?.season == null ||
        seasonTwo?.season == null) {
      source = edge.source;
      target = edge.target;
    } else {
      try {
        var oneTime = _getTimeUsingGSeason(seasonOne);
        var twoTime = _getTimeUsingGSeason(seasonTwo);
        if (oneTime.isBefore(twoTime)) {
          source = edge.source;
          target = edge.target;
        } else {
          source = edge.target;
          target = edge.source;
        }
      } catch (e) {}
    }
    if (source != null && target != null) {
      return dal.GraphEdge(
        source: source,
        target: target,
        relationType: edge.relationType,
      );
    }
    return null;
  }

  DateTime _getTimeUsingGSeason(dal.GStartSeason? seasonOne) {
    return MalApi.getDateTimeForSeason(
        seasonMapInverse[dal.seasonValues.reverse[seasonOne!.season]]!,
        seasonOne.year!);
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
      return e.key?.value == _selectedId;
    }).position;
    final contextSize = size ?? MediaQuery.of(context).size;
    _controller.value = Matrix4.identity()
      ..scale(0.6, 0.6)
      ..translate(
        -(position.dx - (contextSize.width / 2) - 50.0),
        -(position.dy - (contextSize.height / 2)),
      );
  }

  Color _getColorByRelationType(dal.GRelationType? relationType) {
    return _edgeColorMap[relationType] ?? Colors.blue;
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
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
            child: RepaintBoundary(
              key: _globalKey,
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
              _selectedId = widget.id;
              _setInitialPosition();
              if (mounted) setState(() {});
            },
            icon: Icon(Icons.location_searching),
          ),
          Spacer(),
          IconButton.filled(
            onPressed: () => _onEdgeInfo(),
            icon: Icon(Icons.info),
          ),
          SB.w20,
          IconButton.filled(
            onPressed: () => _captureAndSharePng(),
            icon: Icon(Icons.camera_alt),
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
          maxLines: 3,
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
                label: Text(a.mediaType?.standardize() ?? "?"),
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
        onLongPress: () => _onNodeSelect(a),
        child: Ink(
          child: CircleAvatar(
            backgroundImage: NetworkImage(imageUrl),
          ),
        ),
      ),
    );
    final myListStatus = widget.statusMap[a.id];
    final value = NodeStatusValue.fromListStatus(myListStatus);
    final contains = _expandedIds.contains(a.id);
    final isSelected = _selectedId == a.id;
    final statusOutline = Container(
      height: 140.0,
      width: 140.0,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).cardColor,
          boxShadow: [
            if (contains)
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
          if (isSelected) centerBorder,
          if (value.color != null || contains) statusOutline,
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

  Future<void> _captureAndSharePng() async {
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;

      ui.Image? graphImage;
      // Try higher pixel ratios for better quality
      final ratios = [50.0, 30.0, 15.0, 10.0, 5.0, 3.0, 1.0];

      for (final ratio in ratios) {
        try {
          graphImage = await boundary.toImage(pixelRatio: ratio);
          break;
        } catch (e) {
          debugPrint('Failed to capture at ratio $ratio: $e');
        }
      }

      if (graphImage == null) {
        if (mounted) showToast(S.current.Couldnt_generate_graph);
        return;
      }

      // Load Logo
      final logoBytes = await rootBundle.load('assets/images/dal-black-bg.png');
      final logoCodec = await ui.instantiateImageCodec(
        logoBytes.buffer.asUint8List(),
      );
      final logoFrame = await logoCodec.getNextFrame();
      final logoImage = logoFrame.image;

      // Calculate sizes
      // Footer height relative to graph height, but at least enough for logo + padding
      final footerHeight = (graphImage.height * 0.15).clamp(100.0, 400.0);
      final totalWidth = graphImage.width;
      final totalHeight = graphImage.height + footerHeight.toInt();
      final scaleFactor = totalWidth / 1000.0; // Base scale on width

      // Create Canvas
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(
          recorder,
          Rect.fromPoints(Offset.zero,
              Offset(totalWidth.toDouble(), totalHeight.toDouble())));

      // Draw Graph
      canvas.drawImage(graphImage, Offset.zero, Paint());

      // Draw Footer Background
      final footerRect = Rect.fromLTWH(
          0, graphImage.height.toDouble(), totalWidth.toDouble(), footerHeight);
      canvas.drawRect(footerRect, Paint()..color = const Color(0xFF151515));

      // Draw Logo
      final logoSize = footerHeight * 0.7; // Logo takes 80% of footer height
      final logoY = graphImage.height + (footerHeight - logoSize) / 2;
      final logoX = 50.0 * scaleFactor; // Padding from left
      final logoRect = Rect.fromLTWH(logoX, logoY, logoSize, logoSize);

      // Paint logo with high quality filtering
      paintImage(
        canvas: canvas,
        rect: logoRect,
        image: logoImage,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      );

      // Draw Text
      final textSpan = TextSpan(
        text: 'Created from DailyAL App',
        style: TextStyle(
          color: Colors.white,
          fontSize: (footerHeight * 0.35).clamp(24.0, 100.0),
          fontFamily: 'Roboto', // Default flutter font or app font
          fontWeight: FontWeight.bold,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final textX = logoX + logoSize + (40.0 * scaleFactor);
      final textY = graphImage.height + (footerHeight - textPainter.height) / 2;

      textPainter.paint(canvas, Offset(textX, textY));

      // Finalize Image
      final picture = recorder.endRecording();
      final finalImage = await picture.toImage(totalWidth, totalHeight);

      ByteData? byteData =
          await finalImage.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final node = _nodeMap[widget.id];
      final title =
          node?.title?.replaceAll(RegExp(r'[^\w\s]+'), '') ?? 'anime_graph';
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${title}_${widget.id}_$timestamp.png';

      final file = await File('${tempDir.path}/$fileName').create();
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles([XFile(file.path)], text: fileName);
    } catch (e) {
      dal.logDal(e.toString());
      if (mounted) showToast(S.current.Couldnt_generate_graph);
    }
  }

  void _onNodeSelect(dal.GraphNode a) {
    if (a.id != null) {
      _selectedId = a.id!;
      _setInitialPosition();
      if (mounted) setState(() {});
    }
  }
}
