import 'package:dal_commons/src/model/anime/animedetailed.dart';
import 'package:dal_commons/src/model/anime/myanimeliststatus.dart';
import 'package:dal_commons/src/model/global/node.dart';
import 'package:dal_commons/src/model/global/ranking.dart';
import 'package:dal_commons/src/model/manga/mangadetailed.dart';
import 'package:dal_commons/src/model/manga/mymangaliststatus.dart';
import 'package:dal_commons/src/constants/constant.dart';
import 'myliststatus.dart';

import 'package:json_annotation/json_annotation.dart';

class BaseNode {
  final Node? content;
  final Ranking? ranking;
  @JsonKey(ignore: true)
  MyListStatus? myListStatus;

  BaseNode({this.content, this.ranking, this.myListStatus});

  factory BaseNode.fromJson(Map<String, dynamic>? json,
      {String category = "anime"}) {
    MyAnimeListStatus? animeList;
    MyMangaListStatus? mangaList;
    Node? node;
    if (json != null) {
      try {
        animeList = MyAnimeListStatus.fromJson(json["list_status"]);
        if (animeList.numEpisodesWatched == null) throw Error();
      } catch (e) {
        animeList = null;
        try {
          mangaList = MyMangaListStatus.fromJson(json["list_status"]);
          if (mangaList.isRereading == null) throw Error();
        } catch (e) {
          mangaList = null;
        }
      }
      try {
        if (category.equals("anime")) {
          node = AnimeDetailed.fromJson(json["node"]);
        } else if (category.equals("manga")) {
          node = MangaDetailed.fromJson(json["node"]);
        }
      } catch (e) {}
    }

    return json != null
        ? BaseNode(
            myListStatus: animeList ?? mangaList ?? MyAnimeListStatus(),
            content: node ?? Node.fromJson(json["node"]),
            ranking: Ranking.fromJson(json["ranking"]))
        : BaseNode();
  }

  Map<String, dynamic> toJson() {
    return {
      "node": content?.toJson(),
      "ranking": ranking,
      "list_status": myListStatus
    };
  }
}
