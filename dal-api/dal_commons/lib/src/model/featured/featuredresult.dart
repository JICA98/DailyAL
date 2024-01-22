import 'dart:convert';

import 'package:dal_commons/src/model/featured/featured.dart';
import 'package:dal_commons/src/model/global/paging.dart';
import 'package:dal_commons/src/model/global/searchresult.dart';

class FeaturedResult extends SearchResult {
  FeaturedResult({List<FeaturedBaseNode>? data, Paging? paging})
      : super(data: data, paging: paging);

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'data': data?.map((x) => x.toJson()).toList(),
      'paging': paging?.toJson(),
    };
  }

  factory FeaturedResult.fromMap(Map<String, dynamic>? map) {
    return map == null
        ? FeaturedResult()
        : FeaturedResult(
            data: List<FeaturedBaseNode>.from(
              (map['data'] as List ?? []).map<FeaturedBaseNode>(
                (x) => FeaturedBaseNode.fromJson(x as Map<String, dynamic>),
              ),
            ),
            paging: Paging.fromJson(map['paging'] as Map<String, dynamic>),
          );
  }

  @override
  Map<String, dynamic> toJson() => toMap();

  factory FeaturedResult.fromJson(String source) =>
      FeaturedResult.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  int get hashCode => data.hashCode ^ paging.hashCode;






}
