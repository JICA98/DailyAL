import 'dart:collection';

import 'package:dal_api/handlers/environemt.dart';
import 'package:dal_commons/dal_commons.dart';

class SharedPreferences {
  static const sk = 'data';
  static const tableName = 'daily-al-cache';
  final _internalMap = HashMap();

  Future<Map<String, dynamic>?> getMap(String key) async {
    return _internalMap[key];
  }

  Future<bool> setMap(String key, Map<String, dynamic>? data) async {
    if (data == null) {
      return false;
    }
    _internalMap[key] = data;
    return true;
  }
}
