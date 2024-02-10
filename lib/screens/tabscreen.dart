import 'package:dailyanimelist/screens/plainscreen.dart';
import 'package:dailyanimelist/widgets/customfuture.dart';
import 'package:dailyanimelist/widgets/shimmecolor.dart';
import 'package:flutter/material.dart';
import 'package:dal_commons/dal_commons.dart';

class TabScreen<T> extends StatefulWidget {
  final String title;
  final Widget Function(T?) header;
  final Map<String, Widget> Function(T?) tabs;
  final String primaryCategory;
  final Future<T> future;
  final List<Widget>? Function(T?)? actions;
  final Widget? Function(T?)? floatingActionButton;
  const TabScreen({
    Key? key,
    required this.header,
    required this.tabs,
    this.primaryCategory = "anime",
    required this.future,
    required this.title,
    this.actions,
    this.floatingActionButton,
  }) : super(key: key);

  @override
  _TabScreenState<T> createState() => _TabScreenState<T>();
}

class _TabScreenState<T> extends State<TabScreen<T>> {
  late Future<T> future;

  @override
  void initState() {
    super.initState();

    future = widget.future;
  }

  @override
  Widget build(BuildContext context) {
    return CFutureBuilder<T>(
      future: future,
      done: (snapshot) => Scaffold(
        body: nestedScrollView(snapshot.data),
        floatingActionButton: widget.floatingActionButton == null
            ? null
            : widget.floatingActionButton!(snapshot.data),
      ),
      loadingChild: Scaffold(
        body: ShimmerColor(nestedScrollView()),
        appBar: simpleAppBar(widget.title, context),
      ),
    );
  }

  PreferredSizeWidget tabsWidget(List<String> tabs) {
    return TabBar(
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      tabs: tabs.map((e) => Tab(text: e.standardize() ?? '')).toList(),
    );
  }

  Widget nestedScrollView([T? featured]) {
    var tabs = widget.tabs(featured);
    return DefaultTabController(
      initialIndex: 0,
      length: tabs.length,
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            pinned: true,
            floating: true,
            expandedHeight: 340,
            flexibleSpace: ShimmerConditionally(
                showShimmer: featured == null, child: widget.header(featured)),
            title: innerBoxIsScrolled ? Text(widget.title) : null,
            bottom: tabsWidget(tabs.keys.toList()),
            actions: [
              ...(widget.actions != null
                  ? (widget.actions!(featured) ?? [])
                  : []),
              searchIconButton(context),
            ],
          ),
        ],
        body: TabBarView(children: tabs.values.toList()),
      ),
    );
  }
}
