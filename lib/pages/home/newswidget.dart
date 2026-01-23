import 'package:cached_network_image/cached_network_image.dart';
import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/main.dart';
import 'package:dailyanimelist/screens/featurescreen.dart';
import 'package:dailyanimelist/util/responsive_helper.dart';
import 'package:dailyanimelist/widgets/avatarwidget.dart';
import 'package:dailyanimelist/widgets/common/image_preview.dart';
import 'package:dailyanimelist/widgets/shimmecolor.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:flutter/material.dart';
import 'package:dailyanimelist/widgets/featured/tagswidget.dart';

class HomePageNewsWidget extends StatelessWidget {
  final List<FeaturedBaseNode?> featuredList;
  const HomePageNewsWidget(this.featuredList, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTabletOrLarger(context);
    final radius = 12.0;
    return Container(
      height: isTablet ? 295 : 250,
      child: ListView.builder(
        padding: EdgeInsets.only(left: 12, right: 15),
        itemCount: featuredList.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final node = featuredList[index]?.featured;
          return Container(
            width: 320,
            child: ShimmerConditionally(
              showShimmer: node == null,
              child: Card(
                child: InkWell(
                  onTap: () {
                    var id = node?.id;
                    if (id != null)
                      gotoPage(
                          context: context,
                          newPage: FeaturedScreen(
                            category: 'news',
                            featureTitle: node?.title,
                            id: id,
                            imgUrl: node?.mainPicture?.large,
                          ));
                  },
                  borderRadius: BorderRadius.circular(radius),
                  child: node == null
                      ? SB.z
                      : Stack(
                          children: [
                            if (user.pref.showBg)
                              Container(
                                width: double.infinity,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(radius),
                                  child: Opacity(
                                    opacity: .1,
                                    child: CachedNetworkImage(
                                        fit: BoxFit.cover,
                                        imageUrl:
                                            node.mainPicture!.large ?? ''),
                                  ),
                                ),
                              ),
                            NewsTile(node: node, radius: radius),
                          ],
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class NewsTile extends StatelessWidget {
  final Featured node;
  final double radius;
  final bool compact;
  final bool enableTagClicks;

  const NewsTile({
    Key? key,
    required this.node,
    this.radius = 12.0,
    this.compact = false,
    this.enableTagClicks = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: AvatarWidget(
            height: compact ? 120 : 220,
            width: compact ? 80 : 120,
            url: node.mainPicture?.large,
            onTap: () => zoomInImage(context, node.mainPicture?.large ?? ''),
            radius: BorderRadius.circular(radius),
            useUserImageOnError: false,
            userRoundBorderforLoading: false,
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                title(node.title, fontSize: 16, opacity: 1),
                SB.h10,
                Expanded(
                  child: title(
                    node.summary,
                    textOverflow: TextOverflow.fade,
                    fontSize: 12,
                  ),
                ),
                SB.h10,
                if (enableTagClicks && node.tags != null)
                  Container(
                    height: 40,
                    margin: EdgeInsets.only(bottom: 5),
                    child: TagsWidget(
                      tags: node.tags!,
                      category: 'news',
                    ),
                  )
                else
                  Container(
                    height: 15,
                    alignment: Alignment.topLeft,
                    child: title(
                      node.tags?.join(', '),
                      fontSize: 11,
                      textOverflow: TextOverflow.ellipsis,
                    ),
                  )
              ],
            ),
          ),
        )
      ],
    );
  }
}
