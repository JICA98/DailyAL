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
  {'label': 'Tagalog', 'value': 'tagalog'},
  {'label': 'Chinese', 'value': 'chinese'},
  {'label': 'Arabic', 'value': 'arabic'},
  {'label': 'Polish', 'value': 'polish'},
  {'label': 'Hungarian', 'value': 'hungarian'},
  {'label': 'Swedish', 'value': 'swedish'},
  {'label': 'Norwegian', 'value': 'norwegian'},
  {'label': 'Hebrew', 'value': 'hebrew'},
  {'label': 'Dutch', 'value': 'dutch'},
  {'label': 'Russian', 'value': 'russian'},
  {'label': 'Indonesian', 'value': 'indonesian'},
  {'label': 'Danish', 'value': 'danish'},
  {'label': 'Thai', 'value': 'thai'},
  {'label': 'Hindi', 'value': 'hindi'},
  {'label': 'Finnish', 'value': 'finnish'},
  {'label': 'Turkish', 'value': 'turkish'},
  {'label': 'Catalan', 'value': 'catalan'},
  {'label': 'Vietnamese', 'value': 'vietnamese'},
  {'label': 'Lithuanian', 'value': 'lithuanian'},
];

const List<Map<String, String>> _dubConfidenceOptions = [
  {'label': '1 Source',  'value': '1'},
  {'label': '2 Sources', 'value': '2'},
  {'label': '3 Sources', 'value': '3'},
  {'label': '4 Sources', 'value': '4'},
];

const Map<String, List<IconData>> _iconStyles = {
  '0': [DubIcons.style0Dub, DubIcons.style0Partial],
  '1': [DubIcons.style1Dub, DubIcons.style1Partial],
  '2': [DubIcons.style2Dub, DubIcons.style2Partial],
  '3': [DubIcons.style3Dub, DubIcons.style3Partial],
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
                  if (value) {
                    DubInfoManager().ensureLoaded(force: true);
                  }
                  setState(() {});
                },
              ),
            ),

            OptionTile(
              text: S.current.Dub_Language,
              desc: S.current.Dub_Language_Desc,
              trailing: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 140),
                child: SelectButton(
                  selectType: SelectType.select_top,
                  popupText: S.current.Dub_Language,
                  options: _dubLanguageOptions.map((e) => e['value']!).toList(),
                  displayValues: _dubLanguageOptions.map((e) => e['label']!).toList(),
                  selectedOption: user.pref.dubLanguage,
                  onChanged: (value) {
                    user.pref.dubLanguage = value;
                    user.setIntance();
                    DubInfoManager().ensureLoaded(force: true);
                    setState(() {});
                  },
                ),
              ),
            ),

            OptionTile(
              text: S.current.Dub_Confidence,
              desc: S.current.Dub_Confidence_Desc,
              trailing: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 140),
                child: SelectButton(
                  selectType: SelectType.select_top,
                  popupText: S.current.Dub_Confidence,
                  options: _dubConfidenceOptions.map((e) => e['value']!).toList(),
                  displayValues: _dubConfidenceOptions.map((e) => e['label']!).toList(),
                  selectedOption: user.pref.dubMinSourceCount,
                  onChanged: (value) {
                    user.pref.dubMinSourceCount = value;
                    user.setIntance();
                    DubInfoManager().ensureLoaded(force: true);
                    setState(() {});
                  },
                ),
              ),
            ),

            OptionTile(
              text: S.current.Dub_Icon_Style,
              desc: S.current.Dub_Icon_Style_Desc,
              trailing: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 140),
                child: DropdownButton<String>(
                  value: user.pref.dubIconStyle,
                  isExpanded: true,
                  alignment: Alignment.center,
                  underline: const SizedBox.shrink(),
                  isDense: true,
                  selectedItemBuilder: (_) => _iconStyles.entries.map((entry) {
                    return Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(entry.value[0], size: 25),
                          const SizedBox(width: 16),
                          Icon(entry.value[1], size: 25),
                          const SizedBox(width: 10),
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
                            const SizedBox(width: 18),
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
