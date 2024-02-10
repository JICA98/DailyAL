import 'package:dailyanimelist/user/hompagepref.dart';
import 'package:dailyanimelist/widgets/home/animecard.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:flutter/material.dart';

import '../../constant.dart';

class AnimeCardBar extends StatelessWidget {
  final NodeStatusValue? nsv;
  final double smallHeight;
  final double smallWidth;
  final double radius;
  final Node? node;
  final bool showMemberCount;
  final bool showNsv;
  final VoidCallback? onTap;
  final bool showEdit;
  final HomePageTileSize? homePageTileSize;
  final bool showSelfScoreInsteadOfStatus;
  final MyListStatus? myListStatus;
  const AnimeCardBar({
    Key? key,
    this.nsv,
    this.radius = 6,
    this.smallHeight = 30,
    this.smallWidth = 30,
    this.onTap,
    this.showMemberCount = true,
    this.showNsv = true,
    this.showEdit = true,
    this.node,
    this.homePageTileSize,
    this.showSelfScoreInsteadOfStatus = false,
    this.myListStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userPrefResize = homePageTileSize != null;
    final editWidget = Icon(
      Icons.edit,
      color: nsv?.color == null ? Colors.black : Colors.white,
      size: 16,
    );

    final badgeWidget = Center(
      child: Text(
        nsv?.status ?? "",
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 12),
      ),
    );

    final memberCountStyle = TextStyle(
      overflow: TextOverflow.ellipsis,
      fontSize: 13,
    );

    final badgeStatusWidget = Container(
      decoration: BoxDecoration(
          color: nsv?.color ?? Colors.white,
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(radius),
          )),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SB.w5,
          if (showSelfScoreInsteadOfStatus &&
              (myListStatus is MyAnimeListStatus ||
                  myListStatus is MyMangaListStatus))
            starField(
              '${(myListStatus as dynamic)?.score?.toString() ?? '0'} · ',
              starHeight: 14,
              textStyle: memberCountStyle,
            ),
          badgeWidget,
          SB.w5,
          editWidget,
          SB.w5,
        ],
      ),
    );

    final starMemberWidget = (detailed) => Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SB.w10,
            Container(
              height: 14,
              child: Image.asset("assets/images/star.png"),
            ),
            SB.w5,
            title(
                !(detailed is AnimeDetailed || detailed is MangaDetailed)
                    ? ('-')
                    : (detailed.mean == null
                        ? '-'
                        : ratingFormat.format(detailed.mean)),
                fontSize: (!userPrefResize ||
                        homePageTileSize!.index == HomePageTileSize.m.index)
                    ? 11.5
                    : 14,
                opacity: 1),
            SB.w5,
            if (showMemberCount &&
                (detailed is AnimeDetailed || detailed is MangaDetailed) &&
                detailed.numListUsers != null &&
                (!userPrefResize ||
                    homePageTileSize!.index > HomePageTileSize.m.index))
              Expanded(
                child: title(
                  '(${userCountFormat.format(detailed.numListUsers)})',
                  textOverflow: TextOverflow.ellipsis,
                  fontSize: 9,
                  opacity: .7,
                ),
              )
          ],
        );

    final borderRadius = BorderRadius.only(
      bottomRight: Radius.circular(radius),
      bottomLeft: Radius.circular(radius),
    );

    final materialWidget = Material(
      elevation: 5,
      borderRadius: borderRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (!userPrefResize ||
                homePageTileSize!.index >= HomePageTileSize.m.index)
              Expanded(child: starMemberWidget(node)),
            if (showNsv && showEdit) ...[
              SB.w5,
              badgeStatusWidget,
            ]
          ],
        ),
      ),
    );

    return Container(
      width: smallWidth,
      height: smallHeight,
      child: materialWidget,
    );
  }
}

class StatusBadge extends StatelessWidget {
  final double height;
  final double width;
  final NodeStatusValue nsv;
  const StatusBadge(this.nsv, {this.height = 30.0, this.width = 40.0, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: height,
        width: width,
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
            color: nsv.color, borderRadius: BorderRadius.circular(16)),
        child: Center(
          child: title(nsv?.status ?? "",
              opacity: 1, fontSize: 11, colorVal: Colors.white.value),
        ));
  }
}
