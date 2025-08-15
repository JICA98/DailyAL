import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dailyanimelist/cache/cachemanager.dart';
import 'package:dailyanimelist/main.dart' show user;

class DubInfoManager {
  static final DubInfoManager _instance = DubInfoManager._internal();
  factory DubInfoManager() => _instance;
  DubInfoManager._internal();

  static const String _base = 'https://raw.githubusercontent.com/Joelis57/MyDubList/main/final';
  static const String _service = 'mydublist';
  static const int _cacheDurationSeconds = 60 * 60; // 1 hour

  String? _loadedLanguage;
  List<int> _dubbedIds = [];
  List<int> _incompleteIds = [];

  /// Ensure dub info for the language is loaded.
  /// If [language] is null, uses user.pref.dubLanguage (fallback: 'english').
  /// Set [force] to true to bypass cached value even if present.
  Future<void> ensureLoaded({String? language, bool force = false}) async {
    final lang = (language ?? _preferredLanguage()).toLowerCase();

    // If already loaded and not forced, skip
    if (!force && _loadedLanguage == lang && (_dubbedIds.isNotEmpty || _incompleteIds.isNotEmpty)) {
      return;
    }

    final cacheKey = _cacheKey(lang);

    // Try cached first
    if (!force) {
      final cached = await CacheManager.instance.getValueForServiceAutoExpire(
        _service,
        cacheKey,
        _cacheDurationSeconds,
      );
      if (cached != null) {
        _parseAndSet(cached, lang);
        return;
      }
    }

    // Fetch from network
    try {
      final url = _fileUrl(lang);
      final resp = await http.get(Uri.parse(url));
      if (resp.statusCode == 200) {
        final body = resp.body;
        await CacheManager.instance.setValueForServiceAutoExpireIn(
          _service,
          cacheKey,
          body,
        );
        _parseAndSet(body, lang);
        return;
      }
    } catch (_) {}

    // If we fail to load, keep prior data (if any), but record language
    _loadedLanguage = lang;
  }

  bool isDubbed(int id) => _dubbedIds.contains(id);
  bool isIncomplete(int id) => _incompleteIds.contains(id);
  bool hasAnyDub(int id) => isDubbed(id) || isIncomplete(id);

  // ===== Helpers =====

  static String _fileUrl(String lang) => '$_base/dubbed_${lang}.json';
  static String _cacheKey(String lang) => 'dubInfo_${lang}.json';

  String _preferredLanguage() {
    try {
      final v = user.pref.dubLanguage;
      if (v.isNotEmpty) return v;
    } catch (_) {}
    return 'english';
  }

  void _parseAndSet(String jsonStr, String lang) {
    try {
      final decoded = jsonDecode(jsonStr);
      if (decoded is Map<String, dynamic>) {
        _dubbedIds = _toIntList(decoded['dubbed']);
        _incompleteIds = _toIntList(decoded['incomplete']);
      } else {
        _dubbedIds = [];
        _incompleteIds = [];
      }
    } catch (_) {
      _dubbedIds = [];
      _incompleteIds = [];
    }
    _loadedLanguage = lang;
  }

  List<int> _toIntList(dynamic v) {
    if (v is List) {
      final out = <int>[];
      for (final e in v) {
        if (e is int) {
          out.add(e);
        } else if (e is String) {
          final p = int.tryParse(e);
          if (p != null) out.add(p);
        }
      }
      return out;
    }
    return const <int>[];
  }
}
