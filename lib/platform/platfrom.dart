import 'package:dal_commons/dal_commons.dart';
import 'package:flutter/services.dart';

class PlatformMethods {
  static const platform = MethodChannel('com.teen.dailyanimelist/app');

  static Future<void> setAppName({String appName = "DailyAnimeList"}) async {
    try {
      await platform.invokeMethod('setAppName', {'appName': appName});
    } on PlatformException catch (e) {
      logDal(e.message);
    }
  }
}
