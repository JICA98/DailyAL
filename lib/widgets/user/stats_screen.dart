import 'package:collection/collection.dart';
import 'package:dailyanimelist/api/credmal.dart';
import 'package:dailyanimelist/api/jikahelper.dart';
import 'package:dailyanimelist/api/maluser.dart';
import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/enums.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/main.dart';
import 'package:dailyanimelist/pages/settingspage.dart';
import 'package:dailyanimelist/screens/characterscreen.dart';
import 'package:dailyanimelist/screens/generalsearchscreen.dart';
import 'package:dailyanimelist/screens/moreinfo.dart';
import 'package:dailyanimelist/screens/plainscreen.dart';
import 'package:dailyanimelist/user/user.dart';
import 'package:dailyanimelist/util/insight_service.dart';
import 'package:dailyanimelist/widgets/barchart.dart';
import 'package:dailyanimelist/widgets/customfuture.dart';
import 'package:dailyanimelist/widgets/headerwidget.dart';
import 'package:dailyanimelist/widgets/home/accordion.dart';
import 'package:dailyanimelist/widgets/slivers.dart';
import 'package:dailyanimelist/widgets/user/charts/distributed_chart.dart';
import 'package:dailyanimelist/widgets/user/charts/stats_chart.dart';
import 'package:dailyanimelist/widgets/user/contentlistwidget.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final userChartDefaultColors = [
  Colors.green.value,
  Colors.blue.value,
  Colors.orange.value,
  Colors.red.value,
  Colors.brown.value,
];

int getStatusColor(int index) {
  final at = user.pref.userchart.tryAt(index);
  if (at == null || at == -1) {
    return userChartDefaultColors[index];
  } else {
    return at;
  }
}

class UserStatsScreen extends StatefulWidget {
  final String username;
  final bool isSelf;
  const UserStatsScreen({
    super.key,
    required this.username,
    this.isSelf = true,
  });

  @override
  State<UserStatsScreen> createState() => _UserStatsScreenState();
}

class _UserStatsScreenState extends State<UserStatsScreen> {
  UserProfileV4? jikanUser;
  String _category = 'anime';
  Map<String, IconData> _genderTypesMap = {
    "male": Icons.male,
    "female": Icons.female
  };
  UserInsights? _insights;
  late Future<UserProf?> _userProfFuture;

  @override
  void initState() {
    super.initState();
    _userProfFuture = _getUserProfileFuture();
    _setJikanData();
    if (user.status == AuthStatus.AUTHENTICATED) _setUserInsights();
  }

  void _setJikanData() async {
    jikanUser = ((await JikanHelper.getUserInfo(
            username: widget.username, fromCache: false))
        .data);
    if (mounted) setState(() {});
  }

  void _setUserInsights() async {
    var allUserList = await MalUser.getAllUserList(widget.username, _category);
    _insights = UserInsights(allUserList.data ?? [], _category);
    if (mounted) setState(() {});
  }

  var mangaList = [S.current.Reading, 'CMPL', 'On Hold', 'Dropped', 'PTR'];
  var animeList = [S.current.Watching, 'CMPL', 'On Hold', 'Dropped', 'PTW'];

  List<String> titleList(String category) =>
      (category.equals("anime") ? animeList : mangaList).toList();

  Widget _loading() =>
      loadingBelowText(text: '${S.current.Loading} ${S.current.Stats}');

  String _meanScore(UserProf? userProf) {
    return (_category.equals("anime")
            ? (jikanUser?.statistics?.anime?.meanScore?.toStringAsFixed(2) ??
                userProf?.animeStatistics?.meanScore?.toStringAsFixed(2) ??
                "?")
            : (jikanUser?.statistics?.manga?.meanScore?.toStringAsFixed(2) ??
                "?")) +
        " ";
  }

  String _entries(UserProf? userProf) {
    return (_category.equals("anime")
        ? (jikanUser?.statistics?.anime?.totalEntries?.toStringAsFixed(0) ??
            userProf?.animeStatistics?.numItems?.toStringAsFixed(0) ??
            "?")
        : (jikanUser?.statistics?.manga?.totalEntries?.toStringAsFixed(0) ??
            "?"));
  }

  String _days(UserProf? userProf) {
    return (_category.equals("anime")
        ? (userProf?.animeStatistics?.numDaysWatched?.toStringAsFixed(2) ??
            jikanUser?.statistics?.anime?.daysWatched?.toStringAsFixed(2) ??
            "?")
        : (jikanUser?.statistics?.manga?.daysRead?.toStringAsFixed(2) ?? "?"));
  }

  String _soFar(UserProf? userProf) {
    return _category.equals("anime")
        ? ((jikanUser?.statistics?.anime?.episodesWatched?.toString() ??
                userProf?.animeStatistics?.numEpisodes?.toStringAsFixed(0) ??
                "0") +
            " ${S.current.Episodes}")
        : ((jikanUser?.statistics?.manga?.chaptersRead?.toString() ?? "0") +
                " Chps") +
            " - " +
            (jikanUser?.statistics?.manga?.volumesRead?.toString() ?? "0") +
            " Vols";
  }

  String _gender(UserProf? userProf) {
    return (_trimToNull(userProf?.gender) ??
            _trimToNull(jikanUser?.gender) ??
            S.current.UNKNOWN)
        .toLowerCase();
  }

  String _location(UserProf? userProf) {
    return _trimToNull(userProf?.location) ??
        _trimToNull(jikanUser?.location) ??
        S.current.UNKNOWN;
  }

  String _birthDay(UserProf? userProf) {
    return _date(userProf?.birthday) ??
        _trimToNull(jikanUser?.birthday) ??
        S.current.UNKNOWN;
  }

  String? _trimToNull(String? value) {
    if (value == null) return null;
    if (value.isBlank) return null;
    return value;
  }

  String? _date(DateTime? date) {
    if (date == null) return null;
    return DateFormat.yMEd().format(date);
  }

  void _onCategoryChange(value) {
    _category = contentTypes[value];
    _setUserInsights();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return CFutureBuilder<UserProf?>(
      future: _userProfFuture,
      done: (sp) => _statsBuilder(sp.data),
      loadingChild: _loading(),
    );
  }

  Future<UserProf?> _getUserProfileFuture() async {
    if (widget.isSelf) {
      return UserProfService.i.userProf;
    } else {
      return MalUser.getUserInfo(username: widget.username, fromCache: true);
    }
  }

  Widget _statsBuilder(UserProf? userProf) {
    if (userProf == null) return _loading();
    return CustomScrollView(
      slivers: [
        SB.lh10,
        _categorySelector(),
        SB.lh10,
        _profileSection(userProf),
        SB.lh10,
        AnimeMangaPlayingChart(
          userProf: userProf,
          category: _category,
          jikanUser: jikanUser,
          isSelf: widget.isSelf,
        ),
        if (user.status == AuthStatus.AUTHENTICATED) ...[
          if (_insights == null)
            ..._loadingCards
          else
            ..._advancedChartWidgets(_insights!),
        ],
        SB.lh40,
      ],
    );
  }

  List<Widget> get _loadingCards {
    return [
      for (int i = 0; i < 3; ++i)
        SliverWrapper(SizedBox(
          height: 320.0,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: loadingCenterColored,
              ),
            ),
          ),
        )),
    ];
  }

  SliverWrapper _categorySelector() {
    return SliverWrapper(
      HeaderWidget(
        shouldAnimate: false,
        selectedIndex: contentTypes.indexOf(_category),
        listPadding: const EdgeInsets.symmetric(horizontal: 10),
        header: contentTypes.map((e) => e.capitalize()!).toList(),
        onPressed: _onCategoryChange,
      ),
    );
  }

  List<Widget> _advancedChartWidgets(UserInsights insights) {
    return [
      SB.lh10,
      SliverWrapper(_scoreDistribution(
          insights.statusScoreDistributionMap, insights.unrankedShows ?? 0)),
      SB.lh10,
      SliverWrapper(_genreDistribution(insights)),
      SB.lh10,
      if (insights.iLikeItTheyHateIt.isNotEmpty)
        SliverWrapper(_iLikeItTheyHateItWidget(insights)),
      SB.lh10,
      SliverWrapper(_mediaTypeDistribution(insights)),
      if (_animeSelected) ...[
        SB.lh10,
        SliverWrapper(_sourceDistribution(insights)),
      ],
      SB.lh10,
      SliverWrapper(_studioAuthorDistribution(insights)),
      SB.lh10,
    ];
  }

  Widget _sourceDistribution(UserInsights insights) {
    return ScoreItemDistributionWidget(
      scoreItemMap: insights.distributionMap[Distribution.source]!,
      titleList: titleList(_category),
      category: _category,
      title: S.current.Source,
      notEnoughDataMsg: S.current.No_Enough_Data_To_generate_Graph_Info,
      onItemName: (ScoreItem item) => item.source,
      itemColumnName: S.current.Source,
    );
  }

  Widget _mediaTypeDistribution(UserInsights insights) {
    return ScoreItemDistributionWidget(
      scoreItemMap: insights.distributionMap[Distribution.mediaType]!,
      titleList: titleList(_category),
      category: _category,
      title: S.current.Media,
      notEnoughDataMsg: S.current.No_Enough_Data_To_generate_Graph_Info,
      onItemName: (ScoreItem item) => item.mediaType,
      onItemPress: (item) =>
          onMediaTypeTap(item.mediaType ?? '', _category, context),
      itemColumnName: S.current.Media,
    );
  }

  Widget _iLikeItTheyHateItWidget(UserInsights insights) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(S.current.I_Liked_It_They_Hated_It,
                  style: Theme.of(context).textTheme.titleLarge),
              SB.w10,
              IconButton(
                onPressed: () => gotoPage(
                  context: context,
                  newPage: TitlebarScreen(
                    CustomScrollWrapper([
                      _ILikeItTheyHateItList(insights, DisplayType.list_vert)
                    ]),
                    appbarTitle: S.current.I_Liked_It_They_Hated_It,
                  ),
                ),
                icon: Icon(
                  Icons.arrow_forward_ios_rounded,
                ),
              )
            ],
          ),
        ),
        SB.h20,
        SizedBox(
          height: 260.0,
          child: _ILikeItTheyHateItList(insights),
        ),
      ],
    );
  }

  ContentListWidget _ILikeItTheyHateItList(
    UserInsights insights, [
    DisplayType displayType = DisplayType.list_horiz,
  ]) {
    return ContentListWidget(
      displayType: displayType,
      contentList: insights.iLikeItTheyHateIt.map((e) => e.baseNode).toList(),
      padding: EdgeInsets.symmetric(
        horizontal: displayType == DisplayType.list_horiz ? 40.0 : 0,
        vertical: displayType == DisplayType.list_vert ? 20.0 : 0,
      ),
      category: _category,
      updateCacheOnEdit: true,
      showBackgroundImage: false,
      returnSlivers: displayType == DisplayType.list_vert,
      showSelfScoreInsteadOfStatus: true,
    );
  }

  final _genreFilters = [
    S.current.Genres,
    S.current.Explicit_Genres,
    S.current.Themes,
    S.current.Demographics,
  ];

  Widget _genreDistribution(UserInsights insights) {
    return ScoreItemDistributionWidget(
      title: S.current.Genre_Distribution,
      scoreItemMap: insights.distributionMap[Distribution.genre]!,
      titleList: titleList(_category),
      notEnoughDataMsg: S.current.No_Enough_Data_To_generate_Graph,
      category: _category,
      onItemName: (item) {
        if (item.genre != null) {
          return convertGenre(item.genre!, _category);
        }
        return null;
      },
      availableFilters: _genreFilters,
      onItemFilter: (item, selectedFilter) {
        final genre = item.genre;
        if (genre != null) {
          final genreStr = convertGenre(genre, _category);
          final category = Mal.getGenreCategory(genreStr);
          return category.equals(selectedFilter);
        }
        return false;
      },
      onItemPress: (ScoreItem item) {
        if (item.genre != null) {
          onGenrePress(item.genre!, _category, context);
        }
      },
      itemColumnName: S.current.Genres,
    );
  }

  Widget _studioAuthorDistribution(UserInsights insights) {
    return ScoreItemDistributionWidget(
      scoreItemMap: insights.distributionMap[Distribution.studio_author]!,
      titleList: titleList(_category),
      category: _category,
      title: _animeSelected
          ? S.current.Studio_Distribution
          : S.current.Author_Distribution,
      notEnoughDataMsg: S.current.No_Enough_Data_To_generate_Graph_Info,
      onItemName: (ScoreItem item) {
        if (_animeSelected) {
          return item.studio?.name;
        } else {
          return item.author?.author?.firstName;
        }
      },
      onItemPress: _animeSelected
          ? (ScoreItem item) {
              final studio = item.studio;
              if (studio != null) {
                onStudioTap(studio, context);
              }
            }
          : (ScoreItem item) {
              final id = item.author?.author?.id;
              if (id != null) {
                gotoPage(
                  context: context,
                  newPage: CharacterScreen(
                    id: id,
                    charaCategory: 'person',
                  ),
                );
              }
            },
      itemColumnName: _animeSelected ? S.current.Studios : S.current.Authors,
    );
  }

  bool get _animeSelected => _category.equals('anime');

  Widget _scoreDistribution(Map<int, Map<String, int>> map, int unrankedShows) {
    final keys = map.keys.toList();
    final sum = map.values.expand((e) => e.values).sum;
    return ExpandedCard(
      key: Key(_category),
      title: S.current.Score_Distribution,
      height: 270.0,
      bottom: Text('$unrankedShows ${S.current.Un_Ranked_Shows}'),
      child: BarChartWidget(
        getTitlesWidget: (value, meta) => SideTitleWidget(
          axisSide: meta.axisSide,
          space: 10,
          child: Text(keys.elementAt(value.toInt()).toString(),
              style: Theme.of(context).textTheme.labelSmall),
        ),
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          final key = keys.elementAt(groupIndex);
          final currList = map[key]?.values ?? [];
          final currSum = currList.sum;
          final sumText = (sum != 0 && currSum != 0)
              ? '${((currSum / sum) * 100).toStringAsFixed(4)}%'
              : '0%';
          return BarTooltipItem(
            [
              ...map[map.keys.elementAt(groupIndex)]!
                  .entries
                  .where((e) => e.value > 0)
                  .map((entry) => '${entry.key.standardize()} - ${entry.value}')
                  .toList(),
              sumText
            ].join('\n'),
            Theme.of(context).textTheme.bodyMedium ?? TextStyle(),
          );
        },
        data: map.values.map((e) => e.values.toList()).toList(),
        getColor: (_, innerIndex) => Color(getStatusColor(innerIndex)),
      ),
      expandedChild: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          children: map.entries
              .where((e) => e.value.values.reduce((a, b) => a + b) > 0)
              .map((e) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        iconAndText(Icons.star, e.key.toString(), width: 5.0),
                        SB.w20,
                        Expanded(
                          child: Text(
                            e.value.entries
                                .where((e) => e.value > 0)
                                .map((entry) =>
                                    '${entry.key.standardize()} - ${entry.value}')
                                .toList()
                                .join(' '),
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  SliverPadding _profileSection(UserProf userProf) {
    final gender = _gender(userProf);
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      sliver: SliverWrapper(Accordion(
        isOpen: true,
        title: S.current.Profile,
        titleStyle: Theme.of(context).textTheme.titleLarge,
        titlePadding: const EdgeInsets.symmetric(horizontal: 10.0),
        atStartExpanded: true,
        additional: [
          if (widget.isSelf)
            IconButton.filledTonal(
                onPressed: () => launchURLWithConfirmation(
                    '${CredMal.htmlEnd}editprofile.php',
                    context: context),
                icon: Icon(Icons.edit)),
          IconButton.filledTonal(
              onPressed: () => showToast('${S.current.Gender}: $gender'),
              tooltip: gender,
              icon: Icon(
                _genderTypesMap[gender] ?? Icons.ac_unit,
              )),
          IconButton.filledTonal(
              onPressed: () => launchURLWithConfirmation(
                    '${CredMal.htmlEnd}profile/${widget.username}',
                    context: context,
                  ),
              icon: Icon(Icons.open_in_browser))
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _meanScoreField(userProf),
                ),
                Expanded(
                  child: _statField(S.current.Entries.capitalize()!,
                      fieldValue: _entries(userProf)),
                )
              ],
            ),
            Row(
              children: [
                Expanded(
                  child:
                      _statField(S.current.Days, fieldValue: _days(userProf)),
                ),
                Expanded(
                  child: _statField(S.current.So_far,
                      fieldValue: _soFar(userProf)),
                )
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _statField(S.current.Location,
                      fieldValue: _location(userProf)),
                ),
                Expanded(
                  child: _statField(S.current.BirthDay,
                      fieldValue: _birthDay(userProf)),
                )
              ],
            )
          ],
        ),
      )),
    );
  }

  Widget _meanScoreField(UserProf userProf) {
    return _statField(
      S.current.Mean_Score,
      child: starField(
        _meanScore(userProf),
      ),
    );
  }

  Widget _statField(String fieldName, {String? fieldValue, Widget? child}) {
    final labelMedium = Theme.of(context).textTheme.labelMedium;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fieldName,
              style: labelMedium?.copyWith(
                  color: labelMedium.color?.withOpacity(.8)),
            ),
            SB.h10,
            if (child != null)
              child
            else if (fieldValue != null)
              Text(
                fieldValue,
              )
          ],
        ),
      ),
    );
  }
}
