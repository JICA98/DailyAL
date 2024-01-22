import 'dart:math';

import 'package:collection/collection.dart';
import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/pages/userpage.dart';
import 'package:dailyanimelist/theme/themedata.dart';
import 'package:dailyanimelist/widgets/loading/expandedwidget.dart';
import 'package:dailyanimelist/widgets/slivers.dart';
import 'package:dailyanimelist/widgets/togglebutton.dart';
import 'package:dailyanimelist/widgets/user/stats_screen.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AnimeMangaPlayingChart extends StatefulWidget {
  final UserProf userProf;
  final String category;
  final UserProfileV4? jikanUser;
  final bool isSelf;

  const AnimeMangaPlayingChart({
    super.key,
    required this.userProf,
    required this.category,
    this.jikanUser,
    required this.isSelf,
  });

  @override
  State<AnimeMangaPlayingChart> createState() => _AnimeMangaPlayingChartState();
}

class _AnimeMangaPlayingChartState extends State<AnimeMangaPlayingChart> {
  final Duration _animDuration = const Duration(milliseconds: 120);
  bool _isPlaying = false;
  bool _isExpanded = false;
  int _chartTouchIndex = -1;
  String _animeStatSelected = S.current.Status;
  NumberFormat _statFormat = NumberFormat.compact();

  List<double?> _daysData(UserProf userProf) => [
        userProf.animeStatistics?.numDaysWatching,
        userProf.animeStatistics?.numDaysCompleted,
        userProf.animeStatistics?.numDaysOnHold,
        userProf.animeStatistics?.numDaysDropped,
      ];

  final mangaList = [S.current.Reading, 'CMPL', 'On Hold', 'Dropped', 'PTR'];
  final animeList = [S.current.Watching, 'CMPL', 'On Hold', 'Dropped', 'PTW'];

  List<String> _daysTitle = [
    'Watching',
    'Completed',
    'On-Hold',
    'Dropped',
  ];

  @override
  initState() {
    super.initState();
  }

  List<String> titleList(String category) =>
      (category.equals("anime") ? animeList : mangaList).toList();

  bool _isAnimeStatusSelected() => _animeStatSelected.equals(S.current.Status);
  bool get _isAnimeSelected => widget.category.equals('anime');

  UserProf get userProf => widget.userProf;
  String get category => widget.category;
  UserProfileV4? get jikanUser => widget.jikanUser;

  Future<dynamic> _refreshState() async {
    setState(() {});
    await Future<dynamic>.delayed(
      _animDuration + const Duration(milliseconds: 50),
    );
    if (_isPlaying) {
      await _refreshState();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _statusDayChart();
  }

  Widget _statusDayChart() {
    final entryData =
        userStatusData(category, jikanUser, userProf, widget.isSelf);
    final dayData = _daysData(userProf);
    final mangaSelected = category.notEquals('anime');
    final List<num> statusData =
        ((_isAnimeStatusSelected() || mangaSelected) ? entryData : dayData)
            .map((e) => e ?? 0)
            .toList();
    final sorted = statusData.sorted((a, b) => (b - a).toInt());
    final max = sorted.firstOrNull ?? 0;
    final sum = sorted.sum;
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      sliver: SliverWrapper(
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SB.h10,
                SizedBox(
                  width: double.infinity,
                  child: Text(
                      mangaSelected
                          ? S.current.Manga_Stats
                          : S.current.Anime_Statistics,
                      textAlign: TextAlign.center),
                ),
                SB.h20,
                SizedBox(
                  height: 180.0,
                  child: _barChart(statusData, max, category, sum),
                ),
                SB.h10,
                _chartButton(max > 10),
                SB.h10,
                ExpandedSection(
                  expand: _isExpanded,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 5, 20, 15),
                    child: Column(
                      children: titleList(category)
                          .mapIndexed(
                            (index, status) => _statusField(
                              index,
                              status,
                              _isPlaying
                                  ? Random().nextInt(max.toInt())
                                  : entryData[index] ?? 0,
                              _isPlaying
                                  ? Random().nextInt(max.toInt()).toDouble()
                                  : dayData.tryAt(index),
                              !_isAnimeStatusSelected() && !mangaSelected,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  BarChart _barChart(List<num> statusData, num max, String category, num sum) {
    percentage(num value) => (sum != 0 && value != 0)
        ? ' - ${((value / sum) * 100).toStringAsFixed(2)}%'
        : '';
    return BarChart(
      BarChartData(
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Theme.of(context).cardColor,
            getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                BarTooltipItem(
              '${_statusTitle(category, groupIndex)}${percentage(statusData[groupIndex])}',
              Theme.of(context).textTheme.bodySmall ?? TextStyle(),
            ),
          ),
          touchCallback: (FlTouchEvent event, barTouchResponse) {
            setState(() {
              if (!event.isInterestedForInteractions ||
                  barTouchResponse == null ||
                  barTouchResponse.spot == null) {
                _chartTouchIndex = -1;
                return;
              }
              _chartTouchIndex = barTouchResponse.spot!.touchedBarGroupIndex;
            });
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => bottomTitleWidgets(
                value,
                meta,
                statusData.tryAt(value.toInt()),
                category,
                max,
              ),
              reservedSize: 42,
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: false,
        ),
        barGroups: statusData
            .mapIndexed((index, value) => _makeGroupData(
                index, value.toDouble(),
                maxY: max.toDouble(), isTouched: (_chartTouchIndex) == index))
            .toList(),
        gridData: const FlGridData(show: false),
      ),
    );
  }

  BarChartGroupData _makeGroupData(
    int x,
    double y, {
    bool isTouched = false,
    double width = 25,
    double maxY = 20,
  }) {
    final isPlaying = _isPlaying;
    final barColor = isPlaying
        ? UserThemeData.colors
            .elementAt(Random().nextInt(UserThemeData.colors.length))
        : Color(getStatusColor(x));
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: isPlaying
              ? (Random().nextInt(maxY.toInt()).toDouble())
              : isTouched
                  ? y + 1
                  : y,
          color: isTouched ? Theme.of(context).primaryColor : null,
          width: width,
          gradient: isTouched
              ? null
              : LinearGradient(
                  colors: [barColor, _lighten(barColor, 30)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
          borderSide: isTouched
              ? BorderSide(color: Theme.of(context).dividerColor)
              : const BorderSide(color: Colors.white, width: 0),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: maxY,
            color: Theme.of(context).canvasColor,
          ),
        ),
      ],
      showingTooltipIndicators: isTouched ? [0] : null,
    );
  }

  Widget bottomTitleWidgets(
      double value, TitleMeta meta, num? tryAt, String category, num max) {
    String textValue = _statusTitle(category, value);
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 10,
      child: Column(
        children: [
          Text(textValue, style: Theme.of(context).textTheme.labelSmall),
          Text(
              _isPlaying
                  ? Random().nextInt(max.toInt()).toString()
                  : _statFormat.format((tryAt ?? 0)),
              style: Theme.of(context).textTheme.labelSmall)
        ],
      ),
    );
  }

  String _statusTitle(String category, num value) {
    return (_isAnimeStatusSelected() || category.notEquals('anime'))
        ? titleList(category)[value.toInt()]
        : _daysTitle[value.toInt()];
  }

  Color _lighten(Color c, [int percent = 10]) {
    assert(1 <= percent && percent <= 100);
    var p = percent / 100;
    return Color.fromARGB(
        c.alpha,
        c.red + ((255 - c.red) * p).round(),
        c.green + ((255 - c.green) * p).round(),
        c.blue + ((255 - c.blue) * p).round());
  }

  Row _chartButton(bool hasPlayingBtn) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        IconButton.filledTonal(
            onPressed: () {
              _isExpanded = !_isExpanded;
              _chartTouchIndex = -1;
              setState(() {});
            },
            icon: Icon(_isExpanded
                ? Icons.keyboard_arrow_up
                : Icons.keyboard_arrow_down)),
        if (hasPlayingBtn)
          IconButton.filled(
              onPressed: _onPlay,
              icon: Icon(!_isPlaying ? Icons.play_arrow : Icons.pause)),
        Expanded(child: SB.z),
        if (_isAnimeSelected && widget.isSelf)
          ButtonSwitch(
            leftText: S.current.Status,
            rightText: S.current.Days,
            isLeftSelected: _isAnimeStatusSelected(),
            onLeft: () => _changeStatus(S.current.Status),
            onRight: () => _changeStatus(S.current.Days),
          )
      ],
    );
  }

  void _changeStatus(String status) {
    _animeStatSelected = status;
    _chartTouchIndex = -1;
    setState(() {});
  }

  void _onPlay() {
    _chartTouchIndex = -1;
    _isPlaying = !_isPlaying;
    _refreshState();
    setState(() {});
  }

  Widget _statusField(
      int index, String status, int entries, double? days, bool showDays) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_chartTouchIndex == index) {
            _chartTouchIndex = -1;
          } else {
            _chartTouchIndex = index;
          }
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  height: 15,
                  width: 15,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(getStatusColor(index)),
                  ),
                ),
                SB.w10,
                Text(status),
              ],
            ),
            SB.w20,
            if (showDays)
              Text('${(days ?? 0)} ${S.current.Days}')
            else
              Text(
                  '${entries} ${entries > 1 ? S.current.Entries : S.current.Entry}')
          ],
        ),
      ),
    );
  }
}
