import 'package:dal_commons/src/model/anime/broadcast.dart';
import 'package:dal_commons/src/model/anime/detailedmixin.dart';
import 'package:dal_commons/src/model/anime/myanimeliststatus.dart';
import 'package:dal_commons/src/model/global/picture.dart';
import 'package:dal_commons/src/model/manga/mymangaliststatus.dart';

import 'myliststatus.dart';

class Node with AnimeDetailedMixin {
  int? id;
  String? title;
  final String? status;
  Picture? mainPicture;
  final MyListStatus? myListStatus;
  final Broadcast? broadcast;
  @override
  final int? numEpisodes;
  bool? fromCache;
  String? url;
  final String? nodeCategory;

  Node({
    this.id,
    this.mainPicture,
    this.title,
    this.fromCache,
    this.url,
    this.status,
    this.broadcast,
    this.numEpisodes,
    this.myListStatus,
    this.nodeCategory,
  });

  factory Node.fromJson(Map<String, dynamic>? json) {
    MyAnimeListStatus? animeList;
    MyMangaListStatus? mangaList;
    if (json != null && json["my_list_status"] != null) {
      try {
        animeList = MyAnimeListStatus.fromJson(json["my_list_status"]);
        if (animeList.numEpisodesWatched == null) throw Error();
      } catch (e) {
        animeList = null;
        try {
          mangaList = MyMangaListStatus.fromJson(json["my_list_status"]);
          if (mangaList.isRereading == null) throw Error();
        } catch (e) {
          mangaList = null;
        }
      }
    }
    return json != null
        ? Node(
            url: json["url"],
            nodeCategory: json["nodeCategory"],
            fromCache: json["from_cache"] ?? false,
            id: json["id"],
            title: json["title"],
            numEpisodes: json["num_episodes"],
            status: json.containsKey("status") ? json["status"] : null,
            broadcast: Broadcast.fromJson(
                json.containsKey("broadcast") ? json["broadcast"] : null),
            myListStatus: animeList ?? mangaList ?? MyAnimeListStatus(),
            mainPicture: Picture.fromJson(json["main_picture"]))
        : Node();
  }

  Map<String, dynamic> toJson() {
    return {
      "url": url,
      "from_cache": fromCache ?? false,
      "id": id,
      "title": title,
      "broadcast": broadcast,
      "num_episodes": numEpisodes,
      "my_list_status": myListStatus,
      'nodeCategory': nodeCategory,
      "main_picture": mainPicture?.toJson()
    };
  }
}
