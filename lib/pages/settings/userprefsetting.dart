import 'dart:io';

import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/enums.dart';
import 'package:dailyanimelist/pages/settings/optiontile.dart';
import 'package:dailyanimelist/screens/contentdetailedscreen.dart';
import 'package:dailyanimelist/screens/generalsearchscreen.dart';
import 'package:dailyanimelist/widgets/avatarwidget.dart';
import 'package:dailyanimelist/widgets/bottomnavbar.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dailyanimelist/widgets/custombutton.dart';
import 'package:dailyanimelist/widgets/home/accordion.dart';
import 'package:dailyanimelist/widgets/togglebutton.dart';
import 'package:flutter/material.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../main.dart';
import '../../widgets/selectbottom.dart';

final _titleDisplayMap = {
  TitleLang.ro: 'Romanized',
  TitleLang.en: 'English',
  TitleLang.ja: 'Japanese'
};
_changePreferredTitle(TitleLang lang) {
  user.pref.preferredAnimeTitle = lang;
  user.setIntance();
}

Widget preferredTitleOptionTile(ValueChanged<TitleLang> valueChanged) {
  return OptionTile(
    text: S.current.PreferredTitle,
    iconData: Icons.title,
    multiLine: true,
    desc: S.current.PreferredTitle_Desc,
    onPressed: () {},
    trailing: SizedBox(
        width: 100,
        child: SelectButton(
          selectType: SelectType.select_top,
          onChanged: (value) {
            final lang = TitleLang.values.asNameMap()[value]!;
            _changePreferredTitle(lang);
            valueChanged(lang);
          },
          fontStyle: FontStyle.italic,
          iconToUse: Icons.arrow_drop_down,
          popupText: S.current.PreferredTitle,
          options: _titleDisplayMap.keys.map((e) => e.name).toList(),
          selectedOption: user.pref.preferredAnimeTitle.name,
          displayValues: _titleDisplayMap.values.toList(),
        )),
  );
}

final _options = [
  S.current.Home_Page,
  S.current.Forums_Page,
  S.current.listPage,
  S.current.Profile_Page,
  S.current.Explore,
];

Widget startUpPageFeature(ValueChanged<int> onChanged) {
  return OptionTile(
    iconData: Icons.navigation,
    text: S.current.StartUp_page,
    desc: S.current.Customize_Bottom_Navbar_desc,
    trailing: SelectButton(
      popupText: S.current.StartUp_page,
      selectedOption: _options[user.pref.startUpPage],
      options: _options,
      onChanged: (value) {
        user.pref.startUpPage = _options.indexOf(value);
        user.setIntance(updateAuth: false);
        onChanged(user.pref.startUpPage);
      },
    ),
  );
}

final Uuid _uuid = Uuid();
final ImagePicker _picker = ImagePicker();

Future<void> setNewBg(
  Function(String path) onPath, {
  double? limitInBytes,
  VoidCallback? onError,
}) async {
  final image = await _picker.pickImage(source: ImageSource.gallery);
  if (image != null) {
    try {
      if (limitInBytes != null && (await image.length()) > limitInBytes) {
        showToast(S.current.Image_Size_Too_Large);
        return;
      }
      final fileName = _uuid.v4();
      final Directory directory = await getApplicationDocumentsDirectory();
      final String path = '${directory.path}/$fileName.jpg';
      await image.saveTo(path);
    } catch (e) {
      return;
    }
    onPath(image.path);
  } else {
    showToast(S.current.Image_Not_Selected);
    if (onError != null) onError();
  }
}

class UserPrefSettings extends StatefulWidget {
  final VoidCallback? onUiChange;
  const UserPrefSettings({Key? key, this.onUiChange}) : super(key: key);

  @override
  _UserPrefSettingsState createState() => _UserPrefSettingsState();
}

class _UserPrefSettingsState extends State<UserPrefSettings> {
  bool colorOptions = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate(
        // shrinkWrap: true,
        // physics: const NeverScrollableScrollPhysics(),
        // padding: EdgeInsets.zero,
        [
          OptionTile(
            text: user.pref.bgPath != null
                ? S.current.Remove_Image
                : S.current.Select_Image,
            iconData: user.pref.bgPath != null
                ? Icons.image_not_supported
                : Icons.image,
            multiLine: true,
            desc: user.pref.bgPath != null
                ? S.current.Remove_Image_desc
                : S.current.Select_Image_desc,
            onPressed: () => user.pref.bgPath != null
                ? removeBg()
                : setNewBg((path) {
                    user.pref.bgPath = path;
                    user.setIntance();
                    setState(() {});
                  }),
            trailing: imagePickerW,
          ),
          OptionTile(
            text: S.current.NSFW_Preference,
            iconData: Icons.work_off,
            multiLine: true,
            desc: S.current.NSFW_Preference_desc,
            onPressed: () => changeNSFW(!user.pref.nsfw),
            trailing: ToggleButton(
              toggleValue: user.pref.nsfw,
              onToggled: (value) => changeNSFW(value),
            ),
          ),
          OptionTile(
            text: S.current.showAnimeMangaCard,
            iconData: Icons.indeterminate_check_box,
            multiLine: false,
            desc: S.current.showAnimeMangaCardDesc,
            onPressed: () =>
                changeShowAnimeMangaCard(!user.pref.showAnimeMangaCard),
            trailing: ToggleButton(
              toggleValue: user.pref.showAnimeMangaCard,
              onToggled: (value) => changeShowAnimeMangaCard(value),
            ),
          ),
          OptionTile(
            text: S.current.Keep_pages_in_memory,
            iconData: Icons.memory,
            multiLine: false,
            desc: S.current.Keep_pages_in_memory_desc,
            onPressed: () =>
                changeKeepPagesInMemory(!user.pref.keepPagesInMemory),
            trailing: ToggleButton(
              toggleValue: user.pref.keepPagesInMemory,
              onToggled: (value) => changeKeepPagesInMemory(value),
            ),
          ),
          OptionTile(
            text: S.current.Show_priority_in_anime_manga_list,
            iconData: Icons.priority_high,
            multiLine: false,
            desc: S.current.Show_priority_in_anime_manga_list_desc,
            onPressed: () => changeShowPriority(!user.pref.showPriority),
            trailing: ToggleButton(
              toggleValue: user.pref.showPriority,
              onToggled: (value) => changeShowPriority(value),
            ),
          ),
          OptionTile(
            text: S.current.Auto_Translate_Synopsis,
            iconData: Icons.translate,
            onPressed: () =>
                changeAutoTranslate(!user.pref.autoTranslateSynopsis),
            trailing: ToggleButton(
              toggleValue: user.pref.autoTranslateSynopsis,
              onToggled: (value) => changeAutoTranslate(value),
            ),
          ),
          OptionTile(
            text: S.current.ShowOnlyLastQuote,
            iconData: Icons.format_quote,
            desc: S.current.ShowOnlyLastQuote_desc,
            onPressed: () =>
                changeShowOnlyLastQuote(!user.pref.showOnlyLastQuote),
            trailing: ToggleButton(
              toggleValue: user.pref.showOnlyLastQuote,
              onToggled: (value) => changeShowOnlyLastQuote(value),
            ),
          ),
          // OptionTile(
          //   text: S.current.Default_Display_Type,
          //   iconData: Icons.display_settings,
          //   desc: S.current.Default_Display_Type_Desc,
          //   onPressed: () => changedefaultDisplayType(
          //       !(user.pref.defaultDisplayType == DisplayType.list_vert)),
          //   trailing: ToggleButton(
          //     toggleValue:
          //         user.pref.defaultDisplayType == DisplayType.list_vert,
          //     onToggled: (value) => changedefaultDisplayType(value),
          //   ),
          // ),
          OptionTile(
            text: S.current.Auto_Add_Start_End_Date,
            iconData: Icons.date_range,
            desc: S.current.Auto_Add_Start_End_Date_Desc,
            onPressed: () =>
                changeAutoAddStartEndDate(!user.pref.showOnlyLastQuote),
            trailing: ToggleButton(
              toggleValue: user.pref.autoAddStartEndDate,
              onToggled: (value) => changeAutoAddStartEndDate(value),
            ),
          ),
          OptionTile(
            text: S.current.Show_Airing_info_AnimeList,
            iconData: Icons.live_tv_rounded,
            desc: S.current.Show_Airing_info_AnimeList_Desc,
            onPressed: () => changeShowAiringInfo(!user.pref.showAiringInfo),
            trailing: ToggleButton(
              toggleValue: user.pref.showAiringInfo,
              onToggled: (value) => changeShowAiringInfo(value),
            ),
          ),
          if (user.pref.userchart != null)
            Accordion(
              isOpen: colorOptions,
              onChanged: (value) {
                if (mounted)
                  setState(() {
                    colorOptions = value;
                  });
              },
              child: Column(
                children: [
                  for (var i = 0; i < user.pref.userchart.length; i++)
                    colorPalette(i)
                ],
              ),
              title: Container(
                height: 60,
                child: OptionTile(
                  text: S.current.User_Statistics_Chart_Preferences,
                  desc: S.current.Restart_to_see_changes,
                  iconData: Icons.color_lens,
                  multiLine: true,
                  trailing: Icon(
                    colorOptions
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 16,
                  ),
                ),
              ),
            ),
          SB.h10,
          startUpPageFeature((value) {
            if (mounted) setState(() {});
          }),
          SB.h120
        ],
      ),
    );
  }

  Widget get imagePickerW {
    return user.pref.bgPath != null
        ? AvatarAspect(
            url: user.pref.bgPath!,
            isNetworkImage: false,
            radius: BorderRadius.circular(3),
            localFile: true,
          )
        : Container(
            width: 30,
            height: 60,
            child: DottedBorder(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(6),
                  child: Center(
                    child: Icon(
                      Icons.add,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ),
          );
  }

  Widget colorPalette(i) {
    var color = user.pref.userchart.elementAt(i);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      leading: SB.w10,
      title: title(
          myAnimeStatusMap.values.elementAt(i) + "  ${S.current.Chart_color}",
          opacity: 1,
          fontSize: 16),
      subtitle: color != -1
          ? Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Container(
                height: 25,
                alignment: Alignment.centerLeft,
                child: PlainButton(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Text(S.current.Clear),
                  onPressed: () {
                    if (mounted)
                      setState(() {
                        user.pref.userchart[i] = -1;
                      });
                    user.setIntance();
                  },
                ),
              ),
            )
          : null,
      trailing: Container(
        width: 55,
        height: 55,
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: BorderSide(color: Colors.white38),
          ),
          color: color != -1 ? Color(color) : null,
          child: InkWell(
            child: color == -1
                ? Center(
                    child: title(S.current.Select),
                  )
                : null,
            onTap: () async {
              var colorResult = await colorPickerDialog(context, Color(color));
              if (colorResult.result) {
                if (mounted)
                  setState(() {
                    user.pref.userchart[i] = colorResult.color.value;
                  });
                user.setIntance();
              }
            },
          ),
        ),
      ),
    );
  }

  void changeAutoTranslate(bool value) async {
    user.pref.autoTranslateSynopsis = value;
    user.setIntance();
    setState(() {});
    onUIChange();
  }

  void changeKeepPagesInMemory(bool value) async {
    user.pref.keepPagesInMemory = value;
    user.setIntance();
    setState(() {});
    onUIChange();
  }

  void onUIChange() {
    if (widget.onUiChange != null) {
      widget.onUiChange!();
    }
  }

  void changeNSFW(bool value) async {
    user.pref.nsfw = value;
    user.setIntance();
    setState(() {});
    onUIChange();
  }

  void changeShowPriority(bool value) async {
    user.pref.showPriority = value;
    user.setIntance();
    setState(() {});
    onUIChange();
  }

  void changeDetailsExpand(bool value) async {
    user.pref.detailsExpanded = value;
    user.setIntance();
    showToast(S.current.Restart_to_see_changes);
    setState(() {});
    onUIChange();
  }

  changeShowOnlyLastQuote(bool value) {
    user.pref.showOnlyLastQuote = value;
    user.setIntance();
    setState(() {});
  }

  removeBg() {
    user.pref.bgPath = null;
    user.setIntance();
    setState(() {});
  }

  changeAutoAddStartEndDate(bool value) {
    user.pref.autoAddStartEndDate = value;
    user.setIntance();
    setState(() {});
  }

  changeShowAiringInfo(bool value) {
    user.pref.showAiringInfo = value;
    user.setIntance();
    setState(() {});
  }

  changedefaultDisplayType(bool isList) {
    user.pref.defaultDisplayType =
        isList ? DisplayType.list_vert : DisplayType.grid;
    user.setIntance();
    setState(() {});
  }

  changeShowAnimeMangaCard(bool showAnimeMangaCard) {
    user.pref.showAnimeMangaCard = showAnimeMangaCard;
    user.setIntance();
    setState(() {});
  }
}
