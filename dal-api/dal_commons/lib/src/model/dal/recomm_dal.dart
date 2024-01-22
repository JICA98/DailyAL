import 'package:dal_commons/dal_commons.dart';

class RecomBaseList implements DataUnion {
  List<RecomBase>? data;

  RecomBaseList({this.data});

  RecomBaseList.fromList(List<dynamic>? list) {
    data = [];
    if (list == null) return;
    for (var v in list) {
      data?.add(RecomBase.fromJson(v));
    }
  }

  RecomBaseList.fromJson(Map<String, dynamic> json) {
    if (json == null) return;
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(RecomBase.fromJson(v));
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

class RecomBase {
  Node ?relatedNode;
  int? count;
  List<RecomNode>? recommendations;

  RecomBase({this.relatedNode, this.count, this.recommendations});

  RecomBase.fromJson(Map<String, dynamic>? json) {
    if (json == null) return;
    relatedNode =
        json['relatedNode'] != null ? Node.fromJson(json['relatedNode']) : null;
    count = json['count'];
    if (json['recommendations'] != null) {
      recommendations = [];
      json['recommendations'].forEach((v) {
        recommendations?.add(RecomNode.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['relatedNode'] = relatedNode?.toJson();
    data['count'] = count;
    data['recommendations'] = recommendations?.map((v) => v.toJson()).toList();
    return data;
  }
}

class RecomNode {
  String? text;
  int? id;
  String? username;

  RecomNode({this.text, this.id, this.username});

  RecomNode.fromJson(Map<String, dynamic>? json) {
    if (json == null) return;
    text = json['text'];
    id = json['id'];
    username = json['username'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['text'] = text;
    data['id'] = id;
    data['username'] = username;
    return data;
  }
}
