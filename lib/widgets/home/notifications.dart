import 'dart:collection';

import 'package:dailyanimelist/api/dalapi.dart';
import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/main.dart';
import 'package:dailyanimelist/pages/animedetailed/synopsiswidget.dart';
import 'package:dailyanimelist/screens/contentdetailedscreen.dart';
import 'package:dailyanimelist/widgets/avatarwidget.dart';
import 'package:dailyanimelist/widgets/custombutton.dart';
import 'package:dailyanimelist/widgets/customfuture.dart';
import 'package:dailyanimelist/widgets/slivers.dart';
import 'package:dal_commons/commons.dart';
import 'package:flutter/material.dart';

import '../../api/malapi.dart';

class _SchduledNode {
  final int dayofWeek;
  final ScheduleData scheduleData;
  final Node anime;
  _SchduledNode(this.dayofWeek, this.scheduleData, this.anime);
}

class _Filter {
  final String displayText;
  final String value;
  bool isApplied = true;

  _Filter({required this.displayText, required this.value});
}

class NotificationScheduleWidget extends StatefulWidget {
  const NotificationScheduleWidget({Key? key}) : super(key: key);

  @override
  State<NotificationScheduleWidget> createState() =>
      _NotificationScheduleWidgetState();
}

class _NotificationScheduleWidgetState
    extends State<NotificationScheduleWidget> {
  late Future<SearchResult> _seasonResult;
  void onClose() => Navigator.pop(context);

  @override
  void initState() {
    super.initState();
    _setFutures();
  }

  _setFutures([bool fromCache = true]) {
    _seasonResult = MalApi.getCurrentSeason(
      fields: ["my_list_status"],
      fromCache: fromCache,
      limit: 500,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CFutureBuilder<SearchResult>(
      future: _seasonResult,
      done: (e) => CFutureBuilder<Map<int, ScheduleData>>(
        future: DalApi.i.scheduleForMalIds,
        done: (f) => _buildScheduleTree(e.data, f.data),
        loadingChild: loading,
      ),
      loadingChild: loading,
    );
  }

  Widget get loading {
    return _scaffoldWrapper(
      CustomScrollWrapper(
        [
          SB.lh30,
          SliverWrapper(loadingCenter()),
        ],
      ),
      onClose: onClose,
      onRefesh: null,
    );
  }

  _buildScheduleTree(SearchResult? result, Map<int, ScheduleData>? map) {
    Map<int, Node> nodes = HashMap.fromEntries(result?.data
            ?.where(_onlyWithStatus)
            .map((e) => e.content)
            .map((e) => MapEntry(e!.id!, e)) ??
        []);
    final schedulesList = map?.entries
            .where((e) => _onlyWithSchedule(e, nodes))
            .map((e) => _mapToScheduledNode(e, nodes))
            .toList() ??
        [];
    schedulesList
        .sort((a, b) => a.scheduleData.timestamp! - b.scheduleData.timestamp!);
    final dayMap = <int, List<_SchduledNode>>{};
    for (final sch in schedulesList) {
      if (dayMap.containsKey(sch.dayofWeek)) {
        dayMap[sch.dayofWeek]!.add(sch);
      } else {
        dayMap[sch.dayofWeek] = [sch];
      }
    }
    return _buildCustomScrollView(dayMap);
  }

  bool _onlyWithStatus(BaseNode node) {
    if (node?.content?.myListStatus != null) {
      if (node.content!.myListStatus is MyAnimeListStatus) {
        final status = node.content?.myListStatus as MyAnimeListStatus?;
        if (status?.status == null) return false;
        return status!.status!.equals("watching") ||
            status.status!.equals("plan_to_watch");
      }
    }
    return false;
  }

  bool _onlyWithSchedule(MapEntry<int, ScheduleData> e, Map<int, Node> nodes) {
    return nodes.containsKey(e.key);
  }

  Widget _buildCustomScrollView(Map<int, List<_SchduledNode>> map) {
    if (map.isEmpty)
      return _scaffoldWrapper(
        CustomScrollView(
          slivers: [
            if (map.isEmpty)
              SliverWrapper(
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: title(S.current.No_Scheduled_Notificatons,
                      fontSize: 16.0),
                ),
              )
          ],
        ),
        onClose: () => onClose(),
        onRefesh: () {
          setState(() {
            _setFutures(false);
          });
        },
      );
    else
      return _scaffoldWrapper(
        _ScheduleCustomList(
          scheduleNodeData: map,
        ),
        onClose: () => onClose(),
        onRefesh: () {
          setState(() {
            _setFutures(false);
          });
        },
      );
  }

  Widget _scaffoldWrapper(
    Widget child, {
    VoidCallback? onClose,
    VoidCallback? onRefesh,
  }) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(S.current.Notfications),
        actions: _actions(
          onClose: onClose,
          onRefesh: onRefesh,
        ),
      ),
      body: child,
    );
  }

  _SchduledNode _mapToScheduledNode(
      MapEntry<int, ScheduleData> e, Map<int, Node> nodes) {
    final date = DateTime.fromMillisecondsSinceEpoch(e.value.timestamp! * 1000);
    return _SchduledNode(
      date.weekday,
      e.value,
      nodes[e.key]!,
    );
  }
}

List<Widget> _actions({
  VoidCallback? onClose,
  VoidCallback? onRefesh,
}) {
  return [
    IconButton(
      onPressed: onRefesh,
      icon: Icon(Icons.refresh),
    ),
    IconButton(
      onPressed: onClose,
      icon: Icon(Icons.close),
    )
  ];
}

class _ScheduleCustomList extends StatefulWidget {
  final Map<int, List<_SchduledNode>> scheduleNodeData;
  final Widget Function()? header;
  const _ScheduleCustomList({
    Key? key,
    required this.scheduleNodeData,
    this.header,
  }) : super(key: key);

  @override
  State<_ScheduleCustomList> createState() => __ScheduleCustomListState();
}

class __ScheduleCustomListState extends State<_ScheduleCustomList> {
  final _filters = [
    _Filter(displayText: S.current.Plan_To_Watch, value: 'plan_to_watch'),
    _Filter(displayText: S.current.Watching, value: 'watching'),
  ];

  List<String> get _selectedFilters =>
      _filters.where((e) => e.isApplied).map((e) => e.value).toList();

  static const _weekdaysMap = {
    1: 'monday',
    2: 'tuesday',
    3: 'wednesday',
    4: 'thursday',
    5: 'friday',
    6: 'saturday',
    7: 'sunday'
  };

  @override
  Widget build(BuildContext context) {
    final map = widget.scheduleNodeData;
    final entries = (index) => map.entries.elementAt(index);
    return CustomScrollWrapper([
      if (widget.header != null) ...[
        SB.lh30,
        widget.header!(),
      ],
      _buildFilterHeader,
      for (int index = 0; index < map.length; ++index) ...[
        SliverWrapper(
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
            child: title(_weekdaysMap[entries(index).key]!.capitalize()),
          ),
        ),
        SliverListWrapper(
          entries(index)
              .value
              .where((e) => _selectedFilters
                  .contains((e.anime.myListStatus as MyAnimeListStatus).status))
              .map((e) => _buildAnimeListTile(e))
              .toList(),
        )
      ]
    ]);
  }

  Widget _buildAnimeListTile(_SchduledNode node) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () => gotoPage(
            context: context,
            newPage: ContentDetailedScreen(
              node: node.anime,
            )),
        child: Material(
          color: Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SB.w15,
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AvatarWidget(
                    height: 60,
                    width: 60,
                    url: node.anime.mainPicture!.large,
                  ),
                  SB.h10,
                  title('Ep ${node.scheduleData.episode ?? '?'}')
                ],
              ),
              Expanded(
                child: Column(
                  children: [
                    title(
                      node.anime.title,
                      fontSize: 16.0,
                      align: TextAlign.center,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CountDownWidget(
                        timestamp: node.scheduleData.timestamp!,
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget get _buildFilterHeader {
    return SliverWrapper(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
        child: Row(
          children: _filters
              .map(
                (e) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 7.0),
                  child: _buildFilter(e),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Padding _buildFilter(_Filter filter) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: PlainButton(
        child: filter.isApplied
            ? iconAndText(Icons.close, filter.displayText)
            : title(filter.displayText, fontSize: 12),
        onPressed: () {
          if (mounted)
            setState(() {
              filter.isApplied = !filter.isApplied;
            });
        },
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        shape: btnBorder(context),
      ),
    );
  }
}
