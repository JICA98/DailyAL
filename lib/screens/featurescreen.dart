import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dailyanimelist/widgets/customfuture.dart';
import 'package:dailyanimelist/widgets/shimmecolor.dart';
import 'package:dailyanimelist/util/responsive_helper.dart';
import 'package:dailyanimelist/api/malapi.dart';
import 'package:dailyanimelist/enums.dart';
import 'package:dailyanimelist/screens/forumposts.dart';
import 'package:dailyanimelist/screens/tabscreen.dart';
import 'package:dailyanimelist/widgets/background.dart';
import 'package:dailyanimelist/widgets/custombutton.dart';
import 'package:dailyanimelist/widgets/featured/tagswidget.dart';
import 'package:dailyanimelist/widgets/home/bookmarks_widget.dart';
import 'package:dailyanimelist/widgets/loading/shimmerwidget.dart';
import 'package:dailyanimelist/widgets/slivers.dart';
import 'package:dailyanimelist/widgets/user/contentlistwidget.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:flutter/material.dart';
import 'package:dailyanimelist/generated/l10n.dart';

import 'package:dailyanimelist/screens/generalsearchscreen.dart';
import '../constant.dart';

class FeaturedScreen extends StatefulWidget {
  final int id;
  final String? featureTitle;
  final String? imgUrl;
  final String category;
  const FeaturedScreen(
      {Key? key,
      required this.id,
      this.imgUrl,
      this.featureTitle,
      this.category = "featured"})
      : super(key: key);

  @override
  State<FeaturedScreen> createState() => _FeaturedScreenState();
}

class _FeaturedScreenState extends State<FeaturedScreen> {
  late Future<Featured> featuredArticleFuture;

  @override
  void initState() {
    super.initState();
    featuredArticleFuture = MalApi.getFeaturedArticle(
        widget.id, widget.featureTitle,
        category: widget.category);
  }

  @override
  Widget build(BuildContext context) {
    if (ResponsiveHelper.isTabletOrLarger(context)) {
      return _buildTabletLayout();
    }
    return TabScreen<Featured>(
      title: '',
      actions: (_) => _buildActions(_),
      header: (_) => headerWidget(_),
      tabs: (featured) => generateTabs(featured),
      future: featuredArticleFuture,
      floatingActionButton: (_) => _buildFab(_),
    );
  }

  Widget? _buildFab(Featured? _) {
    return (_ != null)
        ? BookMarkFloatingButton(
            type: BookmarkType.values.byName(widget.category),
            id: widget.id,
            data: _,
          )
        : null;
  }

  double get _minLeftPanelWidth => 350.0;
  double get _maxLeftPanelWidth => 600.0;
  double get _defaultLeftPanelWidth => 400.0;
  double? _userDefinedLeftPanelWidth;

  double get _currentLeftPanelWidth =>
      _userDefinedLeftPanelWidth ?? _defaultLeftPanelWidth;

  Widget _buildTabletLayout() {
    return CFutureBuilder<Featured>(
      future: featuredArticleFuture,
      loadingChild: Scaffold(
        appBar: AppBar(title: Text(widget.featureTitle ?? '')),
        body: ShimmerColor(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: ShimmerWidget()),
              Expanded(flex: 3, child: ShimmerWidget()),
            ],
          ),
        ),
      ),
      done: (snapshot) {
        final featured = snapshot.data;
        if (featured != null) {
          imageUrlSet(featured);
        }
        return Scaffold(
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: _currentLeftPanelWidth,
                child: Stack(
                  children: [
                    if (widget.imgUrl != null)
                      Opacity(
                        opacity: 0.5,
                        child: Background(
                          context: context,
                          url: widget.imgUrl,
                          height: double.infinity,
                          width: double.infinity,
                          forceBg: true,
                        ),
                      ),
                    Column(
                      children: [
                        SizedBox(
                          height: kToolbarHeight,
                          child: AppBar(
                            leading: BackButton(),
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            padding:
                                ResponsiveHelper.getContentPadding(context),
                            child: _buildTabletLeftPanel(
                                featured, _currentLeftPanelWidth),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              MouseRegion(
                cursor: SystemMouseCursors.resizeColumn,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      double newWidth = (_userDefinedLeftPanelWidth ??
                              _defaultLeftPanelWidth) +
                          details.delta.dx;
                      _userDefinedLeftPanelWidth = newWidth.clamp(
                          _minLeftPanelWidth, _maxLeftPanelWidth);
                    });
                  },
                  child: Container(
                    width: 8,
                    color: Theme.of(context).dividerColor.withOpacity(0.1),
                    child: Center(
                      child: Container(
                        width: 2,
                        height: 40,
                        color: Theme.of(context).dividerColor.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _buildTabletRightPanel(featured),
              ),
            ],
          ),
          floatingActionButton: _buildFab(featured),
        );
      },
    );
  }

  Widget _buildTabletLeftPanel(Featured? featured, double width) {
    final textTheme = Theme.of(context).textTheme;
    final imageWidth =
        width - (ResponsiveHelper.getHorizontalPadding(context) * 2);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.imgUrl != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: widget.imgUrl ?? '',
              fit: BoxFit.cover,
              width: double.infinity,
              height: imageWidth * 1.4,
            ),
          ),
        SB.h20,
        _buildInfoRow(Icons.person, featured?.postedBy ?? "?"),
        SB.h10,
        _buildInfoRow(Icons.calendar_today, featured?.postedDate ?? "?"),
        SB.h10,
        _buildInfoRow(
            Icons.visibility,
            (featured?.views?.toString() ?? "0") +
                " " +
                (widget.category.equals("featured")
                    ? S.current.Views
                    : S.current.Comments)),
        SB.h15,
        if (featured?.summary != null && featured!.summary!.isNotEmpty)
          Text(featured.summary!, style: textTheme.bodyMedium),
        SB.h15,
        if (featured?.tags != null && featured!.tags!.isNotEmpty)
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: featured!.tags!
                .map((tag) => Card(
                      margin: EdgeInsets.zero,
                      child: InkWell(
                        onTap: () {
                          gotoPage(
                              context: context,
                              newPage: GeneralSearchScreen(
                                autoFocus: false,
                                category: widget.category,
                                filterOutputs: {
                                  "tags": CustomFilters.featuredFilters.first
                                    ..value = tag,
                                },
                                showBackButton: true,
                              ));
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 6.0),
                          child: Text(
                            tag,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).hintColor),
        SB.w10,
        Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
      ],
    );
  }

  Widget _buildTabletRightPanel(Featured? featured) {
    final tabs = generateTabs(featured);
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.featureTitle ?? ''),
          actions: _buildActions(featured),
          automaticallyImplyLeading: false,
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: tabs.keys.map((t) => Tab(text: t.standardize())).toList(),
          ),
        ),
        body: TabBarView(
          children: tabs.values.toList(),
        ),
      ),
    );
  }

  List<Widget> _buildActions(Featured? featured) {
    return [
      if (featured?.summary != null)
        ToolTipButton(
          message: featured?.summary ?? '',
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.info),
          ),
        ),
    ];
  }

  Map<String, Widget> generateTabs(Featured? featured) {
    Map<String, Widget> tabs = {S.current.general: ShimmerWidget()};

    if (featured != null) {
      tabs[S.current.general] = SingleChildScrollView(
          child: HtmlW(data: featured.body, useImageRenderer: true));
      if (widget.category.equals("featured")) {
        tabs[S.current.related_articles] = CustomScrollWrapper([
          ContentListWidget(
            category: "featured",
            contentList: featured.relatedArticles!,
            showEdit: false,
            padding: EdgeInsets.only(top: 15),
            showBackgroundImage: false,
          ),
        ]);
      }
      for (var entry in featured.relatedDatabaseEntries!.entries) {
        tabs[entry.key] = CustomScrollWrapper([
          ContentListWidget(
            category: entry.key,
            contentList: entry.value,
            updateCacheOnEdit: true,
            aspectRatio: 6,
            showImage: false,
            showEdit: contentTypes.contains(entry.key),
            showOnlyEdit: contentTypes.contains(entry.key),
            padding: EdgeInsets.only(top: 15),
          )
        ]);
      }

      if (featured.topidId != null) {
        tabs[S.current.Comments] = ForumPostsScreen(
          showOnlyPosts: true,
          topic: ForumTopicsData(
            id: featured.topidId,
            numberOfPosts: int.tryParse(featured.views!),
          ),
        );
      }
      for (var entry in featured.relatedNews!.entries) {
        tabs[entry.key.replaceAll("More", "")] = CustomScrollWrapper([
          ContentListWidget(
            category: "news",
            contentList: entry.value,
            padding: EdgeInsets.only(top: 15),
            showEdit: false,
            showBackgroundImage: false,
          )
        ]);
      }
    }
    return tabs;
  }

  Widget headerWidget([Featured? featured]) {
    imageUrlSet(featured);
    final textTheme = Theme.of(context).textTheme;
    return FlexibleSpaceBar(
      background: Material(
          child: Stack(
        children: [
          Background(
            context: context,
            url: widget.imgUrl,
            forceBg: true,
          ),
          Padding(
            padding: const EdgeInsets.only(
                top: 100.0, left: 15, right: 15, bottom: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 80.0),
                  child: AutoSizeText(
                    featured?.title ?? '',
                    style: textTheme.titleLarge,
                  ),
                ),
                SB.h30,
                Text(
                    '${featured?.postedBy ?? ""} · ${featured?.postedDate?.toLowerCase() ?? ""}',
                    style: textTheme.bodySmall),
                SB.h5,
                Text(
                    (featured?.views?.toString() ?? "0") +
                        " " +
                        (widget.category.equals("featured")
                            ? S.current.Views
                            : S.current.Comments),
                    style: textTheme.bodySmall),
                SB.h15,
                if (featured?.tags != null && featured!.tags!.isNotEmpty)
                  TagsWidget(
                    tags: featured.tags!,
                    category: widget.category,
                  ),
                SB.h5,
              ],
            ),
          ),
        ],
      )),
    );
  }

  void imageUrlSet(Featured? featured) {
    if (featured != null) {
      featured.mainPicture =
          Picture(large: widget.imgUrl, medium: widget.imgUrl);
    }
  }
}
