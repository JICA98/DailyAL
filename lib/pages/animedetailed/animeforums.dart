import 'package:auto_size_text/auto_size_text.dart';
import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/screens/forumposts.dart';
import 'package:dailyanimelist/widgets/slivers.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:flutter/material.dart';

import '../../main.dart';

class AnimeSubForum extends StatelessWidget {
  final animeId;
  final ForumTopicsHtml topicsHtml;
  final double horizPadding;
  AnimeSubForum(
      {required this.topicsHtml, this.animeId, required this.horizPadding});
  @override
  Widget build(BuildContext context) {
    final onTap = (ForumHtml? topic) => gotoPage(
          context: context,
          newPage: ForumPostsScreen(
            topic: ForumTopicsData(
              id: topic?.topicId,
              title: topic?.title,
              numberOfPosts: int.tryParse(
                  topic?.replies?.replaceAll(" replies", "") ?? ''),
              createdAt: DateTime.tryParse(topic?.createdTime ?? ''),
              createdBy: ForumUser(
                  forumAvatar: null, id: null, name: topic?.createdByName),
              lastPostCreatedBy: ForumUser(
                  forumAvatar: null, id: null, name: topic?.lastPostBy),
              lastPostCreatedAt: DateTime.tryParse(topic?.lastPostTime ?? '?'),
            ),
          ),
        );
    Widget _buildForumWidget(ForumHtml topic) {
      return Container(
        height: 100,
        child: Card(
          child: InkWell(
            onTap: () => onTap(topic),
            customBorder:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AutoSizeText(
                      topic.title ?? "Title",
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.start,
                    ),
                  ),
                  SB.h10,
                  if (topic.lastPostBy != null && topic.lastPostTime != null)
                    Text(
                      (topic.lastPostBy ?? "?") +
                          " · " +
                          (topic.lastPostTime ?? "?"),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final length = topicsHtml.data!.length;
    final pageController =
        PageController(initialPage: 0, viewportFraction: .89);
    final noOfPages = (length / 3).ceilToDouble().toInt();
    final lastPage = noOfPages - 1;

    return Container(
      height: (noOfPages == 1 && length != 3) ? (length == 1 ? 100 : 200) : 300,
      child: PageView.builder(
        itemCount: noOfPages,
        controller: pageController,
        itemBuilder: ((context, pageIndex) {
          return CustomScrollWrapper(
            [
              SliverList(
                  delegate: SliverChildBuilderDelegate(
                (context, i) =>
                    _buildForumWidget(topicsHtml.data![pageIndex * 3 + i]),
                childCount: pageIndex == lastPage
                    ? (length % 3 == 0 ? 3 : length % 3)
                    : 3,
              ))
            ],
            shrink: true,
          );
        }),
      ),
    );
  }
}
