import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/main.dart';
import 'package:dailyanimelist/pages/settings/homepagesettings.dart';
import 'package:dailyanimelist/pages/settings/userprefsetting.dart';
import 'package:dailyanimelist/widgets/custombutton.dart';
import 'package:dailyanimelist/widgets/home/accordion.dart';
import 'package:flutter/material.dart';

bool get hasNewFeatures {
  return [
    user.pref.firstTimePref.homePageSize,
    user.pref.firstTimePref.prefferedTitle,
    user.pref.firstTimePref.startUpPage,
  ].reduce((value, element) => value || element);
}

enum _FlagType {
  homePageSize,
  prefferedTitle,
  startUpPage,
}

class _FeatureSC {
  final String title;
  final bool shown;

  _FeatureSC(this.title, this.shown);
}

class FeatureShowCase extends StatefulWidget {
  const FeatureShowCase({Key? key}) : super(key: key);

  @override
  State<FeatureShowCase> createState() => _FeatureShowCaseState();
}

class _FeatureShowCaseState extends State<FeatureShowCase> {
  var featureFlags = <_FlagType, _FeatureSC>{};

  @override
  void initState() {
    super.initState();
    featureFlags = {
      if (user.pref.firstTimePref.homePageSize)
        _FlagType.homePageSize: _FeatureSC(
          S.current.Tile_Size_Title,
          user.pref.firstTimePref.homePageSize,
        ),
      if (user.pref.firstTimePref.prefferedTitle)
        _FlagType.prefferedTitle: _FeatureSC(
          S.current.PreferredTitle,
          user.pref.firstTimePref.prefferedTitle,
        ),
      if (user.pref.firstTimePref.startUpPage)
        _FlagType.startUpPage: _FeatureSC(
          S.current.StartUp_page,
          user.pref.firstTimePref.startUpPage,
        )
    };
  }

  Widget _featuredField(_FlagType type) {
    return switch (type) {
      _FlagType.homePageSize => homePageTileSizeOption((_) => setState(() {})),
      _FlagType.prefferedTitle =>
        preferredTitleOptionTile((_) => setState(() {})),
      _FlagType.startUpPage => startUpPageFeature((_) => setState(() {})),
    };
  }

  @override
  Widget build(BuildContext context) {
    var children = featureFlags.entries
        .map(
          (e) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: Accordion(
              title: e.value.title,
              isOpen: true,
              titlePadding: EdgeInsets.symmetric(vertical: 10),
              titleStyle: TextStyle(fontSize: 18),
              child: _featuredField(e.key),
            ),
          ),
        )
        .toList();
    return WillPopScope(
        onWillPop: () async {
          await _setFirstTimePrefsOff();
          return true;
        },
        child: Container(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            child: Material(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SB.h35,
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 15),
                      child: title(
                        S.current.New_features,
                        align: TextAlign.start,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  ...children,
                  // SB.h10,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        child: PlainButton(
                          child: Text(S.current.Close),
                          onPressed: () {
                            Navigator.pop(context);
                            _setFirstTimePrefsOff();
                          },
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ));
  }

  Future<void> _setFirstTimePrefsOff() async {
    user.pref.firstTimePref.homePageSize = false;
    user.pref.firstTimePref.prefferedTitle = false;
    user.pref.firstTimePref.startUpPage = false;
    await user.setIntance();
  }
}
