import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dailyanimelist/api/auth/authresp.dart';
import 'package:dailyanimelist/api/credmal.dart';
import 'package:dailyanimelist/main.dart';
import 'package:dailyanimelist/cache/cachemanager.dart';
import 'package:dailyanimelist/user/user.dart';
import 'package:dailyanimelist/widgets/web/c_webview.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;

import '../../constant.dart';

class MalAuth {
  String _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890-._~';
  Random _rnd = Random.secure();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  static String codeChallenge(int length) {
    return new MalAuth().getRandomString(length);
  }

  /// Standard Http POST Request with Auth Header
  static Future<http.Response> httpPostAsync(String url,
      {Map<String, String>? headers, Map<String, String>? body}) {
    if (headers == null) {
      headers = new Map();
    }
    body = body ?? {};
    headers["Accept"] = "application/json";
    headers["Content-Type"] = "application/x-www-form-urlencoded";

    return http.post(Uri.parse(url), headers: headers, body: body);
  }

  static bool checkIfTokenExpired(AuthResponse authResponse) {
    DateTime expiryDate = authResponse.createdTime!
        .add(Duration(seconds: authResponse.expiresIn!));
    return expiryDate.isBefore(DateTime.now());
  }

  static Future<void> refreshToken() async {
    String url = CredMal.otokenEndPoint;

    Map<String, String> body = {
      "client_id": CredMal.clientId,
      "client_secret": CredMal.clientSecret,
      "grant_type": "refresh_token",
      "redirect_uri": CredMal.redirectUri,
      "refresh_token": user.authResponse?.refreshToken ?? ''
    };

    try {
      var response = await httpPostAsync(url, body: body);
      AuthResponse authResponse =
          AuthResponse.fromJson(jsonDecode(response.body));
      user.authResponse = authResponse;
      user.status = AuthStatus.AUTHENTICATED;
      user.setIntance();
    } catch (e) {
      logDal(e);
    }
  }

  static void handleSignIn() async {
    if (user.status == AuthStatus.INPROGRESS) return;
    user.status = AuthStatus.INPROGRESS;
    user.updateUserStatus();
    oAuthSignIn((error) {
      user.status = AuthStatus.UNAUTHENTICATED;
      user.updateUserStatus();
      logDal(error);
    });
  }

  static Future<bool> onCodeReceived(String code, String cc) async {
    String url = CredMal.otokenEndPoint;

    Map<String, String> body = {
      "client_id": CredMal.clientId,
      "client_secret": CredMal.clientSecret,
      "grant_type": "authorization_code",
      "code": code,
      "code_verifier": cc,
      "redirect_uri": CredMal.redirectUri
    };

    try {
      var response = await httpPostAsync(url, body: body);
      AuthResponse authResponse =
          AuthResponse.fromJson(jsonDecode(response.body));
      user.authResponse = authResponse;
      user.status = AuthStatus.AUTHENTICATED;
      user.updateUserStatus();
      await user.setIntance();
      return true;
    } catch (e) {
      user.status = AuthStatus.UNAUTHENTICATED;
      user.updateUserStatus();
      logDal(e);
      return false;
    }
  }

  static void oAuthSignIn(ValueChanged<Error> gotError) async {
    String cc = codeChallenge(127);
    String url = CredMal.oauthEndPoint +
        "?response_type=code&client_id=" +
        CredMal.clientId +
        "&code_challenge=" +
        cc +
        "&state=OAuthLogin&redirect_uri=" +
        CredMal.redirectUri;
    await CacheManager.instance.setValue('cc', cc);

    // Use flutter_web_auth_2 for desktop platforms (Linux, Windows, macOS)
    if (!kIsWeb &&
        (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
      try {
        logDal('Starting OAuth with flutter_web_auth_2 for desktop');
        final result = await FlutterWebAuth2.authenticate(
          url: url,
          callbackUrlScheme: CredMal.callbackUrlScheme,
          options: const FlutterWebAuth2Options(
            useWebview: false, // Use system browser with localhost callback
          ),
        );

        logDal('OAuth callback received: $result');
        final uri = Uri.parse(result);
        final code = uri.queryParameters['code'];

        if (code != null) {
          await onCodeReceived(code, cc);
        } else {
          logDal('No code received from OAuth callback');
          user.status = AuthStatus.UNAUTHENTICATED;
          user.updateUserStatus();
        }
      } catch (e) {
        logDal('OAuth error on desktop: $e');
        user.status = AuthStatus.UNAUTHENTICATED;
        user.updateUserStatus();
      }
    } else {
      // For mobile platforms, use the existing webview approach
      launchWebView(url);
    }
  }

  static Future<void> signOut() async {
    user.authResponse = new AuthResponse();
    user.status = AuthStatus.UNAUTHENTICATED;
    await user.setIntance();
    await CacheManager.instance.resetData();
  }

  static Future<bool> checkIfSignIn(Uri? uri) async {
    String? _code = uri?.queryParameters.tryAt("code");
    if (_code != null) {
      String? cc = await CacheManager.instance.getValue('cc');
      if (cc != null) {
        return onCodeReceived(_code, cc);
      }
    }
    return false;
  }
}
