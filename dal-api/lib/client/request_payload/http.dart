import 'package:json_annotation/json_annotation.dart';

part 'http.g.dart';

@JsonSerializable()
class Http {
  String? method;
  String? path;
  String? protocol;
  String? sourceIp;
  String? userAgent;

  Http({
    this.method,
    this.path,
    this.protocol,
    this.sourceIp,
    this.userAgent,
  });

  factory Http.fromJson(Map<String, dynamic> json) => _$HttpFromJson(json);
  Map<String, dynamic> toJson() => _$HttpToJson(this);
}
