// ignore_for_file: unused_import

import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:dailyanimelist/api/auth/auth.dart';
import 'package:dailyanimelist/api/dalapi.dart';
import 'package:dailyanimelist/cache/cachemanager.dart';
import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/screens/contentdetailedscreen.dart';
import 'package:dailyanimelist/screens/plainscreen.dart';
import 'package:dailyanimelist/util/pathutils.dart';
import 'package:dailyanimelist/widgets/avatarwidget.dart';
import 'package:dailyanimelist/widgets/common/share_builder.dart';
import 'package:dailyanimelist/widgets/customanimations.dart';
import 'package:dailyanimelist/widgets/customappbar.dart';
import 'package:dailyanimelist/widgets/custombutton.dart';
import 'package:dailyanimelist/widgets/customfuture.dart';
import 'package:dailyanimelist/widgets/fadingeffect.dart';
import 'package:dailyanimelist/widgets/home/accordion.dart';
import 'package:dailyanimelist/widgets/loading/shimmerwidget.dart';
import 'package:dailyanimelist/widgets/selectbottom.dart';
import 'package:dailyanimelist/widgets/slivers.dart';
import 'package:dailyanimelist/widgets/translator.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:dailyanimelist/util/responsive_helper.dart';

class Filter {
  String title;
  bool isSelected;
  Filter(this.title, {this.isSelected = false});

  @override
  bool operator ==(covariant Filter other) {
    if (identical(this, other)) return true;

    return other.title == title;
  }

  @override
  int get hashCode => title.hashCode;
}

class ContentReviewPage extends StatefulWidget {
  final List<AnimeReviewHtml> reviews;
  final double horizPadding;
  final String category;
  final Axis axis;
  final int? id;
  final String? selectSortBy;
  ContentReviewPage({
    required this.reviews,
    required this.horizPadding,
    this.category = 'anime',
    this.axis = Axis.horizontal,
    this.id,
    this.selectSortBy,
  });

  @override
  _ContentReviewPageState createState() => _ContentReviewPageState();
}

class _ContentReviewPageState extends State<ContentReviewPage> {
  List<AnimeReviewHtml>? reviews;
  List<Filter> tags = [];
  List<Filter> selectedTags = [];
  List<String> _availableScores = [];
  String selectedScore = S.current.Select;
  AutoScrollController? listController;
  late List<String> _sortByOptions;
  late String selectSortBy;

  @override
  void initState() {
    super.initState();
    if (widget.selectSortBy == null) {
      selectSortBy = S.current.Helpful;
      _sortByOptions = [
        S.current.Helpful,
        S.current.Date,
        S.current.Score,
      ];
    } else {
      selectSortBy = widget.selectSortBy!;
      _sortByOptions = [
        S.current.Date,
        S.current.Score,
      ];
    }
    reviews = widget.reviews;
    tags = reduceFilters(
        widget.reviews.map((e) => Set<String>.from(e.tags ?? [])));
    _availableScores = widget.reviews
        .map((e) => int.tryParse(e.overallRating ?? ''))
        .where((e) => e != null)
        .map((e) => '$e')
        .toSet()
        .toList();
    if (_availableScores.isNotEmpty) {
      _availableScores.insert(0, selectedScore);
    }
    listController = AutoScrollController(
      axis: widget.axis,
      viewportBoundaryGetter: () =>
          Rect.fromLTRB(30, 0, 0, MediaQuery.of(context).padding.right),
    );
  }

  List<AnimeReviewHtml> _sortReviews(List<AnimeReviewHtml>? reviews) {
    reviews ??= [];
    if (selectSortBy.equals(S.current.Helpful)) {
      return [...reviews];
    } else {
      return reviews.sorted(_sortReview).toList();
    }
  }

  int _sortReview(AnimeReviewHtml a, AnimeReviewHtml b) {
    if (selectSortBy.equals(S.current.Date)) {
      final dateOne = parseDate(a.timeAdded);
      final dateTwo = parseDate(b.timeAdded);
      if (dateOne != null && dateTwo != null) {
        return dateTwo.compareTo(dateOne);
      }
    } else if (selectSortBy.equals(S.current.Score)) {
      final scoreOne = int.tryParse(a.overallRating ?? '');
      final scoreTwo = int.tryParse(b.overallRating ?? '');
      if (scoreOne != null && scoreTwo != null) {
        return scoreTwo.compareTo(scoreOne);
      }
    }
    return -1;
  }

  DateTime? parseDate(String? date) {
    try {
      final format = DateFormat('MMM dd, yyyy');
      return format.parse(date ?? '');
    } catch (e) {
      return null;
    }
  }

  List<Filter> reduceFilters(Iterable<Set<String>> stuff) {
    if (stuff.isEmpty) return [];

    return stuff
        .reduce((t1L, t2L) => t1L.union(t2L))
        .map((e) => Filter(e))
        .toList();
  }

  bool get isHoriz => widget.axis == Axis.horizontal;

  _openShowMore(int index) {
    final modalController =
        PageController(initialPage: index, viewportFraction: .95);
    final _reviews = _sortReviews(reviews?.where(_whereReview).toList());

    showCustomSheet(
      context: context,
      constraints: BoxConstraints(
        maxWidth: double.infinity,
      ),
      child: Padding(
        padding: EdgeInsets.only(top: 40),
        child: PageView.builder(
          itemCount: _reviews.length,
          controller: modalController,
          onPageChanged: (pageIndex) => listController?.scrollToIndex(
            pageIndex,
            duration: const Duration(milliseconds: 200),
          ),
          itemBuilder: (context, i) => SingleChildScrollView(
              child: ReviewWidget(
            _reviews.tryAt(i)!,
            i,
            showMore: false,
            category: widget.category,
            onChildTap: (value) {},
          )),
        ),
      ),
      color: Colors.transparent,
      isScrollControlled: true,
      enableDrag: false,
      elevation: 8,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.axis == Axis.horizontal) {
      return _buildHorizontalReviews();
    } else {
      return _buildVericalReviews();
    }
  }

  Widget _buildHorizontalReviews() {
    if (tags.length <= 1) return _buildHorizontalList();
    return Column(
      children: [
        _buildFilters(),
        SB.h20,
        _buildHorizontalList(),
      ],
    );
  }

  Widget _buildVericalReviews() {
    final filteredReviews = _sortReviews(reviews?.where(_whereReview).toList());
    return CustomScrollView(
      controller: listController,
      slivers: [
        _buildSliverAppBar(filteredReviews),
        SB.lh20,
        SliverToBoxAdapter(
          child: Align(
            alignment: Alignment.center,
            child: title('${filteredReviews.length} ${S.current.Reviews}'),
          ),
        ),
        SB.lh20,
        _buildSliverList(filteredReviews),
        SB.lh80,
      ],
    );
  }

  SliverAppBar _buildSliverAppBar(List<AnimeReviewHtml> filteredReviews) {
    return SliverAppBar(
      toolbarHeight: kToolbarHeight,
      pinned: true,
      floating: true,
      snap: false,
      title: Text(S.current.Reviews),
      actions: [searchIcon(context), _buildPopupMenu(filteredReviews)],
      bottom: PreferredSize(
        preferredSize: Size(double.infinity, kToolbarHeight),
        child: (tags.length > 1 || _availableScores.isNotEmpty)
            ? Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: _buildFilters(),
              )
            : SB.z,
      ),
    );
  }

  PopupMenuBuilder _buildPopupMenu(List<AnimeReviewHtml> filteredReviews) {
    return PopupMenuBuilder(
      menuItems: [
        shareMenuItem()
          ..onTap = () => openShareBuilder(
                context,
                [
                  ShareInput(
                      title: S.current.Url,
                      content: DalPathUtils.browserUrl(_buildDalNode())),
                  ...filteredReviews
                      .map((e) => ShareInput(
                            title: '${S.current.Review_By} ${e.userName}',
                            content: e.reviewText!,
                          ))
                      .toList()
                ],
                S.current.Reviews,
                props: ShareOutputProps(termSpace: '\n'),
              ),
        browserMenuItem()
          ..onTap =
              () => DalPathUtils.launchNodeInBrowser(_buildDalNode(), context),
      ],
    );
  }

  DalNode _buildDalNode() {
    return DalNode(
      category: widget.category,
      id: widget.id,
      dalSubType: DalSubType.reviews,
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 35,
      child: CustomScrollView(
        scrollDirection: Axis.horizontal,
        slivers: [
          SB.lw20,
          if (_availableScores.isNotEmpty) ...[
            SB.lw10,
            SliverWrapper(_scoreSelectButton),
            SB.lw10,
          ],
          SliverWrapper(_sortSelectButton),
          SB.lw10,
          _buildTagsWidget(),
          SB.lw20,
        ],
      ),
    );
  }

  SelectButton get _sortSelectButton {
    return SelectButton(
      options: _sortByOptions,
      selectedOption: selectSortBy,
      useShadowChild: true,
      shadowPadding: EdgeInsets.symmetric(horizontal: 10),
      popupText: S.current.Sort_Reviews_By,
      child: iconAndText(Icons.arrow_upward, selectSortBy, reverse: true),
      onChanged: (value) {
        if (mounted)
          setState(() {
            selectSortBy = value;
          });
      },
    );
  }

  SelectButton get _scoreSelectButton {
    return SelectButton(
      shadowPadding: EdgeInsets.symmetric(horizontal: 10),
      selectedOption: selectedScore,
      options: _availableScores,
      popupText: S.current.Select_A_Score,
      useShadowChild: true,
      showSelectWhenNull: true,
      child: _scoreWidget,
      onChanged: (value) {
        if (mounted)
          setState(() {
            selectedScore = value;
          });
      },
    );
  }

  Widget get _scoreWidget {
    final _starWidget = Container(
      height: 15,
      child: Image.asset("assets/images/star.png"),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (selectedScore.notEquals(S.current.Select)) ...[
          ToolTipButton(
            child: Icon(Icons.close, size: 17.0),
            padding: EdgeInsets.zero,
            message: S.current.Select_A_Score,
            onTap: () {
              if (mounted)
                setState(() {
                  selectedScore = S.current.Select;
                });
            },
          ),
          VerticalDivider(),
        ] else
          SB.w5,
        _starWidget,
        SB.w10,
        if (selectedScore.notEquals(S.current.Select)) ...[
          Text(selectedScore),
        ] else ...[
          VerticalDivider(),
          Icon(Icons.arrow_drop_down)
        ],
      ],
    );
  }

  Widget _buildTagsWidget() {
    return SliverList.builder(
      itemCount: tags.length,
      itemBuilder: (context, index) => _buildTag(index, tags[index]),
    );
  }

  Padding _buildTag(int index, Filter filter) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: ShadowButton(
        child: filter.isSelected
            ? iconAndText(Icons.close, filter.title)
            : title(filter.title, fontSize: 12),
        onPressed: () {
          if (mounted)
            setState(() {
              filter.isSelected = !filter.isSelected;
              selectedTags = tags.where((t) => t.isSelected).toList();
            });
        },
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        // shape: btnBorder,
      ),
    );
  }

  Widget _buildHorizontalList() {
    final _reviews = _sortReviews(reviews?.where(_whereReview).toList());
    final isTablet = ResponsiveHelper.isTabletOrLarger(context);
    return Container(
      height: isTablet ? 430 : 385,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        controller: listController,
        padding: EdgeInsets.symmetric(horizontal: widget.horizPadding + 5),
        itemCount: _reviews.length,
        itemBuilder: (context, index) => _buildReview(index, _reviews[index]),
      ),
    );
  }

  Widget _buildSliverList(List<AnimeReviewHtml> filteredReviews) {
    return SliverList(
        delegate: SliverChildBuilderDelegate(
      (context, index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3.5),
        child: _buildReview(index, filteredReviews[index]),
      ),
      childCount: filteredReviews.length,
    ));
  }

  bool _whereReview(AnimeReviewHtml e) {
    final _score = int.tryParse(selectedScore);
    if (selectedTags.length == 0 && _score == null) return true;
    if (_score != null) {
      final rating = e.overallRating;
      if (rating != null) {
        final found = rating.equals(selectedScore);
        if (found) {
          return true;
        }
      }
    }
    return e.tags!.any((t) => selectedTags.contains(Filter(t)));
  }

  Widget _buildReview(int index, AnimeReviewHtml e) {
    return wrapScrollTag(
      controller: listController!,
      index: index,
      child: ReviewWidget(
        e,
        index,
        onChildTap: (i) => _openShowMore(i),
        axis: widget.axis,
        category: widget.category,
      ),
    );
  }
}

class ReactionBox {
  final String reaction;
  final IconData iconData;
  int count;

  ReactionBox(this.reaction, this.count, this.iconData);

  factory ReactionBox.fromWeb(
      String reaction, String count, IconData iconData) {
    return ReactionBox(reaction, int.tryParse(count) ?? 0, iconData);
  }
}

final reactionBoxes = [
  ReactionBox.fromWeb(S.current.Nice, "0", Icons.thumb_up),
  ReactionBox.fromWeb(S.current.Love_it, "0", Icons.favorite),
  ReactionBox.fromWeb(
      S.current.Funny, "0", Icons.sentiment_very_satisfied_sharp),
  ReactionBox.fromWeb(
      S.current.Confusing, "0", Icons.sentiment_very_dissatisfied_rounded),
  ReactionBox.fromWeb(S.current.Informative, "0", Icons.psychology),
  ReactionBox.fromWeb(S.current.Well_written, "0", Icons.description),
  ReactionBox.fromWeb(S.current.Creative, "0", Icons.lightbulb),
];

class ReviewWidget extends StatelessWidget {
  final AnimeReviewHtml review;
  final int index;
  final bool showMore;
  final Axis axis;
  final ValueChanged<int> onChildTap;
  final String category;
  const ReviewWidget(
    this.review,
    this.index, {
    Key? key,
    required this.onChildTap,
    this.axis = Axis.horizontal,
    this.showMore = true,
    this.category = 'anime',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildReviewWidget(review, context);
  }

  Widget _buildReviewWidget(AnimeReviewHtml review, BuildContext context) {
    final visibleRBs = List<ReactionBox>.from(reactionBoxes);

    if (review.reactionBox!.length == 7) {
      review.reactionBox!.asMap().forEach((key, value) {
        visibleRBs[key]..count = int.tryParse(value) ?? 0;
      });
    }
    visibleRBs.sort((a, b) => b.count.compareTo(a.count));
    visibleRBs.removeWhere((e) => e.count == 0);
    final node = review.relatedNode;
    final isTablet = ResponsiveHelper.isTabletOrLarger(context);
    return Container(
      width: axis == Axis.vertical
          ? double.infinity
          : (showMore ? (isTablet ? 450 : 320) : double.infinity),
      height: axis == Axis.vertical
          ? 400
          : (showMore ? null : MediaQuery.of(context).size.height),
      padding: EdgeInsets.only(
        top: showMore ? 0 : 20,
        bottom: showMore ? 17 : 60,
      ),
      child: Card(
        child: InkWell(
          onTap: showMore ? () => onChildTap(index) : null,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!showMore) ...[
                CloseButton(onPressed: () => Navigator.pop(context)),
              ],
              if (node?.id != null) ...[
                SB.h10,
                ToolTipButton(
                  message: '${S.current.Review_On} ${node!.title}',
                  onTap: () => gotoPage(
                      context: context,
                      newPage: ContentDetailedScreen(
                        category: category,
                        id: node.id,
                      )),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: CachedNetworkImageProvider(
                            node.mainPicture?.large ??
                                node.mainPicture?.medium ??
                                '',
                          ),
                        ),
                        SB.w20,
                        title(S.current.Review_On),
                        SB.w5,
                        Expanded(
                          child: title(
                            node.title,
                            opacity: 1,
                            fontSize: 18,
                            textOverflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              SB.h10,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: starTagsWidget(review)),
                    userDetailsWidget(review, context),
                  ],
                ),
              ),
              SB.h10,
              Expanded(
                child: TranslaterWidget(
                  content: review.reviewText,
                  done: (data) => reviewText(data, context),
                ),
              ),
              if (visibleRBs.length != 0) _showReactions(visibleRBs),
              _showMoreTimeWidget(review, context),
            ],
          ),
        ),
      ),
    );
  }

  Padding _showMoreTimeWidget(AnimeReviewHtml review, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, left: 15, right: 15, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (showMore)
            ToolTipButton(
              message: 'Open the review',
              child: Text(
                'Show more...',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              onTap: () => onChildTap(index),
            ),
          title(review.timeAdded ?? ""),
        ],
      ),
    );
  }

  Column userDetailsWidget(AnimeReviewHtml review, BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AvatarWidget(
            username: review?.userName,
            onTap: () {
              if (review?.userName != null) {
                showUserPage(context: context, username: review.userName!);
              }
            },
            height: 40,
            width: 40,
            url: review?.userPicture,
          ),
          const SizedBox(
            height: 7,
          ),
          Text(
            review?.userName ?? "?",
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12),
          ),
        ]);
  }

  Widget starTagsWidget(AnimeReviewHtml review) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              height: 22,
              child: Image.asset("assets/images/star.png"),
            ),
            const SizedBox(
              width: 5,
            ),
            title(review.overallRating ?? "?", fontSize: 24),
          ],
        ),
        SB.h10,
        if (!nullOrEmpty(review.tags))
          ...review.tags!
              .map((e) => title(e, fontSize: 11, opacity: .6))
              .toList()
      ],
    );
  }

  Widget reviewText(String? reviewText, BuildContext context) {
    final style = TextStyle(
        fontSize: ResponsiveHelper.isTabletOrLarger(context) ? 15 : 13);
    final textWidget = showMore
        ? Text(
            reviewText ?? "?",
            overflow: TextOverflow.fade,
            style: style,
          )
        : SelectableText(reviewText ?? "?", style: style);
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 8, 15, 0),
        child: textWidget,
      ),
    );
  }

  Widget _showReactions(List<ReactionBox> visibleRBs) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Container(
        height: 20,
        child: ListView.builder(
          itemCount: visibleRBs.length,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 5),
          itemBuilder: (context, index) {
            final item = visibleRBs.elementAt(index);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: ToolTipButton(
                message: item.reaction,
                usePadding: true,
                padding: const EdgeInsets.symmetric(horizontal: 7),
                child: iconAndText(item.iconData, item.count.toString()),
              ),
            );
          },
        ),
      ),
    );
  }
}

class ReviewGeneratedSummary extends StatefulWidget {
  final List<AnimeReviewHtml> reviews;
  final Future<ContentReviewSummary?>? reviewSummaryFuture;
  const ReviewGeneratedSummary({
    super.key,
    required this.reviews,
    this.reviewSummaryFuture,
  });

  @override
  State<ReviewGeneratedSummary> createState() => _ReviewGeneratedSummaryState();
}

class _ReviewGeneratedSummaryState extends State<ReviewGeneratedSummary> {
  late Future<ContentReviewSummary?> reviewSummaryFuture;
  bool _hasReviewSummary = false;

  List<String> get reviewsText =>
      widget.reviews.map((e) => e.reviewText ?? '').toList();

  @override
  void initState() {
    super.initState();
    if (widget.reviewSummaryFuture != null) {
      _hasReviewSummary = true;
      reviewSummaryFuture = widget.reviewSummaryFuture!;
    } else {
      _hasReviewSummary = false;
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _handlePostFrameCallback());
    }
  }

  void _handlePostFrameCallback() {
    DalApi.i.isFeatureEnabled(FeatureFlag.aireviews).then((value) {
      if (value) {
        _hasReviewSummary = true;
        reviewSummaryFuture = DalApi.i.getReviewsSummary(reviewsText);
        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasReviewSummary) return SB.z;
    if (widget.reviewSummaryFuture == null) {
      return _buildIcon();
    }
    return StateFullFutureWidget(
      done: (sp) => _buildSummary(sp.data),
      loadingChild: _reviewAnimation(),
      future: () => reviewSummaryFuture,
    );
  }

  Widget _buildIcon() {
    final toolTipButton = ToolTipButton(
      message: S.current.Review_summary,
      child: AvatarWidget(
        url: 'assets/images/gemini.png',
        width: 30,
        height: 30,
        onLongPress: _onIconTap,
        isNetworkImage: false,
        onTap: _onIconTap,
      ),
    );
    _showTooltip(toolTipButton);
    return toolTipButton;
  }

  void _showTooltip(ToolTipButton toolTipButton) async {
    if (await CacheManager.instance.isFirstTime('review_summary')) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        toolTipButton.showToolTip();
      });
    } else {
      CacheManager.instance.setFirstTime('review_summary');
    }
  }

  void _onIconTap() {
    showAdaptiveDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(S.current.Review_Summary),
            contentPadding: EdgeInsets.zero,
            backgroundColor: Theme.of(context).colorScheme.surface,
            content: SingleChildScrollView(
              child: Container(
                width: ResponsiveHelper.isTabletOrLarger(context) ? 500 : null,
                child: ReviewGeneratedSummary(
                  reviews: widget.reviews,
                  reviewSummaryFuture: reviewSummaryFuture,
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(S.current.Close),
              ),
            ],
          );
        });
  }

  Widget _reviewAnimation() {
    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          Center(
            child: SizedBox(
              height: 320,
              width: 200,
              child: InterlaceAnimation(
                  colorScheme: Theme.of(context).colorScheme),
            ),
          ),
          Center(
            child: Text(
              S.current.Generating,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(ContentReviewSummary? data) {
    if (data == null || data.verdict.isEmpty) return SB.z;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: _summaryContent(data),
    );
  }

  Widget _summaryContent(ContentReviewSummary data) {
    final verdictWidget = _reviewItem(
      ReviewItem(title: S.current.Verdict, description: data.verdict),
      ToolTipButton(
          child: Icon(Icons.info_outline),
          message: S.current.Review_Summary_Desc),
      true,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SB.h10,
        verdictWidget,
        ...data.pros
            .map((item) => _reviewItem(item, _additionalText(S.current.Pros))),
        ...data.cons
            .map((item) => _reviewItem(item, _additionalText(S.current.Cons))),
        SB.h10,
      ],
    );
  }
}

Widget _reviewItem(
  ReviewItem item,
  Widget additional, [
  bool defaultExpanded = false,
]) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5.0),
    child: Accordion(
      title: item.title,
      atStartExpanded: defaultExpanded,
      isOpen: defaultExpanded,
      additional: [additional],
      child: TranslaterWidget(
        content: item.description,
        done: (data) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Text(data ?? item.description, style: TextStyle(fontSize: 13)),
        ),
      ),
    ),
  );
}

SizedBox _additionalText(String additional) {
  return SizedBox(
    height: 30.0,
    child: PlainButton(
      padding: EdgeInsets.zero,
      onPressed: () {},
      child: Text(additional),
    ),
  );
}
