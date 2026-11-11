import 'package:dailyanimelist/api/jikan_models.dart';

/// Converts jikan-edge's camelCase statistics payload into DailyAL's existing
/// statistics model. The provider-specific wire format stays out of the Jikan
/// v4 `fromJson` parser.
class JikanEdgeStatisticsAdapter {
  const JikanEdgeStatisticsAdapter._();

  static JikanAnimeStatistics fromResponse(dynamic response) {
    if (response is! Map) {
      throw const FormatException('Expected a jikan-edge response object.');
    }

    final dynamic rawData = response['data'];
    if (rawData is! Map) {
      throw const FormatException('Expected a jikan-edge data object.');
    }

    final status = _optionalMap(rawData['status'], 'status');
    final rawScores = rawData['scores'];
    if (rawScores != null && rawScores is! List) {
      throw const FormatException('Expected data.scores to be a list or null.');
    }

    return JikanAnimeStatistics(
      watching: _integer(status?['inProgress']),
      completed: _integer(status?['completed']),
      onHold: _integer(status?['onHold']),
      dropped: _integer(status?['dropped']),
      planToWatch: _integer(status?['planned']),
      total: _integer(status?['total']),
      scores: rawScores == null
          ? null
          : (rawScores as List)
              .map((entry) => _scoreFromJson(entry))
              .toList(growable: false),
    );
  }

  static Map? _optionalMap(dynamic value, String field) {
    if (value == null) return null;
    if (value is! Map) {
      throw FormatException('Expected data.$field to be an object or null.');
    }
    return value;
  }

  static ScoreStatistics _scoreFromJson(dynamic value) {
    if (value is! Map) {
      throw const FormatException('Expected each score entry to be an object.');
    }

    return ScoreStatistics(
      score: _integer(value['score']),
      votes: _integer(value['votes']),
      percentage: _decimal(value['percentage']),
    );
  }

  /// Converts JSON numeric values only when they represent a whole number.
  /// Missing, null, and non-integral values remain null rather than being
  /// rounded or truncated into a different statistic.
  static int? _integer(dynamic value) {
    if (value is! num || !value.isFinite || value % 1 != 0) return null;
    return value.toInt();
  }

  static double? _decimal(dynamic value) {
    if (value is! num || !value.isFinite) return null;
    return value.toDouble();
  }
}
