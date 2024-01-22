import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:dailyanimelist/api/maluser.dart';
import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/enums.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/main.dart';
import 'package:dailyanimelist/pages/settingspage.dart';
import 'package:dailyanimelist/screens/generalsearchscreen.dart';
import 'package:dailyanimelist/user/user.dart';
import 'package:dailyanimelist/widgets/avatarwidget.dart';
import 'package:dailyanimelist/widgets/customfuture.dart';
import 'package:dailyanimelist/widgets/home/bookmarks_widget.dart';
import 'package:dailyanimelist/widgets/selectbottom.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum AppBarMode { color, transparent }

class AppbarMenuItem {
  final String text;
  final Widget? icon;
  VoidCallback? onTap;
  AppbarMenuItem(this.text, this.icon, {this.onTap});
  AppbarMenuItem copy() {
    return AppbarMenuItem(text, icon);
  }

  AppbarMenuItem copyWithTap() {
    return AppbarMenuItem(text, icon, onTap: onTap);
  }
}

final createIcon = (IconData iconData) => Icon(iconData);

final shareMenuItem =
    () => AppbarMenuItem(S.current.Share, createIcon(Icons.share)).copy();

final browserMenuItem = () =>
    AppbarMenuItem(S.current.Open_In_Browser, createIcon(Icons.language))
        .copy();
final bookMarkMenuItem = (BuildContext context) =>
    AppbarMenuItem(S.current.Bookmarks, createIcon(Icons.bookmark),
        onTap: () => gotoPage(
              context: context,
              newPage: BookMarksWidget(),
            )).copyWithTap();

class AppMenuWidget extends StatelessWidget {
  final List<AppbarMenuItem> menuItems;
  final VoidCallback onUserTap;
  final UserProf? userProf;
  final Widget? child;
  final BoxConstraints? constraints;
  const AppMenuWidget({
    super.key,
    required this.menuItems,
    required this.onUserTap,
    this.userProf,
    this.child,
    this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<AppbarMenuItem>(
      tooltip: S.current.Show_Menu,
      child: child,
      constraints: constraints,
      padding: EdgeInsets.zero,
      onSelected: (value) => value.onTap == null ? onUserTap() : value.onTap!(),
      itemBuilder: (_) => menuItems
          .map((e) => PopupMenuItem<AppbarMenuItem>(
                value: e,
                child: Row(
                  children: [
                    if (e.icon != null)
                      e.icon!
                    else
                      _buildAvatarWidget(userProf, onUserTap,
                          padding: EdgeInsets.zero, disableTap: true),
                    SB.w10,
                    Expanded(
                      child: Text(e.text, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

void _onAvatarTap({
  required BuildContext context,
  UserProf? userProf,
  void Function()? onUiChange,
}) {
  showModalBottomSheet(
    isScrollControlled: true,
    useRootNavigator: true,
    isDismissible: true,
    context: context,
    builder: (context) => SettingsPage(
      onUiChange: () => onUiChange != null ? onUiChange() : null,
    ),
  );
}

Material _buildAvatarWidget(
  UserProf? userProf,
  VoidCallback? onUserTap, {
  EdgeInsetsGeometry padding =
      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
  bool disableTap = false,
}) {
  return Material(
    color: Colors.transparent,
    child: Padding(
      padding: padding,
      child: Container(
        height: 25,
        width: 25,
        child: AvatarWidget(
          url: userProf?.picture,
          onTap: disableTap ? null : onUserTap,
        ),
      ),
    ),
  );
}

class PopupMenuBuilder extends StatelessWidget {
  final List<AppbarMenuItem> menuItems;
  final bool includeUserProf;
  const PopupMenuBuilder({
    Key? key,
    required this.menuItems,
    this.includeUserProf = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (includeUserProf) {
      return StateFullFutureWidget<UserProf>(
        loadingChild: SB.z,
        future: () => MalUser.getUserInfo(
            fields: ["anime_statistics", "manga_statistics"], fromCache: true),
        done: (sht) => _buildPopupMenu(sht.data!, context),
      );
    } else {
      return _buildPopupMenu(null, context);
    }
  }

  PopupMenuButton<AppbarMenuItem> _buildPopupMenu(
      UserProf? sht, BuildContext context) {
    return PopupMenuButton<AppbarMenuItem>(
      tooltip: S.current.Show_Menu,
      icon: Icon(Icons.more_vert),
      constraints: const BoxConstraints(
        minWidth: 2.0 * 38.0,
        maxWidth: 3.5 * 56.0,
      ),
      onSelected: (value) => value.onTap == null
          ? _onAvatarTap(context: context, userProf: sht)
          : value.onTap!(),
      itemBuilder: (_) => [
        ...menuItems,
        if (includeUserProf) AppbarMenuItem(S.current.Settings, null)
      ]
          .map((e) => PopupMenuItem<AppbarMenuItem>(
                value: e,
                child: Row(
                  children: [
                    if (e.icon != null)
                      e.icon!
                    else if (sht != null)
                      _buildAvatarWidget(
                        sht,
                        null,
                        padding: EdgeInsets.zero,
                        disableTap: true,
                      ),
                    SB.w10,
                    Expanded(
                      child: Text(
                        e.text,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}
