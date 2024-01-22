import 'package:dal_commons/src/model/global/animenode.dart';
import 'package:dal_commons/src/model/global/node.dart' as dal;
import 'package:dal_commons/src/model/global/searchresult.dart';

class ClubHtml extends dal.Node {
  final String? noOfMembers;
  final String? imgUrl;
  final int? clubId;
  final String? clubName;
  final String? createdBy;
  final String? createdTime;
  final String? lastPostBy;
  final String? lastPostTime;
  final String? desc;

  ClubHtml(
      {this.imgUrl,
      this.clubId,
      this.createdBy,
      this.clubName,
      this.createdTime,
      this.lastPostBy,
      this.desc,
      this.lastPostTime,
      this.noOfMembers});

  factory ClubHtml.fromJson(Map<String, dynamic>? json) {
    return json != null
        ? (ClubHtml(
            desc: json["desc"],
            imgUrl: json["title"],
            clubName: json["club_name"],
            createdBy: json["created_by"],
            createdTime: json["created_time"],
            lastPostBy: json["last_post_by"],
            lastPostTime: json["last_post_time"],
            noOfMembers: json["replies"],
            clubId: json["topic_id"]))
        : ClubHtml();
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "desc": desc,
      "replies": noOfMembers,
      "title": imgUrl,
      "club_name": clubName,
      "created_by": createdBy,
      "created_time": createdTime,
      "last_post_by": lastPostBy,
      "last_post_time": lastPostTime,
      "topic_id": clubId
    };
  }
}

class ClubBaseNode extends BaseNode {
  ClubBaseNode({ClubHtml? content}) : super(content: content);
}

class ClubListHtml extends SearchResult {
  final List<ClubHtml>? clubs;

  ClubListHtml(
      {this.clubs,
      bool? fromCache,
      String? url,
      DateTime? lastUpdated,
      List<ClubBaseNode>? data})
      : super(
            fromCache: fromCache,
            lastUpdated: lastUpdated,
            url: url,
            data: data);

  factory ClubListHtml.fromJson(Map<String, dynamic> json) {
    return ClubListHtml(
        clubs: List.from(json["clubs"] ?? [])
            .map((e) => ClubHtml.fromJson(e))
            .toList(),
        lastUpdated: DateTime.tryParse(json["lastUpdated"]) ?? DateTime.now(),
        fromCache: true);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "fromCache": fromCache ?? false,
      "lastUpdated": lastUpdated.toString(),
      "clubs": clubs
    };
  }
}
