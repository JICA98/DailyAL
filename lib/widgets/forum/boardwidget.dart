import 'package:dailyanimelist/screens/forumtopicsscreen.dart';
import 'package:dailyanimelist/widgets/avatarwidget.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../constant.dart';
import '../../main.dart';

class BoardWidget extends StatefulWidget {
  final Forum forum;
  final forunIndex;
  BoardWidget({required this.forum, this.forunIndex = 0});
  @override
  _BoardWidgetState createState() => _BoardWidgetState();
}

class _BoardWidgetState extends State<BoardWidget>
    with TickerProviderStateMixin {
  late AnimationController buttonController;
  bool isOpen = false;
  final Map<int, List<IconData>> boardIcons = {
    0: [
      Icons.announcement,
      Icons.info,
      Icons.storage,
      Icons.support_rounded,
      Icons.bubble_chart,
      Icons.wine_bar_rounded,
      Icons.ac_unit
    ],
    1: [
      Icons.new_releases_sharp,
      Icons.recommend,
      Icons.people_alt_rounded,
      Icons.animation,
      Icons.book
    ],
    2: [
      Icons.add_to_queue_sharp,
      Icons.gamepad,
      Icons.music_note,
      Icons.fiber_new_sharp,
      Icons.opacity,
      Icons.content_cut,
      Icons.games_outlined
    ],
  };

  final List<String> forumImages = [
    "assets/images/mal-icon.png",
    "assets/images/anime-icon.png",
    "assets/images/general-icon.png",
  ];

  @override
  void initState() {
    super.initState();

    buttonController = new AnimationController(
        vsync: this, duration: Duration(milliseconds: 450));
  }

  expandWidget() {
    animateIcon();
    showCupertinoModalPopup(
        context: context,
        builder: (context) => Material(
              child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: 300),
                  child: showBoards()),
            )).whenComplete(() => animateIcon());
  }

  animateIcon() {
    isOpen = !isOpen;
    isOpen ? buttonController.forward() : buttonController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Material(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                  child: ListTile(
                    onTap: () {
                      expandWidget();
                    },
                    contentPadding:
                        EdgeInsets.only(top: 10, bottom: 10, right: 10),
                    leading: AvatarWidget(
                      height: 50,
                      width: 50,
                      radius: BorderRadius.circular(7),
                      isNetworkImage: false,
                      url: forumImages.elementAt(
                          widget.forunIndex > 2 ? 0 : widget.forunIndex),
                    ),
                    title: Text(widget.forum.title ?? ''),
                    trailing: IconButton(
                      onPressed: () {
                        expandWidget();
                      },
                      icon: AnimatedIcon(
                        icon: AnimatedIcons.list_view,
                        progress: buttonController,
                      ),
                      iconSize: 16,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
        // AnimatedSize(
        //   child: isOpen ? showBoards() : Container(),
        //   vsync: this,
        //   duration: Duration(milliseconds: 350),
        // ),
      ],
    );
  }

  Widget showBoards() {
    var boards = widget.forum.boards;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: boards!.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        var board = boards.elementAt(index);
        return ListTile(
          onTap: board.subBoards == null || board.subBoards!.isEmpty
              ? () {
                  gotoPage(
                      context: context,
                      newPage: ForumTopicsScreen(
                        boardId: board.id,
                        title: board.title,
                      ));
                }
              : null,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          title: title(board.title ?? "Title", opacity: 1, fontSize: 15),
          subtitle: title(board.description ?? "", fontSize: 12),
          trailing: board.subBoards == null || board.subBoards!.isEmpty
              ? null
              : PopupMenuButton<SubBoard>(
                  icon: Icon(Icons.more_vert),
                  onSelected: (value) {
                    gotoPage(
                        context: context,
                        newPage: ForumTopicsScreen(
                          // boardId: board.id,
                          subBoardId: value.id,
                          title: value.title,
                        ));
                  },
                  itemBuilder: (context) => board.subBoards!
                      .map((e) => PopupMenuItem(
                          value: e, enabled: true, child: Text(e.title ?? '')))
                      .toList(),
                ),
          leading: Icon(
            boardIcons[widget.forunIndex]?.elementAt(index) ??
                Icons.disabled_by_default,
          ),
        );
      },
    );
  }
}
