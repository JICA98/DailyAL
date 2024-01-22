import 'package:auto_size_text/auto_size_text.dart';
import 'package:dailyanimelist/api/credmal.dart';
import 'package:dailyanimelist/api/malforum.dart';
import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/screens/plainscreen.dart';
import 'package:dailyanimelist/widgets/forum/nextprev.dart';
import 'package:dailyanimelist/widgets/headerwidget.dart';
import 'package:dailyanimelist/widgets/forum/postwidget.dart';
import 'package:dailyanimelist/widgets/home/accordion.dart';
import 'package:dailyanimelist/widgets/home/bookmarks_widget.dart';
import 'package:dailyanimelist/widgets/selectbottom.dart';
import 'package:dailyanimelist/widgets/shimmecolor.dart';
import 'package:dailyanimelist/widgets/web/c_webview.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:share/share.dart';
import 'package:shimmer/shimmer.dart';

import 'generalsearchscreen.dart';

class ForumPostsScreen extends StatefulWidget {
  final ForumTopicsData? topic;
  final bool isEmptyTopic;
  final VoidCallback? onUiChange;
  final bool showOnlyPosts;
  const ForumPostsScreen(
      {Key? key,
      this.topic,
      this.isEmptyTopic = false,
      this.showOnlyPosts = false,
      this.onUiChange})
      : super(key: key);
  @override
  _ForumPostsScreenState createState() => _ForumPostsScreenState();
}

class _ForumPostsScreenState extends State<ForumPostsScreen> {
  final DateFormat dateFormat = new DateFormat('EEE, MMM d, yyyy');
  final postLimit = 14;
  int pageIndex = 0;
  AutoScrollController? _autoScrollController;
  ForumTopicsData? topic;
  SearchStage loadcontent = SearchStage.started;
  ForumTopicsData sampleTopic = ForumTopicsData(
      title: "What anime do yo like the most?",
      createdAt: DateTime.now(),
      createdBy: ForumUser(name: "OV3RKILL"),
      numberOfPosts: 0);
  String sortType = S.current.Oldest;
  List<String> sortTypeValues = [S.current.Oldest, S.current.Newest];
  bool enableShare = false;
  Set<ForumTopicPost> selectedPosts = {};

  @override
  void initState() {
    super.initState();
    topic = widget.topic;
    _autoScrollController = AutoScrollController(
      viewportBoundaryGetter: () =>
          Rect.fromLTRB(0, 100, 0, MediaQuery.of(context).padding.bottom),
    );
  }

  Future<ForumTopicData?> getForumTopic(
      {int offset = 0, bool fromCache = true}) async {
    // await Future.delayed(const Duration(milliseconds: 500));
    ForumTopicData? _topicDetailed;
    try {
      _topicDetailed = await MalForum.getForumTopicDetail(topic!.id!,
          offset: offset, fromCache: fromCache, limit: postLimit);

      if (shouldUpdateContent(result: _topicDetailed, timeinHoursD: 0.5)) {
        _topicDetailed = await MalForum.getForumTopicDetail(topic!.id!,
            offset: offset, fromCache: false, limit: postLimit);
      }
    } catch (e) {
      logDal(e);
      showToast(S.current.Couldnt_connect_network);
    }
    return _topicDetailed;
  }

  void changePage(int index) {
    if (enableShare) return;
    _autoScrollController
        ?.animateTo(0,
            curve: Curves.ease, duration: Duration(milliseconds: 600))
        .then((value) {
      if (mounted)
        setState(() {
          pageIndex = index;
        });
    });
  }

  void changeSortType(String value) {
    if (enableShare) return;
    if (mounted)
      setState(() {
        sortType = value;
      });
  }

  @override
  void dispose() {
    super.dispose();
    _autoScrollController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ..._bookmarkFloating(),
            _buildFloatingAction(),
          ],
        ),
      ),
      body: WillPopScope(
        child: futurePostCustomScrollViewBuilder(),
        onWillPop: () async {
          if (enableShare) {
            selectedPosts = {};
            enableShare = false;
            setState(() {});
            return false;
          }
          if (widget.onUiChange != null) {
            widget.onUiChange!();
          }
          return true;
        },
      ),
    );
  }

  List<Widget> _bookmarkFloating() {
    if (topic?.id != null)
      return [
        BookMarkFloatingButton(
            type: BookmarkType.forumTopics, id: topic!.id!, data: topic),
        SB.h10,
      ];
    return [];
  }

  Widget _buildFloatingAction() {
    return FloatingActionButton(
      onPressed: topic?.id == null
          ? null
          : () => launchWebView(
              "${CredMal.htmlEnd}forum/?action=message&topic_id=${widget.topic!.id}"),
      child: Icon(Icons.post_add),
    );
  }

  Widget get sliverHeader {
    if (widget.showOnlyPosts) return SB.lz;
    return (topic == null || widget.isEmptyTopic)
        ? SB.lz
        : headerWidget(forumTopic: topic);
  }

  Widget _customScrollView(List<Widget> slivers) {
    return Scrollbar(
      child: CustomScrollView(
        controller: _autoScrollController,
        slivers: slivers,
      ),
    );
  }

  Widget futurePostCustomScrollViewBuilder() {
    logDal(((topic?.numberOfPosts ?? 0) / postLimit).ceil());
    int offset = (pageIndex -
                (sortType.equals(S.current.Newest)
                    ? (((topic?.numberOfPosts ?? 0) - postLimit) / postLimit)
                        .ceil()
                    : 0))
            .abs() *
        postLimit;
    return Padding(
      padding: EdgeInsets.only(top: 0),
      child: FutureBuilder<ForumTopicData?>(
        future: getForumTopic(
            fromCache: sortType.equals(S.current.Newest)
                ? (pageIndex != 0)
                : (widget.topic?.numberOfPosts != null
                    ? (pageIndex !=
                        ((widget.topic!.numberOfPosts! / postLimit).ceil() - 1))
                    : true),
            offset: (pageIndex -
                        (sortType.equals(S.current.Newest)
                            ? (((topic?.numberOfPosts ?? 0) - postLimit) /
                                    postLimit)
                                .ceil()
                            : 0))
                    .abs() *
                postLimit),
        builder: (context, snapshot) {
          logDal(snapshot.connectionState);
          if (snapshot.hasData &&
              (snapshot.connectionState == ConnectionState.done ||
                  enableShare)) {
            return snapshot.data?.posts == null || snapshot.data!.posts!.isEmpty
                ? _customScrollView([
                    sliverHeader,
                    _sliverWidgets([showNoContent()]),
                    SB.h120,
                  ])
                : _customScrollView([
                    sliverHeader,
                    _sliverWidgets([pollWidget(snapshot.data?.poll)]),
                    SB.lh10,
                    PostWidgetBuilder(
                      offset: offset,
                      postLimit: postLimit,
                      postList: snapshot.data!.posts,
                      controller: _autoScrollController!,
                      reverse: sortType.equals(S.current.Newest),
                      showOnlyPosts: widget.showOnlyPosts,
                      onPostsSelected: (_selectedPosts) {
                        selectedPosts = _selectedPosts;
                        if (_selectedPosts.isNotEmpty) {
                          setState(() {
                            enableShare = true;
                          });
                        } else {
                          setState(() {
                            enableShare = false;
                          });
                        }
                      },
                    ),
                    _sliverWidgets([
                      (snapshot.data?.posts != null)
                          ? nextpreviousbtn()
                          : const SizedBox(),
                      SB.h120,
                    ]),
                  ]);
          } else {
            return _customScrollView([
              sliverHeader,
              _sliverWidgets([
                SB.h30,
                loadingCenter(),
                SB.h120,
              ])
            ]);
          }
        },
      ),
    );
  }

  Widget _sliverWidgets(List<Widget> children) {
    return SliverList(delegate: SliverChildListDelegate(children));
  }

  Widget shimmerColor({required Widget child}) {
    var colors = ShimmerColors.fromContext(context);
    return Shimmer.fromColors(
      child: child,
      baseColor: colors.baseColor,
      highlightColor: colors.highlightColor,
    );
  }

  Widget pollWidget(ForumTopicPoll? poll) {
    double totalVotes = 1;
    if (poll?.options != null && poll!.options!.isNotEmpty) {
      totalVotes +=
          poll.options!.map((e) => e.votes!).reduce((v1, v2) => v1 + v2);
    }
    return poll?.question == null
        ? const SizedBox()
        : Padding(
            padding: EdgeInsets.symmetric(vertical: 7, horizontal: 14),
            child: Material(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 5,
                    ),
                    Accordion(
                      child: ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) => Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 17, vertical: 7),
                          child: Container(
                            width: double.infinity,
                            constraints: BoxConstraints(minHeight: 30),
                            child: optionWidget(
                                options: poll!.options!.elementAt(index),
                                totalVotes: totalVotes),
                          ),
                        ),
                        itemCount: poll!.options!.length,
                      ),
                      title: "${S.current.Poll_Question}: ${poll.question}",
                    )
                  ],
                ),
              ),
            ),
          );
  }

  Widget optionWidget(
      {required ForumTopicOptions options, double totalVotes = 1.0}) {
    double votes = (options.votes ?? 0.0) + 0.0;
    logDal((votes / totalVotes) * 100);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: title(options.text! +
              " (${((votes / totalVotes) * 100).toStringAsFixed(2)} %)"),
        ),
        Container(
            height: 35,
            width: 35,
            child: Stack(
              children: [
                Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    value: (votes / totalVotes),
                  ),
                ),
                Center(child: title("${votes.toInt()}")),
              ],
            )),
      ],
    );
  }

  PreferredSizeWidget showPageWidget({required int noOfPosts}) {
    return PreferredSize(
      preferredSize: Size.fromHeight(50),
      child: Padding(
        padding: EdgeInsets.only(top: 10, bottom: 10),
        child: HeaderWidget(
          selectedIndex: pageIndex,
          driftOffset: 80.0,
          shouldAnimate: false,
          defaultBgColor: Colors.transparent,
          header: List.generate(
                  (noOfPosts / postLimit).ceil(), (i) => (i + 1).toString())
              .toList(),
          onPressed: (value) {
            changePage(value);
          },
          fontSize: 16,
        ),
      ),
    );
  }

  Widget nextpreviousbtn() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30.0),
      child: NextPreviousRow(
        onPrevious: pageIndex == 0
            ? null
            : () {
                if (pageIndex > 0) changePage(pageIndex - 1);
              },
        onNext: (topic?.numberOfPosts != null &&
                (pageIndex >= (topic!.numberOfPosts! / postLimit).ceil() - 1))
            ? null
            : () {
                changePage(pageIndex + 1);
              },
      ),
    );
  }

  bool get showBottom =>
      !(topic?.numberOfPosts != null && topic!.numberOfPosts! <= postLimit);

  Widget headerWidget({ForumTopicsData? forumTopic}) {
    return SliverLayoutBuilder(builder: (context, c) {
      return SliverAppBar(
        pinned: true,
        floating: false,
        snap: false,
        automaticallyImplyLeading: selectedPosts.length <= 0,
        title: selectedPosts.length > 0
            ? _sharePrefix
            : (c.scrollOffset > 120 ? Text(forumTopic?.title ?? '') : null),
        actions: (selectedPosts.length > 0)
            ? _shareWidget()
            : [
                if (topic?.numberOfPosts != null)
                  SelectButton(
                    popupText: S.current.Order_by,
                    child: Icon(Icons.sort),
                    options: sortTypeValues,
                    selectedOption: sortType,
                    onChanged: (value) => changeSortType(value),
                  ),
                searchIconButton(context),
                SB.w20,
              ],
        expandedHeight: showBottom ? 270 : 230,
        bottom: showBottom
            ? showPageWidget(noOfPosts: topic?.numberOfPosts ?? 0)
            : null,
        flexibleSpace:
            FlexibleSpaceBar(background: headerBackground(forumTopic)),
      );
    });
  }

  Widget headerBackground(ForumTopicsData? forumTopic) {
    return FlexibleSpaceBar(
      background: Padding(
        padding: const EdgeInsets.only(
            top: 100.0, left: 15, right: 15, bottom: 20.0),
        child: ForumPostHeader(
          dateFormat: dateFormat,
          forumTopic: forumTopic,
          sizedbox: SB.h40,
        ),
      ),
    );
  }

  Widget get _sharePrefix {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              selectedPosts = {};
              enableShare = false;
            });
          },
          icon: Icon(Icons.cancel_rounded),
        ),
        SB.w20,
        Text("${selectedPosts.length} selected")
      ],
    );
  }

  List<Widget> _shareWidget() {
    return [
      IconButton(
        onPressed: () {
          Clipboard.setData(ClipboardData(text: getShareableContent()));
          showToast(S.current.Copied_to_Clipboard);
          setState(() {
            selectedPosts = {};
            enableShare = false;
          });
        },
        icon: Icon(selectedPosts.length > 1 ? Icons.copy_all : Icons.copy),
      ),
      IconButton(
        onPressed: () async {
          await Share.share(getShareableContent(),
              subject: "MyAnimeList Forums - DailyAnimeList");
          setState(() {
            selectedPosts = {};
            enableShare = false;
          });
        },
        icon: Icon(Icons.share),
      ),
      SB.w20,
    ];
  }

  String getShareableContent() {
    return selectedPosts.length == 1
        ? selectedPosts.first.toString()
        : "${S.current.No_of_Posts}: ${selectedPosts.length} \n" +
            selectedPosts.map((e) => e.toString()).reduce((p1, p2) => p1 + p2);
  }
}

class ForumPostHeader extends StatelessWidget {
  const ForumPostHeader({
    super.key,
    required this.dateFormat,
    this.forumTopic,
    this.titleStyle,
    this.sizedbox,
  });
  final ForumTopicsData? forumTopic;
  final DateFormat dateFormat;
  final TextStyle? titleStyle;
  final SizedBox? sizedbox;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    String? formattedDate;
    if (forumTopic?.lastPostCreatedAt != null) {
      formattedDate = dateFormat.format(forumTopic!.lastPostCreatedAt!);
    } else {
      if (forumTopic is ForumHtml) {
        var _topic = forumTopic as ForumHtml;
        if (_topic.lastPostTime != null) formattedDate = _topic.lastPostTime!;
      }
    }
    final lastPostTime =
        '${formattedDate != null ? ' · ${formattedDate}' : ''}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 75.0),
          child: AutoSizeText(
            forumTopic?.title ?? '',
            style: titleStyle ?? textTheme.titleLarge,
          ),
        ),
        sizedbox ?? SB.h30,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AutoSizeText(
              '${forumTopic?.createdBy?.name ?? ""}$lastPostTime',
              style: textTheme.bodySmall,
              textAlign: TextAlign.start,
            ),
            AutoSizeText(
              (forumTopic?.numberOfPosts?.toString() ?? "0") + " Posts",
              style: textTheme.bodySmall,
              textAlign: TextAlign.end,
            )
          ],
        ),
        SB.h10,
      ],
    );
  }
}
