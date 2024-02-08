import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:dailyanimelist/api/auth/auth.dart';
import 'package:dailyanimelist/api/dalapi.dart';
import 'package:dailyanimelist/api/malapi.dart';
import 'package:dailyanimelist/api/maluser.dart';
import 'package:dailyanimelist/enums.dart';
import 'package:dailyanimelist/extensions.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/pages/animedetailed/intereststackwidget.dart';
import 'package:dailyanimelist/pages/animedetailed/synopsiswidget.dart';
import 'package:dailyanimelist/screens/characterscreen.dart';
import 'package:dailyanimelist/screens/clubscreen.dart';
import 'package:dailyanimelist/screens/contentdetailedscreen.dart';
import 'package:dailyanimelist/screens/featurescreen.dart';
import 'package:dailyanimelist/screens/forumposts.dart';
import 'package:dailyanimelist/screens/generalsearchscreen.dart';
import 'package:dailyanimelist/screens/plainscreen.dart';
import 'package:dailyanimelist/user/hompagepref.dart';
import 'package:dailyanimelist/user/user.dart';
import 'package:dailyanimelist/widgets/common/image_preview.dart';
import 'package:dailyanimelist/widgets/custombutton.dart';
import 'package:dailyanimelist/widgets/customfuture.dart';
import 'package:dailyanimelist/widgets/featured/tagswidget.dart';
import 'package:dailyanimelist/widgets/home/animecard.dart';
import 'package:dailyanimelist/widgets/home/nodebadge.dart';
import 'package:dailyanimelist/widgets/listsortfilter.dart';
import 'package:dailyanimelist/widgets/web/c_webview.dart';
import 'package:dal_commons/commons.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../constant.dart';
import '../../main.dart';
import '../avatarwidget.dart';

enum IBType { left, middle, right, all, loading }

class ContentListWidget extends StatelessWidget {
  final List<BaseNode> contentList;
  final String category;
  final bool showIndex;
  final VoidCallback? onContentUpdate;
  final VoidCallback? onStatisticsUpdate;
  final bool updateCacheOnEdit;
  final bool showSelfScoreInsteadOfStatus;
  final bool showStatus;
  final bool showImage;
  final bool showEdit;
  final double aspectRatio;
  final double imageAspectRatio;
  final EdgeInsetsGeometry padding;
  final bool showNoMoreAuth;
  final bool showBackgroundImage;
  final bool showOnlyEdit;
  final DisplayType? displayType;
  final bool returnSlivers;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final void Function(int index, dynamic node)? onClose;
  final double cardHeight;
  final double cardWidth;

  const ContentListWidget({
    Key? key,
    required this.contentList,
    this.category = "anime",
    this.updateCacheOnEdit = false,
    this.onContentUpdate,
    this.padding = EdgeInsets.zero,
    this.showImage = true,
    this.aspectRatio = 3,
    this.imageAspectRatio = .65,
    this.showStatus = true,
    this.showEdit = true,
    this.showNoMoreAuth = false,
    this.onClose,
    this.onStatisticsUpdate,
    this.returnSlivers = true,
    this.displayType = DisplayType.list_vert,
    this.showOnlyEdit = false,
    this.showBackgroundImage = true,
    this.showIndex = false,
    this.cardHeight = 180.0,
    this.cardWidth = 180.0,
    this.shrinkWrap = false,
    this.physics,
    this.showSelfScoreInsteadOfStatus = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (returnSlivers) {
      return SliverList(
        key: PageStorageKey(key),
        delegate: SliverChildListDelegate(_buildSliverContent),
      );
    } else {
      if (displayType == DisplayType.grid) {
        return Padding(
          padding: padding,
          child: _wrapContentList(),
        );
      } else {
        return ListView(
          shrinkWrap: shrinkWrap,
          physics: physics,
          scrollDirection: displayType == DisplayType.list_vert
              ? Axis.vertical
              : Axis.horizontal,
          padding: padding,
          children: _buildContentList,
        );
      }
    }
  }

  List<Widget> get _buildSliverContent {
    return [
      Padding(padding: padding),
      if (displayType == DisplayType.grid)
        _wrapContentList()
      else
        ..._buildContentList,
      showMoreNoAuth()
    ];
  }

  Wrap _wrapContentList() {
    return Wrap(
      direction: Axis.horizontal,
      children: _buildContentList,
      spacing: 4.0,
      alignment: WrapAlignment.center,
      runSpacing: 15.0,
    );
  }

  List<ContentAllWidget> get _buildContentList {
    return contentList
        .getRange(
            0,
            !logicNoMore()
                ? (contentList?.length ?? 0) % 40
                : (contentList?.length ?? 0))
        .toList()
        .asMap()
        .entries
        .map((entry) {
      dynamic dynContent = entry.value;
      dynamic _myListStatus = listStatus(dynContent, category);

      return ContentAllWidget(
        key: Key(MalAuth.codeChallenge(10)),
        dynContent: dynContent,
        myListStatus: _myListStatus,
        index: entry.key,
        aspectRatio: aspectRatio,
        category: category,
        imageAspectRatio: imageAspectRatio,
        onContentUpdate: onContentUpdate,
        showBackgroundImage: showBackgroundImage,
        showEdit: showEdit,
        showImage: showImage,
        showIndex: showIndex,
        showStatus: showStatus,
        updateCacheOnEdit: updateCacheOnEdit,
        onStatisticsUpdate: onStatisticsUpdate,
        showOnlyEdit: showOnlyEdit,
        displayType: displayType ?? DisplayType.list_vert,
        cardHeight: cardHeight,
        cardWidth: cardWidth,
        onClose: onClose != null ? () => onClose!(entry.key, dynContent) : null,
        showSelfScoreInsteadOfStatus: showSelfScoreInsteadOfStatus,
      );
    }).toList();
  }

  bool logicNoMore() {
    return user.status == AuthStatus.AUTHENTICATED || !showNoMoreAuth;
  }

  Widget showMoreNoAuth() {
    if (logicNoMore()) {
      return const SizedBox();
    }
    return Padding(
      padding: EdgeInsets.only(top: 30, left: 20, right: 20),
      child: PlainButton(
        padding: EdgeInsets.symmetric(vertical: 15),
        onPressed: () => gotoAuthPage(),
        child: Text(S.current.Login_to_See_more),
      ),
    );
  }
}

listStatus(
  dynContent,
  String category,
) {
  dynamic _myListStatus;
  try {
    if (category.equals("anime")) {
      _myListStatus = (dynContent?.myListStatus as MyAnimeListStatus);
    } else if (category.equals("manga")) {
      _myListStatus = (dynContent?.myListStatus as MyMangaListStatus);
    }
    if (_myListStatus?.updatedAt == null) {
      _myListStatus = category.equals("anime")
          ? (dynContent?.content?.myListStatus as MyAnimeListStatus)
          : (dynContent?.content?.myListStatus as MyMangaListStatus);
    }
  } catch (e) {}
  return _myListStatus;
}

final _axisTileSizeMap = {
  2: HomePageTileSize.xl,
  3: HomePageTileSize.m,
  4: HomePageTileSize.xs,
};

Widget _baseBaseNode(
  String category,
  BaseNode node,
  index,
  DisplayType displayType, {
  bool showEdit = true,
  HomePageTileSize? homePageTileSize,
  DisplaySubType? displaySubType,
  double? gridHeight,
  bool updateCacheOnEdit = false,
  bool showTime = false,
}) {
  return ContentAllWidget(
    key: Key(MalAuth.codeChallenge(10)),
    dynContent: node,
    myListStatus: listStatus(node, category),
    category: category,
    aspectRatio: 2.35,
    imageAspectRatio: 0.5,
    showBackgroundImage: false,
    displayType: displayType,
    index: index,
    showEdit: showEdit,
    homePageTileSize: homePageTileSize,
    displaySubType: displaySubType,
    gridHeight: gridHeight,
    updateCacheOnEdit: updateCacheOnEdit,
    showTime: showTime,
  );
}

Widget buildBaseNodePageItem(
  String category,
  PageItem<BaseNode> item,
  int index,
  DisplayType displayType, {
  bool showEdit = true,
  HomePageTileSize? homePageTileSize,
  DisplaySubType? displaySubType,
  required int gridAxisCount,
  required double gridHeight,
  bool updateCacheOnEdit = false,
  bool showTime = false,
}) {
  Widget fromItem(int index, BaseNode node, [HomePageTileSize? tileSize]) {
    return _baseBaseNode(
      category,
      node,
      index,
      displayType,
      showEdit: showEdit,
      homePageTileSize: tileSize,
      displaySubType: displaySubType,
      gridHeight: gridHeight,
      updateCacheOnEdit: updateCacheOnEdit,
      showTime: showTime,
    );
  }

  if (displayType == DisplayType.list_vert) {
    return fromItem(index, item.rowItems.first);
  } else {
    homePageTileSize = _axisTileSizeMap[gridAxisCount];
    return SizedBox(
      height: gridHeight,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 7.0),
        child: Row(
          children: item.rowItems
              .asMap()
              .entries
              .map((e) =>
                  Expanded(child: fromItem(e.key, e.value, homePageTileSize)))
              .toList(),
        ),
      ),
    );
  }
}

Widget horizontalList({
  required String category,
  required List<BaseNode> items,
  double? height,
  bool showTime = false,
  EdgeInsetsGeometry? padding,
}) {
  return ContentListWithDisplayType(
    category: category,
    items: items,
    showTime: showTime,
    padding: padding,
    sortFilterDisplay: SortFilterDisplay(
      sort: SortOption(name: '_', value: '_'),
      displayOption: DisplayOption(
        displayType: DisplayType.list_horiz,
        displaySubType: DisplaySubType.compact,
        gridHeight: height ??
            tileMap.tryAt(user.pref.homePageTileSize)!.containerHeight,
        gridCrossAxisCount: 1,
      ),
      filterOutputs: {},
    ),
    tileSize: user.pref.homePageTileSize,
  );
}

class ContentListWithDisplayType extends StatelessWidget {
  final String category;
  final List<BaseNode> items;
  final SortFilterDisplay sortFilterDisplay;
  final bool showTime;
  final HomePageTileSize? tileSize;
  final EdgeInsetsGeometry? padding;
  const ContentListWithDisplayType({
    super.key,
    required this.category,
    required this.items,
    required this.sortFilterDisplay,
    this.showTime = false,
    this.tileSize,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final List<PageItem<BaseNode>> pageItems;
    DisplayType displayType = sortFilterDisplay.displayOption.displayType;
    final gridAxisCount = sortFilterDisplay.displayOption.gridCrossAxisCount;
    final gridHeight = sortFilterDisplay.displayOption.gridHeight;
    final displaySubType = sortFilterDisplay.displayOption.displaySubType;
    final isHoriz =
        sortFilterDisplay.displayOption.displayType == DisplayType.list_horiz;

    if (displayType == DisplayType.list_vert) {
      pageItems = items.map((e) => PageItem([e])).toList();
    } else {
      pageItems = items.chunked(gridAxisCount).map((e) => PageItem(e)).toList();
    }
    Widget buildItem(int index, PageItem<BaseNode> item) {
      return conditional(
        on: isHoriz,
        parent: (child) => SizedBox(
          width: gridHeight * 2 / 3,
          child: child,
        ),
        child: buildBaseNodePageItem(
          category,
          item,
          index,
          displayType,
          gridAxisCount: gridAxisCount,
          gridHeight: gridHeight,
          displaySubType: displaySubType,
          homePageTileSize: tileSize ?? _axisTileSizeMap[gridAxisCount],
          updateCacheOnEdit: true,
          showTime: showTime,
        ),
      );
    }

    if (isHoriz) {
      return Container(
        height: gridHeight,
        child: ListView.builder(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 15),
          scrollDirection: Axis.horizontal,
          itemCount: pageItems.length,
          itemBuilder: (context, index) => buildItem(index, pageItems[index]),
        ),
      );
    }
    return SliverList.builder(
      itemBuilder: (context, index) => buildItem(index, pageItems[index]),
      itemCount: pageItems.length,
    );
  }
}

class ContentAllWidget extends StatefulWidget {
  final String category;
  final dynamic dynContent;
  final bool showImage;
  final Function? onContentUpdate;
  final double imageAspectRatio;
  final bool showBackgroundImage;
  final bool updateCacheOnEdit;
  final bool showEdit;
  final double aspectRatio;
  final bool showIndex;
  final bool showStatus;
  final VoidCallback? onStatisticsUpdate;
  final bool showOnlyEdit;
  final HomePageTileSize? homePageTileSize;
  final DisplayType displayType;
  final dynamic myListStatus;
  final double cardHeight;
  final double? gridHeight;
  final VoidCallback? onClose;
  final double cardWidth;
  final int? index;
  final bool showSelfScoreInsteadOfStatus;
  final DisplaySubType? displaySubType;
  final bool showTime;

  const ContentAllWidget({
    Key? key,
    this.category = "anime",
    this.updateCacheOnEdit = false,
    this.onContentUpdate,
    this.showImage = true,
    this.aspectRatio = 3,
    this.imageAspectRatio = .65,
    this.showStatus = true,
    this.onStatisticsUpdate,
    this.showEdit = true,
    this.showBackgroundImage = true,
    this.showIndex = false,
    this.showOnlyEdit = false,
    this.cardHeight = 180.0,
    this.cardWidth = 180.0,
    this.onClose,
    this.displayType = DisplayType.list_vert,
    @required this.dynContent,
    @required this.myListStatus,
    required this.index,
    this.showSelfScoreInsteadOfStatus = false,
    this.homePageTileSize,
    this.displaySubType,
    this.gridHeight,
    this.showTime = false,
  }) : super(key: key);

  @override
  _ContentAllWidgetState createState() => _ContentAllWidgetState();
}

String getNodeTitle(Node? detailed) {
  try {
    AlternateTitles? alternateTitles;
    if (detailed is AnimeDetailed) {
      alternateTitles = detailed.alternateTitles;
    } else if (detailed is MangaDetailed) {
      alternateTitles = detailed.alternateTitles;
    }
    if (alternateTitles != null &&
        user.pref.preferredAnimeTitle != TitleLang.ro) {
      final en = alternateTitles.en;
      final ja = alternateTitles.ja;
      if (user.pref.preferredAnimeTitle == TitleLang.en &&
          en != null &&
          en.isNotBlank) {
        return en;
      }
      if (user.pref.preferredAnimeTitle == TitleLang.ja &&
          ja != null &&
          ja.isNotBlank) {
        return ja;
      }
    }
  } catch (e) {}
  return detailed?.title ?? "??";
}

onNodeTap(dynamic content, String category, BuildContext context,
    {Function? onUpdateContent}) {
  if (contentTypes.contains(category)) {
    gotoPage(
        context: context,
        newPage: ContentDetailedScreen(
          category: category,
          node: content,
          id: content?.id,
          onUpdateList: () {
            if (onUpdateContent != null) onUpdateContent();
          },
        ));
  } else {
    if (category.equals("video")) {
      launchWebView(content?.videoUrl);
    } else if (category.equals("user")) {
      showUserPage(context: context, username: content?.title);
    } else if (category.equals("forum")) {
      gotoPage(
          context: context,
          newPage: ForumPostsScreen(
            topic: ForumTopicsData(
              id: content?.id,
              title: content?.title,
            ),
          ));
    } else if (category.equals("club")) {
      gotoPage(
          context: context,
          newPage: ClubScreen(
            clubHtml: ClubHtml(
              clubId: content?.id,
              clubName: content?.title,
              imgUrl: content?.mainPicture?.large,
            ),
          ));
    } else if (["featured", "news"].contains(category)) {
      gotoPage(
          context: context,
          newPage: FeaturedScreen(
            category: category,
            id: content?.id,
            featureTitle: content?.title,
            imgUrl: content?.mainPicture?.large,
          ));
    } else
      gotoPage(
          context: context,
          newPage: CharacterScreen(
            charaCategory: category,
            id: content?.id,
          ));
  }
}

class _ContentAllWidgetState extends State<ContentAllWidget>
    with AutomaticKeepAliveClientMixin {
  dynamic myListStatus;
  bool modifyListStatus = false;

  @override
  void initState() {
    super.initState();
    myListStatus = widget.myListStatus;
  }

  get id => widget.dynContent?.content?.id;

  @override
  Widget build(BuildContext context) {
    final String nodeTitle = getNodeTitle(widget.dynContent?.content);
    NodeStatusValue nsv = NodeStatusValue.fromListStatus(myListStatus);
    return ((widget.displayType == DisplayType.grid ||
                widget.displayType == DisplayType.list_horiz) &&
            contentTypes.contains(widget.category))
        ? CFutureBuilder(
            future: DalApi.i.scheduleForMalIds,
            loadingChild: SB.z,
            done: (AsyncSnapshot<Map<int, ScheduleData>> data) => AnimeGridCard(
              scheduleData: data.data?[id],
              node: widget.dynContent?.content,
              category: widget.category,
              showEdit: widget.showEdit,
              myListStatus: myListStatus,
              showCardBar: true,
              updateCache: false,
              showGenres: true,
              showTime: widget.showTime,
              height: widget.cardHeight,
              width: widget.cardWidth,
              parentNsv: nsv,
              onClose: widget.onClose,
              onEdit: () => showEditSheet(context),
              onTap: () => _onTileTap(),
              showSelfScoreInsteadOfStatus: widget.showSelfScoreInsteadOfStatus,
              addtionalWidget: _unseenWidget(),
              homePageTileSize: widget.homePageTileSize,
              displaySubType: widget.displaySubType,
              gridHeight: widget.gridHeight,
            ),
          )
        : _buildListTile(nsv, nodeTitle);
  }

  void _onTileTap() {
    onNodeTap(widget.dynContent?.content, widget.category, context,
        onUpdateContent: widget.onContentUpdate);
  }

  DisplaySubType get _displaySubType {
    if (widget.displaySubType != null) {
      return widget.displaySubType!;
    } else {
      return DisplaySubType.comfortable;
    }
  }

  String? get time {
    if (widget.showTime) {
      var dynContent = widget.dynContent;
      if (dynContent is BaseNode) {
        dynContent = dynContent.content;
      }
      if (dynContent is Node) {
        var broadcast = dynContent.broadcast;
        if (broadcast != null) {
          return MalApi.getFormattedAiringDate(broadcast);
        }
      }
    }
    return null;
  }

  bool get _compact => _displaySubType == DisplaySubType.compact;

  bool get _spacious => _displaySubType == DisplaySubType.spacious;

  Widget _buildListTile(NodeStatusValue nsv, String nodeTitle) {
    if (_compact) {
      return _buildCompactListTile(nsv, nodeTitle);
    }
    if (_spacious) {
      return _buildSpaciousTile(nsv, nodeTitle);
    }
    return _buildConfirmTile(nsv, nodeTitle);
  }

  Widget _buildConfirmTile(NodeStatusValue nsv, String nodeTitle) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      child: conditional(
        on: user.pref.showAnimeMangaCard,
        parent: (child) => Card(
          margin: EdgeInsets.zero,
          child: child,
        ),
        child: InkWell(
          onTap: () => _onTileTap(),
          borderRadius: BorderRadius.circular(12),
          child: Row(
            children: [
              leadingImage(context),
              Expanded(
                  flex: 4,
                  child: AspectRatio(
                    aspectRatio: widget.aspectRatio,
                    child: Stack(
                      children: [
                        if (widget.showImage &&
                            widget.showBackgroundImage &&
                            _imageUrl.isNotBlank &&
                            !user.pref.showAnimeMangaCard)
                          _coverImage(),
                        Container(
                          // height: 90,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                  child: Padding(
                                padding: EdgeInsets.only(
                                    left: 10, top: 5, bottom: 5),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (!widget.showOnlyEdit &&
                                        _hasUpperBar(nsv))
                                      Container(
                                        height: 24,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            indexWidget(widget.index),
                                            starMemberWidget(),
                                            if (nsv?.status != null)
                                              statusBadge(nsv),
                                            if (user.pref.showPriority)
                                              priorityBadge,
                                            if (user.pref.showAiringInfo)
                                              airingBadge,
                                          ],
                                        ),
                                      ),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            top: nodeTitle.length < 30 ? 10 : 4,
                                            bottom: 4),
                                        child: title(
                                          nodeTitle,
                                          textOverflow: TextOverflow.fade,
                                          fontSize:
                                              nodeTitle.length < 30 ? 14 : 13,
                                          scaleFactor: 1,
                                          opacity: 1,
                                        ),
                                      ),
                                    ),
                                    if (widget.category.equals("manga") &&
                                        !widget.showOnlyEdit)
                                      listStatusWidget(),
                                    if (widget.category.equals("user") &&
                                        widget.dynContent.content.lastOnline
                                            .toString()
                                            .isNotBlank)
                                      iconAndText(
                                        Icons.access_time,
                                        widget.dynContent?.content
                                                ?.lastOnline ??
                                            "??",
                                      ),
                                    if (!contentTypes
                                            .contains(widget.category) &&
                                        widget.dynContent?.content
                                            is AddtionalNode)
                                      additional,
                                    if (widget.dynContent is FeaturedBaseNode &&
                                        widget.dynContent?.content?.tags !=
                                            null)
                                      TagsWidget(
                                          category: widget.category,
                                          tags: widget
                                                  .dynContent?.content?.tags ??
                                              []),
                                    _timeWidget(),
                                    genreWidget,
                                  ],
                                ),
                              )),
                              if (!widget.showOnlyEdit)
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 6),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      userStarWidget(myListStatus),
                                      SB.h5,
                                      if (widget.category.equals("anime"))
                                        listStatusWidget(),
                                      SB.h5,
                                      if (widget.showEdit)
                                        editWidget(context, nsv, widget.index)
                                    ],
                                  ),
                                ),
                              if (widget.showOnlyEdit && widget.showEdit)
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    editWidget(context, nsv, widget.index)
                                  ],
                                ),
                              if (widget.category.equals("video"))
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [Icon(Icons.play_circle)],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (widget.onClose != null)
                          Positioned(
                            top: 10,
                            right: 10,
                            child: IconButton.filled(
                              onPressed: widget.onClose,
                              icon: Icon(Icons.close),
                              iconSize: 22,
                            ),
                          )
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Container _coverImage() {
    return Container(
      width: double.infinity,
      child: Opacity(
        opacity: .1,
        child: CachedNetworkImage(fit: BoxFit.cover, imageUrl: _imageUrl),
      ),
    );
  }

  bool _hasUpperBar(NodeStatusValue nsv) {
    return widget.showIndex ||
        _hasMeanStars ||
        nsv?.status != null ||
        user.pref.showPriority;
  }

  Widget starMemberWidget() {
    final detailed = widget.dynContent?.content;
    if (_hasMeanStars) {
      return Padding(
        padding: const EdgeInsets.only(right: 4, left: 4),
        child: Row(
          children: [
            starWwidget(detailed.mean?.toString() ?? '-',
                const EdgeInsets.only(right: 4)),
            if (detailed.numListUsers != null)
              title(
                '(${userCountFormat.format(detailed.numListUsers)})',
                fontSize: 9,
                opacity: .7,
              ),
          ],
        ),
      );
    } else {
      return SB.z;
    }
  }

  bool get _hasMeanStars {
    final detailed = widget.dynContent?.content;
    return detailed != null &&
        (detailed is AnimeDetailed || detailed is MangaDetailed) &&
        (detailed.mean != null);
  }

  String get _imageUrl {
    final content2 = widget.dynContent?.content;
    return content2?.mainPicture?.large ?? '';
  }

  Widget leadingImage(BuildContext context) {
    if (widget.showImage && _imageUrl.isNotBlank) {
      var unseenWidget = _unseenWidget();
      Widget child;
      if (unseenWidget == null) {
        child = _image(context, _imageUrl);
      } else {
        child = Stack(
          children: [
            _image(context, _imageUrl),
            unseenWidget,
          ],
        );
      }
      return Expanded(
        flex: 1,
        child: Padding(
          padding: EdgeInsets.only(right: 10),
          child: child,
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget? _unseenWidget() {
    var content2 = widget.dynContent?.content;
    if (_anime() &&
        content2 is AnimeDetailed &&
        myListStatus?.numEpisodesWatched != null) {
      final alreadyAired = "finished_airing".equalsIgnoreCase(content2.status);
      var episodesWatched = myListStatus?.numEpisodesWatched as int;
      if (alreadyAired && content2.numEpisodes != null) {
        return _episodeUnseenWidget(content2.numEpisodes!, episodesWatched);
      } else {
        return _usingScheduler(
            (data) => _unseenUsingScheduleData(data) ?? SB.z);
      }
    }
    return null;
  }

  Widget _usingScheduler(Widget Function(ScheduleData) widget) {
    return CFutureBuilder<Map<int, ScheduleData>>(
      future: DalApi.i.scheduleForMalIds,
      loadingChild: SB.z,
      done: (sn) {
        ScheduleData? data;
        if (sn.hasData && sn.data!.containsKey(id)) {
          data = sn.data![id]!;
          return widget(data);
        }
        return SB.z;
      },
    );
  }

  bool _anime() => widget.category.equals('anime');

  AvatarAspect _image(BuildContext context, imageUrl) {
    return AvatarAspect(
      aspectRatio: widget.imageAspectRatio,
      useUserImageOnError: false,
      radius: BorderRadius.circular(4),
      onTap: () => zoomInImage(context, imageUrl),
      onLongPress: () => zoomInImage(context, imageUrl),
      url: imageUrl,
      userRoundBorderforLoading: false,
    );
  }

  Widget? _unseenUsingScheduleData(ScheduleData data) {
    var episodesWatched = myListStatus?.numEpisodesWatched as int?;
    if (episodesWatched != null) {
      int? episodesAired = data.episode;
      if (episodesAired != null) {
        episodesAired--;
      } else {
        var contenDetailed = widget.dynContent?.content as AnimeDetailed;
        episodesAired ??= contenDetailed.numEpisodes;
      }
      if (episodesAired != null) {
        return _episodeUnseenWidget(episodesAired, episodesWatched);
      }
    }
    return SB.z;
  }

  Widget? _episodeUnseenWidget(int episodesAired, int episodesWatched) {
    if (episodesAired <= episodesWatched) {
      return null;
    }
    var epsDifference = episodesAired - episodesWatched;
    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.red[700],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '${NumberFormat.compact().format(epsDifference)}',
        style: GoogleFonts.roboto(
          fontSize: 10,
          color: Colors.white,
        ),
      ),
    );
    if (widget.displayType == DisplayType.list_vert) {
      return Positioned(
        bottom: 0,
        right: 0,
        child: child,
      );
    } else {
      return Positioned(
        top: widget.showTime ? 22 : 7,
        right: 3,
        child: child,
      );
    }
  }

  Widget get genreWidget {
    final detailed = widget.dynContent?.content;
    if ((detailed is AnimeDetailed || detailed is MangaDetailed)) {
      final genres = detailed.genres ?? <MalGenre>[];
      final genreMap =
          widget.category.equals("anime") ? Mal.animeGenres : Mal.mangaGenres;
      final content = genres
          .map((e) => genreMap[e.id]?.replaceAll("_", " ") ?? e.name)
          .join(", ");
      final int length = genres.length;
      final mediaText = mediaTypeText;
      final String genreText = genres
          .getRange(0, min(3, length))
          .map((e) => genreMap[e.id]?.replaceAll("_", " ") ?? e.name)
          .join(", ");
      return Container(
        // width: width,
        child: Padding(
          padding: const EdgeInsets.only(top: 1),
          child: ToolTipButton(
            message: content,
            padding: EdgeInsets.zero,
            child: title(
                '$mediaText${mediaText.isNotBlank && genreText.isNotBlank ? " · " : ''}$genreText',
                textOverflow: TextOverflow.ellipsis,
                align: user.pref.isRtl ? TextAlign.right : TextAlign.left,
                fontSize: 11,
                opacity: .6),
          ),
        ),
      );
    } else {
      return SB.z;
    }
  }

  String get mediaTypeText {
    final contentDetailed = widget.dynContent?.content;
    if (contentDetailed != null &&
        (contentDetailed is AnimeDetailed ||
            contentDetailed is MangaDetailed)) {
      return (contentDetailed?.mediaType == null
              ? ""
              : contentDetailed.mediaType.toUpperCase()) +
          " " +
          (contentDetailed is AnimeDetailed
              ? (((contentDetailed.numEpisodes == null ||
                      contentDetailed.numEpisodes == 0)
                  ? ""
                  : ("(" +
                      (contentDetailed?.numEpisodes == null
                          ? "?"
                          : contentDetailed.numEpisodes.toString()) +
                      " eps)")))
              : contentDetailed is MangaDetailed
                  ? (((contentDetailed?.numVolumes == null ||
                          contentDetailed.numVolumes == 0)
                      ? ""
                      : ("(" +
                          (contentDetailed?.numVolumes == null
                              ? "?"
                              : contentDetailed.numVolumes.toString()) +
                          " vols)")))
                  : '');
    } else {
      return '';
    }
  }

  Widget get airingBadge {
    String? airingDetails;
    try {
      airingDetails =
          MalApi.getFormattedAiringDate(widget.dynContent?.content?.broadcast);
    } catch (e) {}
    return airingDetails == null || airingDetails.isBlank
        ? SB.z
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ToolTipButton(
              message: airingDetails,
              child: Icon(
                Icons.info_outline,
                size: 19,
              ),
            ),
          );
  }

  Widget get additional {
    var content = widget.dynContent?.content as AddtionalNode;
    if (content?.additional != null)
      return title(content.additional);
    else
      return SB.z;
  }

  Widget get priorityBadge {
    if (myListStatus == null || !contentTypes.contains(widget.category))
      return SB.z;
    int? value = int.tryParse(myListStatus.priority?.toString() ?? "");
    if (value == null || value == 0) return SB.z;
    String? status;
    Color? color;
    switch (value) {
      case 1:
        status = "M";
        color = Colors.orange;
        break;
      default:
        status = "H";
        color = Colors.red;
    }
    if (status == null || color == null) return SB.z;
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Container(
          width: 40,
          padding: EdgeInsets.zero,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(16)),
          child: Center(
            child: title(status,
                opacity: 1, fontSize: 11, colorVal: Colors.white.value),
          )),
    );
  }

  Widget statusBadge(nsv) => Container(
      width: 40,
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
          color: nsv.color, borderRadius: BorderRadius.circular(16)),
      child: Center(
        child: title(nsv?.status ?? "",
            opacity: 1, fontSize: 11, colorVal: Colors.white.value),
      ));

  Widget indexWidget(index) => widget.showIndex
      ? Padding(
          padding: const EdgeInsets.only(right: 7),
          child: title("#${index + 1}", opacity: 1, fontSize: 16),
        )
      : const SizedBox();

  Widget userStarWidget(
    _myListStatus, {
    Widget? additional,
  }) {
    return (user.status == AuthStatus.AUTHENTICATED &&
            widget.showStatus &&
            _myListStatus?.score != null)
        ? Padding(
            padding: EdgeInsets.only(right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 14,
                  child: Image.asset("assets/images/star.png"),
                ),
                const SizedBox(
                  width: 5,
                ),
                title(_myListStatus?.score?.toString() ?? "0",
                    opacity: 1, fontSize: 14),
                if (additional != null) additional,
              ],
            ))
        : const SizedBox();
  }

  Widget starWwidget(String score,
      [EdgeInsetsGeometry? padding, double? fontSize]) {
    return Padding(
        padding: padding ?? EdgeInsets.only(right: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              height: 14,
              child: Image.asset("assets/images/star.png"),
            ),
            const SizedBox(
              width: 5,
            ),
            title(score, opacity: 1, fontSize: fontSize ?? 14),
          ],
        ));
  }

  Widget listStatusWidget() => Padding(
      padding: EdgeInsets.only(left: 0),
      child: (user.status == AuthStatus.AUTHENTICATED && widget.showStatus)
          ? title(_episodeChapterOrVolume(), opacity: 1)
          : const SizedBox());

  String _episodeChapterOrVolume() {
    return widget.category.equals("anime")
        ? (myListStatus?.numEpisodesWatched == null
            ? ""
            : myListStatus.numEpisodesWatched.toString() + " Eps")
        : (((myListStatus?.numChaptersRead?.toString() ?? "?") +
                " ${S.current.Chapters}") +
            (" - " +
                (myListStatus?.numVolumesRead?.toString() ?? "?") +
                " ${S.current.Volumes}"));
  }

  Widget editWidget(context, nsv, index) => widget.category.equals("anime")
      ? editWidgetAnime(context, nsv, index)
      : editWidgetManga(context, nsv, index);

  Widget editWidgetAnime(context, nsv, index) => Row(
        children: [
          if (_validShowStatus)
            iconButton(
                context,
                index,
                () => updateEpisode(
                    widget.dynContent, myListStatus?.numEpisodesWatched,
                    add: 1),
                IBType.left,
                Icons.add),
          iconButton(context, index, () => showEditSheet(context),
              modifyListStatus ? IBType.loading : IBType.middle, Icons.edit),
          if (_validShowStatus)
            iconButton(
                context,
                index,
                () => updateEpisode(
                    widget.dynContent, myListStatus?.numEpisodesWatched,
                    add: -1),
                IBType.right,
                Icons.remove),
        ],
      );

  bool get _validShowStatus =>
      user.status == AuthStatus.AUTHENTICATED && myListStatus?.status != null;

  Widget editWidgetManga(context, nsv, index) => iconButton(
      context, index, () => showEditSheet(context), IBType.all, Icons.edit);

  onUpdateContent() {
    if (widget.onContentUpdate != null) widget.onContentUpdate!();
    onStatisticsUpdate();
  }

  onStatisticsUpdate() {
    if (widget.onStatisticsUpdate != null) widget.onStatisticsUpdate!();
  }

  showEditSheet(context) {
    dynamic _dynContent = widget.dynContent;
    if (_dynContent is BaseNode) {
      _dynContent?.myListStatus = myListStatus;
    } else {
      _dynContent?.content?.myListStatus = myListStatus;
    }

    showContentEditSheet(context, widget.category, _dynContent,
        updateCache: widget.updateCacheOnEdit, onListStatusChange: (status) {
      onStatisticsUpdate();
      if (mounted && status != null)
        setState(() {
          myListStatus = status;
        });
    }, onDelete: () {
      onStatisticsUpdate();
      if (mounted)
        setState(() {
          myListStatus = null;
        });
    });
  }

  updateEpisode(content, int episodes, {int add = 1}) async {
    showToast(S.current.Updating);
    if (mounted)
      setState(() {
        modifyListStatus = true;
      });
    var status =
        await MalUser.updateEpisodeCount(content, episodes: episodes, add: add);
    if (mounted)
      setState(() {
        modifyListStatus = false;
        if (status != null) {
          myListStatus = status;
        }
      });
  }

  Widget iconButton(context, index, onPressed,
          [IBType type = IBType.middle, IconData iconData = Icons.edit]) =>
      Container(
        width: 30,
        height: 35,
        child: PlainButton(
          padding: EdgeInsets.only(),
          child: type == IBType.loading
              ? Center(child: loadingCenter(containerSide: 15))
              : Icon(
                  iconData,
                  size: 14,
                ),
          shape: (type == IBType.middle || type == IBType.loading)
              ? RoundedRectangleBorder(borderRadius: BorderRadius.zero)
              : type == IBType.left
                  ? RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          topLeft: Radius.circular(12)))
                  : type == IBType.right
                      ? RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(12),
                              topRight: Radius.circular(12)))
                      : RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
          onPressed: () {
            if (!modifyListStatus) onPressed();
          },
        ),
      );

  @override
  bool get wantKeepAlive => true;

  Widget countdownWidget({
    EdgeInsetsGeometry? padding,
    Widget Function(Widget child)? wrapper,
  }) {
    if (widget.category.equals('anime')) {
      return _usingScheduler((data) {
        var child = _countdownWidget(data, padding: padding);
        return wrapper != null ? wrapper(child) : child;
      });
    }
    return SB.z;
  }

  CountDownWidget _countdownWidget(ScheduleData scheduleData,
      {EdgeInsetsGeometry? padding}) {
    return CountDownWidget(
      timestamp: scheduleData.timestamp!,
      customTimer: (t) => t.timerOver
          ? SB.z
          : Padding(
              padding: padding ?? const EdgeInsets.only(top: 2, bottom: 6.0),
              child: RichText(
                text: TextSpan(
                  text: 'Ep ',
                  style: Theme.of(context).textTheme.labelSmall,
                  children: [
                    TextSpan(
                      text: scheduleData.episode?.toString() ?? '?',
                    ),
                    TextSpan(
                      text: ' in ',
                    ),
                    if (t.days > 0) ...[
                      TextSpan(
                        text: t.days.toString(),
                      ),
                      TextSpan(
                        text: 'd ',
                      ),
                    ],
                    if (t.hours > 0) ...[
                      TextSpan(
                        text: t.hours.toString(),
                      ),
                      TextSpan(
                        text: 'h ',
                      ),
                    ],
                    if (t.minutes > 0) ...[
                      TextSpan(
                        text: t.minutes.toString(),
                      ),
                      TextSpan(
                        text: 'm ',
                      ),
                    ],
                    TextSpan(
                      text: t.seconds.toString(),
                    ),
                    TextSpan(
                      text: 's',
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCompactListTile(NodeStatusValue nsv, String nodeTitle) {
    var avatarWidget = AvatarWidget(
      height: 35,
      width: 35,
      url: _imageUrl,
      onTap: () => zoomInImage(context, _imageUrl),
      onLongPress: () => zoomInImage(context, _imageUrl),
      radius: BorderRadius.circular(16),
      useUserImageOnError: false,
    );
    var text = Text(
      nodeTitle,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            overflow: TextOverflow.fade,
            fontSize: 11,
          ),
    );
    return ListTile(
      leading: avatarWidget,
      title: text,
      onTap: () => _onTileTap(),
      subtitle: _timeWidget(),
      trailing: widget.showStatus
          ? editIconButton(
              nsv,
              () => showEditSheet(context),
              6.0,
              null,
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            )
          : null,
    );
  }

  Widget _timeWidget() {
    final timeText = time;

    if (timeText != null)
      return Text(
        timeText,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              overflow: TextOverflow.fade,
              fontSize: 11,
            ),
      );
    else
      return countdownWidget();
  }

  Widget _buildSpaciousTile(NodeStatusValue nsv, String nodeTitle) {
    var unseenWidget = _unseenWidget();
    var content = widget.dynContent?.content;
    Widget Function(Widget child) wrapper = (child) => SizedBox(
          height: 27,
          child: ShadowButton(
            onPressed: () {},
            child: child,
          ),
        );
    final _countdownWidget = time != null
        ? Text(time!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  overflow: TextOverflow.fade,
                  fontSize: 11,
                ))
        : countdownWidget(padding: EdgeInsets.zero, wrapper: wrapper);

    return SpaciousContentWidget(
      category: widget.category,
      item: content,
      value: nsv,
      nodeTitle: nodeTitle,
      showStatus: widget.showStatus,
      updateCache: false,
      onEdit: () => showEditSheet(context),
      leadingAdditional: unseenWidget,
      mediaText: mediaTypeText,
      bottomWidget: _countdownWidget,
      selfStatusWidget: userStarWidget(
        myListStatus,
        additional: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text('(${_episodeChapterOrVolume()})',
              style: Theme.of(context).textTheme.labelSmall),
        ),
      ),
    );
  }
}

Widget buildGridResults(var _results, var _category,
    ScrollController controller, BuildContext context) {
  return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      controller: controller,
      padding: EdgeInsets.zero,
      itemCount: _results.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: MediaQuery.of(context).size.aspectRatio > 1 ? 5 : 2.5,
      ),
      itemBuilder: (context, index) {
        return Material(
            color: Colors.transparent,
            elevation: 0,
            child: InkWell(
                onTap: () {
                  if (_category.equals("user")) {
                    showUserPage(
                        context: context,
                        username: _results.elementAt(index).content?.title);
                  } else if (!contentTypes.contains(_category)) {
                    gotoPage(
                        context: context,
                        newPage: CharacterScreen(
                            charaCategory: _category,
                            id: _results.elementAt(index).content.id));
                  } else {
                    gotoPage(
                        context: context,
                        newPage: ContentDetailedScreen(
                          category: _category,
                          node: _results.elementAt(index).content,
                          id: _results.elementAt(index).content.id,
                        ));
                  }
                },
                child: Container(
                  // width: 200,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AnimeGridCard(
                        height: 60,
                        width: 60,
                        smallHeight: 25,
                        smallWidth: 25,
                        node: _results.elementAt(index).content,
                        showText: false,
                        onTap: () {
                          gotoPage(
                              context: context,
                              newPage: ContentDetailedScreen(
                                category: _category,
                                node: _results.elementAt(index).content,
                                id: _results.elementAt(index).content.id,
                              ));
                        },
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Container(
                          width: 110,
                          child: title(
                              _results.elementAt(index)?.content?.title ?? "?"))
                    ],
                  ),
                )));
      });
}
