import 'dart:convert';

import 'package:dal_commons/dal_commons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CachedUserProf {
  static CachedUserProf instance = new CachedUserProf();
  static SharedPreferences? pref;

  Future<bool> checkIfExists(String url) async {
    try {
      pref = pref ?? await SharedPreferences.getInstance();
      return pref!.containsKey(url);
    } catch (e) {
      logDal(e);
    }
    return false;
  }

  Future<UserProf?> getCachedUserProf(String url,
      {SharedPreferences? pref}) async {
    try {
      pref = pref ?? await SharedPreferences.getInstance();
      if (!(await checkIfExists(url))) {
        return null;
      }
      var userProf = UserProf.fromJson(jsonDecode(pref.getString(url) ?? "{}"));
      userProf.fromCache = true;
      return userProf;
    } catch (e) {
      logDal(e);
    }
    return null;
  }

  Future<bool> setCachedUserProf(String url, UserProf result,
      {SharedPreferences? pref}) async {
    try {
      pref = pref ?? await SharedPreferences.getInstance();

      result.fromCache = true;
      return await pref.setString(url, jsonEncode(result));
    } catch (e) {
      logDal(e);
    }
    return false;
  }
}
