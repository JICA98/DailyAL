import 'package:dailyanimelist/api/maluser.dart';
import 'package:dailyanimelist/main.dart';
import 'package:dailyanimelist/user/user.dart';
import 'package:dailyanimelist/widgets/avatarwidget.dart';
import 'package:dailyanimelist/widgets/customfuture.dart';

import 'package:dal_commons/dal_commons.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icon.dart';

class BottomNavBar extends StatefulWidget {
  final int startIndex;
  final ValueChanged<int>? onChanged;
  BottomNavBar({this.onChanged, this.startIndex = 0});
  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int pageIndex = 0;
  double iconSize = 20.0;

  @override
  void initState() {
    super.initState();
    pageIndex = widget.startIndex;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BottomNavigationBar(
        unselectedItemColor: theme.iconTheme.color?.withOpacity(.5),
        selectedItemColor: theme.iconTheme.color,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: pageIndex,
        enableFeedback: true,
        type: BottomNavigationBarType.shifting,
        onTap: (index) => _onPageChange(index),
        items: [
          BottomNavigationBarItem(
            label: '0',
            icon: LineIcon.home(),
          ),
          BottomNavigationBarItem(
            label: '1',
            icon: LineIcon.comments(),
          ),
          BottomNavigationBarItem(
            label: '2',
            icon: LineIcon.user(),
          ),
          BottomNavigationBarItem(
            label: '3',
            icon: LineIcon.globe(),
          ),
          BottomNavigationBarItem(
            label: '4',
            icon: _userProfileWidget(pageIndex == 4),
          ),
        ]);
  }

  Widget _userProfileWidget(bool isSelected) {
    if (user.status != AuthStatus.AUTHENTICATED) {
      return LineIcon.userCircle();
    }
    return CFutureBuilder<UserProf?>(
      loadingChild: _buildAvatarPlaceholder(isSelected),
      future: MalUser.getUserInfo(
          fields: ["anime_statistics", "manga_statistics"], fromCache: true),
      done: (userProf) {
        return Container(
          height: 27,
          width: 27,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: isSelected
                ? Border.all(
                    color: Theme.of(context).colorScheme.primary, width: 2.0)
                : null,
          ),
          child: AvatarWidget(
            url: userProf.data?.picture,
            height: 27,
            width: 27,
          ),
        );
      },
    );
  }

  Widget _buildAvatarPlaceholder(bool isSelected) {
    return Container(
      height: 27,
      width: 27,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: isSelected
            ? Border.all(
                color: Theme.of(context).colorScheme.primary, width: 2.0)
            : null,
      ),
      child: CircleAvatar(
        backgroundColor: Colors.grey,
        radius: 13.5,
      ),
    );
  }

  void _onPageChange(int index) {
    if (pageIndex != index) {
      widget.onChanged!(index);
      pageIndex = index;
    }
  }
}
