import 'commonV4.dart';

class FriendV4List implements DataUnion {
  List<FriendV4>? friends;
  FriendV4List.fromList(List<dynamic>? list) {
    friends = list?.map<FriendV4>((e) => FriendV4.fromJson(e)).toList() ?? [];
  }
  FriendV4List.fromJson(Map<String, dynamic>? json) {
    if (json == null) return;
    friends = ((json['friends'] ?? []) as List)
            .map<FriendV4>((e) => FriendV4.fromJson(e))
            .toList() ??
        [];
  }
  @override
  Map<String, dynamic> toJson() {
    return {'friends': friends};
  }
}

class FriendV4 {
  UserV4? user;
  String? lastOnline;
  String? friendsSince;

  FriendV4({this.user, this.lastOnline, this.friendsSince});

  FriendV4.fromJson(Map<String, dynamic> ?json) {
    if (json == null) return;
    user = json['user'] != null ? UserV4.fromJson(json['user']) : null;
    lastOnline = json['last_online'];
    friendsSince = json['friends_since'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user'] = user?.toJson();
    data['last_online'] = lastOnline;
    data['friends_since'] = friendsSince;
    return data;
  }
}
