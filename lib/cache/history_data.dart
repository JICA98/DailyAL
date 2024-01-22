import 'dart:collection';

import 'package:dailyanimelist/util/streamutils.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:flutter/material.dart';

enum HistoryDataType {
  query,
  anime,
  manga,
}

const _listLimit = {
  HistoryDataType.query: 7,
  HistoryDataType.anime: 24,
  HistoryDataType.manga: 24,
};

class HistoryData with ToJson {
  List<String> queryHistory;
  List<Node> recentAnime;
  List<Node> recentManga;
  HistoryData({this.queryHistory = const [], this.recentAnime = const [], this.recentManga = const []});

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'queryHistory': queryHistory,
      'recentAnime': recentAnime,
      'recentManga': recentManga,
    };
  }

  static HistoryData fromJson(Map<String, dynamic>? map) {
    if (map == null)
      return HistoryData(
        queryHistory: [],
        recentAnime: [],
        recentManga: [],
      );
    return HistoryData(
      queryHistory: (map['queryHistory'] ?? <String>[])
          .map<String>((e) => e.toString())
          .toList(),
      recentAnime: (map['recentAnime'] ?? <Node>[])
          .map<AnimeDetailed>((e) => AnimeDetailed.fromJson(e))
          .toList(),
      recentManga: (map['recentManga'] ?? <Node>[])
          .map<MangaDetailed>((e) => MangaDetailed.fromJson(e))
          .toList(),
    );
  }

  static void setHistory<T>({
    T? value,
    bool remove = false,
    bool removeAll = false,
    required HistoryDataType dataType,
  }) =>
      StreamUtils.i.addData<HistoryData>(
        StreamType.search_page,
        (oldData) {
          final listAtTask = switchCase(dataType, {
            [HistoryDataType.query]: (_) => oldData.queryHistory,
            [HistoryDataType.anime]: (_) => oldData.recentAnime,
            [HistoryDataType.manga]: (_) => oldData.recentManga,
          });
          if (removeAll) {
            listAtTask?.clear();
          } else {
            listAtTask?.removeWhere((e) {
              if (value is Node && e is Node) return e.id == value.id;
              return e == value;
            });
            if (!remove && value != null) {
              listAtTask?.insert(0, value);
              if (listAtTask!.length > _listLimit[dataType]!) {
                listAtTask.removeLast();
              }
            }
          }
          return oldData;
        },
      );
}
