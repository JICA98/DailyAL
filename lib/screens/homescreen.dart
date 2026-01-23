import 'package:dailyanimelist/api/credmal.dart';
import 'package:dailyanimelist/api/dalapi.dart';
import 'package:dailyanimelist/cache/cachemanager.dart';
import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/notifservice.dart';

import 'package:dailyanimelist/pages/explorepage.dart';
import 'package:dailyanimelist/pages/forumpage.dart';
import 'package:dailyanimelist/pages/homepage.dart';
import 'package:dailyanimelist/pages/settings/about.dart';
import 'package:dailyanimelist/pages/settings_page.dart';
import 'package:dailyanimelist/pages/side_bar.dart';
import 'package:dailyanimelist/pages/userpage.dart';
import 'package:dailyanimelist/pages/userpop.dart';
import 'package:dailyanimelist/screens/contentdetailedscreen.dart';
import 'package:dailyanimelist/screens/generalsearchscreen.dart';
import 'package:dailyanimelist/user/user.dart';
import 'package:dailyanimelist/util/responsive_helper.dart';
import 'package:dailyanimelist/widgets/avatarwidget.dart';
import 'package:dailyanimelist/widgets/background.dart';
import 'package:dailyanimelist/widgets/bottomnavbar.dart';
import 'package:dailyanimelist/widgets/customfuture.dart';
import 'package:dailyanimelist/widgets/home/anime_calendar.dart';
import 'package:dailyanimelist/widgets/home/bookmarks_widget.dart';
import 'package:dailyanimelist/widgets/home/feature_first.dart';
import 'package:dailyanimelist/widgets/will_pop_widget.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class OpacityAnima extends AnimatedWidget {
  OpacityAnima({key, animation, this.child})
      : super(
          key: key,
          listenable: animation,
        );

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    Animation<double> animation = listenable as Animation<double>;
    return Opacity(
      opacity: animation.value,
      child: child,
    );
  }
}

class HomeScreen extends StatefulWidget {
  final int? pageIndex;
  final Node? notifNode;
  final Uri? uri;
  final Widget? loadWidget;

  const HomeScreen(
      {Key? key, this.pageIndex, this.notifNode, this.uri, this.loadWidget})
      : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int pageIndex = 0;
  late AnimationController _animationController;
  late Animation animation;
  final backImagePages = [homeIndex];

  Map<int, Widget> homeWidgets = {};

  @override
  void initState() {
    super.initState();
    pageIndex = 0;

    _animationController = AnimationController(
      vsync: this,
      value: 1.0,
      duration: Duration(milliseconds: 250),
    );
    animation = Tween(begin: 0.0, end: 1.0).animate(_animationController);

    // Initialize with phone widgets by default
    // Will be updated in didChangeDependencies based on actual screen size
    homeWidgets = _getPhoneWidgets();

    if (widget.pageIndex != null) {
      pageIndex = widget.pageIndex! % 4; // Use 4 for initial calculation
    } else {
      pageIndex = user.pref.startUpPage;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await setupScheduledNotifications();
      _checkForUpdates();
      DalApi.i.scheduleForMalIds.then((value) => logDal('loaded'));
      if (widget.uri != null) {
        Navigator.pushNamed(context, widget.uri!.path);
      } else if (widget.notifNode != null) {
        gotoPage(
          context: context,
          newPage: ContentDetailedScreen(
            category: "anime",
            id: widget.notifNode!.id,
            node: widget.notifNode,
          ),
        );
      } else if (widget.loadWidget != null) {
        gotoPage(context: context, newPage: widget.loadWidget!);
      } else {
        if (hasNewFeatures) {
          showCupertinoDialog(
              context: context,
              barrierDismissible: true,
              builder: (context) => AnimatedPadding(
                    padding: MediaQuery.of(context).viewInsets,
                    duration: const Duration(milliseconds: 100),
                    curve: Curves.decelerate,
                    child: FeatureShowCase(),
                  ));
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Now MediaQuery is available, determine the correct widget map
    final screenSize = ResponsiveHelper.getScreenSize(context);
    final useNavigationRail = screenSize.index >= ScreenSize.expanded.index;

    final newWidgets =
        useNavigationRail ? _getTabletWidgets() : _getPhoneWidgets();

    // Only update if the widget map has changed
    if (homeWidgets.length != newWidgets.length) {
      setState(() {
        homeWidgets = newWidgets;
        // Adjust pageIndex if it's out of bounds
        if (pageIndex >= homeWidgets.length) {
          pageIndex = 0;
        }
      });
    }
  }

  Map<int, Widget> _getPhoneWidgets() {
    return {
      homeIndex: OpacityAnima(child: HomePage(), animation: animation),
      forumIndex: OpacityAnima(child: ForumPage(), animation: animation),
      userIndex: OpacityAnima(child: UserPage(), animation: animation),
      exploreIndex: OpacityAnima(child: ExplorePage(), animation: animation),
      phoneProfileIndex: OpacityAnima(
          child: UserPopSlideOpenPage(
              isSelf: true, isFullScreen: true, showCloseBtn: false),
          animation: animation),
    };
  }

  Map<int, Widget> _getTabletWidgets() {
    return {
      homeIndex: OpacityAnima(child: HomePage(), animation: animation),
      socialIndex: OpacityAnima(child: ForumPage(), animation: animation),
      userIndex: OpacityAnima(child: UserPage(), animation: animation),
      exploreIndex: OpacityAnima(child: ExplorePage(), animation: animation),
      searchIndex: OpacityAnima(
          child: GeneralSearchScreen(
              autoFocus: false, showBackButton: false, onClose: _onSearchClose),
          animation: animation),
      profileIndex: OpacityAnima(
          child: UserPopSlideOpenPage(
              isSelf: true, isFullScreen: true, showCloseBtn: false),
          animation: animation),
      bookmarksIndex: OpacityAnima(
          child: BookMarksWidget(showCloseButton: false), animation: animation),
      calendarIndex: OpacityAnima(
          child: AnimeCalendarWidget(showCloseButton: false),
          animation: animation),
    };
  }

  void _onSearchClose() {
    _animationController.reset();
    _animationController.forward();
    if (mounted)
      setState(() {
        pageIndex = homeIndex;
      });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  setupScheduledNotifications() async {
    if (user.status == AuthStatus.AUTHENTICATED) {
      await NotificationService().askForPermission();
      NotificationService().scheduledNotifcation();
    }
  }

  Future<void> _checkForUpdates() async {
    try {
      if (BuildVariant.fdroid == CredMal.buildVariant) {
        return;
      }
      final tag = await getCurrentTag();
      final git = await getLatestRelease();
      final latestTag = git.tagName ?? '';
      final available = isUpdateAvailable(tag, latestTag);
      final hasAlreadyNotified = await _hasAlreadyNotified(latestTag);
      if (available && !hasAlreadyNotified) {
        await showDialog(
          context: context,
          builder: (context) => showUpdateAvailablePopup(git, context, tag),
        );
        CacheManager.instance
            .setValueForServiceAutoExpireIn('update', latestTag, 'true');
      }
    } catch (e) {}
  }

  Future<bool> _hasAlreadyNotified(String latestTag) async {
    return (await CacheManager.instance
                .getValueForServiceAutoExpire('update', latestTag))
            ?.toString()
            .equals('true') ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = ResponsiveHelper.getScreenSize(context);
    final useNavigationRail = screenSize.index >= ScreenSize.expanded.index;

    final bodyContent = WillPopWidget(
      onWillPop: () async {
        return true;
      },
      child: Stack(
        children: [
          AnimatedOpacity(
            opacity: backImagePages.contains(pageIndex) ? 1 : 0,
            duration: Duration(milliseconds: 300),
            child: Background(
              context: context,
              height: MediaQuery.of(context).size.height / 2,
              showLocalFile: user.pref.bgPath != null,
              url: user.pref.bgPath,
            ),
          ),
          user.pref.keepPagesInMemory
              ? IndexedStack(
                  children: homeWidgets.values.toList(),
                  index: pageIndex,
                )
              : homeWidgets[pageIndex % homeWidgets.length]!,
        ],
      ),
    );

    if (useNavigationRail) {
      final isShortScreen = MediaQuery.of(context).size.height < 700;
      return Scaffold(
        body: Row(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: NavigationRail(
                        selectedIndex: pageIndex,
                        onDestinationSelected: (value) => _onSelected(value),
                        labelType: isShortScreen
                            ? NavigationRailLabelType.none
                            : NavigationRailLabelType.all,
                        leading: Padding(
                          padding:
                              const EdgeInsets.only(bottom: 40.0, top: 10.0),
                          child: SizedBox(
                            height: 60,
                            width: 60,
                            child: CircleAvatar(
                              backgroundImage:
                                  AssetImage('assets/images/dal-black-bg.png'),
                              radius: 48.0,
                            ),
                          ),
                        ), // Top spacing
                        trailing: Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 20.0),
                            ),
                          ),
                        ),
                        destinations: [
                          NavigationRailDestination(
                            icon: Icon(Icons.home_outlined),
                            selectedIcon: Icon(Icons.home),
                            label: Text(S.current.Home),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.people_outline),
                            selectedIcon: Icon(Icons.people),
                            label: Text(S.current.Social),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.person_outline),
                            selectedIcon: Icon(Icons.person),
                            label: Text(S.current.User),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.explore_outlined),
                            selectedIcon: Icon(Icons.explore),
                            label: Text(S.current.Explore),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.search_outlined),
                            selectedIcon: Icon(Icons.search),
                            label: Text(S.current.Search),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.bookmarks_outlined),
                            selectedIcon: Icon(Icons.bookmarks),
                            label: Text(S.current.Bookmarks),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.calendar_today_outlined),
                            selectedIcon: Icon(Icons.calendar_today),
                            label: Text(S.current.Calendar),
                          ),
                          NavigationRailDestination(
                            label: Text(S.current.Profile),
                            icon: _userProfileWidget(),
                            selectedIcon: _userProfileWidget(isSelected: true),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            VerticalDivider(thickness: 1, width: 1),
            Expanded(child: bodyContent),
          ],
        ),
      );
    } else {
      return Scaffold(
        bottomNavigationBar: BottomNavBar(
          startIndex: pageIndex,
          onChanged: (value) {
            _animationController.reset();
            _animationController.forward();
            if (mounted)
              setState(() {
                pageIndex = value;
              });
          },
        ),
        body: bodyContent,
      );
    }
  }

  void _onSelected(int value) {
    _animationController.reset();
    _animationController.forward();
    if (mounted)
      setState(() {
        pageIndex = value;
      });
  }

  Widget _userProfileWidget({bool isSelected = false}) {
    if (user.status != AuthStatus.AUTHENTICATED) {
      return IconButton(
        icon: Icon(Icons.settings_outlined),
        onPressed: () {
          gotoPage(context: context, newPage: SettingsPage());
        },
        tooltip: S.current.Settings,
      );
    }
    return CFutureBuilder<UserProf?>(
        loadingChild: SB.z,
        future: UserProfService.i.userProf,
        done: (userProf) {
          return Material(
            color: Colors.transparent,
            child: Container(
              // height: 50,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: Container(
                    child: Container(
                  height: 45,
                  width: 45,
                  decoration: BoxDecoration(
                    border: isSelected
                        ? Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2.0)
                        : null,
                    borderRadius: BorderRadius.circular(22.5),
                  ),
                  child: AvatarWidget(
                    url: userProf.data?.picture,
                    onTap: () => _onSelected(profileIndex),
                  ),
                )),
              ),
            ),
          );
        });
  }
}
