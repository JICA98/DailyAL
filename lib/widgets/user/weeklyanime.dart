import 'package:dailyanimelist/api/malapi.dart';
import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/enums.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/main.dart';
import 'package:dailyanimelist/screens/contentdetailedscreen.dart';
import 'package:dailyanimelist/widgets/custombutton.dart';
import 'package:dailyanimelist/widgets/customfuture.dart';
import 'package:dailyanimelist/widgets/home/animecard.dart';
import 'package:dailyanimelist/widgets/slivers.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:flutter/material.dart';

class WeeklyAnimeWidget extends StatefulWidget {
  final SeasonType? seasonType;
  final int? year;
  const WeeklyAnimeWidget({Key? key, this.seasonType, this.year})
      : super(key: key);

  @override
  _WeeklyAnimeWidgetState createState() => _WeeklyAnimeWidgetState();
}

class _WeeklyAnimeWidgetState extends State<WeeklyAnimeWidget> {
  late Future<List<List<Node>>> scheduleFeature;
  var weekdays = [
    S.current.monday,
    S.current.tuesday,
    S.current.wednesday,
    S.current.thursday,
    S.current.friday,
    S.current.saturday,
    S.current.sunday,
    S.current.Others
  ];

  @override
  void initState() {
    super.initState();
    scheduleFeature = getFuture();
  }

  getFuture() {
    return MalApi.getSchedule(
      currentYear: widget.year,
      seasonType: widget.seasonType,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CFutureBuilder(
      future: scheduleFeature,
      done: handleResult,
      loadingChild: loadingCenter(),
      onError: (error) => {logDal(error)},
    );
  }

  Widget handleResult(AsyncSnapshot<List<List<Node>>>? result) {
    if (result != null && result.hasData && !nullOrEmpty(result.data)) {
      var schedule = result.data!;
      return CustomScrollView(
        slivers: [
          for (int weekIndex = 0; weekIndex < schedule.length; ++weekIndex) ...[
            SB.lh20,
            SliverWrapper(
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: title(weekdays[weekIndex], fontSize: 20, opacity: 1),
              ),
            ),
            SB.lh20,
            SliverToBoxAdapter(
              child: Container(
                height: 255,
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  itemBuilder: (_, animeIndex) {
                    var node = schedule[weekIndex][animeIndex];
                    return AnimeGridCard(
                      height: 170,
                      width: 150,
                      showEdit: true,
                      showTime: true,
                      showCardBar: true,
                      node: node,
                      updateCache: true,
                      onTap: () => navigateTo(
                          context,
                          ContentDetailedScreen(
                            node: node,
                            id: node.id,
                          )),
                    );
                  },
                  itemCount: schedule[weekIndex].length,
                  scrollDirection: Axis.horizontal,
                ),
              ),
            ),
          ],
          SB.lh120
        ],
      );
    } else {
      return showNoContent;
    }
  }

  onRefresh() {
    setState(() {
      scheduleFeature = getFuture();
    });
  }

  Widget get showNoContent {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SB.h40,
          title(S.current.No_Content, fontSize: 20),
          SB.h20,
          refreshButton
        ],
      ),
    );
  }

  Widget get refreshButton {
    return PlainButton(
      child: Text(S.current.refresh),
      onPressed: () => onRefresh(),
    );
  }
}
