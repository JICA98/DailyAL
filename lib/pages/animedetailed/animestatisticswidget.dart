import 'dart:math';

import 'package:dailyanimelist/widgets/user/stats_screen.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dailyanimelist/generated/l10n.dart';

class AnimeStatisticsWidget extends StatefulWidget {
  final AnimeStatistics? statistics;
  const AnimeStatisticsWidget({required this.statistics, double? horizPadding});

  @override
  _AnimeStatisticsWidgetState createState() => _AnimeStatisticsWidgetState();
}

class _AnimeStatisticsWidgetState extends State<AnimeStatisticsWidget> {
  int? touchedIndex;

  /// watching, onHold, ptw, dropped, completed
  List<double> statList = [0.0, 0.0, 0.0, 0.0, 0.0];
  List<double> statListHeight = [0.0, 0.0, 0.0, 0.0, 0.0];
  List<String> statName = [
    S.current.Watching,
    'CMPL',
    S.current.On_Hold,
    S.current.Dropped,
    S.current.PTW,
  ];
  NumberFormat statFormat = NumberFormat.compact();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future.delayed(Duration.zero).then((value) {
      statList[0] =
          double.tryParse(widget.statistics?.status?.watching ?? '') ?? 0.0;
      statList[2] =
          double.tryParse(widget.statistics?.status?.onHold ?? '') ?? 0.0;
      statList[4] =
          double.tryParse(widget.statistics?.status?.planToWatch ?? '') ?? 0.0;
      statList[3] =
          double.tryParse(widget.statistics?.status?.dropped ?? '') ?? 0.0;
      statList[1] =
          double.tryParse(widget.statistics?.status?.completed ?? '') ?? 0.0;

      double maxProp = 0.0;

      maxProp = max(statList[0],
          max(statList[1], max(statList[2], max(statList[3], statList[4]))));
      if (maxProp == 0) maxProp = 1;
      var multiplier = 100 / maxProp;
      for (var i = 0; i < statList.length; i++) {
        statListHeight[i] = statList[i] * multiplier;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          height: 14,
          width: double.infinity,
        ),
        Container(
          height: 260,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(5, (i) => _buildStatBar(i)),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Text(
          "Total " +
              (new NumberFormat.currency(name: "", decimalDigits: 0)
                  .format(widget.statistics?.numListUsers ?? 0.0)) +
              " ${S.current.Members}",
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }

  Column _buildStatBar(int i) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          (new NumberFormat.currency(name: "").format(statList[i] *
                  (100 / formatZeroAsOne(widget.statistics?.numListUsers)))) +
              "%",
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall,
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: statListHeight[i] * 1.75,
            width: 20,
            decoration: BoxDecoration(
              color: Color(getStatusColor(i)),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          statName[i],
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall,
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          statFormat.format(statList[i]),
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelMedium,
        )
      ],
    );
  }

  formatZeroAsOne(int? number) {
    if (number == null || number == 0 || number == double.infinity) return 1;
    return number;
  }
}
