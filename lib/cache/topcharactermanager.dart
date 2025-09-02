import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dailyanimelist/cache/cachemanager.dart';

class TopChar {
  final int id;
  final int favorites;
  final String? name;
  const TopChar({required this.id, required this.favorites, this.name});
}

/// Fetches & caches the latest Top MAL characters (>=100 favorites).
/// Data source: https://github.com/Joelis57/TopMalCharacters (raw in /data)
class TopCharactersManager {
  static final TopCharactersManager _i = TopCharactersManager._internal();
  factory TopCharactersManager() => _i;
  TopCharactersManager._internal();

  static const String _service = 'topmalcharacters';
  static const String _base = 'https://raw.githubusercontent.com/Joelis57/TopMalCharacters/main/data';
  static const List<String> _candidateFiles = <String>[
    'top_characters.min.json',
    'top_characters.json',
  ];
  static const int _cacheDurationSeconds = 60 * 60; // 1 hour

  bool _loaded = false;
  final Map<int, TopChar> _byId = <int, TopChar>{};
  List<int> _sortedIds = const [];

  bool get isLoaded => _loaded;

  Future<void> ensureLoaded({bool force = false}) async {
    if (!force && _loaded && _byId.isNotEmpty) return;

    final cached = await CacheManager.instance.getValueForServiceAutoExpire(
      _service,
      _cacheKey(),
      _cacheDurationSeconds,
    );
    if (!force && cached != null && cached.isNotEmpty) {
      _parseAndSet(cached);
      return;
    }

    for (final file in _candidateFiles) {
      final url = '$_base/$file';
      try {
        final resp = await http.get(Uri.parse(url));
        if (resp.statusCode == 200 && resp.body.isNotEmpty) {
          await CacheManager.instance.setValueForServiceAutoExpireIn(
            _service,
            _cacheKey(),
            resp.body,
          );
          _parseAndSet(resp.body);
          return;
        }
      } catch (_) {/* try next */}
    }
    _loaded = true;
  }

  int? getFavoriteCount(int id) => _byId[id]?.favorites;

  List<int> get topIds => _sortedIds;

  Map<int, int> asFavoritesMap() =>  {for (final e in _byId.entries) e.key: e.value.favorites};

  // Helpers

  static String _cacheKey() => 'top_characters.json';

  void _parseAndSet(String body) {
    final Map<int, TopChar> byId = <int, TopChar>{};
    List<int> sorted = <int>[];

    try {
      final rows = jsonDecode(body) as List<dynamic>;

      for (final r in rows) {
        if (r is! Map<String, dynamic>) continue;

        final id = _asInt(r['mal_id']);
        final fav = _asInt(r['favorites']);
        if (id == null || fav == null) continue;

        byId[id] = TopChar(
          id: id,
          favorites: fav,
          name: r['name'] is String ? r['name'] as String : null,
        );
      }

      final List<TopChar> topList = byId.values.toList()
        ..sort((a, b) => b.favorites.compareTo(a.favorites));
      sorted = topList.map((e) => e.id).toList();
    } catch (_) {
    }

    _byId
      ..clear()
      ..addAll(byId);
    _sortedIds = List.unmodifiable(sorted);
    _loaded = true;
}

  int? _asInt(dynamic v) {
    if (v is int) return v;
    if (v is String) return int.tryParse(v);
    return null;
  }
}
