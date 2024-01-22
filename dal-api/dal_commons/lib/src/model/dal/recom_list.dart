import 'package:dal_commons/dal_commons.dart';

class RecomListData {
  List<RecomCompare>? data;
  String? lastUpdated;
  bool? fromCache;
  String? url;

  RecomListData({this.data, this.lastUpdated, this.fromCache, this.url});

  RecomListData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return;
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(RecomCompare.fromJson(v));
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

class RecomCompare {
  Node? first;
  Node? second;
  String? username;
  String ?timeAgo;
  int? id;
  String? text;

  RecomCompare(
      {this.first,
      this.second,
      this.username,
      this.timeAgo,
      this.id,
      this.text});

  RecomCompare.fromJson(Map<String, dynamic>? json) {
    if (json == null) return;
    first = json['first'] != null ? Node.fromJson(json['first']) : null;
    second = json['second'] != null ? Node.fromJson(json['second']) : null;
    username = json['username'];
    timeAgo = json['timeAgo'];
    id = json['id'];
    text = json['text'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['first'] = first?.toJson();
    data['second'] = second?.toJson();
    data['username'] = username;
    data['timeAgo'] = timeAgo;
    data['id'] = id;
    data['text'] = text;
    return data;
  }
}
