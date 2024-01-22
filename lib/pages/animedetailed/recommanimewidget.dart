import 'package:dailyanimelist/api/credmal.dart';
import 'package:dailyanimelist/api/dalapi.dart';
import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/main.dart';
import 'package:dailyanimelist/screens/contentdetailedscreen.dart';
import 'package:dailyanimelist/widgets/avatarwidget.dart';
import 'package:dailyanimelist/widgets/custombutton.dart';
import 'package:dailyanimelist/widgets/customfuture.dart';
import 'package:dailyanimelist/widgets/home/animecard.dart';
import 'package:dailyanimelist/widgets/slivers.dart';
import 'package:dailyanimelist/widgets/translator.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:flutter/material.dart';

class RecommendedAnimeWidget extends StatelessWidget {
  final List<Recommendation> recommAnime;
  final String category;
  final double horizPadding;
  const RecommendedAnimeWidget(
      {required this.recommAnime, this.category = "anime", required this.horizPadding});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      child: ListView.builder(
        itemCount: recommAnime.length,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: horizPadding + 10),
        itemBuilder: ((context, i) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(3, 6, 3, 3),
            child: AnimeGridCard(
              node: recommAnime[i].recommNode!,
              numRecommendations: recommAnime[i].numRecommendations,
              updateCache: true,
              height: 150,
              width: 140,
              smallHeight: 25,
              showCardBar: true,
              showEdit: true,
              onTap: () => navigateTo(
                  context,
                  ContentDetailedScreen(
                    node: recommAnime[i].recommNode,
                    category: category,
                  )),
            ),
          );
        }),
      ),
    );
  }
}

class ContentFullRecommendation extends StatefulWidget {
  final int id;
  final String category;
  const ContentFullRecommendation({Key? key, required this.id, required this.category})
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
      {Key? key, required this.data, required this.category, required this.controller})
      : super(key: key);

  @override
  State<SelectorNodesWidget> createState() => _SelectorNodesWidgetState();
}

class _SelectorNodesWidgetState extends State<SelectorNodesWidget> {
  final BorderRadius borderRadius = BorderRadius.circular(12);

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildSelectorNodes;
  }

  SliverWrapper get _buildSelectorNodes {
    return SliverWrapper(
      TabBar(
        isScrollable: true,
        controller: widget.controller,
        indicatorColor: Colors.transparent,
        padding: EdgeInsets.symmetric(horizontal: 35),
        dividerColor: Colors.transparent,
        tabs: List.generate(
            widget.data.length,
            (i) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _buildSelectorNode(widget.data[i].relatedNode!, i),
                )).toList(),
      ),
    );
  }

  Widget _buildSelectorNode(Node node, int index) {
    return SizedBox(
      width: 240,
      child: Card(
        child: InkWell(
          onTap: () {
            if (mounted)
              setState(() {
                widget.controller.index = index;
              });
          },
          borderRadius: borderRadius,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AvatarWidget(
                  url: node.mainPicture?.large ??
                      node.mainPicture?.medium ??
                      '',
                  height: 50,
                  width: 50,
                  onTap: () => gotoPage(
                      context: context,
                      newPage: ContentDetailedScreen(
                        category: widget.category,
                        id: node.id,
                        node: node,
                      )),
                ),
                SB.w10,
                Expanded(
                  child: title(
                    node.title ?? '',
                    textOverflow: TextOverflow.fade,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
