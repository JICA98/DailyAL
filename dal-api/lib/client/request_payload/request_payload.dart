import 'headers.dart';
import 'query_string_parameters.dart';
import 'request_context.dart';
import 'package:json_annotation/json_annotation.dart';

part 'request_payload.g.dart';

@JsonSerializable()
class RequestPayload {
  String? version;
  String? routeKey;
  String? rawPath;
  String? rawQueryString;
  List<String?>? cookies;
  Headers? headers;
  QueryStringParameters? queryStringParameters;
  RequestContext? requestContext;
  String? body;
  dynamic pathParameters;
  bool? isBase64Encoded;
  dynamic stageVariables;

  RequestPayload({
    this.version,
    this.routeKey,
    this.rawPath,
    this.rawQueryString,
    this.cookies,
    this.headers,
    this.queryStringParameters,
    this.requestContext,
    this.body,
    this.pathParameters,
    this.isBase64Encoded,
    this.stageVariables,
  });

  factory RequestPayload.fromJson(Map<String, dynamic> json) =>
      _$RequestPayloadFromJson(json);
  Map<String, dynamic> toJson() => _$RequestPayloadToJson(this);
}
