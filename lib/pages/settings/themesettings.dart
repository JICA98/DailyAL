import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/theme/theme.dart';
import 'package:dailyanimelist/theme/themedata.dart';
import 'package:dailyanimelist/pages/settings/settingheader.dart';
import 'package:dailyanimelist/user/userpref.dart';
import 'package:dailyanimelist/widgets/avatarwidget.dart';
import 'package:dailyanimelist/widgets/custombutton.dart';
import 'package:dailyanimelist/widgets/loading/expandedwidget.dart';
import 'package:dailyanimelist/widgets/selectbottom.dart';
import 'package:dailyanimelist/widgets/togglebutton.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../constant.dart';
import '../../main.dart';

class ThemeSettings extends StatefulWidget {
  final bool isIntroPage;

  const ThemeSettings({Key? key, this.isIntroPage = false}) : super(key: key);

  @override
  _ThemeSettingsState createState() => _ThemeSettingsState();
}

class _ThemeSettingsState extends State<ThemeSettings> {
  late UserThemeMode currentThemeMode;
  late UserThemeMode originalThemeMode;
  late String currentThemeColor;
  late String originalThemeColor;
  late UserThemeBg currentThemeBg;
  late UserThemeBg originalThemeBg;
  late bool bgEnabled;
  late bool origBgEnabled;
  static const _userThemeModeEnumMap = {
    'auto': UserThemeMode.Auto,
    'light': UserThemeMode.Light,
    'dark': UserThemeMode.Dark,
    'black': UserThemeMode.Black,
  };
  @override
  void initState() {
    super.initState();
    currentThemeMode = originalThemeMode = user.theme.themeMode;
    currentThemeColor = originalThemeColor = user.theme.color;
    currentThemeBg = originalThemeBg = user.theme.background;
    bgEnabled = origBgEnabled = user.pref.showBg;
  }

  void changeTheme({required String th}) {
    currentThemeColor = th;
    user.theme.color = th;
    setState(() {});
  }

  void save() async {
    if (widget.isIntroPage) {
      user.pref.firstTime = false;
      user.pref.firstTimePref = FirstTimePref(bg: false, news: false);
    }
    await user.setIntance();
    restartApp();
  }

  void reset() {
    user.theme
      ..color = originalThemeColor
      ..themeMode = originalThemeMode
      ..background = originalThemeBg;
    user.pref.showBg = origBgEnabled;
  }

  @override
  Widget build(BuildContext _) {
    return DynamicColorBuilder(
        builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
      final colorScheme = currentColorScheme(
          context, lightDynamic, darkDynamic, currentThemeMode);
      return Theme(
        data: ThemeData(
          useMaterial3: true,
          colorScheme: colorScheme,
        ),
        child: Builder(builder: (context) {
          return WillPopScope(
            child: Scaffold(
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.miniCenterFloat,
              floatingActionButton: FloatingActionButton(
                child: Icon(Icons.check),
                onPressed: () => save(),
              ),
              body: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SettingsSliverHeader(
                      showBackButton: !widget.isIntroPage,
                      onPressed: () {
                        reset();
                        Navigator.pop(context);
                      },
                      title: !widget.isIntroPage
                          ? S.current.Theme_Settings
                          : S.current.Select_a_Theme,
                    ),
                    SB.lh30,
                  ];
                },
                floatHeaderSlivers: false,
                body: themePage,
              ),
            ),
            onWillPop: () async {
              reset();
              return true;
            },
          );
        }),
      );
    });
  }

  Widget get themePage {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _textAndTip(S.current.Pick_a_color, S.current.Pick_a_color_desc),
            SB.h20,
            _colorWrap(),
            SB.h40,
            _textAndTip(S.current.Select_mode, S.current.Select_mode_desc),
            SB.h20,
            _themeMode(),
            SB.h30,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: _textAndTip(
                        S.current.Select_bg, S.current.Select_bg_desc)),
                ToggleButton(
                  toggleValue: user.pref.showBg,
                  onToggled: (value) => changeBG(value),
                ),
              ],
            ),
            SB.h20,
            ExpandedSection(
              expand: bgEnabled,
              child: _bgSelector(),
            ),
          ],
        ),
      ),
    );
  }

  void changeBG(bool value) {
    bgEnabled = value;
    user.pref.showBg = value;
    setState(() {});
  }

  Widget _bgSelector() {
    return SizedBox(
      height: 110.0,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        children: [
          ...backgroundMap.keys
              .toList()
              .asMap()
              .entries
              .map((e) => _onBgBuild(e.key, e.value))
        ],
      ),
    );
  }

  Widget _onBgBuild(int index, UserThemeBg themeBg) {
    String? url = backgroundMap.values.toList()[index];
    final isSelected = themeBg == currentThemeBg;
    final onTap = () {
      currentThemeBg = themeBg;
      user.theme.background = themeBg;
      setState(() {});
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7.0),
      child: SizedBox(
        height: 100.0,
        width: 100.0,
        child: Stack(
          children: [
            Opacity(
              opacity: isSelected ? 0.6 : 1.0,
              child: Material(
                elevation: isSelected ? 8.0 : 0.0,
                child: AvatarWidget(
                  isNetworkImage: false,
                  url: url,
                  radius: BorderRadius.circular(6.0),
                  onLongPress: () {},
                  onTap: onTap,
                ),
              ),
            ),
            if (isSelected)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton.filledTonal(
                      onPressed: onTap,
                      icon: Icon(Icons.check),
                      // color: Theme.of(context).dividerColor,
                    )
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _themeMode() {
    return SelectBar(
      selectedOption: currentThemeMode.name.toLowerCase(),
      options: _userThemeModeEnumMap.keys.toList(),
      onChanged: (value) {
        if (value != null) {
          currentThemeMode = _userThemeModeEnumMap[value]!;
          user.theme.themeMode = currentThemeMode;
          setState(() {});
        }
      },
    );
  }

  Widget _colorWrap() {
    return Align(
      alignment: Alignment.center,
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          if (androidSDKVersion > 30) _autoBox(),
          ...UserThemeData.colorSchemeMap.entries.map(_materialBox),
        ],
      ),
    );
  }

  Widget _textAndTip(String text, String desc) {
    return Row(
      children: [
        Text(text),
        SB.w10,
        ToolTipButton(child: Icon(Icons.info, size: 16.0), message: desc),
      ],
    );
  }

  Widget _addColor() {
    return SizedBox(
      height: 50,
      width: 50,
      child: ShadowButton(
        onPressed: () async {
          final colorResult = await colorPickerDialog(context,
              UserThemeData.colorSchemeMap[currentThemeColor] ?? Colors.white);
          final color = colorResult.color.value;
          if (colorResult.result && mounted) {
            user.theme.userDefinedColors['${color}'] = color;
            changeTheme(th: '${color}');
          }
        },
        padding: EdgeInsets.zero,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _autoBox() {
    return SizedBox(
      height: 50,
      width: 50,
      child: Stack(
        children: [
          _materialBox(MapEntry(UserThemeColor.Auto.name, Colors.black)),
          if (currentThemeColor != UserThemeColor.Auto)
            GestureDetector(
              onTap: () => changeTheme(th: UserThemeColor.Auto.name),
              child: Center(
                child: Text('Auto', style: TextStyle(color: Colors.white)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _materialBox(MapEntry<String, Color> e) {
    final isSelected = currentThemeColor == e.key;
    return SizedBox(
      height: 50,
      width: 50,
      child: Stack(
        children: [
          Material(
            color: e.value,
            elevation: isSelected ? 4 : 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
                side: BorderSide(
                    color: isSelected ? Colors.white54 : Colors.transparent)),
            child: InkWell(
              onTap: () {
                changeTheme(th: e.key);
              },
              borderRadius: BorderRadius.circular(6),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: const SizedBox(
                  height: 50,
                  width: 50,
                ),
              ),
            ),
          ),
          if (isSelected && e.key != UserThemeColor.Auto.name)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton.filledTonal(
                    onPressed: () {},
                    icon: Icon(Icons.check),
                    // color: Theme.of(context).dividerColor,
                  )
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget text(String title, {double? fontSize, double opacity = 1.0}) {
    return Text(
      title,
      style: TextStyle(
          color: Colors.white.withOpacity(opacity), fontSize: fontSize ?? 16),
    );
  }
}
