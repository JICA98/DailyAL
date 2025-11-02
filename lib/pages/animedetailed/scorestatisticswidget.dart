import 'package:dailyanimelist/api/jikan_models.dart';
import 'package:dailyanimelist/api/jikahelper.dart';
import 'package:dailyanimelist/widgets/shimmecolor.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScoreStatisticsWidget extends StatefulWidget {
  final int id;
  final double horizPadding;

  const ScoreStatisticsWidget({
    Key? key,
    required this.id,
    required this.horizPadding,
  }) : super(key: key);

  @override
  _ScoreStatisticsWidgetState createState() => _ScoreStatisticsWidgetState();
}

class _ScoreStatisticsWidgetState extends State<ScoreStatisticsWidget>
    with AutomaticKeepAliveClientMixin {
  late Future<JikanAnimeStatistics?> statisticsFuture;
  List<double> statList = [];
  List<double> statListHeight = [];
  List<String> statName = [];
  NumberFormat statFormat = NumberFormat.compact();

  @override
  void initState() {
    super.initState();
    statisticsFuture = JikanHelper.getAnimeScoreStatistics(widget.id);
  }

  void _animateBars(List<ScoreStatistics> scoreList) {
    // Clear previous data
    statName.clear();
    statList.clear();
    statListHeight.clear();

    // Fill data from scoreList
    for (var scoreStat in scoreList) {
      statName.add(scoreStat.score.toString());
      statList.add(scoreStat.votes?.toDouble() ?? 0.0);
      statListHeight.add(0.0); // Start with 0 height for animation
    }

    // Trigger animation after initial build
    Future.delayed(Duration.zero).then((_) {
      if (mounted) {
        setState(() {
          // Calculate bar heights for animation
          double maxVotes =
              statList.isNotEmpty ? statList.reduce((a, b) => a > b ? a : b) : 1;
          var multiplier = 100 / (maxVotes > 0 ? maxVotes : 1);

          statListHeight = statList.map((votes) => votes * multiplier).toList();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<JikanAnimeStatistics?>(
      future: statisticsFuture,
      builder: (context, snapshot) {
        // Handle loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingGraph(context);
        }

        // Handle error state
        if (snapshot.hasError) {
          return _buildNoDataWidget();
        }

        // Handle no data or null response
        if (!snapshot.hasData || snapshot.data == null || snapshot.data!.scores == null) {
          return _buildNoDataWidget();
        }

        // Display data
        return _scoreStatsWidget(snapshot.data!.scores!);
      },
    );
  }

  Widget _buildLoadingGraph(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          height: 14,
          width: double.infinity,
        ),
        SizedBox(
          height: 260,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(10, (i) => _buildLoadingBar(context, i)),
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        ShimmerColor(
          Container(
            width: 150,
            height: 16,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingBar(BuildContext context, int index) {
    // Create varying heights for visual interest
    final heights = [40.0, 60.0, 80.0, 120.0, 140.0, 160.0, 180.0, 200.0, 220.0, 240.0];

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ShimmerColor(
          Container(
            width: 30,
            height: 12,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: ShimmerColor(
            Container(
              height: heights[index],
              width: 20,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        ShimmerColor(
          Container(
            width: 20,
            height: 12,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        const SizedBox(height: 10),
        ShimmerColor(
          Container(
            width: 30,
            height: 12,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoDataWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          'No score statistics available',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  Widget _scoreStatsWidget(List<ScoreStatistics> scoreList) {
    if (scoreList.isEmpty) return _buildNoDataWidget();

    // Initialize animation on first build
    if (statList.isEmpty) {
      _animateBars(scoreList);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          height: 14,
          width: double.infinity,
        ),
        SizedBox(
          height: 260,
          child: Scrollbar(
            interactive: true,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: widget.horizPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children:
                    List.generate(statList.length, (i) => _buildStatBar(i, scoreList)),
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Text(
          "Total Votes: ${statFormat.format(statList.reduce((a, b) => a + b))}",
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }

  Column _buildStatBar(int i, List<ScoreStatistics> scoreList) {
    final scoreStat = scoreList[i];

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "${scoreStat.percentage?.toStringAsFixed(1) ?? '0'}%",
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall,
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: statListHeight[i] * 1.75,
            width: 20,
            decoration: BoxDecoration(
              color: Color(_getColorForScore(scoreStat.score ?? 0)),
              borderRadius: const BorderRadius.only(
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

  int _getColorForScore(int score) {
    switch (score) {
      case 1:
        return 0xFFD32F2F; // Red
      case 2:
        return 0xFFE64A19; // Deep Orange
      case 3:
        return 0xFFFF6F00; // Orange
      case 4:
        return 0xFFFF8F00; // Orange Accent
      case 5:
        return 0xFFFFA726; // Light Orange
      case 6:
        return 0xFFFFCA28; // Amber
      case 7:
        return 0xFFCDDC39; // Lime
      case 8:
        return 0xFF9CCC65; // Light Green
      case 9:
        return 0xFF66BB6A; // Green
      case 10:
        return 0xFF42A5F5; // Blue (highest score)
      default:
        return 0xFF9E9E9E; // Grey
    }
  }

  @override
  bool get wantKeepAlive => true;
}
