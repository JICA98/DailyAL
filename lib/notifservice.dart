import 'dart:convert';
import 'dart:io';

import 'package:dailyanimelist/api/dalapi.dart';
import 'package:dailyanimelist/api/malapi.dart';
import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/enums.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/main.dart';
import 'package:dailyanimelist/screens/openscreen.dart';
import 'package:dailyanimelist/widgets/user/contentlistwidget.dart';
import 'package:dal_commons/commons.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:notification_permissions/notification_permissions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationChannel {
  final String channelName;
  final String channelId;
  final String channelDescription;
  NotificationChannel._({
    required this.channelName,
    required this.channelId,
    required this.channelDescription,
  });
  static NotificationChannel planToWatch() {
    return NotificationChannel._(
      channelName: 'PlanToWatch List Anime',
      channelId: 'PlanToWatch',
      channelDescription: S.current.PlanToWatchDesc,
    );
  }

  static NotificationChannel watching() {
    return NotificationChannel._(
      channelName: 'Watching List Anime',
      channelId: 'Watching',
      channelDescription: S.current.WatchingDesc,
    );
  }
}

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  final _weekMap = {
    "monday": 1,
    "tuesday": 2,
    "wednesday": 3,
    "thursday": 4,
    "friday": 5,
    "saturday": 6,
    "sunday": 7,
  };

  Future<void> init() async {
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_stat_name');

    tz.initializeTimeZones();

    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid, iOS: null, macOS: null);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveBackgroundNotificationResponse:
          onDidReceiveBackgroundNotificationResponse,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
  }

  Future<Node?> onSelectWhileAsleep() async {
    try {
      var details = await NotificationService()
          .flutterLocalNotificationsPlugin
          .getNotificationAppLaunchDetails();
      if (details?.didNotificationLaunchApp ?? false) {
        logDal('Notif launched dal');
        Node _node = Node.fromJson(
            jsonDecode(details?.notificationResponse?.payload ?? '{}'));
        logDal(_node.toJson());
        if (_node.id != null) {
          return _node;
        }
      } else {
        logDal('auto dal');
      }
    } catch (e) {
      logDal(e);
    }

    return null;
  }

  static void selectNotification(String? payload) async {
    try {
      Node _node = Node.fromJson(jsonDecode(payload ?? '{}'));

      if (_node != null) {
        logDal("--> payload works");
        gotoPage(
            context: MyApp.navigatorKey.currentContext!,
            newPage: OpenScreen(notifNode: _node));
      } else {
        logDal("--> null payload $_node");
      }
    } catch (e) {
      logDal("--> payload error $e");
    }
  }

  void scheduledNotifcation() async {
    var validMyListStatus = ["watching", "plan_to_watch"];
    var nowDate = DateTime.now();
    if (user.pref.notifPref.daySubscribed != null) {
      if (nowDate.difference(user.pref.notifPref.daySubscribed!).inDays < 1) {
        return;
      }
    }
    SearchResult? seasonResult;
    Map<int, ScheduleData>? scheduleData;
    try {
      final results = await Future.wait([
        MalApi.getCurrentSeason(
          fields: [
            "my_list_status",
            "broadcast",
            "status",
            'alternative_titles'
          ],
          sortType: SortType.AnimeScore,
          fromCache: true,
          limit: 500,
        ),
        DalApi.i.scheduleForMalIds
      ]);
      seasonResult = results[0] as SearchResult;
      scheduleData = results[1] as Map<int, ScheduleData>;
    } catch (e) {
      logDal(e);
    }

    if (seasonResult?.data == null) return;
    scheduleData ??= {};

    for (var baseNode in seasonResult!.data!) {
      var node = baseNode.content;
      node!.title = getNodeTitle(node);
      if (node.myListStatus is MyAnimeListStatus) {
        var myListStatus = node?.myListStatus as MyAnimeListStatus;
        if (myListStatus?.status == null) {
          continue;
        }
        if (!validMyListStatus.contains(myListStatus.status)) {
          continue;
        }
        if (myListStatus.status!.equals("watching")) {
          if (!user.pref.notifPref.onWatchingListUpdated) {
            continue;
          }
        }

        if (myListStatus.status!.equals("plan_to_watch")) {
          if (!user.pref.notifPref.onPTWGoesToWatching) {
            continue;
          }
        }
        String body;
        NotificationChannel channel;
        if (myListStatus.status!.equals("watching")) {
          body = S.current.Notif_Update_watchList;
          channel = NotificationChannel.watching();
        } else {
          body = S.current.Notif_Update_PTW;
          channel = NotificationChannel.planToWatch();
        }

        if (scheduleData.containsKey(node.id)) {
          _scheduleUsingLiveChart(
            scheduleData[node.id]!,
            myListStatus,
            node,
            nowDate,
            body,
            channel,
          );
        } else {
          _scheduleUsingMal(
            node?.broadcast,
            myListStatus,
            node,
            nowDate,
            body,
            channel,
          );
        }
      }
    }

    user.pref.notifPref.daySubscribed = nowDate;
    user.setIntance();
  }

  void _scheduleUsingMal(
    Broadcast? broadcast,
    MyAnimeListStatus myListStatus,
    Node node,
    DateTime nowDate,
    String body,
    NotificationChannel channel,
  ) {
    if (broadcast?.startTime != null &&
        broadcast?.dayOfTheWeek != null &&
        myListStatus.status != null &&
        node.status!.equals('currently_airing') &&
        _weekMap.containsKey(broadcast!.dayOfTheWeek)) {
      var weekday = _weekMap[broadcast.dayOfTheWeek]!;
      var timeSplit = broadcast.startTime!.split(":");
      var hours = int.tryParse(timeSplit[0])!;
      var mins = int.tryParse(timeSplit[1])!;
      String title = "${node.title} - ${S.current.A_new_episode_is_out}";
      var nextDate = nowDate.nextDate(weekday);
      nextDate = nextDate.add(Duration(
          hours: hours - 9, minutes: mins + nowDate.timeZoneOffset.inMinutes));

      showNotification(
        serviceId: 21,
        title: title,
        body: body,
        node: node,
        exactDate: nextDate,
        channel: channel,
      );
    }
  }

  void _scheduleUsingLiveChart(
    ScheduleData scheduleData,
    MyAnimeListStatus myListStatus,
    Node node,
    DateTime nowDate,
    String body,
    NotificationChannel channel,
  ) {
    String title = "Ep: ${scheduleData.episode} of ${node.title} is out!";

    var nextDate =
        DateTime.fromMillisecondsSinceEpoch(scheduleData.timestamp! * 1000);

    showNotification(
      serviceId: 21,
      title: title,
      body: body,
      node: node,
      exactDate: nextDate,
      channel: channel,
    );
  }

  static final iconPath =
      'https://play-lh.googleusercontent.com/ZR5oY99qg9mdL9EGDlP3uKDeu0icE3wCGFor3IaAL0xVXXXYQciXavnUVvXFzcQx59w=w240-h480-rw';

  void showNotification({
    int episode = 1,
    int serviceId = 21,
    Node? node,
    String? title,
    String? body,
    DateTime? exactDate,
    Duration addTime = const Duration(milliseconds: 300),
    required NotificationChannel channel,
  }) async {
    if (node?.id == null) {
      return;
    }

    if (exactDate != null && exactDate.difference(DateTime.now()).isNegative) {
      return;
    }

    logDal(
        "${serviceId * 100 + node!.id!} -> $title - $body - scheduled for ${exactDate ?? DateTime.now().add(addTime)}");

    String? imagePath;
    FilePathAndroidBitmap? largeIconBitmap;
    if (node.mainPicture?.large != null && node.title != null) {
      imagePath = await _downloadAndSaveFile(node.mainPicture!.large!,
          node.title!.getFormattedTitleForHtml(true)!);
    }

    StyleInformation? styleInfo;
    if (imagePath != null) {
      largeIconBitmap = FilePathAndroidBitmap(imagePath);
      if (user.pref.notifPref.preferLargeImage) {
        styleInfo = BigPictureStyleInformation(
          FilePathAndroidBitmap(imagePath),
          largeIcon: largeIconBitmap,
          contentTitle: title,
          htmlFormatContentTitle: true,
          summaryText: body,
          htmlFormatSummaryText: true,
          hideExpandedLargeIcon: true,
        );
      }
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      serviceId * 100 + node.id!,
      _replaceTags(title) ?? "DailyAnimeList - ${S.current.Episode_Reminder}",
      _replaceTags(body) ??
          "${node.title} - Episode $episode ${S.current.just_got_aired}!!",
      exactDate != null
          ? tz.TZDateTime.from(exactDate, tz.local)
          : tz.TZDateTime.now(tz.local).add(addTime),
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.channelId,
          channel.channelName,
          channelDescription: channel.channelDescription,
          priority: Priority.high,
          styleInformation: styleInfo,
          icon: 'ic_stat_name',
          largeIcon: largeIconBitmap,
          category: AndroidNotificationCategory.reminder,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: jsonEncode(node.toJson()),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  String? _replaceTags(String? body) {
    if (body == null) return null;
    return body
        .replaceAll('<b>', '')
        .replaceAll('</b>', '')
        .replaceAll('<i>', '')
        .replaceAll('</i>', '');
  }

  Future<String?> _downloadAndSaveFile(String url, String fileName) async {
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final String filePath = '${directory.path}/$fileName';
      final http.Response response = await http.get(Uri.parse(url));
      final File file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      return filePath;
    } catch (e) {
      logDal(e);
      return null;
    }
  }

  Future<void> askForPermission() async {
    if (user.pref.notifPref.onPTWGoesToWatching ||
        user.pref.notifPref.onWatchingListUpdated) {
      final currStatus =
          await NotificationPermissions.getNotificationPermissionStatus();
      if (currStatus == PermissionStatus.denied) {
        final allowed = await showConfirmationDialog(
          alertTitle: S.current.ConfirmNotifPerm,
          desc: S.current.ConfirmNotifPermDesc,
          context: MyApp.navigatorKey.currentContext!,
        );
        if (allowed) {
          await NotificationPermissions.requestNotificationPermissions(
              openSettings: false);
        } else {
          user.pref.notifPref.onPTWGoesToWatching = false;
          user.pref.notifPref.onWatchingListUpdated = false;
          user.setIntance();
        }
      }
    }
  }

  static void onDidReceiveBackgroundNotificationResponse(
      NotificationResponse details) {
    logDal(details);
  }

  static void onDidReceiveNotificationResponse(NotificationResponse details) {
    selectNotification(details.payload);
  }
}
