import 'package:dailyanimelist/api/credmal.dart';
import 'package:dailyanimelist/api/malclubs.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/main.dart';
import 'package:dailyanimelist/util/responsive_helper.dart';
import 'package:dailyanimelist/widgets/club/clublistwidget.dart';
import 'package:dailyanimelist/widgets/homeappbar.dart';
import 'package:dailyanimelist/widgets/loading/shimmerwidget.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:flutter/material.dart';

import '../constant.dart';

class ClubsPage extends StatefulWidget {
  final bool hideAppBar;
  const ClubsPage({Key? key, this.hideAppBar = false}) : super(key: key);

  @override
  _ClubsPageState createState() => _ClubsPageState();
}

class _ClubsPageState extends State<ClubsPage> {
  bool hasOpened = false;
  ClubListHtml? clubListHtml;

  @override
  void initState() {
    super.initState();
    startOpeningAnimation();
    getClubsInfo();
  }

  getClubsInfo([bool fromCache = false]) async {
    clubListHtml = await getClubs(fromCache: fromCache);
    if (mounted) setState(() {});
  }

  Future<ClubListHtml?> getClubs({bool fromCache = true}) async {
    var _clubs = await MalClub.getClubs(fromCache: fromCache);
    if (shouldUpdateContent(
        result: _clubs, timeinHours: user.pref.cacheUpdateFrequency[1])) {
      return await getClubs(fromCache: false);
    } else {
      return _clubs;
    }
  }

  startOpeningAnimation() {
    Future.delayed(Duration(milliseconds: 10)).then((value) {
      if (mounted) {
        setState(() {
          hasOpened = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.hideAppBar) {
      return _buildClubPage();
    }
    final isTablet = ResponsiveHelper.isTabletOrLarger(context);
    final fabRightPosition = isTablet ? 50.0 : 30.0;
    final fabBottomPosition = isTablet ? 20.0 : 10.0;

    return Stack(
      children: [
        AnimatedOpacity(
          opacity: hasOpened ? 1 : 0,
          duration: Duration(milliseconds: 300),
          child: _buildClubPage(),
        ),
        Positioned(
          bottom: fabBottomPosition,
          right: fabRightPosition,
          child: FloatingActionButton(
            onPressed: () => launchURLWithConfirmation(
                '${CredMal.htmlEnd}clubs.php?action=create',
                context: context),
            child: Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  Widget _buildClubPage() {
    final isTablet = ResponsiveHelper.isTabletOrLarger(context);

    if (widget.hideAppBar || isTablet) {
      return RefreshIndicator(
        onRefresh: () async {
          getClubsInfo();
        },
        child: _buildClubContent(isTablet),
      );
    }

    return NestedScrollView(
      headerSliverBuilder: (_, __) => [_buildAppBar()],
      body: RefreshIndicator(
        onRefresh: () async {
          getClubsInfo();
        },
        child: _buildClubContent(isTablet),
      ),
    );
  }

  SliverLayoutBuilder _buildAppBar() {
    return SliverLayoutBuilder(
      builder: (p0, c) => SliverAppBar(
        automaticallyImplyLeading: false,
        pinned: true,
        floating: true,
        expandedHeight: 120,
        title: Padding(
          padding: const EdgeInsets.only(bottom: 5.0),
          child: AppBarHome(
            onUiChange: () {
              if (mounted) setState(() {});
            },
          ),
        ),
        titleSpacing: 0.0,
        bottom: _buildHeaderWidget(),
        toolbarHeight: kToolbarHeight,
        actions: [SB.z],
      ),
    );
  }

  PreferredSize _buildHeaderWidget() {
    final isTablet = ResponsiveHelper.isTabletOrLarger(context);
    final horizontalPadding = ResponsiveHelper.getHorizontalPadding(context);

    return PreferredSize(
      preferredSize: Size(double.infinity, 63),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: 6,
          top: 7.0,
          left: isTablet ? horizontalPadding : 0,
          right: isTablet ? horizontalPadding : 0,
        ),
        child: Container(
          height: 50,
          child: Center(
            child: Text(
              S.current.Clubs,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClubContent(bool isTablet) {
    final contentPadding = ResponsiveHelper.getContentPadding(context);

    if (clubListHtml?.clubs == null) {
      return ShimmerWidget();
    }

    if (clubListHtml!.clubs!.isEmpty) {
      return showNoContent();
    }

    return SingleChildScrollView(
      child: Padding(
        padding: isTablet ? contentPadding : EdgeInsets.zero,
        child: ClubListWidget(
          clubListHtml: clubListHtml!,
        ),
      ),
    );
  }
}
