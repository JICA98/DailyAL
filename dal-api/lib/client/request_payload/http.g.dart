// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'http.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Http _$HttpFromJson(Map<String, dynamic> json) => Http(
      method: json['method'] as String?,
      path: json['path'] as String?,
      protocol: json['protocol'] as String?,
      sourceIp: json['sourceIp'] as String?,
      userAgent: json['userAgent'] as String?,
    );

Map<String, dynamic> _$HttpToJson(Http instance) => <String, dynamic>{
      'method': instance.method,
      'path': instance.path,
      'protocol': instance.protocol,
      'sourceIp': instance.sourceIp,
      'userAgent': instance.userAgent,
    };
