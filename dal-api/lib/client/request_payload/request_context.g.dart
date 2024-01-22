// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_context.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RequestContext _$RequestContextFromJson(Map<String, dynamic> json) =>
    RequestContext(
      accountId: json['accountId'] as String?,
      apiId: json['apiId'] as String?,
      authentication: json['authentication'],
      authorizer: json['authorizer'] == null
          ? null
          : Authorizer.fromJson(json['authorizer'] as Map<String, dynamic>),
      domainName: json['domainName'] as String?,
      domainPrefix: json['domainPrefix'] as String?,
      http: json['http'] == null
          ? null
          : Http.fromJson(json['http'] as Map<String, dynamic>),
      requestId: json['requestId'] as String?,
      routeKey: json['routeKey'] as String?,
      stage: json['stage'] as String?,
      time: json['time'] as String?,
      timeEpoch: json['timeEpoch'] as int?,
    );

Map<String, dynamic> _$RequestContextToJson(RequestContext instance) =>
    <String, dynamic>{
      'accountId': instance.accountId,
      'apiId': instance.apiId,
      'authentication': instance.authentication,
      'authorizer': instance.authorizer,
      'domainName': instance.domainName,
      'domainPrefix': instance.domainPrefix,
      'http': instance.http,
      'requestId': instance.requestId,
      'routeKey': instance.routeKey,
      'stage': instance.stage,
      'time': instance.time,
      'timeEpoch': instance.timeEpoch,
    };
