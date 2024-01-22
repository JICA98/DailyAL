import 'iam.dart';

import 'package:json_annotation/json_annotation.dart';

part 'authorizer.g.dart';

@JsonSerializable()
class Authorizer {
  Iam? iam;

  Authorizer({this.iam});

  factory Authorizer.fromJson(Map<String, dynamic> json) =>
      _$AuthorizerFromJson(json);
  Map<String, dynamic> toJson() => _$AuthorizerToJson(this);
}
