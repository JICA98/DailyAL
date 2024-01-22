import 'package:collection/collection.dart';
import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/widgets/loading/expandedwidget.dart';
import 'package:dailyanimelist/widgets/user/stats_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExpandedCard extends StatefulWidget {
  final String title;
  final Widget child;
  final Widget expandedChild;
  final Widget? bottom;
  final double height;
  final double? width;
  final bool useCard;
  final List<Widget>? actions;
  const ExpandedCard({
    super.key,
    required this.title,
    required this.child,
    required this.expandedChild,
    this.height = 220.0,
    this.useCard = true,
    this.bottom,
    this.width,
    this.actions,
  });

  @override
  State<ExpandedCard> createState() => _ExpandedCardState();
}

class _ExpandedCardState extends State<ExpandedCard> {
  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    final bottom = widget.bottom;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: conditional(
        on: widget.useCard,
        parent: (p0) => Card(child: p0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12.0, vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (widget.actions != null) ...[
                      Expanded(child: SB.w10),
                      ...widget.actions!,
                    ],
                  ],
                ),
              ),
              SB.h15,
              SizedBox(
                height: widget.height,
                width: widget.width,
                child: widget.child,
              ),
              if (bottom != null) ...[
                conditional(
                  on: widget.useCard,
                  parent: (p0) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: p0,
                  ),
                  child: Row(
                    children: [
                      Expanded(child: bottom),
                      SB.w10,
                      _accordionIcon(),
                    ],
                  ),
                ),
                SB.h15,
              ],
              ExpandedSection(
                expand: isExpanded,
                child: widget.expandedChild,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconButton _accordionIcon() {
    return IconButton.filledTonal(
      onPressed: () {
        setState(() {
          isExpanded = !isExpanded;
        });
      },
      icon: Icon(
          isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
    );
  }
}

class BarChartWidget extends StatefulWidget {
  final List<List<num>> data;
  final Widget Function(double value, TitleMeta meta) getTitlesWidget;
  final Color Function(int outerIndex, int innerIndex) getColor;
  final BarTooltipItem? Function(BarChartGroupData, int, BarChartRodData, int)?
      getTooltipItem;

  const BarChartWidget({
    super.key,
    required this.getTitlesWidget,
    required this.data,
    required this.getColor,
    this.getTooltipItem,
  });

  @override
  State<BarChartWidget> createState() => _BarChartWidgetState();
}

class _BarChartWidgetState extends State<BarChartWidget> {
  int _touchIndex = -1;
  late num max;

  @override
  void initState() {
    super.initState();
    max = widget.data.expand((e) => e).max;
  }

  @override
  Widget build(BuildContext context) {
    return _barChart();
  }

  bool isShadowBar(int rodIndex) => rodIndex == 1;
  BarChart _barChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.center,
        groupsSpace: 12,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: widget.getTooltipItem,
            tooltipBgColor: Theme.of(context).cardColor,
            direction: TooltipDirection.auto,
            fitInsideHorizontally: true,
            fitInsideVertically: true,
          ),
          handleBuiltInTouches: false,
          touchCallback: _onTouchCallback,
        ),
        titlesData: _titlesData(),
        borderData: FlBorderData(
          show: false,
        ),
        barGroups: widget.data
            .mapIndexed((index, value) => _makeGroupData(index, value,
                maxY: max.toDouble(), isTouched: _touchIndex == index))
            .toList(),
        gridData: const FlGridData(show: false),
      ),
    );
  }

  void _onTouchCallback(FlTouchEvent event, barTouchResponse) {
    if (!event.isInterestedForInteractions ||
        barTouchResponse == null ||
        barTouchResponse.spot == null) {
      setState(() {
        _touchIndex = -1;
      });
      return;
    }
    final rodIndex = barTouchResponse.spot!.touchedRodDataIndex;
    if (isShadowBar(rodIndex)) {
      setState(() {
        _touchIndex = -1;
      });
      return;
    }
    setState(() {
      _touchIndex = barTouchResponse.spot!.touchedBarGroupIndex;
    });
  }

  FlTitlesData _titlesData() {
    return FlTitlesData(
      show: true,
      rightTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      topTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) => SideTitleWidget(
            axisSide: meta.axisSide,
            space: 5,
            child: Text(
                NumberFormat.compact()
                    .format(_sumValues(widget.data[value.toInt()])),
                style: Theme.of(context).textTheme.labelSmall),
          ),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) => widget.getTitlesWidget(
            value,
            meta,
          ),
          reservedSize: 42,
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: false,
        ),
      ),
    );
  }

  BarChartGroupData _makeGroupData(
    int x,
    List<num> values, {
    bool isTouched = false,
    double width = 19,
    double maxY = 20,
  }) {
    double _fromY = 0;
    List<MapEntry<num, MapEntry<double, double>>> rodItems = [];
    values.forEach((e) {
      final toY = _fromY + e;
      rodItems.add(MapEntry(e, MapEntry(_fromY, toY)));
      _fromY = toY;
    });
    final sum = _sumValues(values);
    return BarChartGroupData(
      x: x,
      groupVertically: true,
      showingTooltipIndicators: isTouched ? [0] : [],
      barRods: [
        BarChartRodData(
          toY: sum,
          width: width,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
          ),
          rodStackItems: rodItems.mapIndexed((index, e) {
            final barColor = widget.getColor(x, index.toInt());
            return BarChartRodStackItem(
              e.value.key,
              e.value.value,
              isTouched ? _lighten(barColor, 50) : barColor,
              BorderSide(
                color: isTouched
                    ? _lighten(Theme.of(context).dividerColor, 50)
                    : Colors.transparent,
                width: isTouched ? 2 : 0,
              ),
            );
          }).toList(),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: maxY,
            color: Theme.of(context).canvasColor,
          ),
        )
      ],
    );
  }

  double _sumValues(List<num> values) {
    return values
        .map((e) => e.toDouble())
        .reduce((value, element) => (value + element).toDouble());
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
}

class RadarChartWidget extends StatefulWidget {
  final Map<String, Map<String, num>> data;
  final List<String> title;
  final Color Function(String key) keyColor;
  final RadarChartTitle Function(int, double)? getTitle;
  final int selectedDataSetIndex;
  final ValueChanged<int> onIndexChange;
  const RadarChartWidget({
    super.key,
    required this.data,
    required this.title,
    required this.keyColor,
    required this.onIndexChange,
    this.getTitle,
    this.selectedDataSetIndex = -1,
  });

  @override
  State<RadarChartWidget> createState() => _RadarChartWidgetState();
}

class _RadarChartWidgetState extends State<RadarChartWidget> {
  late int _selectedDataSetIndex;

  @override
  void initState() {
    super.initState();
    _selectedDataSetIndex = widget.selectedDataSetIndex;
  }

  @override
  Widget build(BuildContext context) {
    return _radarData();
  }

  @override
  void didUpdateWidget(covariant RadarChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDataSetIndex != -1) {
      setState(() {
        _selectedDataSetIndex = widget.selectedDataSetIndex;
      });
    }
  }

  RadarChart _radarData() {
    return RadarChart(
      RadarChartData(
        radarTouchData: RadarTouchData(
          touchCallback: (FlTouchEvent event, response) {
            if (!event.isInterestedForInteractions) {
              setState(() {
                _selectedDataSetIndex = -1;
                widget.onIndexChange(-1);
              });
              return;
            }
            setState(() {
              _selectedDataSetIndex =
                  response?.touchedSpot?.touchedDataSetIndex ?? -1;
              if (_selectedDataSetIndex == -1) {
                widget.onIndexChange(_selectedDataSetIndex);
              }
            });
          },
        ),
        titleTextStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontSize: 9.0,
              letterSpacing: 0.0,
              wordSpacing: 0.0,
            ),
        radarShape: RadarShape.polygon,
        dataSets: _buildDataSets(),
        radarBackgroundColor: Colors.transparent,
        borderData: FlBorderData(show: false),
        radarBorderData: const BorderSide(color: Colors.transparent, width: 0),
        titlePositionPercentageOffset: 0.2,
        getTitle: widget.getTitle,
        tickCount: 1,
        ticksTextStyle:
            const TextStyle(color: Colors.transparent, fontSize: 10),
        tickBorderData: const BorderSide(color: Colors.transparent, width: 0),
        gridBorderData:
            BorderSide(color: Theme.of(context).dividerColor, width: 0),
      ),
      swapAnimationDuration: Duration(milliseconds: 400),
    );
  }

  List<RadarDataSet> _buildDataSets() {
    return widget.data.entries.indexed.map((f) {
      final index = f.$1;
      final e = f.$2;
      final isSelected = index == _selectedDataSetIndex
          ? true
          : _selectedDataSetIndex == -1
              ? true
              : false;
      final color = widget.keyColor(e.key);
      return RadarDataSet(
        fillColor:
            isSelected ? color.withOpacity(0.2) : color.withOpacity(0.05),
        borderColor: isSelected ? color : color.withOpacity(0.25),
        entryRadius: isSelected ? 3 : 2,
        borderWidth: isSelected ? 2.3 : 2,
        dataEntries: e.value.entries
            .map((f) => RadarEntry(value: f.value.toDouble()))
            .toList(),
      );
    }).toList();
  }
}

class RadarChartSample1 extends StatefulWidget {
  RadarChartSample1({super.key});

  @override
  State<RadarChartSample1> createState() => _RadarChartSample1State();
}

class _RadarChartSample1State extends State<RadarChartSample1> {
  int selectedDataSetIndex = -1;
  double angleValue = 0;
  bool relativeAngleMode = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Title configuration',
            style: TextStyle(),
          ),
          Row(
            children: [
              const Text(
                'Angle',
                style: TextStyle(),
              ),
              Slider(
                value: angleValue,
                max: 360,
                onChanged: (double value) => setState(() => angleValue = value),
              ),
            ],
          ),
          Row(
            children: [
              Checkbox(
                value: relativeAngleMode,
                onChanged: (v) => setState(() => relativeAngleMode = v!),
              ),
              const Text('Relative'),
            ],
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                selectedDataSetIndex = -1;
              });
            },
            child: Text(
              'Categories'.toUpperCase(),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: rawDataSets()
                .asMap()
                .map((index, value) {
                  final isSelected = index == selectedDataSetIndex;
                  return MapEntry(
                    index,
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedDataSetIndex = index;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        height: 26,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.amber : Colors.transparent,
                          borderRadius: BorderRadius.circular(46),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 6,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInToLinear,
                              padding: EdgeInsets.all(isSelected ? 8 : 6),
                              decoration: BoxDecoration(
                                color: value.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInToLinear,
                              style: TextStyle(
                                color: isSelected ? value.color : Colors.blue,
                              ),
                              child: Text(value.title),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                })
                .values
                .toList(),
          ),
          AspectRatio(
            aspectRatio: 1.3,
            child: RadarChart(
              RadarChartData(
                radarTouchData: RadarTouchData(
                  touchCallback: (FlTouchEvent event, response) {
                    if (!event.isInterestedForInteractions) {
                      setState(() {
                        selectedDataSetIndex = -1;
                      });
                      return;
                    }
                    setState(() {
                      selectedDataSetIndex =
                          response?.touchedSpot?.touchedDataSetIndex ?? -1;
                    });
                  },
                ),
                dataSets: showingDataSets(),
                radarBackgroundColor: Colors.transparent,
                borderData: FlBorderData(show: false),
                radarBorderData: const BorderSide(color: Colors.transparent),
                titlePositionPercentageOffset: 0.2,
                titleTextStyle: TextStyle(fontSize: 14),
                getTitle: (index, angle) {
                  final usedAngle =
                      relativeAngleMode ? angle + angleValue : angleValue;
                  switch (index) {
                    case 0:
                      return RadarChartTitle(
                        text: 'Mobile or Tablet',
                        angle: usedAngle,
                      );
                    case 2:
                      return RadarChartTitle(
                        text: 'Desktop',
                        angle: usedAngle,
                      );
                    case 1:
                      return RadarChartTitle(text: 'TV', angle: usedAngle);
                    default:
                      return const RadarChartTitle(text: '');
                  }
                },
                tickCount: 1,
                ticksTextStyle:
                    const TextStyle(color: Colors.transparent, fontSize: 10),
                tickBorderData: const BorderSide(color: Colors.transparent),
                gridBorderData:
                    BorderSide(color: Theme.of(context).dividerColor, width: 2),
              ),
              swapAnimationDuration: const Duration(milliseconds: 400),
            ),
          ),
        ],
      ),
    );
  }

  List<RadarDataSet> showingDataSets() {
    return rawDataSets().asMap().entries.map((entry) {
      final index = entry.key;
      final rawDataSet = entry.value;

      final isSelected = index == selectedDataSetIndex
          ? true
          : selectedDataSetIndex == -1
              ? true
              : false;

      return RadarDataSet(
        fillColor: isSelected
            ? rawDataSet.color.withOpacity(0.2)
            : rawDataSet.color.withOpacity(0.05),
        borderColor:
            isSelected ? rawDataSet.color : rawDataSet.color.withOpacity(0.25),
        entryRadius: isSelected ? 3 : 2,
        dataEntries:
            rawDataSet.values.map((e) => RadarEntry(value: e)).toList(),
        borderWidth: isSelected ? 2.3 : 2,
      );
    }).toList();
  }

  List<RawDataSet> rawDataSets() {
    return [
      RawDataSet(
        title: 'Fashion',
        color: Colors.red,
        values: [
          300,
          50,
          250,
        ],
      ),
      RawDataSet(
        title: 'Art & Tech',
        color: Colors.pink,
        values: [
          250,
          100,
          200,
        ],
      ),
      RawDataSet(
        title: 'Entertainment',
        color: Colors.blue,
        values: [
          200,
          150,
          50,
        ],
      ),
      RawDataSet(
        title: 'Off-road Vehicle',
        color: Colors.brown,
        values: [
          150,
          200,
          150,
        ],
      ),
      RawDataSet(
        title: 'Boxing',
        color: Colors.yellow,
        values: [
          100,
          250,
          100,
        ],
      ),
    ];
  }
}

class RawDataSet {
  RawDataSet({
    required this.title,
    required this.color,
    required this.values,
  });

  final String title;
  final Color color;
  final List<double> values;
}
