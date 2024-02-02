import 'package:cached_network_image/cached_network_image.dart';
import 'package:dailyanimelist/api/dalapi.dart';
import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/main.dart';
import 'package:dailyanimelist/pages/animedetailed/synopsiswidget.dart';
import 'package:dailyanimelist/screens/contentdetailedscreen.dart';
import 'package:dailyanimelist/screens/generalsearchscreen.dart';
import 'package:dailyanimelist/screens/plainscreen.dart';
import 'package:dailyanimelist/util/pathutils.dart';
import 'package:dailyanimelist/widgets/avatarwidget.dart';
import 'package:dailyanimelist/widgets/common/image_preview.dart';
import 'package:dailyanimelist/widgets/common/share_builder.dart';
import 'package:dailyanimelist/widgets/customappbar.dart';
import 'package:dailyanimelist/widgets/custombutton.dart';
import 'package:dailyanimelist/widgets/customfuture.dart';
import 'package:dailyanimelist/widgets/home/animecard.dart';
import 'package:dailyanimelist/widgets/home/bookmarks_widget.dart';
import 'package:dailyanimelist/widgets/slivers.dart';
import 'package:dailyanimelist/widgets/translator.dart';
import 'package:dailyanimelist/widgets/user/contentlistwidget.dart';
import 'package:dal_commons/commons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class InterestStackContentList extends StatelessWidget {
  final DisplayType type;
  final double horizPadding;
  final List<InterestStack> interestStacks;
  static BorderRadius radius = BorderRadius.circular(12.0);
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  const InterestStackContentList({
    Key? key,
    required this.horizPadding,
    required this.interestStacks,
    this.shrinkWrap = false,
    this.padding,
    this.type = DisplayType.list_horiz,
  }) : super(key: key);

  bool get isHoriz => type == DisplayType.list_horiz;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isHoriz ? 240 : null,
      child: ListView.builder(
        scrollDirection: isHoriz ? Axis.horizontal : Axis.vertical,
        shrinkWrap: shrinkWrap,
        physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
        padding: padding ??
            (isHoriz
                ? EdgeInsets.symmetric(horizontal: horizPadding + 15.0)
                : EdgeInsets.symmetric(vertical: 20, horizontal: 5)),
        itemCount: interestStacks.length,
        itemBuilder: (context, index) {
          final item = interestStacks.tryAt(index);
          final imageList =
              List<String>.from((item!.imageUrls ?? <String>[]).reversed);
          return Padding(
            padding:
                EdgeInsets.symmetric(horizontal: 5, vertical: isHoriz ? 0 : 10),
            child: Container(
              width: isHoriz ? 310 : null,
              child: Material(
                borderRadius: radius,
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => gotoPage(
                    context: context,
                    newPage: InterestStackDetailedWidget(item),
                  ),
                  borderRadius: radius,
                  splashColor: Theme.of(context).splashColor,
                  child: Row(
                    crossAxisAlignment: isHoriz
                        ? CrossAxisAlignment.center
                        : CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: isHoriz ? 170 : 130,
                        height: isHoriz ? null : 230,
                        child: _buildStackPicttures(context, imageList,
                            radius: radius),
                      ),
                      SB.w15,
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isHoriz) SB.h10,
                            title(
                              item.title?.standardize() ?? '',
                              opacity: 1,
                              fontSize: 16,
                              textOverflow: TextOverflow.fade,
                            ),
                            _usernameWidget(context, item.username),
                            SB.h15,
                            title('${item.entries ?? 0} ${S.current.Entries}',
                                fontSize: 11),
                            SB.h5,
                            title('${item.reStacks ?? 0} ${S.current.Restacks}',
                                fontSize: 11),
                            if (!isHoriz &&
                                item.updatedAt != null &&
                                item.updatedAt!.isNotBlank) ...[
                              SB.h10,
                              title(item.updatedAt, fontSize: 11),
                            ],
                            if (!isHoriz &&
                                item.description != null &&
                                item.description!.isNotBlank) ...[
                              SB.h10,
                              Container(
                                constraints: BoxConstraints(maxHeight: 240.0),
                                child: title(
                                  item.description,
                                  textOverflow: TextOverflow.fade,
                                ),
                              ),
                            ]
                          ],
                        ),
                      )
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

Widget _buildStackPicttures(BuildContext context, List<String> imageList,
    {BorderRadius? radius}) {
  if (nullOrEmpty(imageList)) {
    return cachedImage(radius ?? BorderRadius.circular(6.0), 'url',
        useUserImageOnError: false);
  }
  return Stack(
    children: imageList.asMap().entries.map((e) {
      return Positioned(
        right: e.key * 20.0,
        top: e.key * 10.0 + 10.0,
        bottom: e.key * 10.0 + 10.0,
        child: InkWell(
          onTap: () => zoomInImageList(context, imageList.reversed.toList()),
          child: Container(
            decoration: BoxDecoration(boxShadow: [BoxShadow(blurRadius: 10.0)]),
            child: CachedNetworkImage(
              fit: BoxFit.cover,
              imageUrl: e.value,
            ),
          ),
        ),
      );
    }).toList(),
  );
}

Widget _usernameWidget(
  BuildContext context,
  String? username, [
  bool adBy = true,
  EdgeInsetsGeometry? padding,
]) {
  final String usernameText = adBy ? 'by ${username ?? "?"}' : (username ?? '');

  if (username != null) {
    return Padding(
      padding: padding ?? EdgeInsets.only(top: 15),
      child: conditional(
        on: !invalidUserNames.contains(username),
        child: title(usernameText),
        parent: (ch) => ToolTipButton(
          message: usernameText,
          onTap: () => showUserPage(context: context, username: username),
          child: ch,
        ),
      ),
    );
  } else {
    return SB.z;
  }
}

DalNode? _buildDalNode(InterestStack? stack) {
  if (stack == null) return null;
  return DalNode(
    category: 'stacks',
    id: stack!.id!,
  );
}

class InterestStackDetailedWidget extends StatelessWidget {
  final InterestStack? stack;
  const InterestStackDetailedWidget(this.stack, {Key? key}) : super(key: key);
  static const horizPadding = 25.0;
  static const padding = const EdgeInsets.symmetric(horizontal: horizPadding);

  String _title(InterestStackDetailed? detailed) {
    return detailed?.node?.title?.standardize() ??
        stack?.title?.standardize() ??
        S.current.Interest_Stack;
  }

  bool content(InterestStackDetailed? detailed) =>
      !nullOrEmpty(detailed?.contentDetailedList);

  bool similar(InterestStackDetailed? detailed) =>
      !nullOrEmpty(detailed?.similarStacks);

  bool mal(InterestStackDetailed? detailed) =>
      !nullOrEmpty(detailed?.myAnimeListStacks);

  @override
  Widget build(BuildContext context) {
    return _buildFutureWidget(
      (detailed) => TitlebarScreen(
        Stack(
          children: [
            conditional(
              on: detailed != null,
              child: NestedScrollView(
                headerSliverBuilder: (_, i) => _topSlivers(context, detailed),
                body: _bodyWidget(detailed),
              ),
              parent: (child) => DefaultTabController(
                length: _tabs(detailed).length,
                child: child,
              ),
            ),
            _buildBackButton(context, detailed),
          ],
        ),
        useAppbar: false,
        floatingActionButton: _buildFloatingAction(detailed),
      ),
    );
  }

  BookMarkFloatingButton? _buildFloatingAction(
    InterestStackDetailed? detailed,
  ) {
    if (stack?.id != null || detailed != null) {
      return BookMarkFloatingButton(
          type: BookmarkType.interestStacks, id: stack!.id!, data: stack);
    }
    return null;
  }

  List<Widget> _topSlivers(
    BuildContext context,
    InterestStackDetailed? detailed,
  ) {
    return [
      SB.lh60,
      SliverWrapper(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SB.w20,
            Expanded(child: _titleWidget(context, detailed)),
            SB.w20,
            _picturesWidget(context, detailed),
            SB.w20,
          ],
        ),
      ),
      SB.lh10,
      if (detailed == null)
        _loading
      else ...[
        _dateWidget(detailed),
        SB.lh10,
        if (detailed.node?.description != null &&
            detailed.node!.description!.isNotBlank)
          SliverWrapper(SysonpsisWidget(
            genres: [],
            synopsis: detailed.node?.description ?? '',
            characterLimit: 400,
          )),
        SB.lh10,
        if (showTabs(detailed)) _tabBar(detailed)
      ],
    ];
  }

  bool showTabs(InterestStackDetailed? detailed) {
    return content(detailed) && similar(detailed) && mal(detailed);
  }

  List<String> _tabs(InterestStackDetailed? detailed) => [
        if (content(detailed)) S.current.Entries.standardize()!,
        if (similar(detailed)) S.current.Similar,
        if (mal(detailed)) 'MAL ${S.current.Interest_Stacks}',
      ];

  Widget _tabBar(InterestStackDetailed detailed) => SliverWrapper(
        TabBar(
          isScrollable: true,
          padding: padding,
          tabs: _tabs(detailed)
              .map((e) => Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 3, vertical: 6),
                    child: Text(
                      e,
                      style: TextStyle(fontSize: 15.0),
                    ),
                  ))
              .toList(),
        ),
      );

  StateFullFutureWidget<InterestStackDetailed?> _buildFutureWidget(
      Widget Function(InterestStackDetailed?) child) {
    return StateFullFutureWidget<InterestStackDetailed>(
      future: () => DalApi.i.getInterestStackDetailed(stack!.id!),
      done: (sp) {
        if (sp.data == null) {
          return child(null);
        } else {
          return child(sp.data);
        }
      },
      loadingChild: child(null),
    );
  }

  Container _picturesWidget(
      BuildContext context, InterestStackDetailed? detailed) {
    return Container(
      height: 240,
      width: 170,
      child: _buildStackPicttures(
          context, stack?.imageUrls!.reversed.toList() ?? []),
    );
  }

  Column _titleWidget(BuildContext context, InterestStackDetailed? detailed) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        title(
          _title(detailed),
          opacity: 1,
          fontSize: 18,
          align: TextAlign.center,
        ),
        SB.h15,
        _usernameWidget(
            context, stack?.username, true, const EdgeInsets.only(top: 2)),
      ],
    );
  }

  Widget get _loading => SliverWrapper(
        Padding(
          padding: const EdgeInsets.only(top: 40),
          child: loadingCenterColored,
        ),
      );

  Widget _buildBackButton(
      BuildContext context, InterestStackDetailed? detailed) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 40.0),
        child: FloatingActionButton.extended(
          elevation: 8.0,
          onPressed: () {},
          icon: _buildIconBtn(() => Navigator.pop(context), Icons.arrow_back),
          extendedPadding: EdgeInsets.zero,
          label: PopupMenuBuilder(
            menuItems: [
              shareMenuItem()
                ..onTap = () => openShareBuilder(
                    context,
                    buildShareInputs(detailed?.node ?? stack,
                        _buildDalNode(stack)?.toUrl() ?? ''),
                    S.current.Interest_Stack),
              browserMenuItem()
                ..onTap = () => launchURLWithConfirmation(
                    _buildDalNode(stack)?.toUrl() ?? '',
                    context: context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconBtn(
    VoidCallback onTap,
    IconData iconData,
  ) {
    return IconButton(
      icon: Icon(iconData),
      onPressed: onTap,
    );
  }

  _dateWidget(InterestStackDetailed? detailed) {
    return SliverWrapper(Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (detailed?.createdAt != null)
            title(detailed!.createdAt!, fontSize: 10),
          if (detailed?.createdAt != null && detailed?.node?.updatedAt != null)
            title(' · '),
          if (detailed?.node?.updatedAt != null)
            title(detailed!.node!.updatedAt, fontSize: 10)
        ],
      ),
    ));
  }

  _bodyWidget(InterestStackDetailed? detailed) {
    if (!showTabs(detailed)) return SB.z;
    return TabBarView(
      children: [
        if (content(detailed))
          _buildContentScrollView(detailed!.contentDetailedList!),
        if (similar(detailed))
          _buildInterestStackList(detailed!.similarStacks!),
        if (mal(detailed))
          _buildInterestStackList(detailed!.myAnimeListStacks!),
      ],
    );
  }

  InterestStackContentList _buildInterestStackList(
      List<InterestStack> interestStacks) {
    return InterestStackContentList(
      horizPadding: horizPadding,
      interestStacks: interestStacks,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      type: DisplayType.list_vert,
    );
  }

  _buildContentScrollView(List<AnimeDetailed> contentDetailedList) {
    return ListView.builder(
      itemCount: contentDetailedList.length,
      padding: const EdgeInsets.only(top: 10.0, bottom: 60.0),
      itemBuilder: (context, index) {
        final item = contentDetailedList[index];
        final String category =
            item.additonalInfo!.contains('vol') ? 'manga' : 'anime';
        return SpaciousContentWidget(category: category, item: item);
      },
    );
  }
}

class SpaciousContentWidget extends StatelessWidget {
  const SpaciousContentWidget({
    super.key,
    required this.category,
    required this.item,
    this.value,
    this.showStatus = true,
    this.nodeTitle,
    this.updateCache = true,
    this.onEdit,
    this.leadingAdditional,
    this.mediaText,
    this.additonalText,
    this.selfStatusWidget,
    this.bottomWidget,
  });
  final String category;
  final dynamic item;
  final NodeStatusValue? value;
  final bool showStatus;
  final String? nodeTitle;
  final bool updateCache;
  final VoidCallback? onEdit;
  final Widget? leadingAdditional;
  final String? mediaText;
  final String? additonalText;
  final Widget? selfStatusWidget;
  final Widget? bottomWidget;

  @override
  Widget build(BuildContext context) {
    String? additional;
    try {
      additional = additonalText ??
          item.additonalInfo
              ?.toString()
              .replaceAll('\n', '')
              .replaceAll(' ', '')
              .replaceFirst(',', ', ');
    } catch (e) {}
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(6.0),
          onTap: () => gotoPage(
              context: context,
              newPage: ContentDetailedScreen(
                category: category,
                id: item.id,
              )),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _leading(),
                _trailing(context, additional),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Expanded _trailing(BuildContext context, String? additional) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _starMemberWidget(item, context, category),
            SB.h15,
            title(nodeTitle ?? getNodeTitle(item), fontSize: 18, opacity: 1),
            SB.h15,
            if (item.status != null ||
                item.additonalInfo != null ||
                item.mediaType != null ||
                mediaText != null)
              title(
                '${mediaText ?? item.mediaType?.toString().capitalize() ?? ''} · ${item.status?.toString().standardize() ?? '?'}${additional != null ? ' · ${additional}' : ''}',
                fontSize: 12,
              ),
            SB.h20,
            if (!nullOrEmpty(item.genres)) _genresWidget(),
            if (bottomWidget != null) ...[
              SB.h15,
              bottomWidget!,
            ],
          ],
        ),
      ),
    );
  }

  Container _genresWidget() {
    return Container(
      height: 27,
      child: ListView.builder(
        itemCount: item.genres!.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, i) => Padding(
          padding: const EdgeInsets.only(right: 5, bottom: 3),
          child: ShadowButton(
            onPressed: () => onGenrePress(item.genres![i], category, context),
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: title(
              convertGenre(item.genres![i], category).replaceAll("_", " "),
              opacity: 1,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }

  Widget _leading() {
    var avatarWidget = Padding(
      padding: const EdgeInsets.only(left: 10),
      child: AvatarWidget(
        height: 150.0,
        url: item.mainPicture?.large ?? item.mainPicture?.medium,
        userRoundBorderforLoading: false,
        useUserImageOnError: false,
        radius: BorderRadius.circular(6.0),
      ),
    );
    if (leadingAdditional == null) {
      return avatarWidget;
    } else {
      return Stack(
        children: [
          avatarWidget,
          SB.h10,
          leadingAdditional!,
        ],
      );
    }
  }

  Widget _starMemberWidget(
    dynamic detailed,
    BuildContext context,
    String category,
  ) {
    Widget leading;
    if (selfStatusWidget != null) {
      leading = selfStatusWidget!;
    } else {
      String? numListUsersFormatted;
      try {
        numListUsersFormatted = detailed.numListUsersFormatted;
      } catch (e) {}
      if (detailed.numListUsers != null) {
        numListUsersFormatted ??=
            NumberFormat.compact().format(detailed.numListUsers);
      }
      leading = Row(
        children: [
          Container(
            height: 15,
            child: Image.asset("assets/images/star.png"),
          ),
          SB.w5,
          title(
            detailed.mean?.toStringAsFixed(1) ?? '-',
            fontSize: 15,
            opacity: 1,
          ),
          SB.w10,
          if (numListUsersFormatted != null)
            title(
              '($numListUsersFormatted)',
              textOverflow: TextOverflow.ellipsis,
              opacity: .7,
            )
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        leading,
        Spacer(),
        SB.w10,
        if (detailed.synopsis != null) _synopsisWidget(context, detailed),
        SB.w10,
        editIconButton(
          value,
          () {
            if (onEdit != null) {
              onEdit!();
            } else {
              showContentEditSheet(
                context,
                category,
                detailed,
                updateCache: updateCache,
              );
            }
          },
          6.0,
        ),
        SB.w10,
      ],
    );
  }

  Widget _iconBtn(IconData iconData, VoidCallback onTap) {
    return SizedBox(
      height: 35,
      width: 35,
      child: IconButton.filledTonal(
        onPressed: onTap,
        icon: Icon(iconData),
        iconSize: 20.0,
      ),
    );
  }

  Widget _synopsisWidget(BuildContext context, AnimeDetailed detailed) {
    return _iconBtn(
      Icons.info_outline,
      () => openAlertDialog(
        context: context,
        title: S.current.Synopsis,
        useCloseBtn: true,
        useDefaultBtns: false,
        content: SingleChildScrollView(
          child: TranslaterWidget(
            reversed: true,
            content: detailed.synopsis,
            done: (p0) => title(p0),
          ),
        ),
      ),
    );
  }
}
