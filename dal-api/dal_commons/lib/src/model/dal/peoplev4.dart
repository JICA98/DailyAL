import 'commonV4.dart';

class PeopleV4Data implements DataUnion {
  int? malId;
  String? url;
  String ?websiteUrl;
  Images? images;
  String ?name;
  String? givenName;
  String ?familyName;
  List<String>? alternateNames;
  String? birthday;
  int? favorites;
  String? about;
  List<AnimeRole> ?anime;
  List<MangaRole>? manga;
  List<VoicesFull>? voices;

  PeopleV4Data(
      {this.malId,
      this.url,
      this.websiteUrl,
      this.images,
      this.name,
      this.givenName,
      this.familyName,
      this.alternateNames,
      this.birthday,
      this.favorites,
      this.about,
      this.anime,
      this.manga,
      this.voices});

  PeopleV4Data.fromJson(Map<String, dynamic>? json) {
    if (json == null) return;
    malId = json['mal_id'];
    url = json['url'];
    websiteUrl = json['website_url'];
    images =
        json['images'] != null ? Images.fromJson(json['images']) : null;
    name = json['name'];
    givenName = json['given_name'];
    familyName = json['family_name'];
    alternateNames = json['alternate_names'].cast<String>();
    birthday = json['birthday'];
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
        voices?.add(VoicesFull.fromJson(v));
      });
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['mal_id'] = malId;
    data['url'] = url;
    data['website_url'] = websiteUrl;
    data['images'] = images?.toJson();
    data['name'] = name;
    data['given_name'] = givenName;
    data['family_name'] = familyName;
    data['alternate_names'] = alternateNames;
    data['birthday'] = birthday;
    data['favorites'] = favorites;
    data['about'] = about;
    data['anime'] = anime?.map((v) => v.toJson()).toList();
    data['manga'] = manga?.map((v) => v.toJson()).toList();
    data['voices'] = voices?.map((v) => v.toJson()).toList();
    return data;
  }
}
