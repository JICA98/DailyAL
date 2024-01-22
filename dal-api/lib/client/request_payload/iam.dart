import 'package:json_annotation/json_annotation.dart';

part 'iam.g.dart';

@JsonSerializable()
class Iam {
  String? accessKey;
  String? accountId;
  String? callerId;
  dynamic cognitoIdentity;
  dynamic principalOrgId;
  String? userArn;
  String? userId;

  Iam({
    this.accessKey,
    this.accountId,
    this.callerId,
    this.cognitoIdentity,
    this.principalOrgId,
    this.userArn,
    this.userId,
  });

  factory Iam.fromJson(Map<String, dynamic> json) => _$IamFromJson(json);
  Map<String, dynamic> toJson() => _$IamToJson(this);
}
