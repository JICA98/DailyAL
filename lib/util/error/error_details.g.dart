// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'error_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ErrorDetails _$ErrorDetailsFromJson(Map<String, dynamic> json) => ErrorDetails(
      json['stacktrace'] as String,
      json['exception'] as String,
      json['library'] as String?,
      json['silent'] as String?,
      json['summary'] as String?,
      json['date'] as String?,
      json['currentUser'] as String?,
      json['appVersion'] as String?,
    );

Map<String, dynamic> _$ErrorDetailsToJson(ErrorDetails instance) =>
    <String, dynamic>{
      'stacktrace': instance.stacktrace,
      'exception': instance.exception,
      'library': instance.library,
      'silent': instance.silent,
      'summary': instance.summary,
      'date': instance.date,
      'currentUser': instance.currentUser,
      'appVersion': instance.appVersion,
    };
