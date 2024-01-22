import 'commonV4.dart';

class Club implements DataUnion {
  int? malId;
  String ?name;
  String? url;
  Images? images;
  int? members;
  String ?category;
  String? created;
  String ?access;

  Club(
      {this.malId,
      this.name,
      this.url,
      this.images,
      this.members,
      this.category,
      this.created,
      this.access});

  Club.fromJson(Map<String, dynamic>? json) {
    if (json == null) return;
    malId = json['mal_id'];
    name = json['name'];
    url = json['url'];
    images =
        json['images'] != null ? Images.fromJson(json['images']) : null;
    members = json['members'];
    category = json['category'];
    created = json['created'];
    access = json['access'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['mal_id'] = malId;
    data['name'] = name;
    data['url'] = url;
    data['images'] = images?.toJson();
    data['members'] = members;
    data['category'] = category;
    data['created'] = created;
    data['access'] = access;
    return data;
  }
}
