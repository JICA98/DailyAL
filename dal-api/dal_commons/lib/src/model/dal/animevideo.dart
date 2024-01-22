import 'commonV4.dart';

class AnimeVideoV4 implements DataUnion {
  List<Promo>? promo;
  List<Episodes>? episodes;
  List<MusicVideos>? musicVideos;

  AnimeVideoV4({this.promo, this.episodes, this.musicVideos});

  AnimeVideoV4.fromJson(Map<String, dynamic> json) {
    if (json == null) return;
    if (json['promo'] != null) {
      promo = [];
      json['promo'].forEach((v) {
        promo!.add(Promo.fromJson(v));
      });
    }
    if (json['episodes'] != null) {
      episodes = [];
      json['episodes'].forEach((v) {
        episodes!.add(Episodes.fromJson(v));
      });
    }
    if (json['music_videos'] != null) {
      musicVideos = [];
      json['music_videos'].forEach((v) {
        musicVideos!.add(MusicVideos.fromJson(v));
      });
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (promo != null) {
      data['promo'] = promo!.map((v) => v.toJson()).toList();
    }
    if (episodes != null) {
      data['episodes'] = episodes!.map((v) => v.toJson()).toList();
    }
    if (musicVideos != null) {
      data['music_videos'] = musicVideos!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Promo {
  String? title;
  Trailer? trailer;

  Promo({this.title, this.trailer});

  Promo.fromJson(Map<String, dynamic> json) {
    if (json == null) return;
    title = json['title'];
    trailer =
        json['trailer'] != null ? Trailer.fromJson(json['trailer']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    if (trailer != null) {
      data['trailer'] = trailer?.toJson();
    }
    return data;
  }
}

class Trailer {
  String? youtubeId;
  String? url;
  String? embedUrl;
  Jpg? images;

  Trailer({this.youtubeId, this.url, this.embedUrl, this.images});

  Trailer.fromJson(Map<String, dynamic>? json) {
    if (json == null) return;
    youtubeId = json['youtube_id'];
    url = json['url'];
    embedUrl = json['embed_url'];
    images = json['images'] != null ? Jpg.fromJson(json['images']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['youtube_id'] = youtubeId;
    data['url'] = url;
    data['embed_url'] = embedUrl;
    if (images != null) {
      data['images'] = images?.toJson();
    }
    return data;
  }
}

class Episodes {
  int? malId;
  String? url;
  String? title;
  String? episode;
  Images? images;

  Episodes({this.malId, this.url, this.title, this.episode, this.images});

  Episodes.fromJson(Map<String, dynamic>? json) {
    if (json == null) return;
    malId = json['mal_id'];
    url = json['url'];
    title = json['title'];
    episode = json['episode'];
    images =
        json['images'] != null ? Images.fromJson(json['images']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['mal_id'] = malId;
    data['url'] = url;
    data['title'] = title;
    data['episode'] = episode;
    if (images != null) {
      data['images'] = images?.toJson();
    }
    return data;
  }
}

class MusicVideos {
  String? title;
  Trailer? video;
  Meta? meta;

  MusicVideos({this.title, this.video, this.meta});

  MusicVideos.fromJson(Map<String, dynamic>? json) {
    if (json == null) return;
    title = json['title'];
    video = json['video'] != null ? Trailer.fromJson(json['video']) : null;
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    if (video != null) {
      data['video'] = video?.toJson();
    }
    if (meta != null) {
      data['meta'] = meta?.toJson();
    }
    return data;
  }
}

class Meta {
  String? title;
  String? author;

  Meta({this.title, this.author});

  Meta.fromJson(Map<String, dynamic>? json) {
    if (json == null) return;
    title = json['title'];
    author = json['author'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['author'] = author;
    return data;
  }
}
