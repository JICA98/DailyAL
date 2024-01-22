import 'package:dal_commons/dal_commons.dart';

class ScheduleData with ToJson {
  int? timestamp;
  int? episode;
  RelatedLinks? relatedLinks;

  ScheduleData({this.timestamp, this.episode, this.relatedLinks});

  ScheduleData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return;
    timestamp = json['timestamp'];
    episode = json['episode'];
    relatedLinks = json['relatedLinks'] != null
        ? RelatedLinks.fromJson(json['relatedLinks'])
        : null;
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['timestamp'] = timestamp;
    data['episode'] = episode;
    if (relatedLinks != null) {
      data['relatedLinks'] = relatedLinks?.toJson();
    }
    return data;
  }
}

class RelatedLinks {
  String? website;
  String? preview;
  String? watch;
  String? twitter;
  String? anilist;
  String? mal;
  String? anidb;
  String? animePlanet;
  String? anisearch;
  String? kitsu;
  String? crunchyroll;
  String? hidive;
  String? netflix;

  RelatedLinks(
      {this.website,
      this.preview,
      this.watch,
      this.twitter,
      this.anilist,
      this.mal,
      this.anidb,
      this.animePlanet,
      this.anisearch,
      this.kitsu,
      this.crunchyroll,
      this.hidive,
      this.netflix});

  RelatedLinks.fromJson(Map<String, dynamic>? json) {
    if (json == null) return;
    website = json['website'];
    preview = json['preview'];
    watch = json['watch'];
    twitter = json['twitter'];
    anilist = json['anilist'];
    mal = json['mal'];
    anidb = json['anidb'];
    animePlanet = json['anime-planet'];
    anisearch = json['anisearch'];
    kitsu = json['kitsu'];
    crunchyroll = json['crunchyroll'];
    hidive = json['hidive'];
    netflix = json['netflix'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['website'] = website;
    data['preview'] = preview;
    data['watch'] = watch;
    data['twitter'] = twitter;
    data['anilist'] = anilist;
    data['mal'] = mal;
    data['anidb'] = anidb;
    data['anime-planet'] = animePlanet;
    data['anisearch'] = anisearch;
    data['kitsu'] = kitsu;
    data['crunchyroll'] = crunchyroll;
    data['hidive'] = hidive;
    data['netflix'] = netflix;
    return data;
  }
}
