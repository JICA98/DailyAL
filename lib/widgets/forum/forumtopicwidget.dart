import 'package:auto_size_text/auto_size_text.dart';
import 'package:dailyanimelist/main.dart';
import 'package:dailyanimelist/pages/userpage.dart';
import 'package:dailyanimelist/screens/forumposts.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/screens/plainscreen.dart';
import 'package:dailyanimelist/widgets/loading/shimmerwidget.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../constant.dart';
import '../avatarwidget.dart';

class ForumTopicsList extends StatelessWidget {
  final List<ForumTopicsData>? topics;
  final bool showViewAllButton;
  final Function? onPressed;
  final bool shrinkWrap;
  final EdgeInsets? padding;
  final VoidCallback? onUiChange;
  final int shimmerItemCount;
  final int? showMax;
  const ForumTopicsList({
    Key? key,
    this.topics,
    this.onPressed,
    this.padding,
    this.shrinkWrap = true,
    this.onUiChange,
    this.shimmerItemCount = 6,
    this.showViewAllButton = false,
    this.showMax,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return topics == null
        ? ShimmerWidget(
            itemCount: shimmerItemCount,
          )
        : topics!.isEmpty
            ? showNoContent()
            : ListView(
                shrinkWrap: shrinkWrap,
                padding: EdgeInsets.zero,
                physics:
                    shrinkWrap ? const NeverScrollableScrollPhysics() : null,
                children: [
                  _forumList(),
                  if (showViewAllButton) SB.h20,
                  if (showViewAllButton)
                    longButton(
                        text: S.current.View_All,
                        onPressed: () {
                          if (onPressed != null) onPressed!();
                        })
                ],
              );
  }

  static const complexForums = [1885985, 1886113, 1983768];

  Widget _forumList() {
    var _list = topics?.where((data) => !complexForums.contains(data.id)) ?? [];
    if (showMax != null && showMax! < _list.length) {
      _list = _list.toList().getRange(0, showMax!);
    }
    return ListView(
      shrinkWrap: true,
      padding: padding,
      physics: const NeverScrollableScrollPhysics(),
      children: _list
          .map((topic) => ForumTopicWidget(
                topic: topic,
                onUiChange: onUiChange,
              ))
          .toList(),
    );
  }
}

class ForumTopicWidget extends StatelessWidget {
  final ForumTopicsData topic;
  final DateFormat dateFormat = new DateFormat('EEE, MMM d, yyyy');
  final VoidCallback? onUiChange;
  ForumTopicWidget({required this.topic, this.onUiChange});
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      child: InkWell(
        onTap: () {
          gotoPage(
              context: context,
              newPage: ForumPostsScreen(
                topic: topic,
                onUiChange: onUiChange,
              ));
        },
        onLongPress: () {
          if (topic?.lastPostCreatedAt != null) {
            showToast(
                "${S.current.Last_Post_by} ${topic?.lastPostCreatedBy?.name ?? 'User'} - ${dateFormat.format(topic.lastPostCreatedAt!)}");
          }
        },
        child: Padding(
          padding: const EdgeInsets.only(top: 7.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 12, right: 12),
                child: ForumPostHeader(
                  forumTopic: topic,
                  dateFormat: dateFormat,
                  titleStyle: textTheme.titleMedium,
                ),
              ),
              Divider(thickness: 1.0)
            ],
          ),
        ),
      ),
    );
  }

  Expanded _bottom(String formattedDate, BuildContext context) {
    return Expanded(
      child: Container(
        height: 90,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    iconAndText(Icons.date_range, formattedDate),
                    const SizedBox(
                      width: 12,
                    ),
                    iconAndText(
                        Icons.book_rounded, topic.numberOfPosts.toString(),
                        width: 6),
                  ],
                ),
                const SizedBox(
                  width: 12,
                ),
                GestureDetector(
                  onTap: () {
                    if (topic?.lastPostCreatedBy?.name != null)
                      gotoPage(
                          context: context,
                          newPage: PlainScreen(
                            title: topic?.lastPostCreatedBy?.name ?? '',
                            child: UserPage(
                              initalPageIndex: 1,
                              username: topic?.lastPostCreatedBy?.name ?? '',
                            ),
                          ));
                  },
                  child: iconAndText(
                    Icons.person_outline,
                    topic?.lastPostCreatedBy?.name,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // const SizedBox(
                //   width: 12,
                // )
              ],
            ),
            Divider(thickness: 1.0),
          ],
        ),
      ),
    );
  }
}
