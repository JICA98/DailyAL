import 'package:dal_commons/src/model/dal/commonV4.dart';

class CharacterListData {
  List<CharData>? data;
  String? lastUpdated;
  bool? fromCache;
  String? url;

  CharacterListData({this.data, this.lastUpdated, this.fromCache, this.url});

  CharacterListData.fromJson(Map<String, dynamic> json) {
    if (json == null) return;
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(CharData.fromJson(v));
      });
    }
    lastUpdated = json['lastUpdated'];
    fromCache = json['fromCache'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data?.map((v) => v.toJson()).toList();
    }
    data['lastUpdated'] = lastUpdated;
    data['fromCache'] = fromCache;
    data['url'] = url;
    return data;
  }
}

class CharData {
  int? id;
  int? rank;
  String? name;
  String? otherName;
  RefImage? image;
  int? favorites;
  List<RefNode>? animeRef;
  List<RefNode>? mangaRef;

  CharData(
      {this.id,
      this.rank,
      this.name,
      this.otherName,
      this.image,
      this.favorites,
      this.animeRef,
      this.mangaRef});

  CharData.fromJson(Map<String, dynamic> json) {
    if (json == null) return;
    id = json['id'];
    rank = json['rank'];
    name = json['name'];
    otherName = json['otherName'];
    image = json['image'] != null ? RefImage.fromJson(json['image']) : null;
    favorites = json['favorites'];
    if (json['animeRef'] != null) {
      animeRef = [];
      json['animeRef'].forEach((v) {
        animeRef?.add(RefNode.fromJson(v));
      });
    }
    if (json['mangaRef'] != null) {
      mangaRef = [];
      json['mangaRef'].forEach((v) {
        mangaRef?.add(RefNode.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['rank'] = rank;
    data['name'] = name;
    data['otherName'] = otherName;
    if (image != null) {
      data['image'] = image?.toJson();
    }
    data['favorites'] = favorites;
    if (animeRef != null) {
      data['animeRef'] = animeRef?.map((v) => v.toJson()).toList();
    }
    if (mangaRef != null) {
      data['mangaRef'] = mangaRef?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class RefNode {
  String? title;
  int? id;

  RefNode({this.title, this.id});

  RefNode.fromJson(Map<String, dynamic>? json) {
    if (json == null) return;
    title = json['title'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['id'] = id;
    return data;
  }
}
