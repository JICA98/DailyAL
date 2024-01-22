import 'package:dailyanimelist/main.dart';
import 'package:dailyanimelist/pages/settings/optiontile.dart';
import 'package:dailyanimelist/pages/settings/settingheader.dart';
import 'package:dailyanimelist/user/user.dart';
import 'package:dailyanimelist/util/homepageutils.dart';
import 'package:flutter/material.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dal_commons/dal_commons.dart';
import '../../constant.dart';

class LangOpt {
  String title;
  String value;
  String desc;
  LangOpt(this.title, this.value, this.desc);
}

class LanguageSettings extends StatefulWidget {
  final bool isIntroPage;
  final VoidCallback? update;
  const LanguageSettings({Key? key, this.isIntroPage = false, this.update})
      : super(key: key);

  @override
  _LanguageSettingsState createState() => _LanguageSettingsState();
}

class _LanguageSettingsState extends State<LanguageSettings> {
  List<LangOpt> get langOpts => [
        LangOpt("System Default", "sys", S.of(context).English_Default),
        LangOpt("English", "en_US", S.of(context).English),
        LangOpt("Portuguese", "pt_BR", S.of(context).Portuguese),
        LangOpt("Spanish", "es_ES", S.of(context).Spanish),
        LangOpt("Arabic", "ar_EG", S.of(context).Arabic),
        LangOpt("German", "de_DE", S.of(context).German),
        LangOpt("French", "fr_FR", S.of(context).French),
        LangOpt("Indonesian", "id_ID", S.of(context).Indonesian),
        LangOpt("Russian", "ru_RU", S.of(context).Russian),
        LangOpt("Turkish", "tr-TR", S.of(context).Turkish),
        LangOpt("Japanese", "ja", S.of(context).Japanese),
        LangOpt("Korean", "ko_KR", S.of(context).Korean),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Scrollbar(
        child: CustomScrollView(
          slivers: [
            SettingsSliverHeader(
              title: S.current.Language_settings,
              showBackButton: !widget.isIntroPage,
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  SB.h40,
                  Padding(
                    padding: EdgeInsets.only(left: 30),
                    child: title(S.of(context).Choose_a_Language, fontSize: 20),
                  ),
                  SB.h20,
                  ...langOpts
                      .map(
                        (e) => OptionTile(
                          text: e.title,
                          desc: e.desc,
                          contentPadding: EdgeInsets.symmetric(horizontal: 20),
                          multiLine: e.value.equals("sys"),
                          onPressed: () => _changeLang(e.value),
                          trailing: Radio<String>(
                            value: e.value,
                            groupValue: user.pref.userLanguage,
                            onChanged: (lang) => _changeLang(lang!),
                          ),
                        ),
                      )
                      .toList(),
                  SB.h40,
                  if (!widget.isIntroPage)
                    Container(
                      alignment: Alignment.center,
                      child: title(S.current.Restart_to_see_changes, align: TextAlign.center),
                    ),
                  SB.h40,
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _changeLang(String lang) async {
    user.pref.userLanguage = lang;
    await User.setLocale(user);
    user.pref.hpApiPrefList =
        HomePageUtils().translateTitle(user.pref.hpApiPrefList, context);
    user.pref.isRtl = lang.equals("ar_EG");
    user.setIntance();
    if (widget.update != null) widget.update!();
    if (mounted) setState(() {});
  }
}
