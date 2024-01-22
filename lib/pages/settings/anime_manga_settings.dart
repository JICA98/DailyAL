import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/main.dart';
import 'package:dailyanimelist/pages/settings/customsettings.dart';
import 'package:dailyanimelist/pages/settings/optiontile.dart';
import 'package:dailyanimelist/pages/settings/userprefsetting.dart';
import 'package:dailyanimelist/user/anime_manga_pref.dart';
import 'package:dailyanimelist/user/anime_manga_tab_pref.dart';
import 'package:dailyanimelist/widgets/selectbottom.dart';
import 'package:dailyanimelist/widgets/slivers.dart';
import 'package:dailyanimelist/widgets/togglebutton.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:flutter/material.dart';

class AnimeMangaPageTabEdit extends StatefulWidget {
  final String title;
  final List<AnimeMangaTabPreference> tabs;
  final VoidCallback? onListChange;
  final bool showAccordion;
  const AnimeMangaPageTabEdit(this.title, this.tabs,
      {this.onListChange, super.key, this.showAccordion = true});

  @override
  State<AnimeMangaPageTabEdit> createState() => _AnimeMangaPageTabEditState();
}

class _AnimeMangaPageTabEditState extends State<AnimeMangaPageTabEdit> {
  @override
  Widget build(BuildContext context) {
    final reorderableListView = ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (_, index) => _buildTab(
        index,
        widget.tabs.elementAt(index),
        onVisibiltyChange: () {
          setState(() {});
          if (widget.onListChange != null) {
            widget.onListChange!();
          }
        },
      ),
      itemCount: widget.tabs.length,
      onReorder: (oldIndex, newIndex) {
        if (newIndex > oldIndex) {
          newIndex = newIndex - 1;
        }
        widget.tabs.insert(newIndex, widget.tabs.removeAt(oldIndex));
        setState(() {});
        if (widget.onListChange != null) {
          widget.onListChange!();
        }
      },
    );
    if (widget.showAccordion)
      return AccordionOptionTile(
        text: widget.title,
        isOpen: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: reorderableListView,
        ),
      );
    else
      return reorderableListView;
  }
}

Widget _buildTab(
  int index,
  AnimeMangaTabPreference pref, {
  VoidCallback? onVisibiltyChange,
}) {
  final s = pref.tabType.name.capitalize()!.standardize()!;
  return Card(
    key: ValueKey(pref),
    child: OptionTile(
      text: s,
      contentPadding: EdgeInsets.symmetric(horizontal: 15),
      iconData: Icons.drag_indicator,
      trailing: IconButton(
          onPressed: () async {
            pref.visibility = !pref.visibility;
            if (onVisibiltyChange != null) {
              onVisibiltyChange();
            }
          },
          icon:
              Icon(pref.visibility ? Icons.visibility : Icons.visibility_off)),
    ),
  );
}

class AnimeMangaSettings extends StatefulWidget {
  const AnimeMangaSettings({super.key});

  @override
  State<AnimeMangaSettings> createState() => _AnimeMangaSettingsState();
}

class _AnimeMangaSettingsState extends State<AnimeMangaSettings> {
  final timezoneOptions = {
    TimezonePref.jst: S.current.JST,
    TimezonePref.utc: S.current.UTC,
    TimezonePref.local: S.current.Local_Time,
  };

  @override
  Widget build(BuildContext context) {
    return SettingSliverScreen(
        titleString: S.current.Anime_Manga_settings,
        children: [
          SliverWrapper(
            Column(
              children: [
                OptionTile(
                  text: S.current.Show_CountDown_Time,
                  iconData: Icons.timer,
                  multiLine: true,
                  desc: S.current.Show_CountDown_Time_Desc,
                  onPressed: () =>
                      _changeCountDown(!user.pref.showCountDownInDetailed),
                  trailing: ToggleButton(
                    toggleValue: user.pref.showCountDownInDetailed,
                    onToggled: (value) => _changeCountDown(value),
                  ),
                ),
                OptionTile(
                  text: S.current.Anime_Manga_BG,
                  iconData: Icons.animation_rounded,
                  multiLine: false,
                  desc: S.current.Anime_Manga_BG_Desc,
                  onPressed: () =>
                      _changeAnimeMangaBG(!user.pref.showAnimeMangaBg),
                  trailing: ToggleButton(
                    toggleValue: user.pref.showAnimeMangaBg,
                    onToggled: (value) => _changeAnimeMangaBG(value),
                  ),
                ),
                OptionTile(
                  text: S.current.Anime_Timezone_Pref,
                  iconData: Icons.timelapse_rounded,
                  multiLine: false,
                  trailing: SelectButton(
                    popupText: S.current.Anime_Timezone_Pref,
                    selectedOption: timezoneOptions[
                        user.pref.animeMangaPagePreferences.timezonePref],
                    options: timezoneOptions.values.toList(),
                    onChanged: (value) {
                      user.pref.animeMangaPagePreferences.timezonePref =
                          timezoneOptions.keys.elementAt(
                              timezoneOptions.values.toList().indexOf(value));
                      user.setIntance(shouldNotify: false, updateAuth: false);
                      setState(() {});
                    },
                  ),
                ),
                preferredTitleOptionTile((lang) => setState(() {})),
                AnimeMangaPageTabEdit(
                  S.current.Custom_anime_tabs,
                  user.pref.animeMangaPagePreferences.animeTabs,
                  onListChange: _updateuser,
                ),
                AnimeMangaPageTabEdit(
                  S.current.Custom_manga_tabs,
                  user.pref.animeMangaPagePreferences.mangaTabs,
                  onListChange: _updateuser,
                ),
              ],
            ),
          ),
          SB.lh80,
        ]);
  }

  void _updateuser() {
    user.setIntance(shouldNotify: false, updateAuth: false);
    if (mounted) setState(() {});
  }

  void _changeAnimeMangaBG(bool flag) {
    user.pref.showAnimeMangaBg = flag;
    user.setIntance();
    setState(() {});
  }

  void _changeCountDown(bool value) {
    user.pref.showCountDownInDetailed = value;
    user.setIntance();
    setState(() {});
  }
}
