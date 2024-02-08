import 'package:dailyanimelist/constant.dart';
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

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return SettingSliverScreen(
      titleString: S.current.Settings,
      child: SliverList.list(
        children: settingOptions(context),
      ),
    );
  }

  List<Widget> settingOptions(BuildContext context) {
    return [
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
          text: S.current.Backup_And_Restore,
          iconData: Icons.settings_backup_restore,
          desc: S.current.Backup_And_Restore_desc,
          onPressed: () {
            gotoPage(context: context, newPage: BackUpAndRestorePage());
          }),
      OptionTile(
          text: S.current.User_Preferences,
          iconData: Icons.room_preferences,
          desc: S.current.User_Preferences_desc,
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
          iconData: Icons.language,
          desc: S.current.Language_settings_desc_v2,
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
      SB.h120,
    ];
  }
}
