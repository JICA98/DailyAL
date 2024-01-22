import 'package:dal_commons/src/model/dal/commonV4.dart';

class ClubV4List implements DataUnion {
  List<ClubV4>? data;

  ClubV4List({this.data});

  ClubV4List.fromList(List<dynamic>? list) {
    data = [];
    if (list == null) return;
    for (var v in list) {
      data?.add(ClubV4.fromJson(v));
    }
  }

  ClubV4List.fromJson(Map<String, dynamic>? json) {
    if (json == null) return;
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(ClubV4.fromJson(v));
      });
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['data'] = this.data?.map((v) => v.toJson()).toList();
    return data;
  }
}

class ClubV4 {
  int? malId;
  String? name;
  String? url;

  ClubV4({this.malId, this.name, this.url});

  ClubV4.fromJson(Map<String, dynamic>? json) {
    if (json == null) return;
    malId = json['mal_id'];
    name = json['name'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['mal_id'] = malId;
    data['name'] = name;
    data['url'] = url;
    return data;
  }
}
