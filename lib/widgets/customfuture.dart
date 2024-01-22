import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/extensions.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/screens/generalsearchscreen.dart';
import 'package:dailyanimelist/user/hompagepref.dart';
import 'package:flutter/material.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class CFutureBuilder<T> extends StatelessWidget {
  final Function(AsyncSnapshot<T>) done;
  final Widget loadingChild;
  final Future<T>? future;
  final ValueChanged<Object?>? onError;
  const CFutureBuilder({
    Key? key,
    required this.future,
    required this.done,
    required this.loadingChild,
    this.onError,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
        future: future,
        builder: (_, snapshot) {
          if (snapshot.hasError && onError != null) {
            onError!(snapshot.error);
            return done(AsyncSnapshot.nothing());
          }
          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.done) {
            return done(snapshot);
          } else {
            return loadingChild;
          }
        });
  }
}

class StateFullFutureWidget<T> extends StatefulWidget {
  final Widget Function(AsyncSnapshot<T>) done;
  final Widget loadingChild;
  final ValueChanged<Object?>? onError;
  final Future<T> Function() future;
  final String? refKey;
  const StateFullFutureWidget({
    Key? key,
    required this.done,
    required this.loadingChild,
    required this.future,
    this.refKey,
    this.onError,
  }) : super(key: key);

  @override
  State<StateFullFutureWidget<T>> createState() =>
      _StateFullFutureWidgetState<T>();
}

class _StateFullFutureWidgetState<T> extends State<StateFullFutureWidget<T>>
    with AutomaticKeepAliveClientMixin {
  late Future<T> future;

  @override
  void initState() {
    super.initState();
    future = widget.future();
  }

  @override
  void didUpdateWidget(covariant StateFullFutureWidget<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (mounted &&
        oldWidget.refKey != null &&
        widget.refKey != null &&
        !oldWidget.refKey!.equals(widget.refKey)) {
      setState(() {
        future = widget.future();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CFutureBuilder(
      future: future,
      done: widget.done,
      loadingChild: widget.loadingChild,
      onError: widget.onError,
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class PageItem<T> {
  final List<T> rowItems;
  PageItem(this.rowItems);
}

class InfinitePagination<T> extends StatefulWidget {
  final Future<List<T>> Function(int pageIndex) future;
  final Widget Function(BuildContext _, PageItem<T> item, int index)
      itemBuilder;
  final String? refKey;
  final int pageSize;
  final int initialIndex;
  final DisplayType displayType;
  final int gridChildCount;
  final ScrollController? scrollController;
  final bool enableCustomFilter;
  final List<T> Function(List<List<T>> items)? customFilterBuilder;
  final String? customFilterKey;
  final ValueChanged<int>? countChange;

  const InfinitePagination({
    Key? key,
    required this.future,
    required this.pageSize,
    this.refKey,
    this.initialIndex = 0,
    required this.itemBuilder,
    this.gridChildCount = 2,
    this.scrollController,
    this.displayType = DisplayType.list_vert,
    this.enableCustomFilter = false,
    this.customFilterBuilder,
    this.countChange,
    this.customFilterKey,
  }) : super(key: key);

  @override
  State<InfinitePagination<T>> createState() => _InfinitePaginationState<T>();
}

class _InfinitePaginationState<T> extends State<InfinitePagination<T>> {
  int pageIndex = 0;
  int _pageSize = 20;
  ScrollController? _scrollController;
  late PagingController<int, List<T>> _pagingController;
  bool fetchingPage = false;

  @override
  void initState() {
    super.initState();
    _pagingController = PagingController(firstPageKey: 0)
      ..addPageRequestListener((pageKey) {
        _fetchPage(pageKey);
      });
    _pageSize = widget.pageSize;
    _scrollController = widget.scrollController;
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems = (await widget.future(pageKey)) ?? [];
      final isLastPage = newItems.length < _pageSize;
      final chunked = transformItems(newItems);
      if (isLastPage) {
        _pagingController.appendLastPage(chunked);
      } else {
        final nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(chunked, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
    if (mounted) {
      setState(() {});
      if (!widget.enableCustomFilter) {
        _sendCount();
      }
    }
  }

  void _sendCount() {
    if (widget.countChange != null) {
      widget.countChange!(
          _pagingController.itemList?.expand((e) => e).toList().length ?? 0);
    }
  }

  List<List<T>> transformItems(List<T> items) {
    if (widget.displayType == DisplayType.list_vert) {
      return items.map((e) => [e]).toList();
    } else {
      return items.chunked(widget.gridChildCount).toList();
    }
  }

  @override
  void didUpdateWidget(covariant InfinitePagination<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (mounted) {
      if (oldWidget.displayType != widget.displayType ||
          oldWidget.gridChildCount != widget.gridChildCount) {
        _pagingController.itemList = transformItems(
            _pagingController.itemList?.expand((e) => e).toList() ?? []);
      }
      if (_hasKeyChanged(oldWidget.refKey, widget.refKey)) {
        _pagingController.value = PagingState(nextPageKey: 0);
      }
    }
  }

  bool _hasKeyChanged(String? oldKey, String? newKey) {
    return oldKey != null && newKey != null && !oldKey.equals(newKey);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.customFilterBuilder != null && widget.enableCustomFilter) {
      final filtered = transformItems(
          widget.customFilterBuilder!(_pagingController.itemList ?? []));
      if (filtered.expand((e) => e).isEmpty)
        return SizedBox.expand(child: showNoContent());
      return ListView.builder(
        itemCount: filtered.length,
        controller: _scrollController,
        itemBuilder: (_, index) =>
            widget.itemBuilder(_, PageItem(filtered[index]), index),
      );
    }
    return PagedListView<int, List<T>>(
      pagingController: _pagingController,
      scrollController: _scrollController,
      builderDelegate: PagedChildBuilderDelegate<List<T>>(
        firstPageErrorIndicatorBuilder: (_) => showErrorImage(),
        noItemsFoundIndicatorBuilder: (_) => showNoContent(),
        noMoreItemsIndicatorBuilder: (_) =>
            showNoContent(text: S.current.NoMoreItemsFound),
        itemBuilder: (_, item, index) =>
            widget.itemBuilder(_, PageItem(item), index),
      ),
    );
  }
}
