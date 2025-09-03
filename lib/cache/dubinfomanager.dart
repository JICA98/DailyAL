import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dailyanimelist/cache/cachemanager.dart';
import 'package:dailyanimelist/main.dart' show user;

class DubInfoManager {
  static final DubInfoManager _instance = DubInfoManager._internal();
  factory DubInfoManager() => _instance;
  DubInfoManager._internal();

  static const String _baseRoot = 'https://raw.githubusercontent.com/Joelis57/MyDubList/main/dubs/confidence';
  static const String _service = 'mydublist';
  static const int _cacheDurationSeconds = 60 * 60; // 1 hour

  String? _loadedLanguage;
  String? _loadedConfidenceSlug; // low / normal / high / very-high

  List<int> _dubbedIds = [];
  List<int> _partialIds = [];

  /// Ensure dub info is loaded for [language] and the confidence implied by [minSourceCount].
  /// - If [language] is null, uses user.pref.dubLanguage (fallback 'english').
  /// - If [minSourceCount] is null, uses user.pref.dubMinSourceCount (fallback 1).
  /// - Set [force] to true to bypass cache retrieval.
  Future<void> ensureLoaded({
    String? language,
    int? minSourceCount,
    bool force = false,
  }) async {
    final lang = (language ?? _preferredLanguage()).toLowerCase();
    final minCount = minSourceCount ?? _preferredMinSourceCount();
    final slug = _confidenceSlug(minCount);

    // If already loaded for same tuple, skip
    if (!force &&
        _loadedLanguage == lang &&
        _loadedConfidenceSlug == slug &&
        (_dubbedIds.isNotEmpty || _partialIds.isNotEmpty)) {
      return;
    }

    final cacheKey = _cacheKey(lang, slug);

    // Try cache
    if (!force) {
      final cached = await CacheManager.instance.getValueForServiceAutoExpire(
        _service,
        cacheKey,
        _cacheDurationSeconds,
      );
      if (cached != null) {
        _parseAndSet(cached, lang, slug);
        return;
      }
    }

    // Fetch network
    try {
      final url = _fileUrl(lang, slug);
      final resp = await http.get(Uri.parse(url));
      if (resp.statusCode == 200) {
        final body = resp.body;

        await CacheManager.instance.setValueForServiceAutoExpireIn(
          _service,
          cacheKey,
          body,
        );

        _parseAndSet(body, lang, slug);
        return;
      }
    } catch (_) {}

    _loadedLanguage = lang;
    _loadedConfidenceSlug = slug;
  }

  // Public

  bool isDubbed(int id) => _dubbedIds.contains(id);
  bool isPartial(int id) => _partialIds.contains(id);
  bool hasAnyDub(int id) => isDubbed(id) || isPartial(id);

  // Helpers

  static String _fileUrl(String lang, String slug) =>
      '$_baseRoot/$slug/dubbed_${lang}.json';

  static String _cacheKey(String lang, String slug) =>
      'dubInfo_${lang}_$slug.json';

  String _preferredLanguage() {
    try {
      final v = user.pref.dubLanguage;
      if (v.isNotEmpty) return v;
    } catch (_) {}
    return 'english';
  }

  int _preferredMinSourceCount() {
    try {
      final parsed = int.tryParse(user.pref.dubMinSourceCount);
      if (parsed != null && parsed >= 1) return parsed;
    } catch (_) {}
    return 1; // default to Low
  }

  String _confidenceSlug(int minSourceCount) {
    if (minSourceCount <= 1) return 'low';
    if (minSourceCount == 2) return 'normal';
    if (minSourceCount == 3) return 'high';
    return 'very-high'; // 4+
  }

  void _parseAndSet(String jsonStr, String lang, String slug) {
    try {
      final decoded = jsonDecode(jsonStr);
      if (decoded is Map<String, dynamic>) {
        _dubbedIds = _toIntList(decoded['dubbed']);
        _partialIds = _toIntList(decoded['partial']);
      } else {
        _dubbedIds = [];
        _partialIds = [];
      }
    } catch (_) {
      _dubbedIds = [];
      _partialIds = [];
    }
    _loadedLanguage = lang;
    _loadedConfidenceSlug = slug;
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
