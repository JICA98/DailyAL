import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class Api {
  static final Api _internal = Api._();
  static Api i = _internal;
  static const _configUrl =
      'https://raw.githubusercontent.com/JICA98/DailyAL/psycho/config';
  late Future<Config?> _dalConfigFuture;

  Future<Config?> get dalConfigFuture async {
    return _dalConfigFuture;
  }

  Api._() {
    _dalConfigFuture = _getDalConfigFuture();
  }

  Future<Config> _getDalConfigFuture() async {
    const refUrl = '$_configUrl/serverConfigV3${kDebugMode ? 'Dev' : ''}.json';
    return Config.fromJson(
      jsonDecode((await Dio().get(refUrl)).data),
    );
  }
}

class Config {
  String? discordLink;
  String? dalAPIUrl;
  String? telegramLink;

  Config({
    this.discordLink,
    this.dalAPIUrl,
    this.telegramLink,
  });

  factory Config.fromJson(Map<String, dynamic> json) {
    return Config(
      discordLink: json['discordLink'],
      dalAPIUrl: json['dalAPIUrl'],
      telegramLink: json['telegramLink'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'discordLink': discordLink,
      'dalAPIUrl': dalAPIUrl,
      'telegramLink': telegramLink,
    };
  }
}
