// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'club_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClubDetails _$ClubDetailsFromJson(Map<String, dynamic> json) => ClubDetails(
      data: json['data'] == null
          ? null
          : ClubData.fromJson(json['data'] as Map<String, dynamic>),
      lastUpdated: json['lastUpdated'] == null
          ? null
          : DateTime.parse(json['lastUpdated'] as String),
      fromCache: json['fromCache'] as bool?,
      url: json['url'] as String?,
    );

Map<String, dynamic> _$ClubDetailsToJson(ClubDetails instance) =>
    <String, dynamic>{
      'data': instance.data,
      'lastUpdated': instance.lastUpdated?.toIso8601String(),
      'fromCache': instance.fromCache,
      'url': instance.url,
    };

ClubData _$ClubDataFromJson(Map<String, dynamic> json) => ClubData(
      title: json['title'] as String?,
      information: json['information'] as String?,
      members: (json['members'] as List<dynamic>?)
          ?.map((e) => Member.fromJson(e as Map<String, dynamic>))
          .toList(),
      pictures: (json['pictures'] as List<dynamic>?)
          ?.map((e) => Picture.fromJson(e as Map<String, dynamic>?))
          .toList(),
      forumTopics: (json['forumTopics'] as List<dynamic>?)
          ?.map((e) => ForumHtml.fromJson(e as Map<String, dynamic>?))
          .toList(),
      comments: (json['comments'] as List<dynamic>?)
          ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
          .toList(),
      details: json['details'] == null
          ? null
          : ClubExtra.fromJson(json['details'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ClubDataToJson(ClubData instance) => <String, dynamic>{
      'title': instance.title,
      'information': instance.information,
      'members': instance.members,
      'pictures': instance.pictures,
      'forumTopics': instance.forumTopics,
      'comments': instance.comments,
      'details': instance.details,
    };

Comment _$CommentFromJson(Map<String, dynamic> json) => Comment(
      id: json['id'] as int?,
      by: json['by'] == null
          ? null
          : Member.fromJson(json['by'] as Map<String, dynamic>),
      longAgo: json['longAgo'] as String?,
      content: json['content'] as String?,
    );

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
      'id': instance.id,
      'by': instance.by,
      'longAgo': instance.longAgo,
      'content': instance.content,
    };

Member _$MemberFromJson(Map<String, dynamic> json) => Member(
      username: json['username'] as String?,
      mainPicture: json['mainPicture'] == null
          ? null
          : Picture.fromJson(json['mainPicture'] as Map<String, dynamic>?),
    );

Map<String, dynamic> _$MemberToJson(Member instance) => <String, dynamic>{
      'username': instance.username,
      'mainPicture': instance.mainPicture,
    };

ClubExtra _$ClubExtraFromJson(Map<String, dynamic> json) => ClubExtra(
      picture: json['picture'] == null
          ? null
          : Picture.fromJson(json['picture'] as Map<String, dynamic>?),
      members: json['members'] as int?,
      category: json['category'] as String?,
      pictures: json['pictures'] as int?,
      created: json['created'] as String?,
      staffs: (json['staffs'] as List<dynamic>?)
          ?.map((e) => ClubStaff.fromJson(e as Map<String, dynamic>))
          .toList(),
      clubRelations: json['clubRelations'] == null
          ? null
          : ClubRelations.fromJson(
              json['clubRelations'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ClubExtraToJson(ClubExtra instance) => <String, dynamic>{
      'picture': instance.picture,
      'members': instance.members,
      'category': instance.category,
      'pictures': instance.pictures,
      'created': instance.created,
      'staffs': instance.staffs,
      'clubRelations': instance.clubRelations,
    };

ClubRelations _$ClubRelationsFromJson(Map<String, dynamic> json) =>
    ClubRelations(
      anime: (json['anime'] as List<dynamic>?)
          ?.map((e) => ClubRelation.fromJson(e as Map<String, dynamic>))
          .toList(),
      manga: (json['manga'] as List<dynamic>?)
          ?.map((e) => ClubRelation.fromJson(e as Map<String, dynamic>))
          .toList(),
      character: (json['character'] as List<dynamic>?)
          ?.map((e) => ClubRelation.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ClubRelationsToJson(ClubRelations instance) =>
    <String, dynamic>{
      'anime': instance.anime,
      'manga': instance.manga,
      'character': instance.character,
    };

ClubRelation _$ClubRelationFromJson(Map<String, dynamic> json) => ClubRelation(
      id: json['id'] as int?,
      title: json['title'] as String?,
    );

Map<String, dynamic> _$ClubRelationToJson(ClubRelation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
    };

ClubStaff _$ClubStaffFromJson(Map<String, dynamic> json) => ClubStaff(
      user: json['user'] == null
          ? null
          : Member.fromJson(json['user'] as Map<String, dynamic>),
      position: json['position'] as String?,
    );

Map<String, dynamic> _$ClubStaffToJson(ClubStaff instance) => <String, dynamic>{
      'user': instance.user,
      'position': instance.position,
    };
