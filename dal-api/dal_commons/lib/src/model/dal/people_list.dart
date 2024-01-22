import 'package:dal_commons/src/model/dal/commonV4.dart';

class PeopleListData {
  List<PeopleData>? data;
  String? lastUpdated;
  bool? fromCache;
  String ? url;

  PeopleListData({this.data, this.lastUpdated, this.fromCache, this.url});

  PeopleListData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return;
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(PeopleData.fromJson(v));
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

class PeopleData {
  int? id;
  int? rank;
  String? name;
  String? otherName;
  RefImage? image;
  int? favorites;
  String? birthday;

  PeopleData(
      {this.id,
      this.rank,
      this.name,
      this.otherName,
      this.image,
      this.favorites,
      this.birthday});

  PeopleData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return;
    id = json['id'];
    rank = json['rank'];
    name = json['name'];
    otherName = json['otherName'];
    image = json['image'] != null ? RefImage.fromJson(json['image']) : null;
    favorites = json['favorites'];
    birthday = json['birthday'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['rank'] = rank;
    data['name'] = name;
    data['otherName'] = otherName;
    data['image'] = image?.toJson();
    data['favorites'] = favorites;
    data['birthday'] = birthday;
    return data;
  }
}
