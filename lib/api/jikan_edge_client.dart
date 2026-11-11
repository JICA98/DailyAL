import 'dart:convert';

import 'package:dailyanimelist/api/jikan_edge_statistics_adapter.dart';
import 'package:dailyanimelist/api/jikan_models.dart';
import 'package:http/http.dart' as http;

/// HTTP client for the jikan-edge API.
///
/// This client is intentionally separate from [CredMal.jikanV4]: migrating one
/// feature must not redirect other Jikan integrations.
class JikanEdgeClient {
  static const String baseUrl = 'https://jikan.lucashdo.com/v1';
  static const Duration defaultTimeout = Duration(seconds: 10);

  final http.Client _httpClient;
  final Duration _timeout;

  JikanEdgeClient({
    http.Client? httpClient,
    Duration timeout = defaultTimeout,
  })  : _httpClient = httpClient ?? http.Client(),
        _timeout = timeout;

  /// Fetches anime score statistics and adapts the edge response for DailyAL.
  Future<JikanAnimeStatistics> getAnimeStatistics(int animeId) async {
    if (animeId <= 0) {
      throw ArgumentError.value(animeId, 'animeId', 'Must be a positive ID.');
    }

    final uri = Uri.parse('$baseUrl/anime/$animeId/statistics');
    late final http.Response response;
    try {
      response = await _httpClient
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(_timeout);
    } on TimeoutException catch (error) {
      throw JikanEdgeApiException(
        message: 'The jikan-edge request timed out.',
        cause: error,
      );
    } on http.ClientException catch (error) {
      throw JikanEdgeApiException(
        message: 'The jikan-edge request failed.',
        cause: error,
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _errorFromResponse(response);
    }

    // Let FormatException propagate for an invalid successful response body.
    final dynamic decoded = jsonDecode(response.body);
    return JikanEdgeStatisticsAdapter.fromResponse(decoded);
  }

  JikanEdgeApiException _errorFromResponse(http.Response response) {
    String? code;
    String? message;
    try {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is Map && decoded['error'] is Map) {
        final error = decoded['error'] as Map;
        code = error['code']?.toString();
        message = error['message']?.toString();
      }
    } on FormatException {
      // Some HTTP failures may not have a JSON body. Preserve the status either way.
    }

    return JikanEdgeApiException(
      statusCode: response.statusCode,
      code: code,
      message: message ?? 'jikan-edge returned HTTP ${response.statusCode}.',
    );
  }
}

/// A non-success response or transport failure from jikan-edge.
class JikanEdgeApiException implements Exception {
  final int? statusCode;
  final String? code;
  final String message;
  final Object? cause;

  const JikanEdgeApiException({
    this.statusCode,
    this.code,
    required this.message,
    this.cause,
  });

  @override
  String toString() {
    final status = statusCode == null ? '' : ' (HTTP $statusCode)';
    final errorCode = code == null ? '' : ' [$code]';
    return 'JikanEdgeApiException$errorCode$status: $message';
  }
}
