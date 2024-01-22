import 'dart:convert';
import 'dart:math';

import 'package:dailyanimelist/api/dalapi.dart';
import 'package:dailyanimelist/notifservice.dart';
import 'package:dailyanimelist/pages/settings/customsettings.dart';
import 'package:dailyanimelist/pages/settings/optiontile.dart';
import 'package:dailyanimelist/pages/settings/settingheader.dart';
import 'package:dailyanimelist/widgets/slivers.dart';
import 'package:dailyanimelist/widgets/togglebutton.dart';
import 'package:dailyanimelist/widgets/user/contentlistwidget.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:flutter/material.dart';
import 'package:dailyanimelist/generated/l10n.dart';

import '../../constant.dart';
import '../../main.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({Key? key}) : super(key: key);

  @override
  _NotificationSettingsPageState createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  List<Node> nodes = List.from(jsonDecode(_nodeList))
      .map((e) => AnimeDetailed.fromJson(e['node']))
      .toList();

  @override
  Widget build(BuildContext context) {
    return SettingSliverScreen(
      titleString: S.current.Notification_Settings,
      children: [
        SliverListWrapper([
          Padding(
            padding: EdgeInsets.only(left: 30),
            child: title(S.current.Receive_notifications_on, fontSize: 20),
          ),
          SB.h20,
          OptionTile(
            text: S.current.Anime_on_Watching_List_gets_aired,
            trailing: ToggleButton(
              toggleValue: user.pref.notifPref.onWatchingListUpdated,
              onToggled: (value) {
                user.pref.notifPref.onWatchingListUpdated = value;
                user.setIntance();
                if (mounted) setState(() {});
              },
            ),
          ),
          OptionTile(
            text: S.current.Anime_on_PTW_List_gets_aired,
            trailing: ToggleButton(
              toggleValue: user.pref.notifPref.onPTWGoesToWatching,
              onToggled: (value) {
                user.pref.notifPref.onPTWGoesToWatching = value;
                user.setIntance();
                if (mounted) setState(() {});
              },
            ),
          ),
          OptionTile(
            text: S.current.PreferLargeImageNotif,
            desc: S.current.PreferLargeImageNotifDesc,
            multiLine: true,
            trailing: ToggleButton(
              toggleValue: user.pref.notifPref.preferLargeImage,
              onToggled: (value) {
                user.pref.notifPref.preferLargeImage = value;
                user.setIntance();
                if (mounted) setState(() {});
              },
            ),
          ),
          OptionTile(
            iconData: Icons.edit_notifications,
            text: S.current.RequestPermission,
            onPressed: () async {
              user.pref.notifPref.onPTWGoesToWatching = true;
              user.pref.notifPref.onWatchingListUpdated = true;
              await user.setIntance();
              await NotificationService().askForPermission();
              if (mounted) setState(() {});
            },
          ),
          OptionTile(
            iconData: Icons.notifications_sharp,
            text: S.current.TestNotification,
            onPressed: () async {
              final node = nodes.elementAt(Random().nextInt(nodes.length));
              // final node = nodes.where((e) => e.id == 53127).elementAt(0);
              node.title = getNodeTitle(node);
              String title = 'Ep: 10 of <b>${node.title}</b> is out!';
              NotificationService().showNotification(
                title: title,
                serviceId: 21,
                node: node,
                exactDate:
                    DateTime.now().add(const Duration(seconds: 2)),
                body: S.current.Notif_Update_watchList,
                channel: NotificationChannel.watching(),
              );
              showToast(S.current.NotifScheduled);
            },
          ),
          Padding(
            padding: EdgeInsets.only(top: 40, left: 30, right: 30),
            child: title(S.current.Notification_settings_warning, fontSize: 14),
          )
        ]),
      ],
    );
  }
}

const _nodeList = '''
[{
			"node": {
				"id": 53998,
				"title": "Bleach: Sennen Kessen-hen - Ketsubetsu-tan",
				"main_picture": {
					"medium": "https:\/\/cdn.myanimelist.net\/images\/anime\/1164\/138058.jpg",
					"large": "https:\/\/cdn.myanimelist.net\/images\/anime\/1164\/138058l.jpg"
				},
				"num_episodes": 13,
				"broadcast": {
					"day_of_the_week": "saturday",
					"start_time": "23:00"
				},
				"start_date": "2023-07-08",
				"alternative_titles": {
					"synonyms": [
						"Bleach: Thousand-Year Blood War Arc"
					],
					"en": "Bleach: Thousand-Year Blood War - The Separation",
					"ja": "BLEACH 千年血戦篇-訣別譚-"
				},
				"status": "currently_airing",
				"mean": 8.99,
				"num_list_users": 183459,
				"genres": [
					{
						"id": 1,
						"name": "Action"
					},
					{
						"id": 2,
						"name": "Adventure"
					},
					{
						"id": 10,
						"name": "Fantasy"
					},
					{
						"id": 27,
						"name": "Shounen"
					}
				],
				"media_type": "tv"
			}
		},
		{
			"node": {
				"id": 54898,
				"title": "Bungou Stray Dogs 5th Season",
				"main_picture": {
					"medium": "https:\/\/cdn.myanimelist.net\/images\/anime\/1161\/136691.jpg",
					"large": "https:\/\/cdn.myanimelist.net\/images\/anime\/1161\/136691l.jpg"
				},
				"num_episodes": 11,
				"broadcast": {
					"day_of_the_week": "wednesday",
					"start_time": "23:00"
				},
				"start_date": "2023-07-12",
				"alternative_titles": {
					"synonyms": [],
					"en": "Bungo Stray Dogs 5",
					"ja": "文豪ストレイドッグス"
				},
				"status": "currently_airing",
				"mean": 8.71,
				"num_list_users": 116786,
				"genres": [
					{
						"id": 1,
						"name": "Action"
					},
					{
						"id": 50,
						"name": "Adult Cast"
					},
					{
						"id": 7,
						"name": "Mystery"
					},
					{
						"id": 68,
						"name": "Organized Crime"
					},
					{
						"id": 42,
						"name": "Seinen"
					},
					{
						"id": 31,
						"name": "Super Power"
					},
					{
						"id": 37,
						"name": "Supernatural"
					}
				],
				"media_type": "tv"
			}
		},
		{
			"node": {
				"id": 51009,
				"title": "Jujutsu Kaisen 2nd Season",
				"main_picture": {
					"medium": "https:\/\/cdn.myanimelist.net\/images\/anime\/1792\/138022.jpg",
					"large": "https:\/\/cdn.myanimelist.net\/images\/anime\/1792\/138022l.jpg"
				},
				"num_episodes": 23,
				"broadcast": {
					"day_of_the_week": "thursday",
					"start_time": "23:56"
				},
				"start_date": "2023-07-06",
				"alternative_titles": {
					"synonyms": [
						"Sorcery Fight",
						"JJK"
					],
					"en": "",
					"ja": "呪術廻戦"
				},
				"status": "currently_airing",
				"mean": 8.82,
				"num_list_users": 570136,
				"genres": [
					{
						"id": 1,
						"name": "Action"
					},
					{
						"id": 10,
						"name": "Fantasy"
					},
					{
						"id": 23,
						"name": "School"
					},
					{
						"id": 27,
						"name": "Shounen"
					}
				],
				"media_type": "tv"
			}
		},
		{
			"node": {
				"id": 21,
				"title": "One Piece",
				"main_picture": {
					"medium": "https:\/\/cdn.myanimelist.net\/images\/anime\/6\/73245.jpg",
					"large": "https:\/\/cdn.myanimelist.net\/images\/anime\/6\/73245l.jpg"
				},
				"num_episodes": 0,
				"broadcast": {
					"day_of_the_week": "sunday",
					"start_time": "09:30"
				},
				"start_date": "1999-10-20",
				"alternative_titles": {
					"synonyms": [
						"OP"
					],
					"en": "One Piece",
					"ja": "ONE PIECE"
				},
				"status": "currently_airing",
				"mean": 8.7,
				"num_list_users": 2226902,
				"genres": [
					{
						"id": 1,
						"name": "Action"
					},
					{
						"id": 2,
						"name": "Adventure"
					},
					{
						"id": 10,
						"name": "Fantasy"
					},
					{
						"id": 27,
						"name": "Shounen"
					}
				],
				"media_type": "tv"
			}
		},
		{
			"node": {
				"id": 53716,
				"title": "Hirogaru Sky! Precure",
				"main_picture": {
					"medium": "https:\/\/cdn.myanimelist.net\/images\/anime\/1762\/135268.jpg",
					"large": "https:\/\/cdn.myanimelist.net\/images\/anime\/1762\/135268l.jpg"
				},
				"num_episodes": 0,
				"broadcast": {
					"day_of_the_week": "sunday",
					"start_time": "08:30"
				},
				"start_date": "2023-02-05",
				"alternative_titles": {
					"synonyms": [],
					"en": "Soaring Sky! Pretty Cure",
					"ja": "ひろがるスカイ！プリキュア"
				},
				"status": "currently_airing",
				"mean": 7.69,
				"num_list_users": 7517,
				"genres": [
					{
						"id": 1,
						"name": "Action"
					},
					{
						"id": 10,
						"name": "Fantasy"
					},
					{
						"id": 66,
						"name": "Mahou Shoujo"
					}
				],
				"media_type": "tv"
			}
		},
		{
			"node": {
				"id": 53127,
				"title": "Fate\/strange Fake: Whispers of Dawn",
				"main_picture": {
					"medium": "https:\/\/cdn.myanimelist.net\/images\/anime\/1220\/136619.jpg",
					"large": "https:\/\/cdn.myanimelist.net\/images\/anime\/1220\/136619l.jpg"
				},
				"num_episodes": 1,
				"start_date": "2023-07-02",
				"alternative_titles": {
					"synonyms": [],
					"en": "Fate\/strange Fake: Whispers of Dawn",
					"ja": "Fate\/strange Fake -Whispers of Dawn-"
				},
				"status": "finished_airing",
				"mean": 8.25,
				"num_list_users": 62936,
				"genres": [
					{
						"id": 1,
						"name": "Action"
					},
					{
						"id": 10,
						"name": "Fantasy"
					},
					{
						"id": 37,
						"name": "Supernatural"
					}
				],
				"media_type": "special"
			}
		},
		{
			"node": {
				"id": 49858,
				"title": "Shinigami Bocchan to Kuro Maid 2nd Season",
				"main_picture": {
					"medium": "https:\/\/cdn.myanimelist.net\/images\/anime\/1078\/136947.jpg",
					"large": "https:\/\/cdn.myanimelist.net\/images\/anime\/1078\/136947l.jpg"
				},
				"num_episodes": 12,
				"broadcast": {
					"day_of_the_week": "sunday",
					"start_time": "22:00"
				},
				"start_date": "2023-07-09",
				"alternative_titles": {
					"synonyms": [],
					"en": "The Duke of Death and His Maid Season 2",
					"ja": "死神坊ちゃんと黒メイド"
				},
				"status": "currently_airing",
				"mean": 7.7,
				"num_list_users": 61233,
				"genres": [
					{
						"id": 4,
						"name": "Comedy"
					},
					{
						"id": 74,
						"name": "Romantic Subtext"
					},
					{
						"id": 37,
						"name": "Supernatural"
					}
				],
				"media_type": "tv"
			}
		},
		{
			"node": {
				"id": 51916,
				"title": "Dekiru Neko wa Kyou mo Yuuutsu",
				"main_picture": {
					"medium": "https:\/\/cdn.myanimelist.net\/images\/anime\/1074\/136720.jpg",
					"large": "https:\/\/cdn.myanimelist.net\/images\/anime\/1074\/136720l.jpg"
				},
				"num_episodes": 13,
				"broadcast": {
					"day_of_the_week": "saturday",
					"start_time": "02:23"
				},
				"start_date": "2023-07-08",
				"alternative_titles": {
					"synonyms": [
						"Dekineko"
					],
					"en": "The Masterful Cat Is Depressed Again Today",
					"ja": "デキる猫は今日も憂鬱"
				},
				"status": "currently_airing",
				"mean": 7.59,
				"num_list_users": 63736,
				"genres": [
					{
						"id": 50,
						"name": "Adult Cast"
					},
					{
						"id": 51,
						"name": "Anthropomorphic"
					},
					{
						"id": 4,
						"name": "Comedy"
					},
					{
						"id": 37,
						"name": "Supernatural"
					}
				],
				"media_type": "tv"
			}
		},
		{
			"node": {
				"id": 51318,
				"title": "Hanma Baki: Son of Ogre 2nd Season",
				"main_picture": {
					"medium": "https:\/\/cdn.myanimelist.net\/images\/anime\/1800\/135847.jpg",
					"large": "https:\/\/cdn.myanimelist.net\/images\/anime\/1800\/135847l.jpg"
				},
				"num_episodes": 27,
				"start_date": "2023-07-26",
				"alternative_titles": {
					"synonyms": [
						"The Boy Fascinating the Fighting God 2"
					],
					"en": "Baki Hanma 2nd Season",
					"ja": "範馬刃牙 SON OF OGRE"
				},
				"status": "finished_airing",
				"mean": 8.04,
				"num_list_users": 55865,
				"genres": [
					{
						"id": 54,
						"name": "Combat Sports"
					},
					{
						"id": 58,
						"name": "Gore"
					},
					{
						"id": 27,
						"name": "Shounen"
					},
					{
						"id": 30,
						"name": "Sports"
					}
				],
				"media_type": "ona"
			}
		},
		{
			"node": {
				"id": 55692,
				"title": "Feng Ling Yu Xiu 2nd Season",
				"main_picture": {
					"medium": "https:\/\/cdn.myanimelist.net\/images\/anime\/1634\/136523.jpg",
					"large": "https:\/\/cdn.myanimelist.net\/images\/anime\/1634\/136523l.jpg"
				},
				"num_episodes": 12,
				"start_date": "2023-07-02",
				"alternative_titles": {
					"synonyms": [],
					"en": "Soulmate Adventure Season 2",
					"ja": "风灵玉秀 第二章"
				},
				"status": "currently_airing",
				"mean": 7.32,
				"num_list_users": 1013,
				"genres": [
					{
						"id": 1,
						"name": "Action"
					},
					{
						"id": 2,
						"name": "Adventure"
					},
					{
						"id": 17,
						"name": "Martial Arts"
					}
				],
				"media_type": "ona"
			}
		},
		{
			"node": {
				"id": 54398,
				"title": "Biohazard: Death Island",
				"main_picture": {
					"medium": "https:\/\/cdn.myanimelist.net\/images\/anime\/1348\/133200.jpg",
					"large": "https:\/\/cdn.myanimelist.net\/images\/anime\/1348\/133200l.jpg"
				},
				"num_episodes": 1,
				"start_date": "2023-07-07",
				"alternative_titles": {
					"synonyms": [],
					"en": "Resident Evil: Death Island",
					"ja": "バイオハザード：デスアイランド"
				},
				"status": "finished_airing",
				"mean": 6.67,
				"num_list_users": 5331,
				"genres": [
					{
						"id": 1,
						"name": "Action"
					},
					{
						"id": 14,
						"name": "Horror"
					},
					{
						"id": 24,
						"name": "Sci-Fi"
					}
				],
				"media_type": "movie"
			}
		},
		{
			"node": {
				"id": 49793,
				"title": "Azur Lane: Queen's Orders",
				"main_picture": {
					"medium": "https:\/\/cdn.myanimelist.net\/images\/anime\/1602\/133747.jpg",
					"large": "https:\/\/cdn.myanimelist.net\/images\/anime\/1602\/133747l.jpg"
				},
				"num_episodes": 2,
				"start_date": "2023-07-27",
				"alternative_titles": {
					"synonyms": [],
					"en": "",
					"ja": "アズールレーン Queen's Orders"
				},
				"status": "finished_airing",
				"mean": 6.9,
				"num_list_users": 5366,
				"genres": [
					{
						"id": 38,
						"name": "Military"
					},
					{
						"id": 24,
						"name": "Sci-Fi"
					},
					{
						"id": 27,
						"name": "Shounen"
					},
					{
						"id": 36,
						"name": "Slice of Life"
					}
				],
				"media_type": "ova"
			}
		},
		{
			"node": {
				"id": 8687,
				"title": "Doraemon (2005)",
				"main_picture": {
					"medium": "https:\/\/cdn.myanimelist.net\/images\/anime\/6\/23935.jpg",
					"large": "https:\/\/cdn.myanimelist.net\/images\/anime\/6\/23935l.jpg"
				},
				"num_episodes": 0,
				"broadcast": {
					"day_of_the_week": "friday",
					"start_time": "19:00"
				},
				"start_date": "2005-04-22",
				"alternative_titles": {
					"synonyms": [],
					"en": "",
					"ja": "ドラえもん (2005)"
				},
				"status": "currently_airing",
				"mean": 7.66,
				"num_list_users": 18846,
				"genres": [
					{
						"id": 51,
						"name": "Anthropomorphic"
					},
					{
						"id": 4,
						"name": "Comedy"
					},
					{
						"id": 15,
						"name": "Kids"
					},
					{
						"id": 24,
						"name": "Sci-Fi"
					},
					{
						"id": 27,
						"name": "Shounen"
					}
				],
				"media_type": "tv"
			}
		},
		{
			"node": {
				"id": 53859,
				"title": "Wan Sheng Jie 4",
				"main_picture": {
					"medium": "https:\/\/cdn.myanimelist.net\/images\/anime\/1567\/137044.jpg",
					"large": "https:\/\/cdn.myanimelist.net\/images\/anime\/1567\/137044l.jpg"
				},
				"num_episodes": 12,
				"start_date": "2023-07-05",
				"alternative_titles": {
					"synonyms": [
						"All Saints Street 4"
					],
					"en": "All Saints Street 4",
					"ja": "万圣街4"
				},
				"status": "finished_airing",
				"mean": 7.14,
				"num_list_users": 3213,
				"genres": [
					{
						"id": 4,
						"name": "Comedy"
					},
					{
						"id": 10,
						"name": "Fantasy"
					},
					{
						"id": 6,
						"name": "Mythology"
					}
				],
				"media_type": "ona"
			}
		}]
''';
