import 'dart:convert';

import 'package:dailyanimelist/api/credmal.dart';
import 'package:dailyanimelist/api/dalapi.dart';
import 'package:dailyanimelist/api/maluser.dart';
import 'package:dailyanimelist/util/error/error_details.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class ErrorReporting {
  ErrorReporting._();
  static String? _versionNo;
  static void init() {
    _initPackageInfo();
    FlutterError.onError = (details) async {
      FlutterError.presentError(details);
      final config = await DalApi.i.dalConfigFuture;
      final loggingEnabled = (config)?.errorLogging;
      final includeSilent = !details.silent || (config?.includeSilent ?? false);
      if (loggingEnabled != null && loggingEnabled && includeSilent) {
        UserProf? prof;
        try {
          prof = await MalUser.getUserInfo(fromCache: true);
        } catch (e) {}
        await _pushError(_toError(details, prof?.name).toJson());
      }
    };
  }

  static void _initPackageInfo() {
    try {
      PackageInfo.fromPlatform().then((value) {
        _versionNo = value.version;
      });
    } catch (e) {}
  }

  static ErrorDetails _toError(FlutterErrorDetails details, String? name) {
    return ErrorDetails(
      details.stack.toString(),
      details.exception.toString(),
      details.library,
      details.silent.toString(),
      details.summary.toString(),
      DateTime.now().toIso8601String(),
      name,
      _versionNo,
    );
  }

  static Future<void> _pushError(Map<String, dynamic> data) async {
    try {
      final url =
          '${CredMal.errorReportingUrl}/errorReporting${kDebugMode ? 'Dev' : ''}.json';
      final response = await http.post(Uri.parse(url), body: jsonEncode(data));
      logDal(response);
    } catch (e) {
      logDal(e);
    }
  }
}
