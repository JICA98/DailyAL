import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dailyanimelist/api/malapi.dart';
import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/enums.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/main.dart';
import 'package:dailyanimelist/screens/contentdetailedscreen.dart';
import 'package:dailyanimelist/screens/generalsearchscreen.dart';
import 'package:dailyanimelist/user/hompagepref.dart';
import 'package:dailyanimelist/widgets/common/image_preview.dart';
import 'package:dailyanimelist/widgets/custombutton.dart';
import 'package:dailyanimelist/widgets/fadingeffect.dart';
import 'package:dailyanimelist/widgets/home/nodebadge.dart';
import 'package:dailyanimelist/widgets/user/contentlistwidget.dart';
import 'package:dailyanimelist/widgets/user/stats_screen.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

final NumberFormat userCountFormat = NumberFormat.compact();
final NumberFormat ratingFormat = NumberFormat.currency(name: "");

class AnimeGridCard extends StatelessWidget {
  final Node node;
  final String category;
  final Function? onTap;
  final bool showText;
  final bool showEdit;
  final bool showGenres;
  final double height;
  final double width;
  final double smallHeight;
  final double smallWidth;
  final double? aspectRatio;
  final int? numRecommendations;
  final bool updateCache;
  final double borderRadius;
  final bool showTime;
  final bool showMemberCount;
  final bool showCardBar;
  final VoidCallback? onEdit;
  final NodeStatusValue? parentNsv;
  final double horizPadding;
  final VoidCallback? onClose;
  final bool showSelfScoreInsteadOfStatus;
  final MyListStatus? myListStatus;
  final Widget? addtionalWidget;
  final HomePageTileSize? homePageTileSize;
  final DisplaySubType? displaySubType;
  final double? gridHeight;

  AnimeGridCard({
    required this.node,
    this.category = "anime",
    this.onTap,
    this.numRecommendations,
    this.showText = true,
    this.showEdit = false,
    this.updateCache = false,
    this.height = 200,
    this.width = 140,
    this.showGenres = false,
    this.showTime = false,
    this.borderRadius = 6,
    this.showCardBar = false,
    this.aspectRatio,
    this.smallHeight = 30,
    this.smallWidth = 30,
    this.showMemberCount = true,
    this.onEdit,
    this.parentNsv,
    this.horizPadding = 5.0,
    this.onClose,
    this.showSelfScoreInsteadOfStatus = false,
    this.myListStatus,
    this.addtionalWidget,
    this.homePageTileSize,
    this.displaySubType,
    this.gridHeight,
  });
  @override
  Widget build(BuildContext context) {
    String nodeTitle = getNodeTitle(node);
    if (node?.mainPicture?.large == null) {
      logDal(node);
    }
    String? time;
    if (showTime && node.broadcast != null) {
      time = MalApi.getFormattedAiringDate(node.broadcast!);
    }

    if (_compact || _coverOnly) {
      return Padding(
        padding: const EdgeInsets.only(top: 4.0, left: 6.0, right: 6.0),
        child: cardWidget(context, nodeTitle, time: time),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizPadding),
      child: SizedBox(
        height: gridHeight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            conditional(
              on: gridHeight != null,
              parent: (child) => Expanded(child: child),
              child: _buildImage(context, nodeTitle),
            ),
            if (isEditable) _comfortableEdit(context),
            if (showText) _textWidget(nodeTitle),
            if (time != null)
              Container(
                width: width,
                child: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    time,
                    textAlign:
                        user.pref.isRtl ? TextAlign.right : TextAlign.left,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(fontSize: 11),
                  ),
                ),
              ),
            if (showGenres && (node is AnimeDetailed || node is MangaDetailed))
              genreWidget(context),
            if (gridHeight != null) SB.h5,
          ],
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context, String nodeTitle) {
    if (aspectRatio != null)
      return AspectRatio(
        aspectRatio: aspectRatio!,
        child: cardWidget(context, nodeTitle, borderRadius: borderRadius),
      );
    else
      return Container(
        height: gridHeight != null ? null : height,
        width: gridHeight != null ? null : width,
        child: cardWidget(context, nodeTitle, borderRadius: borderRadius),
      );
  }

  Widget _textWidget(String nodeTitle) {
    return Container(
      width: width,
      padding: EdgeInsets.only(top: 10),
      child: ToolTipButton(
        message: nodeTitle,
        padding: EdgeInsets.zero,
        child: _title(nodeTitle),
      ),
    );
  }

  Text _title(String nodeTitle) {
    return Text(
      nodeTitle,
      textAlign: user.pref.isRtl ? TextAlign.right : TextAlign.left,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
          fontSize: user.pref.preferredAnimeTitle == TitleLang.ja ? 11 : 14),
    );
  }

  DisplaySubType get _displaySubType {
    if (displaySubType != null) {
      return displaySubType!;
    } else {
      return DisplaySubType.comfortable;
    }
  }

  bool get _compact => _displaySubType == DisplaySubType.compact;

  bool get _comfortable => _displaySubType == DisplaySubType.comfortable;

  bool get _coverOnly => _displaySubType == DisplaySubType.cover_only_grid;

  Widget _editAndText(BuildContext context, String nodeTitle) {
    final value = parentNsv ?? NodeStatusValue.fromStatus(node);
    return Positioned(
      bottom: 5,
      left: 5,
      right: 3,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 80.0),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  nodeTitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: Colors.white,
                        overflow: TextOverflow.fade,
                      ),
                ),
              ),
            ),
          ),
          SB.w10,
          if (isEditable) editIconButton(value, () => _onEdit(context)),
        ],
      ),
    );
  }

  AnimeCardBar _comfortableEdit(BuildContext context) {
    return AnimeCardBar(
      radius: borderRadius,
      nsv: parentNsv ?? NodeStatusValue.fromStatus(node),
      node: node,
      showEdit: showEdit,
      smallHeight: smallHeight,
      smallWidth: width,
      showMemberCount: showMemberCount,
      homePageTileSize: homePageTileSize,
      showSelfScoreInsteadOfStatus: showSelfScoreInsteadOfStatus,
      myListStatus: myListStatus,
      onTap: () => _onEdit(context),
    );
  }

  void _onEdit(BuildContext context) {
    if (onEdit != null) {
      onEdit!();
    } else {
      showContentEditSheet(
        context,
        category,
        node,
        updateCache: updateCache,
      );
    }
  }

  DateTime? broadcastTime() {
    var broadcast = node.broadcast;
    if (broadcast?.startTime != null &&
        broadcast?.dayOfTheWeek != null &&
        broadcast?.dayOfTheWeek != 'other') {
      var weekday = MalApi.weekdaysOrderMap[broadcast!.dayOfTheWeek!]!;
      var timeSplit = broadcast!.startTime!.split(":");
      var hours = int.tryParse(timeSplit[0])!;
      var mins = int.tryParse(timeSplit[1])!;
      var nowDate = DateTime.now();
      var nextDate = nowDate.nextDate(weekday);
      return nextDate.add(
        Duration(
            hours: hours - 9, minutes: mins + nowDate.timeZoneOffset.inMinutes),
      );
    }
    return null;
  }

  Widget genreWidget(BuildContext context) {
    if (node is AnimeDetailed || node is MangaDetailed) {
      dynamic detailed = node;
      if (nullOrEmpty(detailed.genres)) return SB.z;
      final genreMap =
          category.equals("anime") ? Mal.animeGenres : Mal.mangaGenres;
      final content =
          detailed.genres.map((e) => genreMap[e.id] ?? e.name).join(", ");
      final int length = detailed.genres.length;

      return Container(
        width: width,
        child: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: ToolTipButton(
            message: content,
            padding: EdgeInsets.zero,
            child: Text(
              detailed.genres
                  .getRange(0, min(3, length))
                  .map((e) => genreMap[e.id] ?? e.name)
                  .join(", "),
              overflow: TextOverflow.ellipsis,
              textAlign: user.pref.isRtl ? TextAlign.right : TextAlign.left,
              style:
                  Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 9),
            ),
          ),
        ),
      );
    } else {
      return SB.z;
    }
  }

  Widget animePicture(BuildContext context, [double borderRadius = 6.0]) {
    String? url = node.mainPicture?.large ?? node.mainPicture?.medium;
    return InkWell(
        onTap: () {
          if (onTap != null) onTap!();
        },
        onLongPress: url == null ? null : () => zoomInImage(context, url),
        customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius)),
        child: (node.mainPicture?.large != null ||
                node.mainPicture?.medium != null)
            ? CachedNetworkImage(
                imageUrl:
                    node.mainPicture?.large ?? node.mainPicture?.medium ?? '',
                placeholder: (context, url) {
                  if (!_comfortable) return loadingCenterColored;
                  return cardLoading(
                      radius: borderRadius, height: height, width: width);
                },
                errorWidget: (context, url, error) => loadingError(),
                imageBuilder: (context, imageProvider) =>
                    loadedImage(imageProvider),
              )
            : Container(
                child: Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      child: Image.asset("assets/images/error_image.png"),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      S.current.No_Image,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                )),
              ));
  }

  Widget cardWidget(
    BuildContext context,
    String nodeTitle, {
    double borderRadius = 6.0,
    String? time,
  }) {
    return Material(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Stack(
        children: [
          aspectRatio != null
              ? AspectRatio(
                  aspectRatio: aspectRatio!,
                  child: animePicture(context, borderRadius),
                )
              : animePicture(context, borderRadius),
          if (_compact) _blackBGforText(borderRadius),
          if (_compact) _editAndText(context, nodeTitle),
          if (_compact) _timeCard(time),
          if (numRecommendations != null) _recomWidget(context, borderRadius),
          if (addtionalWidget != null && !_coverOnly) addtionalWidget!,
        ],
      ),
    );
  }

  Positioned _blackBGforText(double borderRadius) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SizedBox(
        height: 70,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: CustomPaint(
              foregroundPainter: FadingEffect(
                color: Colors.black,
                start: 5,
                end: 250,
              ),
              child: SB.z),
        ),
      ),
    );
  }

  Transform _recomWidget(BuildContext context, double borderRadius) {
    return Transform.translate(
      offset: Offset(-3, -3),
      child: Container(
          width: smallWidth,
          height: smallHeight,
          decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(borderRadius),
                bottomRight: Radius.circular(borderRadius),
              )),
          child: Center(
            child: Text(
              numRecommendations.toString(),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
          )),
    );
  }

  bool get isEditable =>
      showCardBar && (category.equals('anime') || category.equals('manga'));

  loadedImage(
    ImageProvider<Object> imageProvider,
  ) {
    return Stack(
      children: [
        Ink(
          decoration: BoxDecoration(
              borderRadius: (isEditable && _comfortable)
                  ? BorderRadius.only(
                      topRight: Radius.circular(borderRadius),
                      topLeft: Radius.circular(borderRadius),
                    )
                  : BorderRadius.circular(borderRadius),
              image: DecorationImage(fit: BoxFit.cover, image: imageProvider)),
        ),
        if (onClose != null)
          Positioned(
            right: 0,
            child:
                IconButton.filled(onPressed: onClose!, icon: Icon(Icons.clear)),
          ),
      ],
    );
  }

  Widget _timeCard(String? time) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 20,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(borderRadius),
            topRight: Radius.circular(borderRadius),
          ),
        ),
        child: Center(
          child: AutoSizeText(
            time ?? "",
            textAlign: TextAlign.center,
            maxFontSize: 12.0,
            minFontSize: 7.0,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

Widget editIconButton(NodeStatusValue? value, VoidCallback onEdit) {
  return SizedBox(
    width: 30,
    height: 30,
    child: ShadowButton(
      backgroundColor: value?.color,
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
      onPressed: onEdit,
      child: Icon(
        Icons.edit,
        size: 16,
        color: Colors.white,
      ),
    ),
  );
}

class NodeStatusValue {
  String? status;
  Color? color;
  int? index;

  NodeStatusValue({required status, color = Colors.transparent});

  NodeStatusValue.fromListStatus(myListStatus) {
    try {
      setDynStatus(myListStatus.status);
    } catch (e) {}
  }

  NodeStatusValue.fromStatus(dynamic node) {
    dynamic dynStatus;
    if (node.myListStatus is MyAnimeListStatus) {
      dynStatus = node.myListStatus as MyAnimeListStatus;
      dynStatus = dynStatus.status;
    } else if (node.myListStatus is MyMangaListStatus) {
      dynStatus = node.myListStatus as MyMangaListStatus;
      dynStatus = dynStatus.status;
    }
    setDynStatus(dynStatus);
    // logDal(status);
  }

  NodeStatusValue.fromString(String _status) {
    setDynStatus(_status);
  }

  setDynStatus(dynStatus) {
    if (dynStatus != null) {
      String lowStatus = dynStatus.toString().toLowerCase();
      if (lowStatus.equals("watching")) {
        status = "CW";
        index = 0;
      }
      if (lowStatus.equals("reading")) {
        status = "CR";
        index = 0;
      }

      if (lowStatus.equals("completed")) {
        status = "CMP";
        index = 1;
      }

      if (lowStatus.equals("on_hold")) {
        status = "OH";
        index = 2;
      }

      if (lowStatus.equals("dropped")) {
        status = "DP";
        index = 3;
      }

      if (lowStatus.equals("plan_to_watch")) {
        status = "PTW";
        index = 4;
      }

      if (lowStatus.equals("plan_to_read")) {
        status = "PTR";
        index = 4;
      }
      if (index != null) {
        color = Color(getStatusColor(index ?? 0));
      }
    }
  }
}

class PriorityBadge {
  String? status;
  Color? color;
}
