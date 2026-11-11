import 'dart:async';

import 'package:dailyanimelist/api/jikan_edge_client.dart';
import 'package:dailyanimelist/api/jikan_edge_statistics_adapter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('JikanEdgeStatisticsAdapter', () {
    test('maps edge status and score fields into the existing UI model', () {
      final result = JikanEdgeStatisticsAdapter.fromResponse({
        'data': {
          'status': {
            'inProgress': 120,
            'completed': 340,
            'onHold': 12,
            'dropped': 8,
            'planned': 90,
            'total': 570,
          },
          'scores': [
            {'score': 10, 'votes': 80, 'percentage': 40.5},
            {'score': 9, 'votes': 60, 'percentage': 30},
          ],
          'fetchedAt': '2026-11-11T00:00:00.000Z',
        },
        'meta': {
          'cached': true,
          'stale': false,
          'refreshFailed': false,
          'fetchedAt': '2026-11-11T00:00:00.000Z',
        },
      });

      expect(result.watching, 120);
      expect(result.completed, 340);
      expect(result.onHold, 12);
      expect(result.dropped, 8);
      expect(result.planToWatch, 90);
      expect(result.total, 570);
      expect(result.scores, hasLength(2));
      expect(result.scores![0].score, 10);
      expect(result.scores![0].votes, 80);
      expect(result.scores![0].percentage, 40.5);
      // The adapter retains the API's score ordering.
      expect(result.scores![1].score, 9);
    });

    test('preserves an empty score list', () {
      final result = JikanEdgeStatisticsAdapter.fromResponse({
        'data': {
          'status': {
            'inProgress': null,
            'completed': null,
            'onHold': null,
            'dropped': null,
            'planned': null,
            'total': null,
          },
          'scores': <dynamic>[],
          'fetchedAt': '2026-11-11T00:00:00.000Z',
        },
        'meta': <String, dynamic>{},
      });

      expect(result.scores, isEmpty);
    });

    test('keeps absent and nullable score fields null', () {
      final result = JikanEdgeStatisticsAdapter.fromResponse({
        'data': {
          'status': {'inProgress': null},
          'scores': [
            {'score': null, 'votes': null, 'percentage': null},
            <String, dynamic>{},
          ],
        },
        'meta': <String, dynamic>{},
      });

      expect(result.watching, isNull);
      expect(result.completed, isNull);
      expect(result.scores, hasLength(2));
      expect(result.scores![0].score, isNull);
      expect(result.scores![0].votes, isNull);
      expect(result.scores![0].percentage, isNull);
      expect(result.scores![1].score, isNull);
    });

    test('accepts integer and double JSON numbers without truncating fractions', () {
      final result = JikanEdgeStatisticsAdapter.fromResponse({
        'data': {
          'status': {'inProgress': 12.0},
          'scores': [
            {'score': 9.0, 'votes': 50.0, 'percentage': 42},
            {'score': 8.5, 'votes': 2.5, 'percentage': 1.25},
          ],
        },
        'meta': <String, dynamic>{},
      });

      expect(result.watching, 12);
      expect(result.scores![0].score, 9);
      expect(result.scores![0].votes, 50);
      expect(result.scores![0].percentage, 42.0);
      expect(result.scores![1].score, isNull);
      expect(result.scores![1].votes, isNull);
      expect(result.scores![1].percentage, 1.25);
    });

    test('rejects malformed success envelopes instead of inventing data', () {
      expect(
        () => JikanEdgeStatisticsAdapter.fromResponse({'meta': {}}),
        throwsFormatException,
      );
      expect(
        () => JikanEdgeStatisticsAdapter.fromResponse({
          'data': {'scores': 'not-a-list'},
        }),
        throwsFormatException,
      );
    });
  });

  group('JikanEdgeClient', () {
    test('requests the edge statistics route and adapts its response', () async {
      Uri? requestedUri;
      final client = JikanEdgeClient(
        httpClient: MockClient((request) async {
          requestedUri = request.url;
          return http.Response(
            '{"data":{"status":{"inProgress":1,"completed":2,"onHold":0,"dropped":0,"planned":3,"total":6},"scores":[{"score":8,"votes":25,"percentage":75.5}],"fetchedAt":"2026-11-11T00:00:00.000Z"},"meta":{"cached":true,"stale":false,"refreshFailed":false,"fetchedAt":"2026-11-11T00:00:00.000Z"}}',
            200,
          );
        }),
      );

      final result = await client.getAnimeStatistics(123);

      expect(requestedUri.toString(),
          'https://jikan.lucashdo.com/v1/anime/123/statistics');
      expect(result.scores!.single.score, 8);
      expect(result.scores!.single.votes, 25);
      expect(result.scores!.single.percentage, 75.5);
    });

    test('preserves the error envelope for non-2xx responses', () async {
      final client = JikanEdgeClient(
        httpClient: MockClient((_) async => http.Response(
              '{"error":{"code":"NOT_FOUND","message":"Anime not found.","requestId":"req-1"}}',
              404,
            )),
      );

      await expectLater(
        client.getAnimeStatistics(123),
        throwsA(
          isA<JikanEdgeApiException>()
              .having((error) => error.statusCode, 'statusCode', 404)
              .having((error) => error.code, 'code', 'NOT_FOUND')
              .having((error) => error.message, 'message', 'Anime not found.'),
        ),
      );
    });

    test('reports malformed JSON in a successful response', () async {
      final client = JikanEdgeClient(
        httpClient: MockClient((_) async => http.Response('{invalid', 200)),
      );

      await expectLater(client.getAnimeStatistics(123), throwsFormatException);
    });

    test('wraps network failures', () async {
      final client = JikanEdgeClient(
        httpClient: MockClient((_) => Future<http.Response>.error(
              http.ClientException('Connection failed'),
            )),
      );

      await expectLater(
        client.getAnimeStatistics(123),
        throwsA(isA<JikanEdgeApiException>().having(
            (error) => error.cause, 'cause', isA<http.ClientException>())),
      );
    });

    test('wraps request timeouts', () async {
      final client = JikanEdgeClient(
        timeout: const Duration(milliseconds: 1),
        httpClient: MockClient((_) async {
          await Future<void>.delayed(const Duration(milliseconds: 20));
          return http.Response('{}', 200);
        }),
      );

      await expectLater(
        client.getAnimeStatistics(123),
        throwsA(isA<JikanEdgeApiException>().having(
            (error) => error.cause, 'cause', isA<TimeoutException>())),
      );
    });

    test('rejects non-positive anime IDs before making a request', () async {
      final client = JikanEdgeClient(
        httpClient: MockClient((_) async => http.Response('{}', 200)),
      );

      await expectLater(client.getAnimeStatistics(0), throwsArgumentError);
    });
  });
}
