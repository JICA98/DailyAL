import 'package:dailyanimelist/cache/dubinfomanager.dart';
import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:dailyanimelist/pages/settings/customsettings.dart';
import 'package:dailyanimelist/pages/settings/optiontile.dart';
import 'package:dailyanimelist/widgets/togglebutton.dart';
import 'package:dailyanimelist/widgets/selectbottom.dart';
import 'package:dailyanimelist/icons/dub_icons.dart';
import '../../main.dart';

const List<Map<String, String>> _dubLanguageOptions = [
  {'label': 'English', 'value': 'english'},
  {'label': 'Spanish', 'value': 'spanish'},
  {'label': 'German', 'value': 'german'},
  {'label': 'French', 'value': 'french'},
  {'label': 'Italian', 'value': 'italian'},
  {'label': 'Portuguese', 'value': 'portuguese'},
  {'label': 'Korean', 'value': 'korean'},
  {'label': 'Chinese', 'value': 'chinese'},
  {'label': 'Polish', 'value': 'polish'},
  {'label': 'Hungarian', 'value': 'hungarian'},
  {'label': 'Norwegian', 'value': 'norwegian'},
  {'label': 'Swedish', 'value': 'swedish'},
  {'label': 'Hebrew', 'value': 'hebrew'},
  {'label': 'Indonesian', 'value': 'indonesian'},
  {'label': 'Thai', 'value': 'thai'},
  {'label': 'Hindi', 'value': 'hindi'},
  {'label': 'Finnish', 'value': 'finnish'},
  {'label': 'Turkish', 'value': 'turkish'},
  {'label': 'Tagalog', 'value': 'tagalog'},
  {'label': 'Arabic', 'value': 'arabic'},
  {'label': 'Dutch', 'value': 'dutch'},
  {'label': 'Catalan', 'value': 'catalan'},
  {'label': 'Vietnamese', 'value': 'vietnamese'},
  {'label': 'Filipino', 'value': 'filipino'},
];

const Map<String, List<IconData>> _iconStyles = {
  '0': [DubIcons.style0Dub, DubIcons.style0Incomplete],
  '1': [DubIcons.style1Dub, DubIcons.style1Incomplete],
  '2': [DubIcons.style2Dub, DubIcons.style2Incomplete],
  '3': [DubIcons.style3Dub, DubIcons.style3Incomplete],
};

class DubSettingsPage extends StatefulWidget {
  const DubSettingsPage({Key? key}) : super(key: key);
  @override
  _DubSettingsPageState createState() => _DubSettingsPageState();
}

class _DubSettingsPageState extends State<DubSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return SettingSliverScreen(
      titleString: S.current.Dub_Settings,
      children: [
        SliverList(
          delegate: SliverChildListDelegate([
            OptionTile(
              text: S.current.Dub_Show_Icon,
              multiLine: true,
              desc: S.current.Dub_Show_Icon_Desc,
              trailing: ToggleButton(
                toggleValue: user.pref.showDubStatus,
                onToggled: (value) {
                  user.pref.showDubStatus = value;
                  user.setIntance();
                  if (value) DubInfoManager().ensureLoaded();
                  setState(() {});
                },
              ),
            ),

            OptionTile(
              text: S.current.Dub_Language,
              desc: S.current.Dub_Language_Desc,
              trailing: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 100),
                child: SelectButton(
                  selectType: SelectType.select_top,
                  popupText: S.current.Dub_Language,
                  options: _dubLanguageOptions.map((e) => e['value']!).toList(),
                  displayValues: _dubLanguageOptions.map((e) => e['label']!).toList(),
                  selectedOption: user.pref.dubLanguage,
                  onChanged: (value) {
                    user.pref.dubLanguage = value;
                    user.setIntance();
                    DubInfoManager().ensureLoaded();
                    setState(() {});
                  },
                ),
              ),
            ),

            OptionTile(
              text: S.current.Dub_Icon_Style,
              desc: S.current.Dub_Icon_Style_Desc,
              trailing: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 100),
                child: DropdownButton<String>(
                  value: user.pref.dubIconStyle,
                  isExpanded: true,
                  alignment: Alignment.center,
                  underline: SizedBox.shrink(),
                  isDense: true,
                  selectedItemBuilder: (_) => _iconStyles.entries.map((entry) {
                    return Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(entry.value[0], size: 25),
                          SizedBox(width: 16),
                          Icon(entry.value[1], size: 25),
                          SizedBox(width: 10),
                        ],
                      ),
                    );
                  }).toList(),
                  items: _iconStyles.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(entry.value[0], size: 25),
                            SizedBox(width: 18),
                            Icon(entry.value[1], size: 25),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    user.pref.dubIconStyle = value;
                    user.setIntance();
                    setState(() {});
                  },
                ),
              ),
            ),

            OptionTile(
              text: S.current.Dub_Report,
              iconData: Icons.bug_report,
              onPressed: () => launchURLWithConfirmation(
                'https://github.com/Joelis57/MyDubList/issues/new',
                context: context,
              ),
            ),

            OptionTile(
              text: S.current.Dub_Support,
              iconData: Icons.favorite,
              onPressed: () => launchURLWithConfirmation(
                'https://ko-fi.com/joelis',
                context: context,
              ),
            ),
          ]),
        ),
      ],
    );
  }
}
