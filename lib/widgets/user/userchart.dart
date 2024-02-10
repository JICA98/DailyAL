import 'dart:async';

import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/main.dart';
import 'package:dailyanimelist/widgets/avatarwidget.dart';
import 'package:dailyanimelist/widgets/shimmecolor.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../constant.dart';

Map<String, IconData> genderTypesMap = {
  "male": Icons.male,
  "female": Icons.female
};

class UserChart extends StatefulWidget {
  final List<int?>? data;
  final List<double?>? extraData;
  final List<int>? colorData;
  final double defaultRadius;
  final double radius;
  final bool showTitle;
  final List<String>? titleList;
  final int? index;
  final double height;
  final String category;
  final String? username;
  final String? gender;

  final double width;
  final String? imageUrl;
  UserChart(
      {this.data,
      this.defaultRadius = 30.0,
      this.colorData,
      this.titleList,
      this.showTitle = false,
      this.imageUrl,
      this.extraData,
      this.index,
      this.gender,
      this.category = "anime",
      this.username = "@me",
      this.radius = 40.0,
      this.height = 150,
      this.width = 170});
  @override
  _UserChartState createState() => _UserChartState();
}

class _UserChartState extends State<UserChart> {
  late double defaultRadius;
  late int index;
  late double radius;
  bool stopTimer = false;
  List<int> colorData = [];
  List<String> titleList = [];

  static const themeColorData = {
    "fall": [0xff8D6E63, 0xff795548, 0xff6D4C41, 0xff5D4037, 0xff4E342E],
    "spring": [0xffAD1457, 0xffC2185B, 0xffD81B60, 0xffE91E63, 0xffEC407A],
    "summer": [0xffb71c1c, 0xffd32f2f, 0xffe53935, 0xfff44336, 0xffef5350],
    "winter": [0xff1565C0, 0xff1976D2, 0xff1E88E5, 0xff2196F3, 0xff42A5F5],
    "dust": [0xff2b2b2b, 0xff383838, 0xff545454, 0xff7c7c7c, 0xff9d9d9d],
    "night": [0xff9d9d9d, 0xff7c7c7c, 0xff545454, 0xff383838, 0xff2b2b2b],
  };

  static const dayColorData = [
    0xffEF5350,
    0xffAB47BC,
    0xff5C6BC0,
    0xff66BB6A,
    0xff42A5F5
  ];

  @override
  void initState() {
    super.initState();
    defaultRadius = widget.defaultRadius ?? 40.0;
    radius = widget.radius ?? 50.0;
    index = widget.index ?? -1;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      initColorData();
      Timer.periodic(Duration(seconds: 2), (timer) {
        if (mounted && !stopTimer) {
          setState(() {
            index = (index + 1) % widget.data!.length;
          });
        }
      });
    });
  }

  initColorData() {
    colorData = List.from(widget.colorData ?? colorList());

    if (user.pref.userchart != null) {
      for (var i = 0; i < user.pref.userchart.length; i++) {
        if (user.pref.userchart[i] != -1) colorData[i] = user.pref.userchart[i];
      }
    }
  }

  List<int> colorList() {
    final color = Theme.of(context).primaryColor;
    return List.generate(5, (i) => _lighten(color, (i + 1) * 2))
        .map((e) => e.value)
        .toList();
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

  var mangaList = [S.current.Reading, 'CMPL', 'On Hold', 'Dropped', 'PTR'];
  var animeList = [S.current.Watching, 'CMPL', 'On Hold', 'Dropped', 'PTW'];

  @override
  Widget build(BuildContext context) {
    bool isNull = widget.data == null ||
        widget.data!.isEmpty ||
        widget.data?.first == null;
    titleList = widget.category.equals("anime") ? animeList : mangaList;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          children: [
            Container(
              height: widget.height,
              width: widget.width,
              child: isNull
                  ? ShimmerColor(
                      Container(
                        decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            shape: BoxShape.circle),
                      ),
                    )
                  : PieChart(
                      PieChartData(
                          sections: widget.data!
                              .asMap()
                              .map(
                                (key, value) => MapEntry(
                                  key,
                                  PieChartSectionData(
                                      value: (value == 0
                                          ? 1
                                          : value!.toDouble() ?? 1),
                                      title: titleList[key % titleList.length],
                                      showTitle: index == key,
                                      titleStyle: TextStyle(fontSize: 11),
                                      titlePositionPercentageOffset: .65,
                                      radius:
                                          index == key ? radius : defaultRadius,
                                      color: key == index
                                          ? Theme.of(context).primaryColor
                                          : Color(colorData.elementAt(
                                              key % titleList.length))),
                                ),
                              )
                              .values
                              .toList(),
                          sectionsSpace: 5.0,
                          centerSpaceRadius: 50.0,
                          pieTouchData: PieTouchData(
                              enabled: true,
                              touchCallback: (event, response) {
                                logDal(response
                                    ?.touchedSection?.touchedSectionIndex);
                                setState(() {
                                  stopTimer = true;
                                  if (response?.touchedSection
                                          ?.touchedSectionIndex !=
                                      null) {
                                    index = response?.touchedSection
                                            ?.touchedSectionIndex ??
                                        -1;
                                  } else {
                                    if (event.isInterestedForInteractions) {
                                      index = -1;
                                    }
                                  }
                                });
                              })),
                      swapAnimationDuration: Duration(milliseconds: 250),
                    ),
            ),
            if (widget.gender != null)
              Positioned(
                  bottom: 30,
                  right: 25,
                  child: Container(
                    height: 25,
                    width: 25,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      genderTypesMap[widget.gender] ?? Icons.ac_unit,
                      color: Colors.grey,
                    ),
                  )),
            Positioned(
              top: 20,
              left: 20,
              child: AvatarWidget(
                height: 100,
                width: 100,
                username: (widget.username != null &&
                        widget.username!.notEquals("@me"))
                    ? widget.username
                    : null,
                radius: BorderRadius.circular(radius),
                onTap: () {
                  if (mounted) {
                    setState(() {
                      stopTimer = true;
                      index = -1;
                    });
                  }
                },
                url: widget.imageUrl,
              ),
            ),
          ],
        ),
        widget.showTitle
            ? const SizedBox(
                height: 25,
              )
            : SizedBox(),
        widget.showTitle
            ? title(
                (index == -1 || index == null)
                    ? S.current.Anime_Statistics
                    : (((widget.data?[index % titleList.length]
                                    ?.toStringAsFixed(0) ??
                                "") +
                            " Items") +
                        (index < (widget.extraData?.length ?? 1) &&
                                (widget.extraData?[index %
                                        (widget.extraData?.length ?? 1)] !=
                                    null)
                            ? (" - " +
                                (widget.extraData?[index %
                                            (widget.extraData!.length ?? 1)]
                                        ?.toStringAsFixed(2) ??
                                    "") +
                                " Days")
                            : "")),
              )
            : SizedBox(),
      ],
    );
  }
}
