import 'package:json_annotation/json_annotation.dart';

part 'query_string_parameters.g.dart';

@JsonSerializable()
class QueryStringParameters {
  String? parameter1;
  String? parameter2;

  QueryStringParameters({this.parameter1, this.parameter2});
  factory QueryStringParameters.fromJson(Map<String, dynamic> json) =>
      _$QueryStringParametersFromJson(json);
  Map<String, dynamic> toJson() => _$QueryStringParametersToJson(this);
}
