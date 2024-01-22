import 'package:dal_commons/src/model/dal/characterv4.dart';
import 'package:dal_commons/src/model/dal/animevideo.dart';
import 'package:dal_commons/src/model/dal/clubV4.dart';
import 'package:dal_commons/src/model/dal/clubinfov4.dart';
import 'package:dal_commons/src/model/dal/friendv4.dart';
import 'package:dal_commons/src/model/dal/peoplev4.dart';
import 'package:dal_commons/src/model/dal/recomm_dal.dart';
import 'package:dal_commons/src/model/dal/userfavV4.dart';
import 'package:dal_commons/src/model/dal/userprofv4.dart';
import 'package:dal_commons/src/model/dal/userupdateV4.dart';

mixin ToJson {
  Map<String, dynamic> toJson();
}

mixin DataUnion {
  Map<String, dynamic> toJson();
  static DataUnion? fromJson(DataUnionType type, dynamic json) {
    switch (type) {
      case DataUnionType.character:
        return CharacterV4Data.fromJson(json);
      case DataUnionType.people:
        return PeopleV4Data.fromJson(json);
      case DataUnionType.user:
        return UserProfileV4.fromJson(json);
      case DataUnionType.about:
        return About.fromJson(json);
      case DataUnionType.friend:
        return FriendV4List.fromList(json as List);
      case DataUnionType.club:
        return ClubV4List.fromList(json as List);
      case DataUnionType.favorites:
        return UserFavV4.fromJson(json);
      case DataUnionType.userupdates:
        return UserUpdateList.fromJson(json);
      case DataUnionType.clubinfo:
        return Club.fromJson(json);
      case DataUnionType.animevideo:
        return AnimeVideoV4.fromJson(json);
      case DataUnionType.recomm_base:
        return RecomBaseList.fromList(json as List);
      default:
        return null;
    }
  }
}

enum DataUnionType {
  user,
  character,
  people,
  about,
  friend,
  club,
  favorites,
  userupdates,
  clubinfo,
  animevideo,
  recomm_base,
}

class JikanV4Result<T extends DataUnion> {
  T? data;
  Pagination? pagination;

  JikanV4Result({this.data, this.pagination});

  JikanV4Result.fromJson(DataUnionType type, Map<String, dynamic>? json) {
    if (json == null) return;
    data = json['data'] != null ? DataUnion.fromJson(type, json['data']) as T? : null;
    pagination = json['pagination'] != null
        ? Pagination.fromJson(json['pagination'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['data'] = this.data?.toJson();
    data['pagination'] = pagination?.toJson();
    return data;
  }
}

class Images {
  ImageUrl? jpg;
  ImageUrl? webp;

  Images({this.jpg, this.webp});

  Images.fromJson(Map<String, dynamic>? json) {
    if (json == null) return;
    jpg = json['jpg'] != null ? ImageUrl.fromJson(json['jpg']) : null;
    webp = json['webp'] != null ? ImageUrl.fromJson(json['webp']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['jpg'] = jpg?.toJson();
    data['webp'] = webp?.toJson();
    return data;
  }
}

class About implements DataUnion {
  String? about;
  About.fromJson(Map<String, dynamic> ?json) {
    if (json == null) return;
    about = json['about'];
  }
  @override
  Map<String, dynamic> toJson() {
    return {'about': about};
  }
}

class AnimeRole {
  String? role;
  JikanV4Node? anime;

  AnimeRole({this.role, this.anime});

  AnimeRole.fromJson(Map<String, dynamic>? json) {
    if (json == null) return;
    role = json['role'];
    anime =
        json['anime'] != null ? JikanV4Node.fromJson(json['anime']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['role'] = role;
    data['anime'] = anime?.toJson();
    return data;
  }
}

class JikanV4Node {
  int? malId;
  String ?url;
  Images? images;
  String ?title;

  JikanV4Node({this.malId, this.url, this.images, this.title});

  JikanV4Node.fromJson(Map<String, dynamic>? json) {
    if (json == null) return;
    malId = json['mal_id'];
    url = json['url'];
    images =
        json['images'] != null ? Images.fromJson(json['images']) : null;
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['mal_id'] = malId;
    data['url'] = url;
    data['images'] = images?.toJson();
    data['title'] = title;
    return data;
  }
}

class Jpg {
  String ?imageUrl;
  String ?smallImageUrl;
  String ?largeImageUrl;

  Jpg({this.imageUrl, this.smallImageUrl, this.largeImageUrl});

  Jpg.fromJson(Map<String, dynamic>? json) {
    if (json == null) return;
    imageUrl = json['image_url'];
    smallImageUrl = json['small_image_url'];
    largeImageUrl = json['large_image_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['image_url'] = imageUrl;
    data['small_image_url'] = smallImageUrl;
    data['large_image_url'] = largeImageUrl;
    return data;
  }
}

class MangaRole {
  String? role;
  JikanV4Node ?manga;

  MangaRole({this.role, this.manga});

  MangaRole.fromJson(Map<String, dynamic> ?json) {
    if (json == null) return;
    role = json['role'];
    manga =
        json['manga'] != null ? JikanV4Node.fromJson(json['manga']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['role'] = role;
    data['manga'] = manga?.toJson();
    return data;
  }
}

class Voices {
  String?language;
  Person? person;

  Voices({this.language, this.person});

  Voices.fromJson(Map<String, dynamic> ?json) {
    if (json == null) return;
    language = json['language'];
    person =
        json['person'] != null ? Person.fromJson(json['person']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['language'] = language;
    data['person'] = person?.toJson();
    return data;
  }
}

class Person {
  int? malId;
  String? url;
  Images? images;
  String? name;

  Person({this.malId, this.url, this.images, this.name});

  Person.fromJson(Map<String, dynamic>? json) {
    if (json == null) return;
    malId = json['mal_id'];
    url = json['url'];
    images =
        json['images'] != null ? Images.fromJson(json['images']) : null;
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

class ImageUrl {
  String? imageUrl;

  ImageUrl({this.imageUrl});

  ImageUrl.fromJson(Map<String, dynamic>? json) {
    if (json == null) return;
    imageUrl = json['image_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['image_url'] = imageUrl;
    return data;
  }
}

class VoicesFull {
  String? role;
  JikanV4Node? anime;
  JikanV4Node? character;

  VoicesFull({this.role, this.anime, this.character});

  VoicesFull.fromJson(Map<String, dynamic> json) {
    role = json['role'];
    anime =
        json['anime'] != null ? JikanV4Node.fromJson(json['anime']) : null;
    character = json['character'] != null
        ? JikanV4Node.fromJson(json['character'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['role'] = role;
    data['anime'] = anime?.toJson();
    data['character'] = character?.toJson();
    return data;
  }
}

class Pagination {
  int? lastVisiblePage;
  bool? hasNextPage;

  Pagination({this.lastVisiblePage, this.hasNextPage});

  Pagination.fromJson(Map<String, dynamic>? json) {
    if (json == null) return;
    lastVisiblePage = json['last_visible_page'];
    hasNextPage = json['has_next_page'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['last_visible_page'] = lastVisiblePage;
    data['has_next_page'] = hasNextPage;
    return data;
  }
}

class RefImage {
  String? medium;
  String? large;

  RefImage({this.medium, this.large});

  RefImage.fromJson(Map<String, dynamic>? json) {
    if (json == null) return;
    medium = json['medium'];
    large = json['large'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['medium'] = medium;
    data['large'] = large;
    return data;
  }
}

class ListData<T extends ToJson> {
  List<T>? data;
  String? lastUpdated;
  bool? fromCache;
  String? url;

  ListData({this.data, this.lastUpdated, this.fromCache, this.url});

  ListData.fromJson(
    Map<String, dynamic>? json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (json == null) return;
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(fromJson(v));
      });
    }
    lastUpdated = json['lastUpdated'];
    fromCache = json['fromCache'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['data'] = this.data?.map((v) => v.toJson()).toList();
    data['lastUpdated'] = lastUpdated;
    data['fromCache'] = fromCache;
    data['url'] = url;
    return data;
  }
}

class UserV4 {
  String? username;
  String? url;
  Images? images;

  UserV4({this.username, this.url, this.images});

  UserV4.fromJson(Map<String, dynamic>? json) {
    if(json == null) return;
    username = json['username'];
    url = json['url'];
    images =
        json['images'] != null ? Images.fromJson(json['images']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['username'] = username;
    data['url'] = url;
    data['images'] = images?.toJson();
    return data;
  }
}
