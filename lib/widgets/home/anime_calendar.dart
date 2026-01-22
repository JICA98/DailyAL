import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:dailyanimelist/api/dalapi.dart';
import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/pages/animedetailed/synopsiswidget.dart';
import 'package:dailyanimelist/screens/contentdetailedscreen.dart';
import 'package:dailyanimelist/util/streamutils.dart';
import 'package:dailyanimelist/widgets/avatarwidget.dart';
import 'package:dailyanimelist/widgets/custombutton.dart';
import 'package:dailyanimelist/widgets/customfuture.dart';
import 'package:dailyanimelist/widgets/slivers.dart';
import 'package:dal_commons/commons.dart';
import 'package:flutter/material.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:intl/intl.dart';

import '../../api/malapi.dart';

class SchduledNode {
  final int dayofWeek;
  final ScheduleData scheduleData;
  final Node anime;
  final bool currentDay;

  SchduledNode(
    this.dayofWeek,
    this.scheduleData,
    this.anime, {
    this.currentDay = false,
  });

  static SchduledNode _currentDayNode() {
    final now = DateTime.now();
    return SchduledNode(
      now.weekday,
      ScheduleData(timestamp: now.millisecondsSinceEpoch ~/ 1000),
      Node(),
      currentDay: true,
    );
  }
}

class _Filter {
  final String displayText;
  final String value;
  bool isApplied = true;

  _Filter({required this.displayText, required this.value});
}

class AnimeCalendarWidget extends StatefulWidget {
  final bool showCloseButton;
  const AnimeCalendarWidget({Key? key, this.showCloseButton = true})
      : super(key: key);

  @override
  State<AnimeCalendarWidget> createState() => _AnimeCalendarWidgetState();
}

class _AnimeCalendarWidgetState extends State<AnimeCalendarWidget> {
  late Future<SearchResult> _seasonResult;

  void onClose() => Navigator.pop(context);

  @override
  void initState() {
    super.initState();
    _setFutures();
  }

  _setFutures([bool fromCache = true]) {
    _seasonResult = MalApi.getCurrentSeason(
      fields: ["my_list_status", 'num_episodes'],
      fromCache: fromCache,
      limit: 500,
    );
    DalApi.i.resetScheduleForMalIds();
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

  Widget _buildScheduleTree(SearchResult? result, Map<int, ScheduleData>? map) {
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
    if (schedulesList.isNotEmpty) {
      schedulesList.add(SchduledNode._currentDayNode());
    }
    schedulesList
        .sort((a, b) => a.scheduleData.timestamp! - b.scheduleData.timestamp!);
    final dayMap = <int, List<SchduledNode>>{};
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
    if (node.content?.myListStatus != null) {
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

  Widget _buildCustomScrollView(Map<int, List<SchduledNode>> map) {
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
        title: Text(S.current.AnimeCalendar),
        actions: _actions(
          onClose: onClose,
          onRefesh: onRefesh,
          showCloseButton: widget.showCloseButton,
        ),
      ),
      body: child,
    );
  }

  SchduledNode _mapToScheduledNode(
      MapEntry<int, ScheduleData> e, Map<int, Node> nodes) {
    final date = DateTime.fromMillisecondsSinceEpoch(e.value.timestamp! * 1000);
    return SchduledNode(
      date.weekday,
      e.value,
      nodes[e.key]!,
    );
  }
}

List<Widget> _actions({
  VoidCallback? onClose,
  VoidCallback? onRefesh,
  bool showCloseButton = true,
}) {
  return [
    IconButton(
      onPressed: onRefesh,
      icon: Icon(Icons.refresh),
    ),
    if (showCloseButton)
      IconButton(
        onPressed: onClose,
        icon: Icon(Icons.close),
      )
  ];
}

class _ScheduleCustomList extends StatefulWidget {
  final Map<int, List<SchduledNode>> scheduleNodeData;
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
  StreamListener<int> _streamListener = StreamListener<int>();

  List<SchduledNode> _currentDayNodes(int weekIndex) {
    return _mapAtIndex(weekIndex).value.where(_filterScheduleNode).toList();
  }

  MapEntry<int, List<SchduledNode>> _mapAtIndex(int weekIndex) {
    return widget.scheduleNodeData.entries.elementAt(weekIndex);
  }

  @override
  void initState() {
    super.initState();
    _setupCurrentDayUpdater();
  }

  void _setupCurrentDayUpdater() {
    Future.doWhile(() => Future.delayed(Duration(seconds: 1), () {
          if (mounted) {
            _streamListener.controller
                .add(DateTime.now().millisecondsSinceEpoch ~/ 1000);
            return true;
          }
          return false;
        }));
  }

  @override
  Widget build(BuildContext context) {
    final map = widget.scheduleNodeData;
    return CustomScrollWrapper([
      if (widget.header != null) ...[
        SB.lh30,
        widget.header!(),
      ],
      _buildFilterHeader,
      for (int index = 0; index < map.length; ++index) ..._weekChildren(index)
    ]);
  }

  List<Widget> _weekChildren(int weekIndex) {
    final mapEntry = _mapAtIndex(weekIndex);
    final hasCurrentNode = mapEntry.value.any((e) => e.currentDay);
    return [
      SliverWrapper(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
          child: title(_weekdaysMap[mapEntry.key]!.capitalize()),
        ),
      ),
      if (hasCurrentNode)
        StreamBuilder<int>(
          stream: _streamListener.stream,
          builder: (context, snapshot) {
            _setLatestTimestamp(mapEntry, snapshot);
            return _listTiles(mapEntry, weekIndex);
          },
        )
      else
        _listTiles(mapEntry, weekIndex)
    ];
  }

  void _setLatestTimestamp(
      MapEntry<int, List<SchduledNode>> mapEntry, AsyncSnapshot<int> snapshot) {
    mapEntry.value.where((e) => e.currentDay).forEach((e) {
      if (snapshot.hasData) e.scheduleData.timestamp = snapshot.data!;
    });
  }

  SliverListWrapper _listTiles(
      MapEntry<int, List<SchduledNode>> mapEntry, int weekIndex) {
    return SliverListWrapper(
      mapEntry.value
          .where(_filterScheduleNode)
          .mapIndexed((i, n) => _buildAnimeListTile(i, n, weekIndex))
          .toList(),
    );
  }

  bool _filterScheduleNode(SchduledNode e) {
    if (e.currentDay) return true;
    return _selectedFilters
        .contains((e.anime.myListStatus as MyAnimeListStatus).status);
  }

  Widget _buildAnimeListTile(int index, SchduledNode node, int dayIndex) {
    if (node.currentDay) {
      final nextNode = _getNextClosestNode(node);
      return _buildCurrentDayTile(node, index, nextNode);
    }
    final labelSmall = Theme.of(context).textTheme.labelSmall;
    final timestamp = node.scheduleData.timestamp!;
    final epsWidget =
        Text('Ep ${node.scheduleData.episode ?? '?'} in', style: labelSmall);
    final dateTime = ShadowButton(
      onPressed: () => _showShowSnack(S.current.Show, node),
      padding: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Text(_hourMinText(timestamp)),
      ),
    );
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
                  dateTime
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Column(
                    children: [
                      title(
                        node.anime.title,
                        fontSize: 16.0,
                        align: TextAlign.center,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: CountDownWidget(
                                timestamp: timestamp,
                                elevation: 0,
                                prefix: epsWidget,
                                style: labelSmall,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add_alert),
                            onPressed: () => _addToCalendar(node),
                          ),
                        ],
                      ),
                    ],
                  ),
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

  Widget _buildCurrentDayTile(
      SchduledNode node, int index, SchduledNode? nextNode) {
    return StreamBuilder<int>(
        stream: _streamListener.stream,
        builder: (context, snapshot) {
          node.scheduleData.timestamp =
              snapshot.data ?? node.scheduleData.timestamp;
          return Container(
            height: 50.0,
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Stack(
              children: [
                Center(
                  child: Divider(thickness: 2),
                ),
                Center(
                  child: ToolTipButton(
                    message: '',
                    onTap: () {
                      if (nextNode != null) {
                        _showShowSnack(S.current.NextShow, nextNode);
                      }
                    },
                    padding: EdgeInsets.zero,
                    child: _currentTime(node),
                  ),
                ),
              ],
            ),
          );
        });
  }

  void _showShowSnack(String message, SchduledNode nextNode) {
    final timestamp = _timeStampText(nextNode.scheduleData.timestamp!);
    String nextShowMsg =
        '$message: ${nextNode.anime.title} at ${timestamp.join(' ')}';
    showSnackBar(Text(nextShowMsg));
  }

  Widget _currentTime(SchduledNode node) {
    final texts = _timeStampText(node.scheduleData.timestamp!);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 5.0),
        child: RichText(
            text: TextSpan(children: [
          TextSpan(
            text: texts[0],
            style: TextStyle(
              fontSize: 16.0,
            ),
          ),
          TextSpan(
            text: ' (${texts[1]})',
            style: TextStyle(
              fontSize: 10.0,
              color:
                  Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(.7),
            ),
          ),
        ])),
      ),
    );
  }

  List<String> _timeStampText(int stamp) {
    final timestamp = DateTime.fromMillisecondsSinceEpoch(stamp * 1000);
    String hourMinText = _hourMinText(stamp);
    String timezoneText =
        '${timestamp.timeZoneName} ${timestamp.timeZoneOffset.isNegative ? '-' : '+'}${timestamp.timeZoneOffset.inHours}:${timestamp.timeZoneOffset.inMinutes.remainder(60).toString().padLeft(2, '0')}';
    return [hourMinText, timezoneText];
  }

  String _hourMinText(int stamp) {
    final timestamp = DateTime.fromMillisecondsSinceEpoch(stamp * 1000);
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  SchduledNode? _getNextClosestNode(SchduledNode node) {
    var list = widget.scheduleNodeData.values.flattened
        .where(_filterScheduleNode)
        .toList();
    list.sort((a, b) => a.scheduleData.timestamp! - b.scheduleData.timestamp!);
    final index = list.indexOf(node);
    return list.tryAt(index + 1);
  }

  void _addToCalendar(SchduledNode node) {
    _showAddToCalendarSheet(node);
  }

  void _showAddToCalendarSheet(SchduledNode node) {
    final anime = node.anime;
    final schedule = node.scheduleData;
    final startDate =
        DateTime.fromMillisecondsSinceEpoch(schedule.timestamp! * 1000);
    final endDate = startDate.add(Duration(minutes: 25));
    final canRecurring = anime.numEpisodes != null && anime.numEpisodes != 0;

    showCustomSheet(
      context: context,
      child: SafeArea(
        child: StatefulBuilder(
          builder: (context, setSheetState) {
            bool recurring = canRecurring;
            return _AddToCalendarSheetContent(
              animeTitle: anime.title ?? '',
              startDate: startDate,
              endDate: endDate,
              canRecurring: canRecurring,
              initialRecurring: recurring,
              onConfirm: (useRecurring) {
                Navigator.of(context).pop();
                _createCalendarEvent(node, startDate, endDate,
                    useRecurring: useRecurring);
              },
            );
          },
        ),
      ),
    );
  }

  void _createCalendarEvent(
    SchduledNode node,
    DateTime startDate,
    DateTime endDate, {
    required bool useRecurring,
  }) {
    final anime = node.anime;
    final schedule = node.scheduleData;

    Recurrence? recurrence;
    if (useRecurring && anime.numEpisodes != null && schedule.episode != null) {
      final total = anime.numEpisodes!;
      final nextEp = schedule.episode!;
      int occurrences = total - nextEp + 1;
      if (occurrences < 1) occurrences = 1;
      recurrence = Recurrence(
        frequency: Frequency.weekly,
        ocurrences: occurrences,
      );
    }

    final Event event = Event(
      title: _getCalendarTitle(schedule, anime, recurrence),
      description: _getAnimeDescription(anime, schedule),
      startDate: startDate,
      endDate: endDate,
      iosParams: IOSParams(
        reminder: Duration(minutes: 10),
        url: anime.mainPicture?.large ?? '',
      ),
      androidParams: AndroidParams(
        emailInvites: [],
      ),
      recurrence: recurrence,
    );

    Add2Calendar.addEvent2Cal(event).then((result) {
      if (result) {
        showSnackBar(Text(S.current.Event_Added_To_Calendar));
      } else {
        showSnackBar(Text(S.current.Error_Adding_Event_To_Calendar));
      }
    }).catchError((e) {
      logDal('Error adding event to calendar: $e');
      showSnackBar(Text(S.current.Error_Adding_Event_To_Calendar));
    });
  }

  String _getCalendarTitle(
      ScheduleData schedule, Node anime, Recurrence? recurrence) {
    return recurrence != null
        ? '${anime.title} Episode Release Reminder'
        : 'Ep ${schedule.episode ?? '?'} - ${anime.title}';
  }

  _getAnimeDescription(Node anime, ScheduleData schedule) {
    final title = '${anime.title} - Episode ${schedule.episode ?? '?'}';
    final airDate = DateFormat.yMMMd().format(
        DateTime.fromMillisecondsSinceEpoch(schedule.timestamp! * 1000));
    final relatedLinks = schedule.relatedLinks;
    final linksBuffer = StringBuffer();

    if (relatedLinks != null) {
      void appendLink(String? label, String? url) {
        if (url != null && url.isNotEmpty) {
          linksBuffer.writeln('$label: $url');
        }
      }

      appendLink('Website', relatedLinks.website);
      appendLink('Twitter', relatedLinks.twitter);
      appendLink('AniList', relatedLinks.anilist);
      appendLink('MyAnimeList', relatedLinks.mal);
      appendLink('AniDB', relatedLinks.anidb);
      appendLink('AnimePlanet', relatedLinks.animePlanet);
      appendLink('AniSearch', relatedLinks.anisearch);
      appendLink('Kitsu', relatedLinks.kitsu);
      appendLink('Crunchyroll', relatedLinks.crunchyroll);
      appendLink('Hidive', relatedLinks.hidive);
      appendLink('Netflix', relatedLinks.netflix);
    }

    return '$title\nAir Date: $airDate\n\nLinks:\n${linksBuffer.toString()}\n'
        'This is a reminder for the scheduled episode of $title. \n\n Generated by DailyAL.';
  }
}

class _AddToCalendarSheetContent extends StatefulWidget {
  final String animeTitle;
  final DateTime startDate;
  final DateTime endDate;
  final bool canRecurring;
  final bool initialRecurring;
  final ValueChanged<bool> onConfirm;

  const _AddToCalendarSheetContent({
    Key? key,
    required this.animeTitle,
    required this.startDate,
    required this.endDate,
    required this.canRecurring,
    required this.initialRecurring,
    required this.onConfirm,
  }) : super(key: key);

  @override
  State<_AddToCalendarSheetContent> createState() =>
      _AddToCalendarSheetContentState();
}

class _AddToCalendarSheetContentState
    extends State<_AddToCalendarSheetContent> {
  late bool _recurring;

  @override
  void initState() {
    super.initState();
    _recurring = widget.initialRecurring;
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat.yMMMd().add_Hm().format(widget.startDate);
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event_available),
              SB.w10,
              Expanded(
                child: title(
                  S.current.Add_To_Calendar_Prompt,
                  fontSize: 22,
                ),
              ),
            ],
          ),
          SB.h30,
          title(
            widget.animeTitle,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          SB.h10,
          iconAndText(Icons.access_time, timeStr, fontSize: 13),
          if (widget.canRecurring) ...[
            SB.h20,
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(S.current.Add_Recurring_Event),
              subtitle: Text(S.current.Add_Recurring_Event_Desc),
              value: _recurring,
              onChanged: (v) => setState(() => _recurring = v),
            ),
          ],
          SB.h20,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              PlainButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(S.current.Cancel),
              ),
              SB.w10,
              ShadowButton(
                onPressed: () =>
                    widget.onConfirm(_recurring && widget.canRecurring),
                child: Text(S.current.Add),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
