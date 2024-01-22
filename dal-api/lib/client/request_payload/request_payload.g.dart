// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RequestPayload _$RequestPayloadFromJson(Map<String, dynamic> json) =>
    RequestPayload(
      version: json['version'] as String?,
      routeKey: json['routeKey'] as String?,
      rawPath: json['rawPath'] as String?,
      rawQueryString: json['rawQueryString'] as String?,
      cookies: (json['cookies'] as List<dynamic>?)
          ?.map((e) => e as String?)
          .toList(),
      headers: json['headers'] == null
          ? null
          : Headers.fromJson(json['headers'] as Map<String, dynamic>),
      queryStringParameters: json['queryStringParameters'] == null
          ? null
          : QueryStringParameters.fromJson(
              json['queryStringParameters'] as Map<String, dynamic>),
      requestContext: json['requestContext'] == null
          ? null
          : RequestContext.fromJson(
              json['requestContext'] as Map<String, dynamic>),
      body: json['body'] as String?,
      pathParameters: json['pathParameters'],
      isBase64Encoded: json['isBase64Encoded'] as bool?,
      stageVariables: json['stageVariables'],
    );

Map<String, dynamic> _$RequestPayloadToJson(RequestPayload instance) =>
    <String, dynamic>{
      'version': instance.version,
      'routeKey': instance.routeKey,
      'rawPath': instance.rawPath,
      'rawQueryString': instance.rawQueryString,
      'cookies': instance.cookies,
      'headers': instance.headers,
      'queryStringParameters': instance.queryStringParameters,
      'requestContext': instance.requestContext,
      'body': instance.body,
      'pathParameters': instance.pathParameters,
      'isBase64Encoded': instance.isBase64Encoded,
      'stageVariables': instance.stageVariables,
    };
