import 'package:auto_size_text/auto_size_text.dart';
import 'package:dailyanimelist/api/malapi.dart';
import 'package:dailyanimelist/enums.dart';
import 'package:dailyanimelist/screens/forumposts.dart';
import 'package:dailyanimelist/screens/tabscreen.dart';
import 'package:dailyanimelist/widgets/avatarwidget.dart';
import 'package:dailyanimelist/widgets/background.dart';
import 'package:dailyanimelist/widgets/custombutton.dart';
import 'package:dailyanimelist/widgets/featured/tagswidget.dart';
import 'package:dailyanimelist/widgets/home/bookmarks_widget.dart';
import 'package:dailyanimelist/widgets/loading/shimmerwidget.dart';
import 'package:dailyanimelist/widgets/slivers.dart';
import 'package:dailyanimelist/widgets/translator.dart';
import 'package:dailyanimelist/widgets/user/contentlistwidget.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:flutter/material.dart';
import 'package:dailyanimelist/generated/l10n.dart';

import '../constant.dart';
import '../main.dart';

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
    return TabScreen<Featured>(
      title: '',
      actions: (_) => _buildActions(_),
      header: (_) => headerWidget(_),
      tabs: (featured) => generateTabs(featured),
      future: featuredArticleFuture,
      floatingActionButton: (_) => (_ != null)
          ? BookMarkFloatingButton(
              type: BookmarkType.values.byName(widget.category),
              id: widget.id,
              data: _,
            )
          : null,
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
