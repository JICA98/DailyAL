import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/pages/settings_page.dart';

import 'package:dailyanimelist/user/user.dart';
import 'package:dailyanimelist/widgets/custombutton.dart';
import 'package:dailyanimelist/widgets/home/bookmarks_widget.dart';
import 'package:dailyanimelist/widgets/home/anime_calendar.dart';
import 'package:dal_commons/commons.dart';
import 'package:flutter/material.dart';

import '../api/maluser.dart';
import '../constant.dart';
import '../main.dart';
import '../screens/generalsearchscreen.dart';

Future<UserProf> _userProfileFuture = MalUser.getUserInfo(
    fields: ["anime_statistics", "manga_statistics"], fromCache: true);

void _refreshFuture() {
  _userProfileFuture = MalUser.getUserInfo(
      fields: ["anime_statistics", "manga_statistics"], fromCache: true);
}

class AppBarHome extends StatefulWidget {
  final VoidCallback? onUiChange;
  final Widget? titleWidget;
  const AppBarHome({
    Key? key,
    this.onUiChange,
    this.titleWidget,
  }) : super(key: key);

  @override
  State<AppBarHome> createState() => _AppBarHomeState();
}

class _AppBarHomeState extends State<AppBarHome> {
  static const horizPadding = 20.0;
  static const iconSize = 20.0;
  UserProf? userProf;

  @override
  void initState() {
    super.initState();
    if (user.status == AuthStatus.AUTHENTICATED) getUserProfile();
    user.addListener(() {
      if (user.status == AuthStatus.AUTHENTICATED) {
        _refreshFuture();
        getUserProfile();
      }
    });
  }

  getUserProfile() async {
    try {
      userProf = await _userProfileFuture;
      if (mounted) setState(() {});
    } catch (e) {
      logDal(e);
    }
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: horizPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          widget.titleWidget ??
              SizedBox(
                height: 35,
                width: 35,
                child: CircleAvatar(
                  backgroundImage: AssetImage('assets/images/dal-black-bg.png'),
                  radius: 48.0,
                ),
              ),
          Expanded(child: SB.z),
          _appBarActions(),
        ],
      ),
    );
  }

  ToolTipButton _searchButton() {
    return ToolTipButton(
      message: S.current.Search_Bar_Text,
      padding: const EdgeInsets.symmetric(horizontal: 7.0),
      usePadding: true,
      onTap: () => gotoPage(context: context, newPage: GeneralSearchScreen()),
      child: Icon(Icons.search, size: iconSize),
    );
  }

  Widget _appBarActions() {
    return SizedBox(
      height: 29.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          PlainButton(
            onPressed: () {},
            padding: EdgeInsets.symmetric(horizontal: 5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _searchButton(),
                SB.w10,
                _bookMarksButton(),
                SB.w10,
                _calendarButton(),
                SB.w10,
                _settingsIcon
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget get _settingsIcon {
    return ToolTipButton(
      message: S.current.Settings,
      padding: const EdgeInsets.symmetric(horizontal: 7.0),
      usePadding: true,
      onTap: () => gotoPage(context: context, newPage: SettingsPage()),
      child: Icon(Icons.settings_outlined, size: iconSize),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildTopBar();
  }

  Widget _calendarButton() {
    return ToolTipButton(
      message: S.current.AnimeCalendar,
      padding: const EdgeInsets.symmetric(horizontal: 7.0),
      usePadding: true,
      onTap: () => gotoPage(context: context, newPage: AnimeCalendarWidget()),
      child: Icon(Icons.calendar_today_outlined, size: iconSize),
    );
  }

  Widget _bookMarksButton() {
    return ToolTipButton(
      message: S.current.Bookmarks,
      usePadding: true,
      padding: const EdgeInsets.symmetric(horizontal: 7.0),
      onTap: () => gotoPage(context: context, newPage: BookMarksWidget()),
      child: Icon(Icons.bookmark_outline, size: iconSize),
    );
  }
}
