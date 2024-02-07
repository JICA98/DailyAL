import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/notifservice.dart';
import 'package:dailyanimelist/pages/explorepage.dart';
import 'package:dailyanimelist/pages/forumpage.dart';
import 'package:dailyanimelist/pages/homepage.dart';
import 'package:dailyanimelist/pages/settings/about.dart';
import 'package:dailyanimelist/pages/side_bar.dart';
import 'package:dailyanimelist/pages/userpage.dart';
import 'package:dailyanimelist/screens/contentdetailedscreen.dart';
import 'package:dailyanimelist/screens/user_profile.dart';
import 'package:dailyanimelist/user/user.dart';
import 'package:dailyanimelist/widgets/background.dart';
import 'package:dailyanimelist/widgets/bottomnavbar.dart';
import 'package:dailyanimelist/widgets/home/feature_first.dart';
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
    homeWidgets = {
      homeIndex: OpacityAnima(child: HomePage(), animation: animation),
      forumIndex: OpacityAnima(child: ForumPage(), animation: animation),
      userIndex: OpacityAnima(child: UserPage(), animation: animation),
      profileIndex: OpacityAnima(
          child: UserProfilePage(isSelf: true), animation: animation),
      exploreIndex: OpacityAnima(child: ExplorePage(), animation: animation)
    };

    if (widget.pageIndex != null) {
      pageIndex = widget.pageIndex! % homeWidgets.length;
    } else {
      pageIndex = user.pref.startUpPage;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await setupScheduledNotifications();
      _checkForUpdates();
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

  setupScheduledNotifications() async {
    if (user.status == AuthStatus.AUTHENTICATED) {
      await NotificationService().askForPermission();
      NotificationService().scheduledNotifcation();
    }
  }

  Future<void> _checkForUpdates() async {
    try {
      final tag = await getCurrentTag();
      final git = await getLatestRelease();
      final available = isUpdateAvailable(tag, git.tagName ?? '');
      if (available) {
        await showDialog(
          context: context,
          builder: (context) => showUpdateAvailablePopup(git, context, tag),
        );
      }
    } catch (e) {}
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: Drawer(
        child: AppSideBar(),
      ),
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
      body: WillPopScope(
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
      ),
    );
  }
}
