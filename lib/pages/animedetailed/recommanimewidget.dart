import 'package:dailyanimelist/api/credmal.dart';
import 'package:dailyanimelist/api/dalapi.dart';
import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/screens/contentdetailedscreen.dart';
import 'package:dailyanimelist/widgets/avatarwidget.dart';
import 'package:dailyanimelist/widgets/custombutton.dart';
import 'package:dailyanimelist/widgets/customfuture.dart';
import 'package:dailyanimelist/widgets/slivers.dart';
import 'package:dailyanimelist/widgets/translator.dart';
import 'package:dailyanimelist/widgets/user/contentlistwidget.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:flutter/material.dart';

class RecommendedAnimeWidget extends StatelessWidget {
  final List<Recommendation> recommAnime;
  final String category;
  final double horizPadding;
  const RecommendedAnimeWidget(
      {required this.recommAnime,
      this.category = "anime",
      required this.horizPadding});

  @override
  Widget build(BuildContext context) {
    return horizontalList(
      showRecommendations: true,
      category: category,
      padding: EdgeInsets.symmetric(horizontal: horizPadding + 5.0),
      items: recommAnime
          .map(
            (e) => BaseNode(
              content: e.recommNode!..numRecommendations = e.numRecommendations,
              myListStatus: e.recommNode?.myListStatus,
            ),
          )
          .toList(),
    );
  }
}

class ContentFullRecommendation extends StatefulWidget {
  final int id;
  final String category;
  const ContentFullRecommendation(
      {Key? key, required this.id, required this.category})
      : super(key: key);

  @override
  State<ContentFullRecommendation> createState() =>
      _ContentFullRecommendationState();
}

class _ContentFullRecommendationState extends State<ContentFullRecommendation>
    with SingleTickerProviderStateMixin {
  late Future<dynamic> recomBaseFuture;
  final BorderRadiusGeometry borderRadius = BorderRadius.circular(12);
  TabController? controller;

  @override
  void initState() {
    super.initState();
    recomBaseFuture =
        DalApi.i.getRecomData(id: widget.id, category: widget.category);
  }

  @override
  void dispose() {
    super.dispose();
    controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CFutureBuilder(
      future: recomBaseFuture,
      done: (sp) => done(sp.data),
      loadingChild: _loadingWidget,
    );
  }

  Widget get _loadingWidget {
    return loadingBelowText(
      padding: const EdgeInsets.all(10.0),
      text: S.current.Recommendation_Loading,
    );
  }

  Widget done(list) {
    if (list == null || nullOrEmpty(list.data)) return showNoContent();
    final data = list.data as List<RecomBase>;

    final sliverList = (RecomBase e) => CustomScrollWrapper([
          SliverWrapper(Align(
            alignment: Alignment.center,
            child: title(
              '${e.recommendations?.length ?? 0} ${S.current.Recommendations}',
            ),
          )),
          SB.lh20,
          if (nullOrEmpty(e.recommendations))
            SliverWrapper(showNoContent())
          else
            _buildRecomComments(e),
          SB.lh80
        ]);

    controller ??= TabController(length: data.length, vsync: this);

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SelectorNodesWidget(
            category: widget.category,
            controller: controller!,
            data: data,
          )
        ];
      },
      body: TabBarView(
        controller: controller,
        children: data.map((e) => sliverList(e)).toList(),
      ),
    );
  }

  SliverList _buildRecomComments(RecomBase selectedNode) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((_, index) {
        final item = selectedNode.recommendations![index];
        return Card(
          child: Column(children: [
            SB.h10,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  AvatarWidget(
                    username: item.username,
                    height: 40,
                    width: 40,
                    onTap: () => showUserPage(
                        context: context, username: item.username!),
                  ),
                  SB.w20,
                  title(item.username),
                  Expanded(child: SB.z),
                  ToolTipButton(
                    onTap: () {
                      reportWithConfirmation(
                        type: ReportType.recommendation,
                        context: context,
                        content: title(
                            '${S.current.Recommendation_made_by} ${item.username} & id: ${item.id}'),
                        optionalUrl:
                            '${CredMal.htmlEnd}dbchanges.php?go=reportanimerecommendation&id=${item.id}',
                      );
                    },
                    message: S.current.Report_Recommendation,
                    child: title(S.current.Report, fontSize: 11),
                  ),
                  SB.w20,
                ],
              ),
            ),
            SB.h10,
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TranslaterWidget(
                content: item.text,
                done: (data) => title(data),
                buttonPadding: EdgeInsets.zero,
              ),
            ),
            SB.h10,
          ]),
        );
      }, childCount: selectedNode.recommendations!.length),
    );
  }
}

class SelectorNodesWidget extends StatefulWidget {
  final List<RecomBase> data;
  final String category;
  final TabController controller;
  const SelectorNodesWidget(
      {Key? key,
      required this.data,
      required this.category,
      required this.controller})
      : super(key: key);

  @override
  State<SelectorNodesWidget> createState() => _SelectorNodesWidgetState();
}

class _SelectorNodesWidgetState extends State<SelectorNodesWidget> {
  final BorderRadius borderRadius = BorderRadius.circular(12);
  final _tabScrollController = ScrollController();
  static const double tabWidth = 240.0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      if (mounted) {
        setState(() {});
        _centerSelectedTab(widget.controller.index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildSelectorNodes;
  }

  SliverWrapper get _buildSelectorNodes {
    final screenWidth = MediaQuery.of(context).size.width;
    final double sidePadding = (screenWidth - tabWidth) / 2;

    return SliverWrapper(
      SizedBox(
        height: 80,
        child: TabBar(
          isScrollable: true,
          controller: widget.controller,
          indicatorColor: Colors.transparent,
          dividerColor: Colors.transparent,
          physics: const BouncingScrollPhysics(),
          labelPadding: EdgeInsets.zero,
          tabAlignment: TabAlignment.start,
          tabs: List.generate(
            widget.data.length,
            (i) => Padding(
              padding: EdgeInsets.only(
                left: i == 0 ? sidePadding : 8,
                right: i == widget.data.length - 1 ? sidePadding : 8,
              ),
              child: _buildSelectorNode(widget.data[i].relatedNode!, i),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectorNode(Node node, int index) {
    return SizedBox(
      width: tabWidth,
      child: RepaintBoundary(
        child: GestureDetector(
          onTap: () {
            if (mounted) {
              setState(() {
                widget.controller.index = index;
              });
            }
          },
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  RepaintBoundary(
                    child: AvatarWidget(
                      url: node.mainPicture?.large ?? node.mainPicture?.medium ?? '',
                      height: 50,
                      width: 50,
                      onTap: () => gotoPage(
                        context: context,
                        newPage: ContentDetailedScreen(
                          category: widget.category,
                          id: node.id,
                          node: node,
                        )
                      ),
                    ),
                  ),
                  SB.w10,
                  Expanded(
                    child: title(
                      node.title ?? '',
                      textOverflow: TextOverflow.fade,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _centerSelectedTab(int index) {
    final screenWidth = MediaQuery.of(context).size.width;
    final offset = (index * tabWidth) - (screenWidth - tabWidth) / 2;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_tabScrollController.hasClients) return;
      final maxScroll = _tabScrollController.position.maxScrollExtent;
      final safeOffset = offset.clamp(0.0, maxScroll);
      _tabScrollController.animateTo(
        safeOffset,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }
}
