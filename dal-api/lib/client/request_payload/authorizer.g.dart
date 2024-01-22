// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'authorizer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Authorizer _$AuthorizerFromJson(Map<String, dynamic> json) => Authorizer(
      iam: json['iam'] == null
          ? null
          : Iam.fromJson(json['iam'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AuthorizerToJson(Authorizer instance) =>
    <String, dynamic>{
      'iam': instance.iam,
    };
