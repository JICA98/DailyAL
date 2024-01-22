import 'package:json_annotation/json_annotation.dart';

part 'headers.g.dart';

@JsonSerializable()
class Headers {
  String? header1;
  String? header2;

  Headers({this.header1, this.header2});

  factory Headers.fromJson(Map<String, dynamic> json) =>
      _$HeadersFromJson(json);
  Map<String, dynamic> toJson() => _$HeadersToJson(this);
}
