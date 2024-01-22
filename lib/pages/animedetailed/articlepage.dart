import 'package:dailyanimelist/api/dalapi.dart';
import 'package:dailyanimelist/api/malapi.dart';
import 'package:dailyanimelist/main.dart';
import 'package:dailyanimelist/screens/featurescreen.dart';
import 'package:dailyanimelist/screens/plainscreen.dart';
import 'package:dailyanimelist/widgets/avatarwidget.dart';
import 'package:dailyanimelist/widgets/customfuture.dart';
import 'package:dailyanimelist/widgets/forum/nextprev.dart';
import 'package:dailyanimelist/widgets/loading/shimmerwidget.dart';
import 'package:dailyanimelist/widgets/shimmecolor.dart';
import 'package:dailyanimelist/widgets/slivers.dart';
import 'package:dailyanimelist/widgets/user/contentlistwidget.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../constant.dart';

class ArticlePage extends StatefulWidget {
  final int? id;
  final String? category;
  final String? additonalCategory;
  final VoidCallback? onPageChange;
  final double horizPadding;
  const ArticlePage({
    Key? key,
    this.id,
    this.category,
    this.additonalCategory,
    this.onPageChange,
    required this.horizPadding,
  }) : super(key: key);

  @override
  _ArticlePageState createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage>
    with AutomaticKeepAliveClientMixin<ArticlePage> {
  Future<SearchResult>? articleFuture;
  int page = 1;

  Future<SearchResult> _getArticles() async {
    return DalApi.i.searchFeaturedArticles(
      id: widget.id,
      category: widget.additonalCategory!,
      additonalCategory: widget.category!,
      page: page,
      containerName: widget.additonalCategory!.equals("news")
          ? "js-scrollfix-bottom-rel"
          : "news-list",
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.id != null && articleFuture == null) {
      articleFuture = _getArticles();
    }
  }

  bool get isNews => widget.additonalCategory!.equals("news");

  @override
  Widget build(BuildContext context) {
    return articleFuture == null
        ? ShimmerWidget()
        : CFutureBuilder<SearchResult>(
            future: articleFuture,
            done: (s) =>
                _aritcleWidget((s.data?.data ?? []) as List<FeaturedBaseNode>),
            loadingChild: _loadingWidget,
          );
  }

  Widget get _loadingWidget {
    return ShimmerColor(
      _aritcleWidget(List.generate(12, (index) => FeaturedBaseNode())),
    );
  }

  Widget _aritcleWidget(List<FeaturedBaseNode> data) {
    if (data.isEmpty) {
      return showNoContent();
    }
    return Container(
      height: isNews ? 180 : 270,
      child: GridView.builder(
        itemCount: data.length,
        scrollDirection: Axis.horizontal,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: isNews ? .3 : .9,
          mainAxisSpacing: 0,
          crossAxisSpacing: 0,
          crossAxisCount: isNews ? 2 : 1,
        ),
        padding: EdgeInsets.symmetric(
            horizontal: widget.horizPadding + 10, vertical: 7),
        itemBuilder: (context, index) =>
            _buildNewsTile(data[index].content as Featured?, index),
      ),
    );
  }

  Widget _buildNewsTile(Featured? content, int index) {
    return Card(
      child: content == null
          ? SB.z
          : InkWell(
              onTap: () {
                gotoPage(
                    context: context,
                    newPage: FeaturedScreen(
                      category: widget.additonalCategory!,
                      id: content.id!,
                      featureTitle: content.title,
                      imgUrl: content.mainPicture?.large,
                    ));
              },
              borderRadius: BorderRadius.circular(12),
              child: Column(
                children: [
                  _titleWidget(content),
                  if (!isNews) ...[
                    SB.h10,
                    _summaryWidget(content),
                    SB.h10,
                    _bottomWidget(content),
                  ]
                ],
              ),
            ),
    );
  }

  Padding _bottomWidget(Featured content) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          title(content.postedBy ?? '', selectable: true),
          SB.w20,
          if (content.views!.isNotBlank)
            iconAndText(Icons.remove_red_eye, content.views)
        ],
      ),
    );
  }

  Widget _summaryWidget(Featured content) {
    return Expanded(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: title(content.summary ?? ''),
      ),
    );
  }

  Widget _titleWidget(Featured content) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AvatarWidget(
              height: 40,
              width: 40,
              url: content.mainPicture!.large ?? content.mainPicture!.medium,
              userRoundBorderforLoading: false,
            ),
            SB.w20,
            Expanded(
              child:
                  title(content.title ?? '', textOverflow: TextOverflow.fade),
            )
          ],
        ),
      ),
    );
  }

  Widget _nextPrevRow(SearchResult? result) {
    if (widget.additonalCategory!.equals("featured")) return SB.z;
    return NextPreviousRow(
      onNext: isResultEmpty(result) ? null : () => _changePage(page + 1),
      onPrevious: page == 1 ? null : () => _changePage(page - 1),
    );
  }

  _changePage(int _page) {
    page = _page;
    articleFuture = _getArticles();
    if (widget.onPageChange != null) widget.onPageChange!();
    if (mounted) setState(() {});
  }

  bool isResultEmpty(SearchResult? result) =>
      result?.data == null || result!.data!.isEmpty;

  @override
  bool get wantKeepAlive => true;
}
