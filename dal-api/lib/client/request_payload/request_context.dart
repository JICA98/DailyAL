import 'authorizer.dart';
import 'http.dart';
import 'package:json_annotation/json_annotation.dart';

part 'request_context.g.dart';

@JsonSerializable()
class RequestContext {
  String? accountId;
  String? apiId;
  dynamic authentication;
  Authorizer? authorizer;
  String? domainName;
  String? domainPrefix;
  Http? http;
  String? requestId;
  String? routeKey;
  String? stage;
  String? time;
  int? timeEpoch;

  RequestContext({
    this.accountId,
    this.apiId,
    this.authentication,
    this.authorizer,
    this.domainName,
    this.domainPrefix,
    this.http,
    this.requestId,
    this.routeKey,
    this.stage,
    this.time,
    this.timeEpoch,
  });

  factory RequestContext.fromJson(Map<String, dynamic> json) =>
      _$RequestContextFromJson(json);
  Map<String, dynamic> toJson() => _$RequestContextToJson(this);
}
