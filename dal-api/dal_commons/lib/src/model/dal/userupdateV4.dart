import 'commonV4.dart';

class UserUpdateList implements DataUnion {
  List<UserUpdate>? data;

  UserUpdateList({this.data});

  UserUpdateList.fromJson(dynamic json) {
    if (json == null) return;
    var _data = [];
    data = [];
    if (json is List) {
      _data = json;
    } else if (json['data'] != null) {
      _data = json['data'];
    }
    for (var v in _data) {
      data?.add(UserUpdate.fromJson(v));
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['data'] = this.data?.map((v) => v.toJson()).toList();
    return data;
  }
}

class UserUpdate {
  UserV4? user;
  double? score;
  String? status;
  int? episodesSeen;
  int? episodesTotal;
  int? volumesRead;
  int? volumesTotal;
  int? chaptersRead;
  int? chaptersTotal;
  String? date;

  UserUpdate(
      {this.user,
      this.score,
      this.status,
      this.episodesSeen,
      this.episodesTotal,
      this.volumesRead,
      this.volumesTotal,
      this.chaptersRead,
      this.chaptersTotal,
      this.date});

  UserUpdate.fromJson(Map<String, dynamic>? json) {
    if (json == null) return;
    user = json['user'] != null ? UserV4.fromJson(json['user']) : null;
    score = double.tryParse('${json['score']}');
    status = json['status'];
    episodesSeen = json['episodes_seen'];
    episodesTotal = json['episodes_total'];
    volumesRead = json['volumes_read'];
    volumesTotal = json['volumes_total'];
    chaptersRead = json['chapters_read'];
    chaptersTotal = json['chapters_total'];

    date = json['date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user'] = user?.toJson();
    data['score'] = score;
    data['status'] = status;
    data['episodes_seen'] = episodesSeen;
    data['episodes_total'] = episodesTotal;
    data['volumes_read'] = volumesRead;
    data['volumes_total'] = volumesTotal;
    data['chapters_read'] = chaptersRead;
    data['chapters_total'] = chaptersTotal;
    data['date'] = date;
    return data;
  }
}
