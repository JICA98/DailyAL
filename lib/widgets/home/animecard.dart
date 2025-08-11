import 'dart:math';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dailyanimelist/api/malapi.dart';
import 'package:dailyanimelist/cache/dubinfomanager.dart';
import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/enums.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/icons/dub_icons.dart';
import 'package:dailyanimelist/main.dart';
import 'package:dailyanimelist/screens/contentdetailedscreen.dart';
import 'package:dailyanimelist/screens/generalsearchscreen.dart';
import 'package:dailyanimelist/theme/theme.dart';
import 'package:dailyanimelist/user/hompagepref.dart';
import 'package:dailyanimelist/widgets/common/image_preview.dart';
import 'package:dailyanimelist/widgets/custombutton.dart';
import 'package:dailyanimelist/widgets/fadingeffect.dart';
import 'package:dailyanimelist/widgets/home/nodebadge.dart';
import 'package:dailyanimelist/widgets/user/contentlistwidget.dart';
import 'package:dailyanimelist/widgets/user/stats_screen.dart';
import 'package:dal_commons/commons.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:flutter/material.dart';
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
  final bool updateCache;
  final double borderRadius;
  final bool showTime;
  final bool showMemberCount;
  final bool showRecommendations;
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
  final ScheduleData? scheduleData;
  final double? gridHeight;

  AnimeGridCard({
    required this.node,
    this.category = "anime",
    this.onTap,
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
    this.showRecommendations = false,
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
    this.scheduleData,
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
        child: cardWidget(context, nodeTitle,
            time: time, myListStatus: myListStatus),
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
              child: _buildImage(context, nodeTitle, time),
            ),
            if (isEditable) _comfortableEdit(context),
            if (showText) _textWidget(nodeTitle),
            if (showGenres && (node is AnimeDetailed || node is MangaDetailed))
              genreWidget(context),
            if (gridHeight != null) SB.h5,
          ],
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context, String nodeTitle, String? time) {
    if (aspectRatio != null)
      return AspectRatio(
        aspectRatio: aspectRatio!,
        child: cardWidget(context, nodeTitle,
            borderRadius: borderRadius, time: time),
      );
    else
      return Container(
        height: gridHeight != null ? null : height,
        width: gridHeight != null ? null : width,
        child: cardWidget(context, nodeTitle,
            borderRadius: borderRadius, time: time),
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

  Widget _editAndText(
    BuildContext context,
    String nodeTitle,
    double borderRadius,
    MyListStatus? myListStatus,
  ) {
    final value = parentNsv ?? NodeStatusValue.fromStatus(node);
    return Align(
      alignment: AlignmentDirectional.bottomCenter,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 45.0),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(5, 0, 5, 8),
                child: Text(
                  nodeTitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 14,
                      color: Colors.white,
                      overflow: TextOverflow.fade,
                      fontWeight: FontWeight.w400,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          offset: Offset(1, 1),
                          blurRadius: 2,
                        )
                      ]),
                ),
              ),
            ),
          ),
          SB.w10,
          if (isEditable)
            editIconButton(
                value, () => _onEdit(context), borderRadius, myListStatus),
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
    MyListStatus? myListStatus,
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
          if (_compact) ...[
            _blackBGforText(borderRadius),
            _editAndText(context, nodeTitle, borderRadius, myListStatus),
            _episodeWatchProgressBar(myListStatus),
            showRecommendations ? _recommendationBadge() : _memberCountMeanScore(time),
          ],
          _dubStatusIcon(),
          if (time != null) _timeCard(time),
          if (addtionalWidget != null && !_coverOnly) addtionalWidget!,
          _favoriteCountWidget(),
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
        height: 80,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: CustomPaint(
              foregroundPainter: FadingEffect(
                color: Colors.black,
                start: 5,
                end: 255,
                extend: 10,
              ),
              child: SB.z),
        ),
      ),
    );
  }

  Widget _memberCountMeanScore(String? time) {
    if (showMemberCount && (node is AnimeDetailed || node is MangaDetailed)) {
      final content = node as dynamic;
      final int? memberCount = content.numListUsers;
      final double? meanScore = content.mean;
      if (memberCount == null && meanScore == null) return SB.z;
      return Positioned(
        top: time != null ? 22 : 7,
        left: 5,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Center(
              child: Text(
                "${meanScore == null ? '' : meanScore.toStringAsFixed(2) + ' | '}${memberCount == null ? '' : userCountFormat.format(memberCount)}",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 9),
              ),
            ),
          ),
        ),
      );
    }

    return SB.z;
  }

  Widget _dubStatusIcon() {
    if (!user.pref.showDubStatus || node is! AnimeDetailed) return SB.z;
    if (!category.equals("anime")) return SB.z;
    if (onClose != null) return SB.z;
    
    final content = node as dynamic;
    final int? id = content.id;
    if (id == null) return SB.z;

    IconData? icon;
    if (DubInfoManager().isDubbed(id)) {
      icon = DubIcons.preferredDubIcon;
    } else if (DubInfoManager().isIncomplete(id)) {
      icon = DubIcons.preferredIncompleteDubIcon;
    } else {
      return SB.z;
    }

    return Positioned(
      top: 7,
      right: 5,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Padding(
          padding: DubIcons.preferredPadding,
          child: Center(
            child: Icon(
              icon,
              size: 14,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _recommendationBadge() {
    if (showRecommendations && (node is AnimeDetailed || node is MangaDetailed)) {
      final content = node as dynamic;
      final int? recommendations = content.numRecommendations;

      return Positioned(
        top: 7,
        left: 5,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.people, size: 14, color: Colors.white),
              const SizedBox(width: 4),
              Text(
                userCountFormat.format(recommendations),
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ],
          ),
        ),
      );
    }

    return SB.z;
  }

  Widget _episodeWatchProgressBar(MyListStatus? myListStatus) {
    double? watchProgress;
    double? releaseProgress;
    final episodes = scheduleData?.episode;
    if (node is AnimeDetailed) {
      final listStatus = myListStatus as MyAnimeListStatus?;
      final watched = listStatus?.numEpisodesWatched;
      int? numEpisodes = node.numEpisodes;
      if (episodes != null && episodes > 1) {
        numEpisodes = (episodes + 5);
        releaseProgress = (episodes - 1) / numEpisodes;
      }
      if (watched != null && numEpisodes != null && numEpisodes > 0) {
        watchProgress = watched / numEpisodes;
      }
    }
    if (watchProgress == null) return SB.z;

    return Align(
      alignment: AlignmentDirectional.topCenter,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1.5),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius * 2),
          child: Container(
            height: 2.5,
            width: width,
            color: Colors.grey[500],
            child: Stack(
              children: [
                if (releaseProgress != null)
                  LinearProgressIndicator(
                    value: releaseProgress,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                  ),
                LinearProgressIndicator(
                  value: watchProgress,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _favoriteCountWidget() {
    if (node is AnimeDetailed || node is MangaDetailed) return SB.z;
    final dynamic detailed = node;
    final int? favorites = detailed.favorites;
    if (favorites == null ) return SB.z;

    return Positioned(
      bottom: 5,
      left: 5,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.favorite,
              color: Colors.redAccent,
              size: 12,
            ),
            SizedBox(width: 4),
            Text(
              userCountFormat.format(favorites),
              style: TextStyle(color: Colors.white, fontSize: 10),
            ),
          ],
        ),
      ),
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

  Widget _timeCard(String time) {
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
            time,
            textAlign: TextAlign.center,
            maxFontSize: 10.0,
            minFontSize: 7.0,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

Widget editIconButton(
  NodeStatusValue? value,
  VoidCallback onEdit,
  double borderRadius, [
  dynamic myListStatus,
  OutlinedBorder? shape,
]) {
  Widget child;
  final score = myListStatus?.score as int?;
  final hasScore = score != null && score > 0;
  final bgColor = value?.color ?? Colors.black;
  final textColor = getTextColor(bgColor);
  if (hasScore) {
    child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.star, size: 16, color: textColor),
        Text(
          score.toString(),
          style: TextStyle(
            color: textColor,
            fontSize: 12,
          ),
        ),
      ],
    );
  } else {
    child = Icon(
      Icons.edit,
      size: 16,
      color: textColor,
    );
  }
  return SizedBox(
    width: hasScore ? 40 : 30,
    height: 30,
    child: ShadowButton(
      backgroundColor: bgColor,
      padding: EdgeInsets.zero,
      shape: shape ??
          RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
            topLeft: Radius.circular(borderRadius * 2),
            bottomRight: Radius.circular(borderRadius),
          )),
      onPressed: onEdit,
      child: child,
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
