import 'package:dailyanimelist/pages/settings/customsettings.dart';
import 'package:dailyanimelist/pages/settings/dropdowncustom.dart';
import 'package:dailyanimelist/pages/settings/settingheader.dart';
import 'package:dailyanimelist/widgets/slivers.dart';
import 'package:flutter/material.dart';
import 'package:dailyanimelist/generated/l10n.dart';

import '../../constant.dart';
import '../../main.dart';

class CacheSettingsPage extends StatefulWidget {
  static Map<int, List<dynamic>> pageFrequency = {
    0: [
      S.current.Home_Page,
      Icons.home_outlined,
      [2, 4, 8, 12, 24]
    ],
    1: [
      S.current.Forums_Page,
      Icons.forum_sharp,
      [1, 2, 4, 8, 12, 24]
    ],
    2: [
      S.current.User_Page,
      Icons.person,
      [0, 1, 2, 4, 8, 12, 24]
    ],
  };

  @override
  _CacheSettingsPageState createState() => _CacheSettingsPageState();
}

class _CacheSettingsPageState extends State<CacheSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return SettingSliverScreen(
      titleString: 'Cache Settings',
      child: SliverListWrapper(
        [
          const SizedBox(
            height: 30,
          ),
          Padding(
            padding: EdgeInsets.only(left: 30, right: 20, bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                title("Update Frequency in Hours", fontSize: 20),
                ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: CacheSettingsPage.pageFrequency.keys.map(
                    (key) {
                      var page = CacheSettingsPage.pageFrequency[key]!;
                      var name = page[0];
                      var icondata = page[1];
                      var values = page[2];
                      var dropdownvalue = user.pref.cacheUpdateFrequency[key];

                      return ListTile(
                        // onTap: () {},
                        title: text(name),
                        leading: Icon(icondata),
                        trailing: CustomDropdownButton(
                          dropdownValue: dropdownvalue.toString(),
                          values: values,
                          onChanged: (value) {
                            user.pref.cacheUpdateFrequency[key] =
                                int.tryParse(value ?? '') ?? 2;
                            user.setIntance();
                            if (mounted) setState(() {});
                          },
                        ),
                        contentPadding: EdgeInsets.only(bottom: 20),
                      );
                    },
                  ).toList(),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
