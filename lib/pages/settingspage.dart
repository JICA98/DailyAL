import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dailyanimelist/api/auth/auth.dart';
import 'package:dailyanimelist/api/dalapi.dart';
import 'package:dailyanimelist/api/maluser.dart';
import 'package:dailyanimelist/cache/cachemanager.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/pages/settings/anime_manga_settings.dart';
import 'package:dailyanimelist/pages/settings/backup_restore.dart';
import 'package:dailyanimelist/pages/settings/cachesettings.dart';
import 'package:dailyanimelist/pages/settings/customsettings.dart';
import 'package:dailyanimelist/pages/settings/homepagesettings.dart';
import 'package:dailyanimelist/pages/settings/langsettings.dart';
import 'package:dailyanimelist/pages/settings/notifsettings.dart';
import 'package:dailyanimelist/pages/settings/optiontile.dart';
import 'package:dailyanimelist/pages/settings/themesettings.dart';
import 'package:dailyanimelist/pages/settings/userprefsetting.dart';
import 'package:dailyanimelist/screens/homescreen.dart';
import 'package:dailyanimelist/screens/plainscreen.dart';
import 'package:dailyanimelist/user/user.dart';
import 'package:dailyanimelist/util/streamutils.dart';
import 'package:dailyanimelist/widgets/customfuture.dart';
import 'package:dailyanimelist/widgets/fadingeffect.dart';
import 'package:dailyanimelist/widgets/home/accordion.dart';
import 'package:dailyanimelist/widgets/home/bookmarks_widget.dart';
import 'package:dailyanimelist/widgets/home/notifications.dart';
import 'package:dailyanimelist/widgets/shimmecolor.dart';
import 'package:dailyanimelist/widgets/slivers.dart';
import 'package:dailyanimelist/widgets/user/stats_screen.dart';
import 'package:dailyanimelist/widgets/user/user_header.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

import '../constant.dart';
import '../main.dart';
import '../widgets/custombutton.dart';

class UserProfService {
  late Future<UserProf?> userProf;
  UserProfService._() {
    userProf = getUserProfile();
    user.addListener(() {
      if (user.status == AuthStatus.AUTHENTICATED) {
        userProf = getUserProfile();
      }
    });
  }

  Future<UserProf?> getUserProfile() async {
    try {
      return MalUser.getUserInfo(
          fields: ["anime_statistics", "manga_statistics"], fromCache: true);
    } catch (e) {
      logDal(e);
      return Future.value(null);
    }
  }

  static Future<String?> getProfileBGDownloadUrl(int id) async {
    String? url = null;
    final path = getProfileBGPath(id);
    try {
      final expiresIn = 3600 * 24 * 30;
      final cachedUrl = await CacheManager.instance
          .getValueForServiceAutoExpire(
              SettingsPage.serviceName, path, expiresIn);
      if (cachedUrl != null) return cachedUrl;
      supa.SupabaseClient client = supa.Supabase.instance.client;

      url = await client.storage
          .from('user-bgs')
          .createSignedUrl(path, expiresIn);
    } catch (e) {
      logDal(e);
    }
    await setCacheUrl(path, url);
    return url;
  }

  static String getProfileBGPath(int id) => 'public/$id.image';

  static Future<void> setCacheUrl(String path, String? url) async {
    await CacheManager.instance
        .setValueForServiceAutoExpireIn(SettingsPage.serviceName, path, url);
  }

  static UserProfService i = UserProfService._();
  factory UserProfService() => i;
}

class _UserAction {
  final String title;
  final Widget Function(String) widget;
  final IconData icon;
  final bool useAppbar;
  _UserAction(
    this.title,
    this.icon,
    this.widget, {
    this.useAppbar = true,
  });
}

class SettingsPage extends StatefulWidget {
  final Function(int)? onIndexChange;
  final VoidCallback? onUiChange;
  static const serviceName = 'SettingsPage';
  const SettingsPage({
    Key? key,
    this.onIndexChange,
    this.onUiChange,
  }) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with TickerProviderStateMixin {
  double maxHeight = 300.0;
  bool hasExpanded = false;
  bool expandComplete = false;
  final _userActions = [
    _UserAction(S.current.Stats, Icons.stacked_bar_chart,
        (name) => UserStatsScreen(username: name)),
    _UserAction(
        S.current.About, Icons.info, (name) => UserHeader().aboutWidget(name)),
    _UserAction(S.current.Friends, Icons.people_alt,
        (name) => UserHeader().friendsWidget(name)),
    _UserAction(S.current.Clubs, Icons.castle,
        (name) => UserHeader().clubsWidget(name)),
    _UserAction(S.current.Favorites, Icons.favorite,
        (name) => UserHeader().favoritesWidget(name)),
    _UserAction(S.current.History, Icons.history,
        (name) => UserHistoryWidget(username: name)),
    _UserAction(S.current.Notfications, Icons.notifications,
        (name) => NotificationScheduleWidget(),
        useAppbar: false),
    _UserAction(
        S.current.Bookmarks, Icons.bookmark, (name) => BookMarksWidget(),
        useAppbar: false),
  ];
  StreamListener<bool> _imageListener = StreamListener(false);
  late String _bgImageRefKey;

  @override
  void initState() {
    super.initState();
    _bgImageRefKey = MalAuth.codeChallenge(10);
  }

  Future<String?> _getProfileImageUrlFuture(int? id) async {
    if (id == null) {
      return Future.value(null);
    } else {
      return UserProfService.getProfileBGDownloadUrl(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProf?>(
        future: UserProfService().userProf,
        builder: (_, snapshot) {
          final userProf = snapshot.data;
          final header =
              _buildHeader(userProf, context).map((e) => SliverWrapper(e));
          return SizedBox(
            height: MediaQuery.of(context).size.height / 1.35,
            child: CustomScrollView(slivers: [
              if (userProf != null) ...header else ..._buildHeaderShimmer(),
              if (user.status == AuthStatus.AUTHENTICATED)
                SliverWrapper(_userActionsWidget(userProf)),
              _accordionWrapper(S.current.Settings, settingOptions),
              SliverListWrapper(_bottom),
              SB.lh40,
            ]),
          );
        });
  }

  Widget _userActionsWidget(UserProf? userProf) {
    if (userProf == null) {
      return ShimmerColor(Padding(
        padding: const EdgeInsets.all(12.0),
        child: SizedBox(
          height: 180.0,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(),
          ),
        ),
      ));
    }
    return Accordion(
      isOpen: true,
      atStartExpanded: true,
      titlePadding: EdgeInsets.all(12.0),
      title: S.current.My_Profile,
      child: Wrap(
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: _userActions
            .map((e) => PlainButton(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  onPressed: () {
                    if (userProf.name != null) {
                      gotoPage(
                        context: context,
                        newPage: TitlebarScreen(
                          e.widget(userProf!.name!),
                          appbarTitle: e.title,
                          useAppbar: e.useAppbar,
                        ),
                      );
                    }
                  },
                  child: iconAndText(e.icon, e.title,
                      mainAxisSize: MainAxisSize.min),
                ))
            .toList(),
      ),
    );
  }

  Widget _accordionWrapper(String title, List<Widget> children) {
    return SliverWrapper(
      Accordion(
        isOpen: true,
        atStartExpanded: true,
        titlePadding: EdgeInsets.all(12.0),
        title: title,
        child: Column(
          children: children,
        ),
      ),
    );
  }

  List<Widget> _buildHeader(UserProf? userProf, BuildContext context) {
    return [
      StateFullFutureWidget<String?>(
        refKey: _bgImageRefKey,
        future: () => _getProfileImageUrlFuture(userProf?.id),
        loadingChild: _buildHeaderWithImage(userProf, null),
        done: (snapshot) => _buildHeaderWithImage(userProf, snapshot.data),
      )
    ];
  }

  Widget _buildHeaderWithImage(UserProf? userProf, String? imageData) {
    return Stack(
      children: [
        if (imageData != null)
          SizedBox(
            height: 180.0,
            width: double.infinity,
            child: CachedNetworkImage(
              imageUrl: imageData,
              fit: BoxFit.cover,
              placeholder: (context, url) => loadingCenterColored,
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          ),
        if (imageData != null)
          SizedBox(
            height: 180.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _blackBGforText(0),
              ],
            ),
          ),
        SizedBox(
          height: 190.0,
          child: Builder(builder: (context) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 5.0),
                  child: _userAvatar(userProf, imageData),
                ),
                SB.h10,
                if (imageData == null) ...[
                  Divider(
                    thickness: 1.0,
                    color: Theme.of(context).cardColor,
                  ),
                ] else
                  SB.h10,
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _blackBGforText(double borderRadius) {
    return SizedBox(
      height: 120,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: CustomPaint(
            foregroundPainter: FadingEffect(
              color: Colors.black,
              start: 5,
              end: 255,
            ),
            child: SB.z),
      ),
    );
  }

  List<Widget> _buildHeaderShimmer() {
    return [
      SB.h120,
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: ShimmerColor(Row(
            children: [
              Container(
                height: 35,
                width: 35,
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: Colors.white),
              ),
              SB.w20,
              Text(S.current.Loading_Profile),
            ],
          ))),
      SB.h10,
      Divider(
        thickness: 1.0,
        color: Theme.of(context).cardColor,
      ),
    ].map((e) => SliverWrapper(e)).toList();
  }

  Widget _userAvatar(UserProf? userProf, String? data) {
    return Row(
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(userProf?.picture ?? ""),
        ),
        SB.w20,
        Text(userProf?.name ?? S.current.User_not_Logged_in),
        Spacer(),
        _profileBgEditWidget(data),
      ],
    );
  }

  Widget _profileBgEditWidget(String? data) {
    if (user.status != AuthStatus.AUTHENTICATED) return SB.z;
    return StreamBuilder<bool>(
        initialData: _imageListener.initialData,
        stream: _imageListener.stream,
        builder: (context, sp) {
          final ongoingOperation = sp.data ?? false;
          if (ongoingOperation)
            return SizedBox(
              height: 35,
              width: 35,
              child: ShadowButton(
                onPressed: () {},
                child: loadingCenterColored,
                padding: EdgeInsets.zero,
              ),
            );
          return SizedBox(
            height: 35,
            width: 35,
            child: IconButton.filledTonal(
              iconSize: 16.0,
              icon: Icon(data == null ? Icons.edit : Icons.close),
              onPressed: () {
                _imageListener.update(true);
                if (data == null)
                  _onSetBG();
                else {
                  _removeBG();
                }
              },
            ),
          );
        });
  }

  void _removeBG() async {
    if (!(await showConfirmationDialog(
        context: context, alertTitle: S.current.Remove_the_Bg))) {
      _imageListener.update(false);
      return;
    }
    if (await _onRemoveBg()) {
      _bgImageRefKey = MalAuth.codeChallenge(10);
      showToast(S.current.Profile_bg_removed);
    } else {
      showToast(S.current.Error_removing_image);
    }
    if (mounted) setState(() {});
    _imageListener.update(false);
  }

  void _onSetBG() {
    setNewBg(
      (path) async {
        if (await _uploadFile(path)) {
          _bgImageRefKey = MalAuth.codeChallenge(10);
          showToast(S.current.Profile_bg_set);
        } else {
          showToast(S.current.Error_uploading_image);
        }
        if (mounted) setState(() {});
        _imageListener.update(false);
      },
      limitInBytes: 1024 * 1024 * 1.5,
      onError: () => _imageListener.update(false),
    );
  }

  Future<bool> _onRemoveBg() async {
    try {
      final userProf = await UserProfService.i.userProf;
      if (userProf == null) return false;
      final id = userProf.id;
      if (id == null) return false;
      supa.SupabaseClient client = supa.Supabase.instance.client;
      await client.storage.from('user-bgs').remove(['public/$id.image']);
      await UserProfService.setCacheUrl(
          UserProfService.getProfileBGPath(id), null);
      return true;
    } catch (e) {
      logDal(e);
    }

    return false;
  }

  Future<bool> _uploadFile(String path) async {
    try {
      final userProf = await UserProfService.i.userProf;
      if (userProf == null) return false;
      final id = userProf.id;
      final name = userProf.name;
      if (id == null || name == null) return false;
      final bgFile = File(path);
      var uri = Uri.file(path);
      final map = {'jpeg': 'jpg', 'jpg': 'jpg', 'png': 'png', 'gif': 'gif'};
      final extension =
          map[uri.pathSegments.last.split(".").last.toLowerCase()];
      if (extension == null) {
        showToast(S.current.Invalid_extension);
        return false;
      }
      supa.SupabaseClient client = supa.Supabase.instance.client;
      await client.storage.from('user-bgs').upload('public/$id.image', bgFile,
          fileOptions: supa.FileOptions(contentType: 'image/$extension'));
      return true;
    } catch (e) {
      logDal(e);
    }

    return false;
  }

  List<Widget> get userOptions {
    return [];
  }

  List<Widget> get settingOptions {
    return [
      OptionTile(
          text: S.current.Theme_Settings,
          iconData: Icons.color_lens,
          // desc: S.current.Theme_setting_desc_v2,
          smallTiles: true,
          onPressed: () {
            gotoPage(context: context, newPage: ThemeSettings());
          }),
      if (kDebugMode)
        OptionTile(
            text: "Cache Settings",
            iconData: Icons.cached,
            smallTiles: true,
            // desc: "Customize your cache settings.",
            onPressed: () {
              gotoPage(context: context, newPage: CacheSettingsPage());
            }),
      OptionTile(
          text: S.current.Notification_Settings,
          iconData: Icons.notifications,
          // desc: S.current.Notification_setting_desc,
          smallTiles: true,
          onPressed: () {
            gotoPage(context: context, newPage: NotificationSettingsPage());
          }),
      OptionTile(
          text: S.current.Home_Page_Setting,
          iconData: Icons.home_work,
          smallTiles: true,
          // desc: S.current.HomePageSettings_desc,
          onPressed: () {
            gotoPage(
                context: context,
                newPage: HomePageSettings(
                  onUiChange: () {
                    if (widget.onUiChange != null) widget.onUiChange!();
                  },
                ));
          }),
      OptionTile(
          text: S.current.Anime_Manga_settings,
          iconData: LineIcons.cryingFace,
          // desc: S.current.Anime_Manga_settings_desc,
          smallTiles: true,
          onPressed: () {
            gotoPage(context: context, newPage: AnimeMangaSettings());
          }),
      OptionTile(
          text: S.current.Backup_And_Restore,
          iconData: Icons.settings_backup_restore,
          // desc: S.current.Backup_And_Restore_desc,
          smallTiles: true,
          onPressed: () {
            gotoPage(context: context, newPage: BackUpAndRestorePage());
          }),
      OptionTile(
          text: S.current.User_Preferences,
          iconData: Icons.room_preferences,
          smallTiles: true,
          // desc: S.current.User_Preferences_desc,
          onPressed: () {
            gotoPage(
                context: context,
                newPage: SettingSliverScreen(
                  titleString: S.current.User_Preferences,
                  child: UserPrefSettings(
                    onUiChange: () {
                      if (widget.onUiChange != null) widget.onUiChange!();
                    },
                  ),
                ));
          }),
      OptionTile(
          text: S.current.Language_settings,
          smallTiles: true,
          iconData: Icons.language,
          // desc: S.current.Language_settings_desc_v2,
          onPressed: () {
            gotoPage(
              context: context,
              newPage: LanguageSettings(
                update: () {
                  if (mounted) setState(() {});
                },
              ),
            );
          }),
    ];
  }

  List<Widget> get _bottom => [
        OptionTile(
          text: S.current.Rate_Review,
          iconData: Icons.rate_review,
          smallTiles: true,
          // desc: S.current.Rate_Review_desc,
          onPressed: () => launchURL(
              "https://play.google.com/store/apps/details?id=com.teen.dailyanimelist"),
        ),
        CFutureBuilder<Servers?>(
          future: DalApi.i.dalConfigFuture,
          done: (snapshot) {
            if (hasText(snapshot.data?.discordLink))
              return OptionTile(
                text: S.current.DiscordInvite,
                smallTiles: true,
                // desc: S.current.DiscordInviteDesc,
                iconData: Icons.discord,
                onPressed: () => launchURL(snapshot.data!.discordLink!),
              );
            else
              return SB.z;
          },
          loadingChild: SB.z,
        ),
        CFutureBuilder<Servers?>(
          future: DalApi.i.dalConfigFuture,
          done: (snapshot) {
            if (snapshot.data?.bmacLink ?? false)
              return OptionTile(
                smallTiles: true,
                text: S.current.Buy_Me_A_Copy,
                // desc: S.current.Buy_Me_A_Copy_Desc,
                iconData: Icons.coffee,
                onPressed: () =>
                    launchURL("https://www.buymeacoffee.com/dailyanimelist"),
              );
            else
              return SB.z;
          },
          loadingChild: SB.z,
        ),
        OptionTile(
            text: S.current.Logout,
            authOnly: true,
            smallTiles: true,
            iconData: Icons.logout,
            onPressed: () {
              launchLogOutConfirmation(context: context);
            }),
        SB.h20,
        PlainButton(
          onPressed: () => launchURLWithConfirmation('https://flutter.dev/',
              context: context),
          child: title('${S.current.Made_With_Flutter} Flutter'),
        ),
      ];

  Widget _terms() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        BorderButton(
          child: title("Terms and Conditions"),
          borderSide: BorderSide.none,
          onPressed: () {},
        ),
        BorderButton(
          child: title("Privacy Policy"),
          borderSide: BorderSide.none,
          onPressed: () {},
        )
      ],
    );
  }

  Widget avatarWidget() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Material(
        color: Colors.transparent,
        child: AnimatedContainer(
          duration: Duration(seconds: 300),
          padding: EdgeInsets.only(top: hasExpanded ? 60 : 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  user.status == AuthStatus.AUTHENTICATED
                      ? BorderButton(
                          child: iconAndText(
                            Icons.logout,
                            S.current.Logout,
                          ),
                          onPressed: () {
                            launchLogOutConfirmation(context: context);
                          })
                      : BorderButton(
                          child: iconAndText(
                            Icons.login,
                            S.current.Log_In,
                          ),
                          onPressed: () {
                            gotoPage(
                                context: context,
                                newPage: HomeScreen(
                                  pageIndex: 2,
                                ));
                          }),
                  BorderButton(
                      child: iconAndText(
                        Icons.settings,
                        S.current.Settings,
                      ),
                      onPressed: () {
                        if (mounted)
                          setState(() {
                            maxHeight = MediaQuery.of(context).size.height;
                            hasExpanded = true;
                          });
                      })
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
