import 'package:dailyanimelist/api/dalapi.dart';
import 'package:dailyanimelist/cache/cachemanager.dart';
import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/icons/dub_icons.dart';
import 'package:dailyanimelist/pages/settings/about.dart';
import 'package:dailyanimelist/pages/settings/anime_manga_settings.dart';
import 'package:dailyanimelist/pages/settings/backup_restore.dart';
import 'package:dailyanimelist/pages/settings/cachesettings.dart';
import 'package:dailyanimelist/pages/settings/customsettings.dart';
import 'package:dailyanimelist/pages/settings/dubsettings.dart';
import 'package:dailyanimelist/pages/settings/homepagesettings.dart';
import 'package:dailyanimelist/pages/settings/langsettings.dart';
import 'package:dailyanimelist/pages/settings/list_pref_settings.dart';
import 'package:dailyanimelist/pages/settings/notifsettings.dart';
import 'package:dailyanimelist/pages/settings/optiontile.dart';
import 'package:dailyanimelist/pages/settings/themesettings.dart';
import 'package:dailyanimelist/pages/settings/userprefsetting.dart';
import 'package:dailyanimelist/widgets/common/adaptive_layout.dart';
import 'package:dailyanimelist/widgets/custombutton.dart';
import 'package:dailyanimelist/widgets/customfuture.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:dailyanimelist/main.dart';
import 'dart:io';
import 'package:dailyanimelist/user/user.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

class SettingsPage extends StatefulWidget {
  final VoidCallback? onUiChange;
  const SettingsPage({
    super.key,
    this.onUiChange,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

// Settings item model for tablet layout
class _SettingsItem {
  final String text;
  final String? desc;
  final IconData iconData;
  final Widget Function(BuildContext, VoidCallback?) contentBuilder;
  final bool authOnly;
  final Color? color;

  const _SettingsItem({
    required this.text,
    this.desc,
    required this.iconData,
    required this.contentBuilder,
    this.authOnly = false,
    this.color,
  });
}

class _SettingsPageState extends State<SettingsPage> {
  // Default to Theme Settings (index 1, after Logout)
  int _selectedIndex = 1;
  double _leftPanelWidth = 350.0;
  static const double _minLeftPanelWidth = 280.0;
  static const double _maxLeftPanelWidth = 500.0;

  // Build list of settings items
  List<_SettingsItem> _getSettingsItems() {
    return [
      _SettingsItem(
        text: S.current.Logout,
        desc: S.current.Logout_desc,
        iconData: Icons.logout,
        authOnly: true,
        contentBuilder: (context, onUiChange) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout,
                  size: 64, color: Theme.of(context).colorScheme.primary),
              SB.h20,
              Text(S.current.Logout,
                  style: Theme.of(context).textTheme.headlineSmall),
              SB.h10,
              Text(S.current.Logout_desc),
              SB.h30,
              FilledButton(
                onPressed: () => launchLogOutConfirmation(context: context),
                child: Text(S.current.Logout),
              ),
            ],
          ),
        ),
      ),
      _SettingsItem(
        text: S.current.Theme_Settings,
        desc: S.current.Theme_setting_desc_v2,
        iconData: Icons.color_lens,
        contentBuilder: (context, onUiChange) => ThemeSettings(),
      ),
      if (kDebugMode)
        _SettingsItem(
          text: "Cache Settings",
          desc: "Customize your cache settings.",
          iconData: Icons.cached,
          contentBuilder: (context, onUiChange) => CacheSettingsPage(),
        ),
      _SettingsItem(
        text: S.current.Notification_Settings,
        desc: S.current.Notification_setting_desc,
        iconData: Icons.notifications,
        contentBuilder: (context, onUiChange) => NotificationSettingsPage(),
      ),
      _SettingsItem(
        text: S.current.User_Preferences,
        desc: S.current.User_Preferences_desc,
        iconData: Icons.room_preferences,
        contentBuilder: (context, onUiChange) => SettingSliverScreen(
          titleString: S.current.User_Preferences,
          child: UserPrefSettings(onUiChange: onUiChange),
        ),
      ),
      _SettingsItem(
        text: S.current.List_preferences,
        desc: S.current.List_preferences_desc,
        iconData: Icons.list_alt,
        contentBuilder: (context, onUiChange) => ListPreferenceSettings(),
      ),
      _SettingsItem(
        text: S.current.Home_Page_Setting,
        desc: S.current.HomePageSettings_desc,
        iconData: Icons.home_work,
        contentBuilder: (context, onUiChange) =>
            HomePageSettings(onUiChange: onUiChange),
      ),
      _SettingsItem(
        text: S.current.Anime_Manga_settings,
        desc: S.current.Anime_Manga_settings_desc,
        iconData: LineIcons.cryingFace,
        contentBuilder: (context, onUiChange) => AnimeMangaSettings(),
      ),
      _SettingsItem(
        text: S.current.Dub_Settings,
        desc: S.current.Dub_Settings_Desc,
        iconData: DubIcons.preferredDubIcon,
        contentBuilder: (context, onUiChange) => DubSettingsPage(),
      ),
      _SettingsItem(
        text: S.current.Backup_And_Restore,
        desc: S.current.Backup_And_Restore_desc,
        iconData: Icons.settings_backup_restore,
        contentBuilder: (context, onUiChange) => BackUpAndRestorePage(),
      ),
      _SettingsItem(
        text: S.current.About,
        desc: S.current.About_desc,
        iconData: Icons.info,
        contentBuilder: (context, onUiChange) => AboutPage(),
      ),
      _SettingsItem(
        text: S.current.Language_settings,
        desc: S.current.Language_settings_desc_v2,
        iconData: Icons.language,
        contentBuilder: (context, onUiChange) => LanguageSettings(
          update: () {
            if (mounted) setState(() {});
          },
        ),
      ),
      if (Platform.isLinux || Platform.isWindows || Platform.isMacOS)
        _SettingsItem(
          text: "Clear App Storage",
          desc: "Clear all app data and settings.",
          iconData: Icons.delete_forever,
          color: Colors.red,
          contentBuilder: (context, onUiChange) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.delete_forever, size: 64, color: Colors.red),
                SB.h20,
                Text("Clear App Storage",
                    style: Theme.of(context).textTheme.headlineSmall),
                SB.h10,
                Text("Clear all app data and settings."),
                SB.h30,
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () => _clearAppStorage(context),
                  child: Text("Clear Storage"),
                ),
              ],
            ),
          ),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayout(
      compactBuilder: (context) => _buildCompactLayout(),
      expandedBuilder: (context) => _buildTabletLayout(),
    );
  }

  // Compact layout - single column, navigate to new pages
  Widget _buildCompactLayout() {
    return SettingSliverScreen(
      titleString: S.current.Settings,
      child: SliverList.list(
        children: _buildCompactSettingOptions(context),
      ),
    );
  }

  // Tablet layout - dual pane with left menu and right content
  Widget _buildTabletLayout() {
    final items = _getSettingsItems();
    // Filter out auth-only items if not authenticated
    final visibleItems = items.where((item) {
      if (item.authOnly && user.status != AuthStatus.AUTHENTICATED) {
        return false;
      }
      return true;
    }).toList();

    // Ensure selected index is valid
    final safeIndex = _selectedIndex.clamp(0, visibleItems.length - 1);

    return Scaffold(
      body: Row(
        children: [
          // Left panel - Settings menu
          SizedBox(
            width: _leftPanelWidth,
            child: Material(
              elevation: 0,
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    floating: false,
                    automaticallyImplyLeading: true,
                    title: Text(S.current.Settings),
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  SB.lh20,
                  SliverList.builder(
                    itemCount: visibleItems.length,
                    itemBuilder: (context, index) {
                      final item = visibleItems[index];
                      final isSelected = index == safeIndex;
                      return _buildMenuTile(item, index, isSelected);
                    },
                  ),
                  SliverToBoxAdapter(
                    child: CFutureBuilder<Servers?>(
                      future: DalApi.i.dalConfigFuture,
                      done: (snapshot) {
                        if (snapshot.data?.bmacLink ?? false) {
                          return _buildMenuTile(
                            _SettingsItem(
                              text: S.current.Buy_Me_A_Copy,
                              desc: S.current.Buy_Me_A_Copy_Desc,
                              iconData: Icons.coffee,
                              contentBuilder: (context, onUiChange) => Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.coffee,
                                        size: 64,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                                    SB.h20,
                                    Text(S.current.Buy_Me_A_Copy,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall),
                                    SB.h10,
                                    Text(S.current.Buy_Me_A_Copy_Desc),
                                    SB.h30,
                                    FilledButton(
                                      onPressed: () => launchURL(
                                          "https://ko-fi.com/abhaybyte"),
                                      child: Text(S.current.Buy_Me_A_Copy),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            -1,
                            false,
                          );
                        }
                        return SB.z;
                      },
                      loadingChild: SB.z,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: PlainButton(
                        onPressed: () => launchURLWithConfirmation(
                          'https://flutter.dev/',
                          context: context,
                        ),
                        child: title('${S.current.Made_With_Flutter} Flutter'),
                      ),
                    ),
                  ),
                  SB.lh80,
                ],
              ),
            ),
          ),
          // Resizable divider
          MouseRegion(
            cursor: SystemMouseCursors.resizeColumn,
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                setState(() {
                  final newWidth = _leftPanelWidth + details.delta.dx;
                  _leftPanelWidth = newWidth.clamp(
                    _minLeftPanelWidth,
                    _maxLeftPanelWidth,
                  );
                });
              },
              child: Container(
                width: 8,
                color: Theme.of(context).dividerColor.withOpacity(0.1),
                child: Center(
                  child: Container(
                    width: 2,
                    height: 40,
                    color: Theme.of(context).dividerColor.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
          // Right panel - Selected settings content
          Expanded(
            child: visibleItems[safeIndex].contentBuilder(
              context,
              widget.onUiChange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(_SettingsItem item, int index, bool isSelected) {
    return Material(
      color: isSelected
          ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
          : Colors.transparent,
      child: ListTile(
        leading: Icon(
          item.iconData,
          color: item.color ??
              (isSelected ? Theme.of(context).colorScheme.primary : null),
        ),
        title: Text(
          item.text,
          style: TextStyle(
            color: item.color,
            fontWeight: isSelected ? FontWeight.w600 : null,
          ),
        ),
        subtitle: item.desc != null
            ? Text(
                item.desc!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12),
              )
            : null,
        selected: isSelected,
        onTap: () {
          if (index >= 0) {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
      ),
    );
  }

  // Compact layout settings options (navigate to new pages)
  List<Widget> _buildCompactSettingOptions(BuildContext context) {
    return [
      OptionTile(
          text: S.current.Logout,
          desc: S.current.Logout_desc,
          authOnly: true,
          iconData: Icons.logout,
          onPressed: () {
            launchLogOutConfirmation(context: context);
          }),
      OptionTile(
          text: S.current.Theme_Settings,
          iconData: Icons.color_lens,
          desc: S.current.Theme_setting_desc_v2,
          onPressed: () {
            gotoPage(context: context, newPage: ThemeSettings());
          }),
      if (kDebugMode)
        OptionTile(
            text: "Cache Settings",
            iconData: Icons.cached,
            desc: "Customize your cache settings.",
            onPressed: () {
              gotoPage(context: context, newPage: CacheSettingsPage());
            }),
      OptionTile(
          text: S.current.Notification_Settings,
          iconData: Icons.notifications,
          desc: S.current.Notification_setting_desc,
          onPressed: () {
            gotoPage(context: context, newPage: NotificationSettingsPage());
          }),
      OptionTile(
          text: S.current.User_Preferences,
          iconData: Icons.room_preferences,
          desc: S.current.User_Preferences_desc,
          onPressed: () => _openUserPreferences(context)),
      OptionTile(
          text: S.current.List_preferences,
          iconData: Icons.list_alt,
          desc: S.current.List_preferences_desc,
          onPressed: () =>
              gotoPage(context: context, newPage: ListPreferenceSettings())),
      OptionTile(
          text: S.current.Home_Page_Setting,
          iconData: Icons.home_work,
          desc: S.current.HomePageSettings_desc,
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
          desc: S.current.Anime_Manga_settings_desc,
          onPressed: () {
            gotoPage(context: context, newPage: AnimeMangaSettings());
          }),
      OptionTile(
        text: S.current.Dub_Settings,
        iconData: DubIcons.preferredDubIcon,
        desc: S.current.Dub_Settings_Desc,
        onPressed: () => gotoPage(context: context, newPage: DubSettingsPage()),
      ),
      OptionTile(
          text: S.current.Backup_And_Restore,
          iconData: Icons.settings_backup_restore,
          desc: S.current.Backup_And_Restore_desc,
          onPressed: () {
            gotoPage(context: context, newPage: BackUpAndRestorePage());
          }),
      _aboutTile,
      CFutureBuilder<Servers?>(
        future: DalApi.i.dalConfigFuture,
        done: (snapshot) {
          if (snapshot.data?.bmacLink ?? false)
            return OptionTile(
              text: S.current.Buy_Me_A_Copy,
              desc: S.current.Buy_Me_A_Copy_Desc,
              iconData: Icons.coffee,
              onPressed: () => launchURL("https://ko-fi.com/abhaybyte"),
            );
          else
            return SB.z;
        },
        loadingChild: SB.z,
      ),
      OptionTile(
          text: S.current.Language_settings,
          iconData: Icons.language,
          desc: S.current.Language_settings_desc_v2,
          onPressed: () => _openLanguageSettings(context)),
      if (Platform.isLinux || Platform.isWindows || Platform.isMacOS)
        OptionTile(
          text: "Clear App Storage",
          iconData: Icons.delete_forever,
          desc: "Clear all app data and settings.",
          color: Colors.red,
          onPressed: () => _clearAppStorage(context),
        ),
      PlainButton(
        onPressed: () =>
            launchURLWithConfirmation('https://flutter.dev/', context: context),
        child: title('${S.current.Made_With_Flutter} Flutter'),
      ),
      SB.h120,
    ];
  }

  void _clearAppStorage(BuildContext context) async {
    final result = await showConfirmationDialog(
      context: context,
      alertTitle: "Clear App Storage?",
      desc: "This will remove all data and settings. App will restart.",
    );
    if (result) {
      await CacheManager.instance.clearAppStorage();
      showToast("App Storage Cleared");
      RestartApp.restartApp(context);
    }
  }

  Widget get _aboutTile {
    return OptionTile(
      text: S.current.About,
      desc: S.current.About_desc,
      iconData: Icons.info,
      onPressed: () => gotoPage(context: context, newPage: AboutPage()),
    );
  }

  void _openLanguageSettings(BuildContext context) {
    gotoPage(
      context: context,
      newPage: LanguageSettings(
        update: () {
          if (mounted) setState(() {});
        },
      ),
    );
  }

  void _openUserPreferences(BuildContext context) {
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
  }
}
