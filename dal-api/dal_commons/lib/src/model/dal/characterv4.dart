import 'commonV4.dart';

class CharacterV4Result {
  CharacterV4Data? data;

  CharacterV4Result({this.data});

  CharacterV4Result.fromJson(Map<String, dynamic>? json) {
    if (json == null) return;
    data = json['data'] != null
        ? CharacterV4Data.fromJson(json['data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['data'] = this.data?.toJson();
    return data;
  }
}

class CharacterV4Data implements DataUnion {
  int ?malId;
  String ?url;
  Images ?images;
  String ?name;
  String ?nameKanji;
  List<String>? nicknames;
  int? favorites;
  String ?about;
  List<AnimeRole>? anime;
  List<MangaRole>? manga;
  List<Voices>? voices;

  CharacterV4Data(
      {this.malId,
      this.url,
      this.images,
      this.name,
      this.nameKanji,
      this.nicknames,
      this.favorites,
      this.about,
      this.anime,
      this.manga,
      this.voices});

  CharacterV4Data.fromJson(Map<String, dynamic>? json) {
    if (json == null) return;
    malId = json['mal_id'];
    url = json['url'];
    images =
        json['images'] != null ? Images.fromJson(json['images']) : null;
    name = json['name'];
    nameKanji = json['name_kanji'];
    nicknames = json['nicknames'].cast<String>();
    favorites = json['favorites'];
    about = json['about'];
    if (json['anime'] != null) {
      anime = [];
      json['anime'].forEach((v) {
        anime?.add(AnimeRole.fromJson(v));
      });
    }
    if (json['manga'] != null) {
      manga = [];
      json['manga'].forEach((v) {
        manga?.add(MangaRole.fromJson(v));
      });
    }
    if (json['voices'] != null) {
      voices = [];
      json['voices'].forEach((v) {
        voices?.add(Voices.fromJson(v));
      });
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['mal_id'] = malId;
    data['url'] = url;
    data['images'] = images?.toJson();
    data['name'] = name;
    data['name_kanji'] = nameKanji;
    data['nicknames'] = nicknames;
    data['favorites'] = favorites;
    data['about'] = about;
    data['anime'] = anime?.map((v) => v.toJson()).toList();
    data['manga'] = manga?.map((v) => v.toJson()).toList();
    data['voices'] = voices?.map((v) => v.toJson()).toList();
    return data;
  }
}
