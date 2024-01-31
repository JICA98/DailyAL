// To parse this JSON data, do
//
//     final jikanAnime = jikanAnimeFromJson(jsonString);

import 'dart:convert';

JikanAnime jikanAnimeFromJson(String str) => JikanAnime.fromJson(json.decode(str));

String jikanAnimeToJson(JikanAnime data) => json.encode(data.toJson());

class JikanAnime {
    final int? malId;
    final String? url;
    final Map<String, JImage>? images;
    final JTrailer? trailer;
    final bool? approved;
    final List<JTitle>? titles;
    final String? title;
    final String? titleEnglish;
    final String? titleJapanese;
    final List<String>? titleSynonyms;
    final String? type;
    final String? source;
    final int? episodes;
    final String? status;
    final bool? airing;
    final JAired? aired;
    final String? duration;
    final String? rating;
    final double? score;
    final int? scoredBy;
    final int? rank;
    final int? popularity;
    final int? members;
    final int? favorites;
    final String? synopsis;
    final String? background;
    final String? season;
    final int? year;
    final JikanBroadcast? broadcast;
    final List<JDemographic>? producers;
    final List<JDemographic>? licensors;
    final List<JDemographic>? studios;
    final List<JDemographic>? genres;
    final List<JDemographic>? explicitGenres;
    final List<JDemographic>? themes;
    final List<JDemographic>? demographics;

    JikanAnime({
        this.malId,
        this.url,
        this.images,
        this.trailer,
        this.approved,
        this.titles,
        this.title,
        this.titleEnglish,
        this.titleJapanese,
        this.titleSynonyms,
        this.type,
        this.source,
        this.episodes,
        this.status,
        this.airing,
        this.aired,
        this.duration,
        this.rating,
        this.score,
        this.scoredBy,
        this.rank,
        this.popularity,
        this.members,
        this.favorites,
        this.synopsis,
        this.background,
        this.season,
        this.year,
        this.broadcast,
        this.producers,
        this.licensors,
        this.studios,
        this.genres,
        this.explicitGenres,
        this.themes,
        this.demographics,
    });

    factory JikanAnime.fromJson(Map<String, dynamic> json) => JikanAnime(
        malId: json["mal_id"],
        url: json["url"],
        images: Map.from(json["images"]!).map((k, v) => MapEntry<String, JImage>(k, JImage.fromJson(v))),
        trailer: json["trailer"] == null ? null : JTrailer.fromJson(json["trailer"]),
        approved: json["approved"],
        titles: json["titles"] == null ? [] : List<JTitle>.from(json["titles"]!.map((x) => JTitle.fromJson(x))),
        title: json["title"],
        titleEnglish: json["title_english"],
        titleJapanese: json["title_japanese"],
        titleSynonyms: json["title_synonyms"] == null ? [] : List<String>.from(json["title_synonyms"]!.map((x) => x)),
        type: json["type"],
        source: json["source"],
        episodes: json["episodes"],
        status: json["status"],
        airing: json["airing"],
        aired: json["aired"] == null ? null : JAired.fromJson(json["aired"]),
        duration: json["duration"],
        rating: json["rating"],
        score: json["score"],
        scoredBy: json["scored_by"],
        rank: json["rank"],
        popularity: json["popularity"],
        members: json["members"],
        favorites: json["favorites"],
        synopsis: json["synopsis"],
        background: json["background"],
        season: json["season"],
        year: json["year"],
        broadcast: json["broadcast"] == null ? null : JikanBroadcast.fromJson(json["broadcast"]),
        producers: json["producers"] == null ? [] : List<JDemographic>.from(json["producers"]!.map((x) => JDemographic.fromJson(x))),
        licensors: json["licensors"] == null ? [] : List<JDemographic>.from(json["licensors"]!.map((x) => JDemographic.fromJson(x))),
        studios: json["studios"] == null ? [] : List<JDemographic>.from(json["studios"]!.map((x) => JDemographic.fromJson(x))),
        genres: json["genres"] == null ? [] : List<JDemographic>.from(json["genres"]!.map((x) => JDemographic.fromJson(x))),
        explicitGenres: json["explicit_genres"] == null ? [] : List<JDemographic>.from(json["explicit_genres"]!.map((x) => JDemographic.fromJson(x))),
        themes: json["themes"] == null ? [] : List<JDemographic>.from(json["themes"]!.map((x) => JDemographic.fromJson(x))),
        demographics: json["demographics"] == null ? [] : List<JDemographic>.from(json["demographics"]!.map((x) => JDemographic.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "mal_id": malId,
        "url": url,
        "images": Map.from(images!).map((k, v) => MapEntry<String, dynamic>(k, v.toJson())),
        "trailer": trailer?.toJson(),
        "approved": approved,
        "titles": titles == null ? [] : List<dynamic>.from(titles!.map((x) => x.toJson())),
        "title": title,
        "title_english": titleEnglish,
        "title_japanese": titleJapanese,
        "title_synonyms": titleSynonyms == null ? [] : List<dynamic>.from(titleSynonyms!.map((x) => x)),
        "type": type,
        "source": source,
        "episodes": episodes,
        "status": status,
        "airing": airing,
        "aired": aired?.toJson(),
        "duration": duration,
        "rating": rating,
        "score": score,
        "scored_by": scoredBy,
        "rank": rank,
        "popularity": popularity,
        "members": members,
        "favorites": favorites,
        "synopsis": synopsis,
        "background": background,
        "season": season,
        "year": year,
        "broadcast": broadcast?.toJson(),
        "producers": producers == null ? [] : List<dynamic>.from(producers!.map((x) => x.toJson())),
        "licensors": licensors == null ? [] : List<dynamic>.from(licensors!.map((x) => x.toJson())),
        "studios": studios == null ? [] : List<dynamic>.from(studios!.map((x) => x.toJson())),
        "genres": genres == null ? [] : List<dynamic>.from(genres!.map((x) => x.toJson())),
        "explicit_genres": explicitGenres == null ? [] : List<dynamic>.from(explicitGenres!.map((x) => x.toJson())),
        "themes": themes == null ? [] : List<dynamic>.from(themes!.map((x) => x.toJson())),
        "demographics": demographics == null ? [] : List<dynamic>.from(demographics!.map((x) => x.toJson())),
    };
}

class JAired {
    final String? from;
    final String? to;
    final Prop? prop;

    JAired({
        this.from,
        this.to,
        this.prop,
    });

    factory JAired.fromJson(Map<String, dynamic> json) => JAired(
        from: json["from"],
        to: json["to"],
        prop: json["prop"] == null ? null : Prop.fromJson(json["prop"]),
    );

    Map<String, dynamic> toJson() => {
        "from": from,
        "to": to,
        "prop": prop?.toJson(),
    };
}

class Prop {
    final From? from;
    final From? to;
    final String? string;

    Prop({
        this.from,
        this.to,
        this.string,
    });

    factory Prop.fromJson(Map<String, dynamic> json) => Prop(
        from: json["from"] == null ? null : From.fromJson(json["from"]),
        to: json["to"] == null ? null : From.fromJson(json["to"]),
        string: json["string"],
    );

    Map<String, dynamic> toJson() => {
        "from": from?.toJson(),
        "to": to?.toJson(),
        "string": string,
    };
}

class From {
    final int? day;
    final int? month;
    final int? year;

    From({
        this.day,
        this.month,
        this.year,
    });

    factory From.fromJson(Map<String, dynamic> json) => From(
        day: json["day"],
        month: json["month"],
        year: json["year"],
    );

    Map<String, dynamic> toJson() => {
        "day": day,
        "month": month,
        "year": year,
    };
}

class JikanBroadcast {
    final String? day;
    final String? time;
    final String? timezone;
    final String? string;

    JikanBroadcast({
        this.day,
        this.time,
        this.timezone,
        this.string,
    });

    factory JikanBroadcast.fromJson(Map<String, dynamic> json) => JikanBroadcast(
        day: json["day"],
        time: json["time"],
        timezone: json["timezone"],
        string: json["string"],
    );

    Map<String, dynamic> toJson() => {
        "day": day,
        "time": time,
        "timezone": timezone,
        "string": string,
    };
}

class JDemographic {
    final int? malId;
    final String? type;
    final String? name;
    final String? url;

    JDemographic({
        this.malId,
        this.type,
        this.name,
        this.url,
    });

    factory JDemographic.fromJson(Map<String, dynamic> json) => JDemographic(
        malId: json["mal_id"],
        type: json["type"],
        name: json["name"],
        url: json["url"],
    );

    Map<String, dynamic> toJson() => {
        "mal_id": malId,
        "type": type,
        "name": name,
        "url": url,
    };
}

class JImage {
    final String? imageUrl;
    final String? smallJImageUrl;
    final String? largeJImageUrl;

    JImage({
        this.imageUrl,
        this.smallJImageUrl,
        this.largeJImageUrl,
    });

    factory JImage.fromJson(Map<String, dynamic> json) => JImage(
        imageUrl: json["image_url"],
        smallJImageUrl: json["small_image_url"],
        largeJImageUrl: json["large_image_url"],
    );

    Map<String, dynamic> toJson() => {
        "image_url": imageUrl,
        "small_image_url": smallJImageUrl,
        "large_image_url": largeJImageUrl,
    };
}

class JTitle {
    final String? type;
    final String? title;

    JTitle({
        this.type,
        this.title,
    });

    factory JTitle.fromJson(Map<String, dynamic> json) => JTitle(
        type: json["type"],
        title: json["title"],
    );

    Map<String, dynamic> toJson() => {
        "type": type,
        "title": title,
    };
}

class JTrailer {
    final String? youtubeId;
    final String? url;
    final String? embedUrl;

    JTrailer({
        this.youtubeId,
        this.url,
        this.embedUrl,
    });

    factory JTrailer.fromJson(Map<String, dynamic> json) => JTrailer(
        youtubeId: json["youtube_id"],
        url: json["url"],
        embedUrl: json["embed_url"],
    );

    Map<String, dynamic> toJson() => {
        "youtube_id": youtubeId,
        "url": url,
        "embed_url": embedUrl,
    };
}
