import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/enums.dart';
import 'package:dal_commons/dal_commons.dart';

enum Distribution {
  genre,
  studio_author,
  mediaType,
  source,
}

class ScoreItem {
  int count;
  int sum;
  double mean;
  final MalGenre? genre;
  final String? status;
  final AnimeStudio? studio;
  final MangaAuthors? author;
  final String? mediaType;
  final String? source;
  ScoreItem(
    this.count,
    this.sum,
    this.mean, {
    this.genre,
    this.status,
    this.studio,
    this.author,
    this.mediaType,
    this.source,
  });
}

class ScoreDiffNode implements Comparable<ScoreDiffNode> {
  static final validStatus = ['reading', 'watching', 'completed'];
  final double scoreDiff;
  final BaseNode baseNode;
  ScoreDiffNode(this.scoreDiff, this.baseNode);

  @override
  int compareTo(ScoreDiffNode other) {
    return other.scoreDiff.compareTo(this.scoreDiff);
  }
}

class UserInsights {
  final Map<int, Map<String, int>> statusScoreDistributionMap = {};
  // final Map<String, Map<String, ScoreItem>> genreStatusScoreMap = {};
  // final Map<String, Map<String, ScoreItem>> studioAuthorStatusScoreMap = {};
  // final Map<String, Map<String, ScoreItem>> mediaTypeStatusScoreMap = {};
  // final Map<String, Map<String, ScoreItem>> sourceStatusScoreMap = {};
  final Map<Distribution, Map<String, Map<String, ScoreItem>>> distributionMap =
      {};
  final Set<ScoreDiffNode> iLikeItTheyHateIt = SplayTreeSet();
  final Set<int> _idSet = {};
  int? unrankedShows;
  final List<BaseNode> _basenodes;
  final String category;

  static Iterable<MapEntry<String, Map<String, ScoreItem>>> _getEmptyMap(
      String category) {
    return (category.equals('anime') ? myAnimeStatusMap : myMangaStatusMap)
        .keys
        .map((e) => MapEntry(e, {}));
  }

  UserInsights(this._basenodes, this.category) {
    unrankedShows = 0;
    Map<int, Map<String, int>> _statusScoreDistributionMap = {};

    final Map<Distribution, Map<String, Map<String, ScoreItem>>>
        _distributionMap = Map.fromEntries(Distribution.values
            .map((e) => MapEntry(e, Map.fromEntries(_getEmptyMap(category)))));
    Map<String, int> getInnerMap() => Map.fromEntries(
        (category.equals('anime') ? myAnimeStatusMap : myMangaStatusMap)
            .keys
            .map((e) => MapEntry(e, 0)));
    for (final item in _basenodes) {
      final myListStatus = item.myListStatus;
      final node = item.content;
      String? statusKey = null;
      int? scoreKey = null;
      List<MalGenre>? _genres;
      List<AnimeStudio>? studios;
      List<MangaAuthors>? authors;
      String? mediaType;
      String? source;
      int? id = null;
      double? mean = null;

      if (myListStatus is MyAnimeListStatus) {
        statusKey = myListStatus.status;
        scoreKey = myListStatus.score;
      } else if (myListStatus is MyMangaListStatus) {
        statusKey = myListStatus.status;
        scoreKey = myListStatus.score;
      }
      if (node is AnimeDetailed) {
        // meanKey = node.mean;
        _genres = node.genres;
        id = node.id;
        mean = node.mean;
        studios = node.studios;
        mediaType = node.mediaType;
        source = node.source;
      } else if (node is MangaDetailed) {
        // meanKey = node.mean;
        _genres = node.genres;
        mean = node.mean;
        id = node.id;
        authors = node.authors;
        mediaType = node.mediaType;
      }

      if (id != null) {
        if (_idSet.lookup(id) != null) {
          return;
        } else {
          _idSet.add(id);
        }
      }

      if (scoreKey != null) {
        if (scoreKey == 0 && unrankedShows != null) {
          unrankedShows = unrankedShows! + 1;
          continue;
        }
        if (mean != null &&
            mean > 0 &&
            mean < 7.05 &&
            scoreKey > 7 &&
            ScoreDiffNode.validStatus.contains(statusKey)) {
          iLikeItTheyHateIt.add(ScoreDiffNode(scoreKey - mean, item));
        }
        if (statusKey != null) {
          if (!nullOrEmpty(_genres)) {
            _genres?.forEach((genre) {
              final itemName = convertGenre(genre, category);
              if (itemName.notEquals('?')) {
                addToGlobalScoreMap(_distributionMap[Distribution.genre]!,
                    statusKey!, itemName, scoreKey!,
                    genre: genre);
              }
            });
          }
          if (!nullOrEmpty(studios)) {
            studios?.forEach((studio) {
              final itemName = studio.name;
              if (itemName != null) {
                addToGlobalScoreMap(
                    _distributionMap[Distribution.studio_author]!,
                    statusKey!,
                    itemName,
                    scoreKey!,
                    studio: studio);
              }
            });
          }
          if (!nullOrEmpty(authors)) {
            authors?.forEach((author) {
              final itemName = author.author?.id?.toString();
              if (itemName != null) {
                addToGlobalScoreMap(
                    _distributionMap[Distribution.studio_author]!,
                    statusKey!,
                    itemName,
                    scoreKey!,
                    author: author);
              }
            });
          }
          if (mediaType != null) {
            addToGlobalScoreMap(_distributionMap[Distribution.mediaType]!,
                statusKey, mediaType, scoreKey,
                mediaType: mediaType);
          }
          if (source != null) {
            addToGlobalScoreMap(_distributionMap[Distribution.source]!,
                statusKey, source, scoreKey,
                source: source);
          }
          _statusScoreDistributionMap[scoreKey] ??= getInnerMap();
          _statusScoreDistributionMap[scoreKey]![statusKey] ??= 0;
          _statusScoreDistributionMap[scoreKey]![statusKey] =
              _statusScoreDistributionMap[scoreKey]![statusKey]! + 1;
        }
      }
    }

    for (var i = 1; i <= 10; i++) {
      _statusScoreDistributionMap.putIfAbsent(i, () => getInnerMap());
    }
    statusScoreDistributionMap.addEntries(
        _statusScoreDistributionMap.entries.sorted((a, b) => b.key - a.key));

    _distributionMap.forEach((key, value) {
      Map<String, Map<String, ScoreItem>> _value = {};
      _value.addEntries(
        value.entries.map(
          (f) => MapEntry(
            f.key,
            Map.fromEntries(f.value.entries.map(_calculateMeanScore)),
          ),
        ),
      );
      distributionMap[key] = value;
    });
  }

  static void addToGlobalScoreMap(
    Map<String, Map<String, ScoreItem>> map,
    String statusKey,
    String itemName,
    int scoreKey, {
    MalGenre? genre,
    AnimeStudio? studio,
    MangaAuthors? author,
    String? mediaType,
    String? source,
  }) {
    final _scoreMap = map[statusKey] ?? {};
    var _scoreItem = _scoreMap[itemName];
    if (_scoreItem == null) {
      _scoreItem = ScoreItem(1, scoreKey, 0.0,
          genre: genre,
          status: statusKey,
          author: author,
          studio: studio,
          mediaType: mediaType,
          source: source);
    } else {
      _scoreItem.count++;
      _scoreItem.sum += scoreKey;
    }
    _scoreMap[itemName] = _scoreItem;
    map[statusKey] = _scoreMap;
  }

  MapEntry<String, ScoreItem> _calculateMeanScore(
    MapEntry<String, ScoreItem> e,
  ) {
    final _scoreItem = e.value;
    final mean = _scoreItem.sum / _scoreItem.count;
    _scoreItem.mean = (mean.isNaN || mean.isInfinite) ? 0.0 : mean;
    return e;
  }
}
