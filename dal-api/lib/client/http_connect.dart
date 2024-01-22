import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dal_commons/dal_commons.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:retry/retry.dart';

class HttpConnect {
  static const _options = RetryOptions(maxAttempts: 8);
  static const _retryDuration = Duration(seconds: 10);

  static Future<http.Response> retryGet(
    String url,
    Map<String, String> headers,
  ) async {
    logDal('hitting -> $url');
    final response = await _options.retry(
      // Make a GET request
      () => http.get(Uri.parse(url), headers: headers).timeout(_retryDuration),
      // Retry on SocketException or TimeoutException
      retryIf: (e) {
        logDal('retrying... on $e');
        return e is SocketException || e is TimeoutException;
      },
    );
    return response;
  }

  static Future<http.Response> retryGetNoH(String url) => retryGet(url, {});

  static Future<Map<String, dynamic>?> retryGetChecked(
    String url,
    Map<String, String> headers,
  ) async {
    var response = await retryGet(url, headers);
    if (response.statusCode != 200) {
      logDal(response.body);
      return null;
    } else {
      return jsonDecode(response.body);
    }
  }

  static Future<T?> htmlPage<T>(
    String url,
    dynamic Function(Document) fromHtml, {
    Map<String, String>? headers,
  }) async {
    var response = await retryGet(url, headers ?? {});
    if (response.statusCode != 200) {
      logDal(response.body);
      return null;
    } else {
      final parsed = fromHtml(parse(response.body));
      if (parsed is List) {
        return parsed as T;
      } else {
        return toJson(parsed) as T;
      }
    }
  }

  static Map<String, dynamic>? toJson(dynamic data) {
    try {
      return data?.toJson();
    } catch (e) {
      if (e is NoSuchMethodError) {
        return data;
      } else {
        return null;
      }
    }
  }
}
