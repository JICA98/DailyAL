import 'commonV4.dart';

class UserProfileV4 implements DataUnion {
  int? malId;
  String? username;
  String? url;
  Images ?images;
  String? lastOnline;
  String ?gender;
  String ?birthday;
  String ?location;
  String ?joined;
  Statistics? statistics;
  List<External>? external;

  UserProfileV4(
      {this.malId,
      this.username,
      this.url,
      this.images,
      this.lastOnline,
      this.gender,
      this.birthday,
      this.location,
      this.joined,
      this.statistics,
      this.external});

  UserProfileV4.fromJson(Map<String, dynamic>? json) {
    if (json == null) return;
    malId = json['mal_id'];
    username = json['username'];
    url = json['url'];
    images =
        json['images'] != null ? Images.fromJson(json['images']) : null;
    lastOnline = json['last_online'];
    gender = json['gender'];
    birthday = json['birthday'];
    location = json['location'];
    joined = json['joined'];
    statistics = json['statistics'] != null
        ? Statistics.fromJson(json['statistics'])
        : null;
    if (json['external'] != null) {
      external = [];
      json['external'].forEach((v) {
        external?.add(External.fromJson(v));
      });
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['mal_id'] = malId;
    data['username'] = username;
    data['url'] = url;
    data['images'] = images?.toJson();
    data['last_online'] = lastOnline;
    data['gender'] = gender;
    data['birthday'] = birthday;
    data['location'] = location;
    data['joined'] = joined;
    data['statistics'] = statistics?.toJson();
    data['external'] = external?.map((v) => v.toJson()).toList();
    return data;
  }
}

class Statistics {
  AnimeStats? anime;
  MangaStats? manga;

  Statistics({this.anime, this.manga});

  Statistics.fromJson(Map<String, dynamic>? json) {
    if (json == null) return;
    anime =
        json['anime'] != null ? AnimeStats.fromJson(json['anime']) : null;
    manga =
        json['manga'] != null ? MangaStats.fromJson(json['manga']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['anime'] = anime?.toJson();
    data['manga'] = manga?.toJson();
    return data;
  }
}

class AnimeStats {
  double? daysWatched;
  double? meanScore;
  int? watching;
  int? completed;
  int? onHold;
  int? dropped;
  int? planToWatch;
  int? totalEntries;
  int? rewatched;
  int? episodesWatched;

  AnimeStats(
      {this.daysWatched,
      this.meanScore,
      this.watching,
      this.completed,
      this.onHold,
      this.dropped,
      this.planToWatch,
      this.totalEntries,
      this.rewatched,
      this.episodesWatched});

  AnimeStats.fromJson(Map<String, dynamic> ?json) {
    if (json == null) return;
    daysWatched = double.tryParse('${json['days_watched']}');
    meanScore = double.tryParse('${json['mean_score']}');
    watching = json['watching'];
    completed = json['completed'];
    onHold = json['on_hold'];
    dropped = json['dropped'];
    planToWatch = json['plan_to_watch'];
    totalEntries = json['total_entries'];
    rewatched = json['rewatched'];
    episodesWatched = json['episodes_watched'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['days_watched'] = daysWatched;
    data['mean_score'] = meanScore;
    data['watching'] = watching;
    data['completed'] = completed;
    data['on_hold'] = onHold;
    data['dropped'] = dropped;
    data['plan_to_watch'] = planToWatch;
    data['total_entries'] = totalEntries;
    data['rewatched'] = rewatched;
    data['episodes_watched'] = episodesWatched;
    return data;
  }
}

class MangaStats {
  double? daysRead;
  double? meanScore;
  int? reading;
  int? completed;
  int? onHold;
  int? dropped;
  int? planToRead;
  int? totalEntries;
  int? reread;
  int? chaptersRead;
  int ?volumesRead;

  MangaStats(
      {this.daysRead,
      this.meanScore,
      this.reading,
      this.completed,
      this.onHold,
      this.dropped,
      this.planToRead,
      this.totalEntries,
      this.reread,
      this.chaptersRead,
      this.volumesRead});

  MangaStats.fromJson(Map<String, dynamic> ?json) {
    if (json == null) return;
    daysRead = double.tryParse('${json['days_read']}');
    meanScore = double.tryParse('${json['mean_score']}');
    reading = json['reading'];
    completed = json['completed'];
    onHold = json['on_hold'];
    dropped = json['dropped'];
    planToRead = json['plan_to_read'];
    totalEntries = json['total_entries'];
    reread = json['reread'];
    chaptersRead = json['chapters_read'];
    volumesRead = json['volumes_read'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['days_read'] = daysRead;
    data['mean_score'] = meanScore;
    data['reading'] = reading;
    data['completed'] = completed;
    data['on_hold'] = onHold;
    data['dropped'] = dropped;
    data['plan_to_read'] = planToRead;
    data['total_entries'] = totalEntries;
    data['reread'] = reread;
    data['chapters_read'] = chaptersRead;
    data['volumes_read'] = volumesRead;
    return data;
  }
}

class External {
  String? name;
  String? url;

  External({this.name, this.url});

  External.fromJson(Map<String, dynamic>? json) {
    if (json == null) return;
    name = json['name'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['url'] = url;
    return data;
  }
}
