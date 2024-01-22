import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/main.dart';
import 'package:dailyanimelist/screens/generalsearchscreen.dart';
import 'package:dailyanimelist/widgets/background.dart';
import 'package:dailyanimelist/widgets/customappbar.dart';
import 'package:dailyanimelist/widgets/custombutton.dart';
import 'package:dailyanimelist/widgets/home/bookmarks_widget.dart';
import 'package:flutter/material.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:google_fonts/google_fonts.dart';

void _gotoSearch(BuildContext context) {
  gotoPage(context: context, newPage: GeneralSearchScreen(autoFocus: false));
}

class PlainScreen extends StatelessWidget {
  final Widget child;
  final String title;
  const PlainScreen({Key? key, required this.child, required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TitlebarScreen(child, appbarTitle: title);
  }
}

AppBar simpleAppBar(String title, BuildContext context) {
  return AppBar(title: Text(title), actions: [searchIconButton(context)]);
}

IconButton searchIconButton(BuildContext context) =>
    IconButton(onPressed: () => _gotoSearch(context), icon: Icon(Icons.search));

IconButton bookmarkAction(BuildContext context) => IconButton(
    onPressed: () => gotoPage(context: context, newPage: BookMarksWidget()),
    icon: Icon(Icons.bookmark_outline));

class TitlebarScreen extends StatelessWidget {
  final Widget child;
  final String? appbarTitle;
  final bool useAppbar;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool autoIncludeSearch;
  const TitlebarScreen(
    this.child, {
    Key? key,
    this.appbarTitle,
    this.useAppbar = true,
    this.autoIncludeSearch = true,
    this.actions,
    this.floatingActionButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> _actions = [
      if (autoIncludeSearch) searchIcon(context),
      ...(actions ?? []),
    ];
    return Scaffold(
      floatingActionButton: floatingActionButton,
      appBar: useAppbar
          ? AppBar(
              actions: _actions,
              title: Text(appbarTitle ?? 'DailyAL', style: TextStyle()),
            )
          : null,
      body: child,
    );
  }
}

ToolTipButton searchIcon(BuildContext context) {
  return ToolTipButton(
    usePadding: true,
    message: S.current.Search_Bar_Text,
    onTap: () => _gotoSearch(context),
    child: Icon(Icons.search),
  );
}
