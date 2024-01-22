// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'iam.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Iam _$IamFromJson(Map<String, dynamic> json) => Iam(
      accessKey: json['accessKey'] as String?,
      accountId: json['accountId'] as String?,
      callerId: json['callerId'] as String?,
      cognitoIdentity: json['cognitoIdentity'],
      principalOrgId: json['principalOrgId'],
      userArn: json['userArn'] as String?,
      userId: json['userId'] as String?,
    );

Map<String, dynamic> _$IamToJson(Iam instance) => <String, dynamic>{
      'accessKey': instance.accessKey,
      'accountId': instance.accountId,
      'callerId': instance.callerId,
      'cognitoIdentity': instance.cognitoIdentity,
      'principalOrgId': instance.principalOrgId,
      'userArn': instance.userArn,
      'userId': instance.userId,
    };
