import 'package:dailyanimelist/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SliverWrapper extends StatelessWidget {
  final Widget child;
  const SliverWrapper(this.child, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate([child]),
    );
  }
}

class SliverListWrapper extends StatelessWidget {
  final List<Widget> children;
  const SliverListWrapper(this.children, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate(children),
    );
  }
}

class CustomScrollWrapper extends StatelessWidget {
  final List<Widget> slivers;
  final bool shrink;
  final Axis scrollDirection;
  const CustomScrollWrapper(this.slivers,
      {Key? key, this.shrink = false, this.scrollDirection = Axis.vertical})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      shrinkWrap: shrink,
      physics: shrink ? const NeverScrollableScrollPhysics() : null,
      slivers: slivers,
      scrollDirection: scrollDirection,
    );
  }
}

class SliverAppBarWrapper extends StatelessWidget {
  final Color? backgroundColor;
  final Color? afterScrollBgColor;
  final double expandedHeight;
  final Widget? flexSpace;
  final PreferredSizeWidget? bottom;
  final Widget? title;
  final Widget? Function()? onScrollTitle;
  final bool implyLeading;
  final List<Widget>? actions;
  final double? toolbarHeight;
  final bool snap;
  const SliverAppBarWrapper({
    Key? key,
    this.backgroundColor,
    this.afterScrollBgColor,
    this.expandedHeight = 0,
    this.flexSpace,
    this.implyLeading = true,
    this.bottom,
    this.title,
    this.snap = false,
    this.toolbarHeight,
    this.actions,
    this.onScrollTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return appbar;
  }

  SliverLayoutBuilder get appbar {
    return SliverLayoutBuilder(
      builder: (p0, c) => SliverAppBar(
        automaticallyImplyLeading: implyLeading,
        pinned: true,
        floating: true,
        snap: snap,
        title: onScrollTitle != null ? (c.scrollOffset > 0 ? onScrollTitle!() : null) : title,
        actions: actions,
        backgroundColor: afterScrollBgColor == null
            ? backgroundColor
            : (c.scrollOffset > 0 ? backgroundColor : afterScrollBgColor),
        toolbarHeight: toolbarHeight ?? kToolbarHeight,
        expandedHeight: expandedHeight,
        flexibleSpace: flexSpace != null
            ? FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: flexSpace,
              )
            : null,
        bottom: bottom,
      ),
    );
  }
}
