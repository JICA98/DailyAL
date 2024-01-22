// import 'package:dailyanimelist/main.dart';
// import 'package:flutter/material.dart';

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> launchWebView(String url) async {
  try {
    if (!kIsWeb && Platform.isAndroid) {
      await FlutterWebBrowser.openWebPage(url: url);
    } else {
      await launchUrl(Uri.parse(url));
    }
  } catch (e) {
    debugPrint(e.toString());
  }
}
