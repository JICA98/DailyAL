import 'dart:convert';

import 'package:dailyanimelist/api/auth/authresp.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/theme/theme.dart';
import 'package:dailyanimelist/theme/themedata.dart';
import 'package:dailyanimelist/user/hompagepref.dart';
import 'package:dailyanimelist/user/userpref.dart';
import 'package:dailyanimelist/util/homepageutils.dart';
import 'package:dal_api/dal_local_api.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl_standalone.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AuthStatus { UNAUTHENTICATED, AUTHENTICATED, INPROGRESS }

class User with ChangeNotifier {
  AuthStatus status;
  AuthResponse? authResponse;
  UserTheme theme;
  UserThemeV2? themeV2;
  String? themeNameV2;
  UserPreferences pref;

  User({
    this.authResponse,
    required this.pref,
    this.status = AuthStatus.UNAUTHENTICATED,
    required this.theme,
    this.themeV2,
    this.themeNameV2,
  });

  void updateUserStatus() {
    notifyListeners();
  }

  static Future<User> getInstance() async {
    var sharedPref = await SharedPreferences.getInstance();
    User newUser =
        User.fromJson(jsonDecode(sharedPref.getString("user") ?? "{}"));
    if (!kIsWeb) {
      newUser.authResponse = await _getAuthResponse();
    }
    return newUser;
  }

  static Future<AuthResponse> _getAuthResponse() async {
    var ss = FlutterSecureStorage();
    return AuthResponse.fromJson(
        jsonDecode(await ss.read(key: "authResponse") ?? "{}"));
  }

  Future<User> runPostInitialization() async {
    await setLocale(this);
    await initializeDateFormatting(this.pref.userLanguage, null);
    await updateFirstTimePref(this);
    return this;
  }

  static Future<void> setLocale(User newUser) async {
    var languageCode = "en_US";
    if (newUser.pref.userLanguage.equals("sys")) {
      var locale = await findSystemLocale();
      if (getLanguageCodes(S.delegate.supportedLocales)
          .contains(Intl.shortLocale(locale))) {
        languageCode = locale;
      }
      newUser.pref.hpApiPrefList =
          HomePageUtils().translateTitle(newUser.pref.hpApiPrefList);
    } else {
      languageCode = newUser.pref.userLanguage;
    }
    await S.load(Locale.fromSubtags(languageCode: languageCode));
  }

  static List<String> getLanguageCodes(List<Locale> locales) =>
      locales.map((e) => e.languageCode).toList();

  Future<void> setIntance({
    bool shouldNotify = false,
    bool updateAuth = true,
  }) async {
    var sharedPref = await SharedPreferences.getInstance();
    var ss = FlutterSecureStorage();
    await sharedPref.setString("user", jsonEncode(this));
    if (!kIsWeb && updateAuth) {
      await ss.write(key: "authResponse", value: jsonEncode(this.authResponse));
    }
    logDal("Updated User Instance -> ${this.toJson()}");
    if (shouldNotify) {
      notifyListeners();
    }
  }

  Future<void> setMetadata() {
    return setIntance(shouldNotify: false, updateAuth: false);
  }

  Future<void> refreshAuthStatus() async {
    final authResponse = await _getAuthResponse();
    this.authResponse = authResponse;
    status = authResponse.accessToken == null
        ? AuthStatus.UNAUTHENTICATED
        : AuthStatus.AUTHENTICATED;
    await setIntance(shouldNotify: false, updateAuth: false);
  }

  static Future<void> updateFirstTimePref(User newUser) async {
    final userPref = newUser.pref;
    if (userPref.hpApiPrefList.isEmpty) {
      userPref.hpApiPrefList = defaultHPPrefList;
    }
    if (!userPref.firstTime) {
      bool hasChanged = false;
      if (userPref.firstTimePref.bg) {
        newUser.pref.showBg = true;
        newUser.pref.firstTimePref.bg = false;
        hasChanged = true;
      }
      if (userPref.firstTimePref.news) {
        newUser.pref.hpApiPrefList.insert(0, defaultHPPrefList[0]);
        newUser.pref.firstTimePref.news = false;
        hasChanged = true;
      }
      if (userPref.firstTimePref.themeV3) {
        newUser.pref.firstTimePref.themeV3 = false;
        hasChanged = _migrateV2ToV3(newUser);
      }
      if (hasChanged) {
        await newUser.setIntance();
      }
    }
  }

  static AuthStatus getAuthStatus(int index) {
    final status = AuthStatus.values.elementAt(index);
    return status == AuthStatus.INPROGRESS
        ? AuthStatus.UNAUTHENTICATED
        : status;
  }

  static User fromJson(Map<String, dynamic>? json) {
    UserTheme userTheme;
    if (json == null || !json.containsKey('theme_v3')) {
      userTheme = UserTheme.defaultTheme();
    } else {
      userTheme = UserTheme.fromJson(json['theme_v3']);
    }
    if (json != null) {
      return User(
        theme: userTheme,
        pref: UserPreferences.fromJson(json["preferences"]),
        status: getAuthStatus(json["auth_status"] ?? 0),
        themeV2: UserThemeV2.fromJson(json['theme_v2'] ?? {}),
        themeNameV2: json['theme_name_v2'],
      );
    } else {
      return User(
        pref: UserPreferences.fromJson(null),
        theme: userTheme,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "auth_status": status.index,
      "preferences": pref.toJson(),
      "theme_v3": theme.toJson(),
    };
  }

  static bool _migrateV2ToV3(User newUser) {
    final v2 = newUser.themeV2;
    final v2Name = newUser.themeNameV2;
    bool hasChanged = false;
    if (v2Name != null) {
      final convertedTheme = UserThemeData.v2ToV3ThemeMap[v2Name];
      if (convertedTheme != null) {
        newUser.theme..color = convertedTheme;
        hasChanged = true;
      }
      if (v2 != null) {
        final color = v2.buttonColor;
        if (color != null && v2Name.equals('custom')) {
          newUser.theme.userDefinedColors['${color}'] = color;
          newUser.theme.color = '${color}';
          return true;
        }
        if (v2.bg != null) {
          int index = backgroundMap.values.toList().indexOf(v2.bg!);
          if (index != -1) {
            newUser.theme.background = backgroundMap.keys.toList()[index];
          }
        }
      }
    }
    return hasChanged;
  }
}
