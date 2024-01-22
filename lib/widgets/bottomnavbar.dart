import 'package:flutter/material.dart';
import 'package:line_icons/line_icon.dart';

class BottomNavBar extends StatefulWidget {
  final startIndex;
  final ValueChanged<int>? onChanged;
  BottomNavBar({this.onChanged, this.startIndex = 0});
  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int pageIndex = 0;
  double iconSize = 20.0;

  Map<int, Icon> lineIconMap = {
    0: LineIcon.home(),
    1: LineIcon.comments(),
    2: LineIcon.list(),
    3: LineIcon.user(),
    4: LineIcon.globe(),
  };

  @override
  void initState() {
    super.initState();
    pageIndex = widget.startIndex ?? 0;
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
        items: List.generate(
            lineIconMap.length,
            (index) => BottomNavigationBarItem(
                  label: '$index',
                  icon: lineIconMap[index]!,
                )));
  }

  void _onPageChange(int index) {
    if (pageIndex != index) {
      widget.onChanged!(index);
      pageIndex = index;
    }
  }
}
