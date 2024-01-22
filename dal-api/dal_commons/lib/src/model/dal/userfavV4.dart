import 'commonV4.dart';

class UserFavV4 implements DataUnion {
  List<JikanSubDetailed>? anime;
  List<JikanSubDetailed>? manga;
  List<CharactersFav>? characters;
  List<PeopleFav>? people;

  UserFavV4({this.anime, this.manga, this.characters, this.people});

  UserFavV4.fromJson(Map<String, dynamic>? json) {
    if (json == null) return;
    if (json['anime'] != null) {
      anime = [];
      json['anime'].forEach((v) {
        anime?.add(JikanSubDetailed.fromJson(v));
      });
    }
    if (json['manga'] != null) {
      manga = [];
      json['manga'].forEach((v) {
        manga?.add(JikanSubDetailed.fromJson(v));
      });
    }
    if (json['characters'] != null) {
      characters = [];
      json['characters'].forEach((v) {
        characters?.add(CharactersFav.fromJson(v));
      });
    }
    if (json['people'] != null) {
      people = [];
      json['people'].forEach((v) {
        people?.add(PeopleFav.fromJson(v));
      });
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['anime'] = anime?.map((v) => v.toJson()).toList();
    data['manga'] = manga?.map((v) => v.toJson()).toList();
    data['characters'] = characters?.map((v) => v.toJson()).toList();
    data['people'] = people?.map((v) => v.toJson()).toList();
    return data;
  }
}

class JikanSubDetailed {
  String? type;
  int? startYear;
  int? malId;
  String? url;
  Images? images;
  String? title;

  JikanSubDetailed(
      {this.type,
      this.startYear,
      this.malId,
      this.url,
      this.images,
      this.title});

  JikanSubDetailed.fromJson(Map<String, dynamic>? json) {
    if (json == null) return;
    type = json['type'];
    startYear = json['start_year'];
    malId = json['mal_id'];
    url = json['url'];
    images = json['images'] != null ? Images.fromJson(json['images']) : null;
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['start_year'] = startYear;
    data['mal_id'] = malId;
    data['url'] = url;
    data['images'] = images?.toJson();
    data['title'] = title;
    return data;
  }
}

class CharactersFav {
  int? malId;
  String? url;
  Images? images;
  String? name;
  String? type;
  String? title;

  CharactersFav(
      {this.malId, this.url, this.images, this.name, this.type, this.title});

  CharactersFav.fromJson(Map<String, dynamic>? json) {
    if (json == null) return;
    malId = json['mal_id'];
    url = json['url'];
    images = json['images'] != null ? Images.fromJson(json['images']) : null;
    name = json['name'];
    type = json['type'];
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['mal_id'] = malId;
    data['url'] = url;
    data['images'] = images?.toJson();
    data['name'] = name;
    data['type'] = type;
    data['title'] = title;
    return data;
  }
}

class PeopleFav {
  int? malId;
  String? url;
  Images? images;
  String? name;

  PeopleFav({this.malId, this.url, this.images, this.name});

  PeopleFav.fromJson(Map<String, dynamic>? json) {
    if (json == null) return;
    malId = json['mal_id'];
    url = json['url'];
    images = json['images'] != null ? Images.fromJson(json['images']) : null;
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['mal_id'] = malId;
    data['url'] = url;
    data['images'] = images?.toJson();
    data['name'] = name;
    return data;
  }
}
