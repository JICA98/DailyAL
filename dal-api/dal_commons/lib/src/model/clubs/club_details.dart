// To parse this JSON data, do
//
//     final clubDetails = clubDetailsFromJson(jsonString);

import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

import '../forum/forumtopicsdata.dart';
import '../forum/html/forumhtml.dart';
import '../global/picture.dart';

part 'club_details.g.dart';

ClubDetails clubDetailsFromJson(String str) =>
    ClubDetails.fromJson(json.decode(str));

String clubDetailsToJson(ClubDetails data) => json.encode(data.toJson());

@JsonSerializable()
class ClubDetails {
  @JsonKey(name: "data")
  final ClubData? data;
  @JsonKey(name: "lastUpdated")
  final DateTime? lastUpdated;
  @JsonKey(name: "fromCache")
  final bool? fromCache;
  @JsonKey(name: "url")
  final String? url;

  ClubDetails({
    this.data,
    this.lastUpdated,
    this.fromCache,
    this.url,
  });

  factory ClubDetails.fromJson(Map<String, dynamic> json) =>
      _$ClubDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$ClubDetailsToJson(this);
}

@JsonSerializable()
class ClubData {
  @JsonKey(name: "title")
  final String? title;
  @JsonKey(name: "information")
  final String? information;
  @JsonKey(name: "members")
  final List<Member>? members;
  @JsonKey(name: "pictures")
  final List<Picture>? pictures;
  @JsonKey(name: "forumTopics")
  final List<ForumHtml>? forumTopics;
  @JsonKey(name: "comments")
  final List<Comment>? comments;
  @JsonKey(name: "details")
  final ClubExtra? details;

  ClubData({
    this.title,
    this.information,
    this.members,
    this.pictures,
    this.forumTopics,
    this.comments,
    this.details,
  });

  factory ClubData.fromJson(Map<String, dynamic> json) =>
      _$ClubDataFromJson(json);

  Map<String, dynamic> toJson() => _$ClubDataToJson(this);
}

@JsonSerializable()
class Comment {
  @JsonKey(name: "id")
  final int? id;
  @JsonKey(name: "by")
  final Member? by;
  @JsonKey(name: "longAgo")
  final String? longAgo;
  @JsonKey(name: "content")
  final String? content;

  Comment({
    this.id,
    this.by,
    this.longAgo,
    this.content,
  });

  factory Comment.fromJson(Map<String, dynamic> json) =>
      _$CommentFromJson(json);

  Map<String, dynamic> toJson() => _$CommentToJson(this);
}

@JsonSerializable()
class Member {
  @JsonKey(name: "username")
  final String? username;
  @JsonKey(name: "mainPicture")
  final Picture? mainPicture;

  Member({
    this.username,
    this.mainPicture,
  });

  factory Member.fromJson(Map<String, dynamic> json) => _$MemberFromJson(json);

  Map<String, dynamic> toJson() => _$MemberToJson(this);
}

@JsonSerializable()
class ClubExtra {
  @JsonKey(name: "picture")
  final Picture? picture;
  @JsonKey(name: "members")
  final int? members;
  @JsonKey(name: "category")
  final String? category;
  @JsonKey(name: "pictures")
  final int? pictures;
  @JsonKey(name: "created")
  final String? created;
  @JsonKey(name: "staffs")
  final List<ClubStaff>? staffs;
  @JsonKey(name: "clubRelations")
  final ClubRelations? clubRelations;

  ClubExtra({
    this.picture,
    this.members,
    this.category,
    this.pictures,
    this.created,
    this.staffs,
    this.clubRelations,
  });

  factory ClubExtra.fromJson(Map<String, dynamic> json) =>
      _$ClubExtraFromJson(json);

  Map<String, dynamic> toJson() => _$ClubExtraToJson(this);
}

@JsonSerializable()
class ClubRelations {
    @JsonKey(name: "anime")
    final List<ClubRelation>? anime;
    @JsonKey(name: "manga")
    final List<ClubRelation>? manga;
    @JsonKey(name: "character")
    final List<ClubRelation>? character;

    ClubRelations({
        this.anime,
        this.manga,
        this.character,
    });

    factory ClubRelations.fromJson(Map<String, dynamic> json) => _$ClubRelationsFromJson(json);

    Map<String, dynamic> toJson() => _$ClubRelationsToJson(this);
}

@JsonSerializable()
class ClubRelation {
    @JsonKey(name: "id")
    final int? id;
    @JsonKey(name: "title")
    final String? title;

    ClubRelation({
        this.id,
        this.title,
    });

    factory ClubRelation.fromJson(Map<String, dynamic> json) => _$ClubRelationFromJson(json);

    Map<String, dynamic> toJson() => _$ClubRelationToJson(this);
}

@JsonSerializable()
class ClubStaff {
  @JsonKey(name: "user")
  final Member? user;
  @JsonKey(name: "position")
  final String? position;

  ClubStaff({
    this.user,
    this.position,
  });

  factory ClubStaff.fromJson(Map<String, dynamic> json) =>
      _$ClubStaffFromJson(json);

  Map<String, dynamic> toJson() => _$ClubStaffToJson(this);
}