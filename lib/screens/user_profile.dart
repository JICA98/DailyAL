import 'package:cached_network_image/cached_network_image.dart';
import 'package:dailyanimelist/api/credmal.dart';
import 'package:dailyanimelist/api/jikahelper.dart';
import 'package:dailyanimelist/api/maluser.dart';
import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/main.dart';
import 'package:dailyanimelist/pages/settingspage.dart';
import 'package:dailyanimelist/pages/userpage.dart';
import 'package:dailyanimelist/screens/plainscreen.dart';
import 'package:dailyanimelist/user/user.dart';
import 'package:dailyanimelist/util/streamutils.dart';
import 'package:dailyanimelist/widgets/avatarwidget.dart';
import 'package:dailyanimelist/widgets/common/image_preview.dart';
import 'package:dailyanimelist/widgets/custombutton.dart';
import 'package:dailyanimelist/widgets/customfuture.dart';
import 'package:dailyanimelist/widgets/home/bookmarks_widget.dart';
import 'package:dailyanimelist/widgets/homeappbar.dart';
import 'package:dailyanimelist/widgets/loading/expandedwidget.dart';
import 'package:dailyanimelist/widgets/selectbottom.dart';
import 'package:dailyanimelist/widgets/slivers.dart';
import 'package:dailyanimelist/widgets/user/signinpage.dart';
import 'package:dailyanimelist/widgets/user/stats_screen.dart';
import 'package:dailyanimelist/widgets/user/user_header.dart';
import 'package:dailyanimelist/widgets/user/weeklyanime.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:flutter/material.dart';

final profileHeaders = [
  UserProfileType(S.current.Profile, Icons.stacked_bar_chart,
      (name, isSelf) => UserStatsScreen(username: name, isSelf: isSelf)),
  UserProfileType(S.current.Friends, Icons.people_alt,
      (name, _) => UserHeader().friendsWidget(name)),
  UserProfileType(S.current.Clubs, Icons.castle,
      (name, _) => UserHeader().clubsWidget(name)),
  UserProfileType(
      S.current.About, Icons.info, (name, _) => UserHeader().aboutWidget(name)),
  UserProfileType(S.current.Favorites, Icons.favorite,
      (name, _) => UserHeader().favoritesWidget(name)),
  UserProfileType(S.current.History, Icons.history,
      (name, _) => UserHistoryWidget(username: name)),
  UserProfileType(
      S.current.WeeklyAnime, Icons.weekend, (name, _) => WeeklyAnimeWidget()),
];

PreferredSize profileHeaderWidget({
  required PageController pageController,
  required StreamListener<int> pageListner,
  required List<UserProfileType> profileHeaders,
}) {
  return PreferredSize(
    preferredSize: Size(double.infinity, 50.0),
    child: SizedBox(
      height: 50.0,
      child: StreamBuilder<int?>(
          stream: pageListner.stream,
          builder: (context, snapshot) {
            final currentPage = snapshot.data ?? 0;
            return Container(
              height: 35,
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                scrollDirection: Axis.horizontal,
                itemCount: profileHeaders.length,
                itemBuilder: (_, i) => HeaderButton(
                  active: currentPage == i,
                  iconData: profileHeaders[i].icon,
                  title: profileHeaders[i].title,
                  onTap: () {
                    pageController.animateToPage(
                      i,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeIn,
                    );
                  },
                ),
              ),
            );
          }),
    ),
  );
}

class UserProfileType {
  final String title;
  final Widget Function(String username, bool isSelf) widget;
  final IconData icon;
  final bool isSelf;
  UserProfileType(
    this.title,
    this.icon,
    this.widget, {
    this.isSelf = true,
  });
}

class UserProfilePage extends StatefulWidget {
  final bool isSelf;
  final String? username;
  const UserProfilePage({super.key, required this.isSelf, this.username});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late PageController _pageController;
  late StreamListener<int> _pageListner;
  String category = 'anime';
  List<UserProfileType> get _profileHeaders => widget.isSelf
      ? profileHeaders
      : [
          _userPageType(),
          ...profileHeaders,
        ];
  ScrollController _controller = ScrollController();
  late Future<UserProf?> _userProfFuture;
  StreamListener<bool> _expandUserProfile = StreamListener(false);

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _pageListner = StreamListener(0);
    _userProfFuture = _getUserProfileFuture();
  }

  @override
  void dispose() {
    super.dispose();
    _pageListner.dispose();
    _pageController.dispose();
    _controller.dispose();
    user.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (user.status == AuthStatus.UNAUTHENTICATED) {
      return Scaffold(
        body: SigninWidget(),
        appBar: PreferredSize(
            preferredSize: Size(double.infinity, kToolbarHeight),
            child: Padding(
              padding: const EdgeInsets.only(top: 35.0),
              child: AppBarHome(),
            )),
      );
    }
    return WillPopScope(
      onWillPop: () async {
        if (_expandUserProfile.currentValue!) {
          _expandUserProfile.update(false);
          return false;
        }
        return true;
      },
      child: StateFullFutureWidget<UserProf?>(
        done: (snapshot) {
          final userProf = snapshot.data;
          String? username = userProf?.name;
          return conditional(
            on: !widget.isSelf,
            parent: (child) => _otherUserPage(child, userProf),
            child: Stack(
              children: [
                NestedScrollView(
                  controller: _controller,
                  headerSliverBuilder: (_, __) => [
                    if (widget.isSelf)
                      _buildAppBar()
                    else
                      SliverWrapper(_headerWidget()),
                  ],
                  body: username == null ? loadingBelowText() : _body(username),
                ),
                if (userProf != null && !widget.isSelf)
                  StreamBuilder<bool>(
                      stream: _expandUserProfile.stream,
                      initialData: _expandUserProfile.initialData,
                      builder: (context, snapshot) {
                        var boolV = snapshot.data ?? false;
                        return ExpandedSection(
                          expand: boolV,
                          child: _expandedProfileWidget(userProf),
                        );
                      }),
              ],
            ),
          );
        },
        loadingChild: widget.isSelf
            ? loadingBelowText()
            : TitlebarScreen(loadingBelowText(), appbarTitle: widget.username),
        future: () => _userProfFuture,
      ),
    );
  }

  void _reportUser(UserProf prof) {
    reportWithConfirmation(
        type: ReportType.profile,
        context: context,
        content: Row(children: [
          AvatarWidget(
            url: prof.picture,
            height: 40,
            width: 40,
          ),
          SB.w10,
          title(prof.name)
        ]),
        queryParams: {'id': prof.id});
  }

  Widget _otherUserPage(Widget child, UserProf? prof) {
    final id = prof?.id;
    final _userActions = {
      // if (id != null)
      //   S.current.Add_Friend: () {
      //     launchURLWithConfirmation(
      //         '${CredMal.htmlEnd}myfriends.php?go=add&id=$id',
      //         context: context);
      //   },
      if (id != null) S.current.Report_User: () => _reportUser(prof!),
    };
    final _userIconMap = {
      S.current.Add_Friend: Icons.person_add_alt_1,
      S.current.Report_User: Icons.report
    };
    final picture = prof?.picture;

    return TitlebarScreen(
      child,
      autoIncludeSearch: false,
      appbarTitle: widget.username,
      floatingActionButton: _floatingActionBtn(prof),
      actions: [
        SB.w20,
        if (id != null)
          StreamBuilder<bool>(
              stream: _expandUserProfile.stream,
              initialData: _expandUserProfile.initialData,
              builder: (context, snapshot) {
                var boolV = snapshot.data ?? false;
                if (boolV) {
                  return SizedBox(
                    width: 35,
                    child: IconButton(
                      onPressed: () {
                        _expandUserProfile.update(false);
                      },
                      icon: Icon(Icons.close),
                    ),
                  );
                }
                return _avatar(picture);
              }),
        SB.w20,
      ],
    );
  }

  Widget _avatar(
    String? picture, {
    double height = 35,
  }) {
    var borderRadius = BorderRadius.circular(100.0);
    return SizedBox(
      height: height,
      width: height,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: CircleAvatar(
          radius: 32.0,
          child: InkWell(
            onTap: _onAvatarTap,
            onLongPress: () {
              if (picture != null) zoomInImage(context, picture);
            },
            borderRadius: borderRadius,
            child: picture == null
                ? Icon(Icons.person)
                : CachedNetworkImage(
                    imageUrl: picture,
                    fit: BoxFit.cover,
                  ),
          ),
        ),
      ),
    );
  }

  _onAvatarTap() {
    _expandUserProfile.update(!_expandUserProfile.currentValue!);
  }

  Widget _floatingActionBtn(UserProf? prof) {
    return BookMarkFloatingButton(
      type: BookmarkType.malUser,
      id: widget.username,
      data: UserProf(
        name: widget.username,
        picture: prof?.picture,
      ),
    );
  }

  Future<UserProf?> _getUserProfileFuture() async {
    if (widget.isSelf) {
      return UserProfService.i.userProf;
    } else {
      return MalUser.getUserInfo(username: widget.username!, fromCache: true);
    }
  }

  SliverLayoutBuilder _buildAppBar() {
    return SliverLayoutBuilder(
      builder: (p0, c) => SliverAppBar(
        automaticallyImplyLeading: false,
        pinned: true,
        floating: true,
        expandedHeight: 110,
        actions: [SB.z],
        title: Padding(
          padding: const EdgeInsets.only(bottom: 5.0),
          child: AppBarHome(
            onUiChange: () {
              if (mounted) setState(() {});
            },
          ),
        ),
        titleSpacing: 0.0,
        bottom: _headerWidget(),
        toolbarHeight: kToolbarHeight,
      ),
    );
  }

  PreferredSize _headerWidget() {
    return profileHeaderWidget(
      pageController: _pageController,
      pageListner: _pageListner,
      profileHeaders: _profileHeaders,
    );
  }

  UserProfileType _userPageType() {
    return UserProfileType(
      S.current.List,
      Icons.list,
      (username, isSelf) => UserPage(
        username: username,
        initalPageIndex: 1,
        isSelf: isSelf,
        category: category,
        controller: _controller,
      ),
    );
  }

  Widget _expandedProfileWidget(UserProf prof) {
    return SizedBox(
      height: 265.0,
      width: double.infinity,
      child: Material(
        elevation: 12.0,
        shape: RoundedRectangleBorder(
          // side: BorderSide(color: Colors.grey[300]!),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20.0),
            bottomRight: Radius.circular(20.0),
          ),
        ),
        child: Stack(
          children: [
            if (prof.id != null) _profileBackground(prof),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 40),
                _avatar(
                  prof.picture,
                  height: 120,
                ),
                SB.h30,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ShadowButton(
                        onPressed: () => launchURLWithConfirmation(
                          '${CredMal.htmlEnd}profile/${prof.name}',
                          context: context,
                        ),
                        child: iconAndText(
                          Icons.open_in_browser,
                          S.current.Open_In_Browser,
                        ),
                      ),
                      ShadowButton(
                        onPressed: () => _reportUser(prof),
                        child: iconAndText(
                          Icons.report,
                          S.current.Report_User,
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(width: double.infinity),
                SB.h20,
              ],
            ),
          ],
        ),
      ),
    );
  }

  StateFullFutureWidget<String?> _profileBackground(UserProf prof) {
    return StateFullFutureWidget<String?>(
      future: () => UserProfService.getProfileBGDownloadUrl(prof.id!),
      loadingChild: SB.z,
      done: (snapshot) {
        final url = snapshot.data;
        if (url == null) return SB.z;
        return SizedBox(
          height: 140,
          width: double.infinity,
          child: InkWell(
            onTap: () => zoomInImage(context, url),
            child: Ink(
                decoration: BoxDecoration(
              image: DecorationImage(
                image: CachedNetworkImageProvider(url),
                fit: BoxFit.cover,
              ),
            )),
          ),
        );
      },
    );
  }

  Widget _body(String username) {
    return PageView.builder(
      onPageChanged: (value) => _pageListner.update(value),
      controller: _pageController,
      itemCount: _profileHeaders.length,
      itemBuilder: (context, index) =>
          _profileHeaders[index].widget(username, widget.isSelf),
    );
  }
}
