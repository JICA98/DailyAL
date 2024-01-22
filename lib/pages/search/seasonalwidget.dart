import 'package:dailyanimelist/api/malapi.dart';
import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/enums.dart';
import 'package:dailyanimelist/main.dart';
import 'package:dailyanimelist/screens/generalsearchscreen.dart';
import 'package:dailyanimelist/screens/plainscreen.dart';
import 'package:dailyanimelist/screens/seasonal_screen.dart';
import 'package:dailyanimelist/widgets/custombutton.dart';
import 'package:dailyanimelist/widgets/headerwidget.dart';
import 'package:dailyanimelist/widgets/user/weeklyanime.dart';
import 'package:flutter/material.dart';

class SeasonalWidget extends StatefulWidget {
  static const horizPadding = 20.0;
  final bool useSlivers;
  const SeasonalWidget({
    Key? key,
    this.useSlivers = false,
  }) : super(key: key);

  @override
  State<SeasonalWidget> createState() => _SeasonalWidgetState();
}

class _SeasonalWidgetState extends State<SeasonalWidget> {
  final seasonList = seasonMapCaps.values.toList();
  final yearList = List.generate(SeasonalConstants.totalYears,
      (index) => (SeasonalConstants.maxYear - index).toString());
  int currentYearIndex =
      (SeasonalConstants.maxYear - MalApi.getCurrentSeasonYear()).abs();
  int currentSeasonIndex = MalApi.getSeasonType().index;

  @override
  Widget build(BuildContext context) {
    if (widget.useSlivers) {
      return SliverList(delegate: SliverChildListDelegate(_buildWidgets));
    } else {
      return Column(
        children: _buildWidgets,
      );
    }
  }

  List<Widget> get _buildWidgets {
    return [
      HeaderWidget(
        listPadding:
            const EdgeInsets.symmetric(horizontal: SeasonalWidget.horizPadding),
        header: yearList,
        selectedIndex: currentYearIndex,
        shouldAnimate: false,
        fontSize: 19,
        onPressed: (index) {
          if (mounted)
            setState(() {
              currentYearIndex = index;
            });
        },
      ),
      SB.h30,
      HeaderWidget(
        listPadding:
            const EdgeInsets.symmetric(horizontal: SeasonalWidget.horizPadding),
        header: seasonList,
        selectedIndex: currentSeasonIndex,
        fontSize: 13,
        shouldAnimate: false,
        itemPadding: const EdgeInsets.symmetric(horizontal: 20),
        onPressed: (index) {
          if (mounted)
            setState(() {
              currentSeasonIndex = index;
            });
        },
      ),
      SB.h20,
      Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: SeasonalWidget.horizPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ShadowButton(
              onPressed: () => gotoPage(
                  context: context,
                  newPage: SeasonalScreen(
                    seasonType: seasonMap.keys.elementAt(currentSeasonIndex),
                    year: int.parse(yearList.elementAt(currentYearIndex)),
                  )),
              child: Text(S.current.Search_By_Season),
            ),
            ShadowButton(
              onPressed: () => gotoPage(
                  context: context,
                  newPage: TitlebarScreen(
                    WeeklyAnimeWidget(
                      seasonType: seasonMap.keys.elementAt(currentSeasonIndex),
                      year: int.tryParse(yearList.elementAt(currentYearIndex)) ?? DateTime.now().year,
                    ),
                    appbarTitle:
                        '${seasonMapCaps.values.elementAt(currentSeasonIndex)} ${yearList.elementAt(currentYearIndex)}',
                  )),
              child: Text(S.current.WeeklyAnime),
            ),
          ],
        ),
      )
    ];
  }
}
