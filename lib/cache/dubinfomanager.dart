import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dailyanimelist/cache/cachemanager.dart';

class DubInfoManager {
  static final DubInfoManager _instance = DubInfoManager._internal();
  factory DubInfoManager() => _instance;
  DubInfoManager._internal();

  static const String _url = 'https://raw.githubusercontent.com/MAL-Dubs/MAL-Dubs/main/data/dubInfo.json';
  static const String _service = 'mal-dubs';
  static const String _key = 'dubInfo.json';
  static const int _cacheDurationSeconds = 60 * 60;

  List<int> _dubbedIds = [];
  List<int> _incompleteIds = [];

  Future<void> ensureLoaded() async {
    final cached = await CacheManager.instance.getValueForServiceAutoExpire(
      _service,
      _key,
      _cacheDurationSeconds,
    );

    if (cached != null) {
      _parseAndSet(cached);
      return;
    }

    try {
      final response = await http.get(Uri.parse(_url));
      if (response.statusCode == 200) {
        final body = response.body;
        await CacheManager.instance.setValueForServiceAutoExpireIn(
          _service,
          _key,
          body,
        );
        _parseAndSet(body);
      }
    } catch (_) { }
  }

  void _parseAndSet(String json) {
    try {
      final map = jsonDecode(json);
      _dubbedIds = (map['dubbed'] as List<dynamic>? ?? []).whereType<int>().toList();
      _incompleteIds = (map['incomplete'] as List<dynamic>? ?? []).whereType<int>().toList();
    } catch (_) {
      _dubbedIds = [];
      _incompleteIds = [];
    }
  }

  bool isDubbed(int id) => _dubbedIds.contains(id);
  bool isIncomplete(int id) => _incompleteIds.contains(id);
  bool hasAnyDub(int id) => isDubbed(id) || isIncomplete(id);
}
